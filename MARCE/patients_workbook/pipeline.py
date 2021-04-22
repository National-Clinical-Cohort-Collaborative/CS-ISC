import pyspark.sql.functions as F
from functools import reduce
from pyspark.sql import DataFrame

@transform_pandas(
    Output(rid="ri.vector.main.execute.06ff9784-4e5d-423e-866d-8efd8849bded"),
    cohort=Input(rid="ri.foundry.main.dataset.cedda6b1-b35c-4347-af4c-2da88649e101"),
    condition_occurrence=Input(rid="ri.foundry.main.dataset.526c0452-7c18-46b6-8a5d-59be0b79a10b"),
    drug_era=Input(rid="ri.foundry.main.dataset.4f424984-51a6-4b10-9b2b-0410afa1b2f8"),
    drug_exposure=Input(rid="ri.foundry.main.dataset.fd499c1d-4b37-4cda-b94f-b7bf70a014da"),
    procedure_occurrence=Input(rid="ri.foundry.main.dataset.f8826e21-741d-49bb-a7eb-47ea98bb2b5f"),
    visit_occurrence=Input(rid="ri.foundry.main.dataset.3f74d43a-d981-4e17-93f0-21c811c57aab")
)
def censor(drug_era, drug_exposure, visit_occurrence, procedure_occurrence, condition_occurrence, cohort):
    cohort = cohort
    patients = cohort.select(F.col("person_id").alias("pid"))

    #visit_occurrence
    visit = patients.join(visit_occurrence, patients.pid==visit_occurrence.person_id) \
        .select("person_id", "visit_start_date", "visit_end_date") \
        .groupBy("person_id") \
        .agg(
            F.min(F.col("visit_start_date")).alias("first_seen_date"), 
            F.max(F.coalesce("visit_end_date","visit_start_date")).alias("censor_date"))

    #procedure_occurrence
    procedure = patients.join(procedure_occurrence, patients.pid==procedure_occurrence.person_id) \
        .select("person_id", "procedure_date", "procedure_date") \
        .groupBy("person_id") \
        .agg(
            F.min("procedure_date").alias("first_seen_date"), 
            F.max("procedure_date").alias("censor_date"))

    #condition_occurrence
    condition = patients.join(condition_occurrence, patients.pid==condition_occurrence.person_id) \
        .select("person_id", "condition_start_date", "condition_end_date") \
        .groupBy("person_id") \
        .agg(
            F.min(F.col("condition_start_date")).alias("first_seen_date"), 
            F.max(F.coalesce("condition_end_date","condition_start_date")).alias("censor_date"))

    #drug_exposure
    drug_exp = patients.join(drug_exposure, patients.pid==drug_exposure.person_id) \
        .select("person_id", "drug_exposure_start_date", "drug_exposure_end_date") \
        .groupBy("person_id") \
        .agg(
            F.min(F.col("drug_exposure_start_date")).alias("first_seen_date"), 
            F.max(F.coalesce("drug_exposure_end_date","drug_exposure_start_date")).alias("censor_date"))

    #drug_era
    drug_e = patients.join(drug_era, patients.pid==drug_era.person_id) \
        .select("person_id", "drug_era_start_date", "drug_era_end_date") \
        .groupBy("person_id") \
        .agg(
            F.min(F.col("drug_era_start_date")).alias("first_seen_date"), 
            F.max(F.coalesce("drug_era_end_date","drug_era_start_date")).alias("censor_date"))

    # Merge DataFrames with reduce and perform final groupBy
    return reduce(DataFrame.unionAll, [visit,procedure,condition,drug_exp,drug_e]) \
        .groupBy("person_id") \
        .agg(
            F.min("first_seen_date").alias("first_seen_date"), 
            F.max("censor_date").alias("censor_date"))
            
    return df

@transform_pandas(
    Output(rid="ri.vector.main.execute.925087a1-73b2-4533-94a3-877f2d71b606"),
    cohort=Input(rid="ri.foundry.main.dataset.cedda6b1-b35c-4347-af4c-2da88649e101"),
    comorbidty_concept=Input(rid="ri.vector.main.execute.2327bbf2-a8ee-4c43-a494-b4a15f4d231e"),
    condition_occurrence=Input(rid="ri.foundry.main.dataset.526c0452-7c18-46b6-8a5d-59be0b79a10b")
)
def comorbidity_unpivoted(comorbidty_concept, condition_occurrence, cohort):
    return condition_occurrence \
        .select("person_id","condition_concept_id","condition_start_date") \
        .join(comorbidty_concept.hint("broadcast"),"condition_concept_id") \
        .join(cohort,"person_id") \
        .filter((F.col("covid_dx_date").isNull()) | (F.col("condition_start_date")<=F.col("covid_dx_date"))) \
        .select("person_id","comorbidity")

@transform_pandas(
    Output(rid="ri.vector.main.execute.6053aff2-6fd1-4ab3-bbd4-55560eb06eda"),
    cohort=Input(rid="ri.foundry.main.dataset.cedda6b1-b35c-4347-af4c-2da88649e101"),
    complete_patient_table_with_derived_scores=Input(rid="ri.foundry.main.dataset.6d919ff2-5b79-4411-8336-485b698b735d"),
    microvisits_to_macrovisits=Input(rid="ri.foundry.main.dataset.89927e78-e712-4dcd-a470-18c1620bd03e")
)
def covid_macrovisits(microvisits_to_macrovisits, complete_patient_table_with_derived_scores, cohort):
    
    visits = complete_patient_table_with_derived_scores.select("person_id","visit_occurrence_id")

    micro_macro = microvisits_to_macrovisits.select("visit_occurrence_id","macrovisit_id","macrovisit_start_date","macrovisit_end_date")

    return cohort \
        .filter(F.col("covid")==1) \
        .select("person_id") \
        .join(visits,"person_id") \
        .join(micro_macro,"visit_occurrence_id")

@transform_pandas(
    Output(rid="ri.vector.main.execute.32cd7cc9-681e-42b1-a724-42eb89627943"),
    cohort=Input(rid="ri.foundry.main.dataset.cedda6b1-b35c-4347-af4c-2da88649e101"),
    death=Input(rid="ri.foundry.main.dataset.9c6c12b0-8e09-4691-91e4-e5ff3f837e69"),
    visit_occurrence=Input(rid="ri.foundry.main.dataset.3f74d43a-d981-4e17-93f0-21c811c57aab")
)
def death_hospice(death, visit_occurrence, cohort):
    pt_death = death.select("person_id","death_date") \
        .join(cohort,"person_id")

    pt_hospice = visit_occurrence \
        .filter(F.col("discharge_to_concept_name").isin([
            'Patient died',
            'Hospice',
            'Expired',
            'Hospice - medical facility',
            'Hospice - home'
        ])) \
        .select("person_id",F.col("visit_end_date").alias("death_date")) \
        .join(cohort, "person_id")

    return pt_death \
        .union(pt_hospice) \
        .groupBy("person_id") \
        .agg(F.max("death_date").alias("death_date"))

