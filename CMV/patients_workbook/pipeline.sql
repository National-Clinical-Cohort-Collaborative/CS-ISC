

@transform_pandas(
    Output(rid="ri.vector.main.execute.f429d2e8-ef8f-43fc-aad7-d39ae75f7dbb"),
    cohort=Input(rid="ri.foundry.main.dataset.cedda6b1-b35c-4347-af4c-2da88649e101"),
    comorbidity_unpivoted=Input(rid="ri.vector.main.execute.925087a1-73b2-4533-94a3-877f2d71b606")
)
SELECT
    a.person_id,
    max(case when b.comorbidity = 'ckd' then 1 else 0 end) ckd,
    max(case when b.comorbidity = 'hypertension' then 1 else 0 end) hypertension,
    max(case when b.comorbidity = 'diabetes' then 1 else 0 end) diabetes,
    max(case when b.comorbidity = 'copd' then 1 else 0 end) copd,
    max(case when b.comorbidity = 'copd_asthma' then 1 else 0 end) copd_asthma,
    max(case when b.comorbidity = 'cancer' then 1 else 0 end) cancer,
    max(case when b.comorbidity = 'cad' then 1 else 0 end) cad,
    max(case when b.comorbidity = 'chf' then 1 else 0 end) chf,
    max(case when b.comorbidity = 'pvd' then 1 else 0 end) pvd,
    max(case when b.comorbidity = 'liver' then 1 else 0 end) liver,
    max(case when b.comorbidity = 'rheumatic' then 1 else 0 end) rheumatic,
    max(case when b.person_id is not null then 1 else 0 end) comorbidity_history
FROM cohort a
left join comorbidity_unpivoted b on a.person_id = b.person_id
group by a.person_id

@transform_pandas(
    Output(rid="ri.vector.main.execute.f79b5e2b-6861-4e34-a48e-b86ca4437ba1"),
    patients=Input(rid="ri.foundry.main.dataset.3dc7f9d3-9a7e-48fe-89b2-f4caf338f342")
)
SELECT 
    covid,
    sum(ckd) ckd,
    sum(hypertension) hypertension,
    sum(diabetes) diabetes,
    sum(copd_asthma) copd_asthma,
    sum(cancer) cancer,
    sum(cad) cad,
    sum(chf) chf,
    sum(pvd) pvd,
    sum(liver) liver,
    sum(rheumatic) rheumatic,
    sum(comorbidity_history) comorbidity_history
FROM patients
group by covid

@transform_pandas(
    Output(rid="ri.vector.main.execute.2327bbf2-a8ee-4c43-a494-b4a15f4d231e"),
    concept_set_members=Input(rid="ri.foundry.main.dataset.e670c5ad-42ca-46a2-ae55-e917e3e161b6")
)
SELECT distinct
    case 
        when concept_set_name = 'chronic kidney disease' then 'ckd'
        when concept_set_name = 'Atlas 807 N3C Essential Hypertension' then 'hypertension'
        when concept_set_name = 'Charlson - DM' then 'diabetes'
        when concept_set_name in ('COPD v2 atlas#804 revised','asthma') then 'copd_asthma'
        when concept_set_name = 'Charlson - Cancer' then 'cancer'
        when concept_set_name = 'Coronary Artery DiseaseV2 Atlas 811' then 'cad'
        when concept_set_name = 'Charlson - CHF' then 'chf'
        when concept_set_name = 'Charlson - PVD' then 'pvd'
        when concept_set_name = 'Charlson - Rheumatic' then 'rheumatic'
        when concept_set_name = 'liver disease' then 'liver'
        else 'uncategorized'
    end comorbidity,
    concept_name,
    concept_id condition_concept_id
FROM concept_set_members
where is_most_recent_version = true
    and codeset_id in (
        889975596, --chronic kidney disease
        343580642, --Atlas 807 N3C Essential hypertension
        719585646, --Charlson - DM
        903690033, --COPD v2 atlas#804 revised
        413507552, --asthma
        535274723, --Charlson - Cancer
        630858234, --Coronary Artery DiseaseV2 Atlas 811
        359043664, --Charlson - CHF        
        376881697, --Charlson - PVD
        765004404, --Charlson - Rheumatic
        882514953 --liver disease
    )

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.d5790855-853f-40fd-95d0-403a923c329d"),
    patients=Input(rid="ri.foundry.main.dataset.3dc7f9d3-9a7e-48fe-89b2-f4caf338f342")
)
select
    *
from patients
where covid = 1 and age >= 18

@transform_pandas(
    Output(rid="ri.vector.main.execute.772a34bb-0110-441d-b753-aa9f8f542466"),
    _person=Input(rid="ri.foundry.main.dataset.af5e5e91-6eeb-4b14-86df-18d84a5aa010"),
    cohort=Input(rid="ri.foundry.main.dataset.cedda6b1-b35c-4347-af4c-2da88649e101"),
    complete_patient_table_with_derived_scores=Input(rid="ri.foundry.main.dataset.6d919ff2-5b79-4411-8336-485b698b735d")
)
SELECT
    a.person_id,
    a.data_partner_id,
    COALESCE(b.age_at_visit_start_in_years_int, year(current_date()) - year_of_birth) age,
    case 
        when a.gender_concept_name = 'MALE' then 'Male'
        when a.gender_concept_name = 'FEMALE' then 'Female'
        else 'Unknown'
    end sex,
    case
        when a.race_concept_name = 'Black or African American' then 'Black or African American'
        when a.race_concept_name = 'White' then 'White'
        else 'Unknown/Other'
    end race,
    case 
        when a.ethnicity_concept_name = 'Hispanic or Latino' then 'Hispanic or Latino'
        when a.ethnicity_concept_name = 'Not Hispanic or Latino' then 'Not Hispanic or Latino'
        else 'Unknown/Other'
    end ethnicity,
    case
        when a.ethnicity_concept_name = 'Hispanic or Latino' then 'Hispanic or Latino'
        when a.race_concept_name = 'White' then 'White'
        when a.race_concept_name = 'Black or African American' then 'Black or African American'
        else 'Other/Unknown'
    end race_ethnicity
FROM cohort c
inner join _person a on a.person_id = c.person_id
left join complete_patient_table_with_derived_scores b on a.person_id = b.person_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.3dc7f9d3-9a7e-48fe-89b2-f4caf338f342"),
    censor=Input(rid="ri.vector.main.execute.06ff9784-4e5d-423e-866d-8efd8849bded"),
    cohort=Input(rid="ri.foundry.main.dataset.cedda6b1-b35c-4347-af4c-2da88649e101"),
    comorbidity=Input(rid="ri.vector.main.execute.f429d2e8-ef8f-43fc-aad7-d39ae75f7dbb"),
    complete_patient_table_with_derived_scores=Input(rid="ri.foundry.main.dataset.6d919ff2-5b79-4411-8336-485b698b735d"),
    covid_macrovisits=Input(rid="ri.vector.main.execute.6053aff2-6fd1-4ab3-bbd4-55560eb06eda"),
    death_hospice=Input(rid="ri.vector.main.execute.32cd7cc9-681e-42b1-a724-42eb89627943"),
    demographics=Input(rid="ri.vector.main.execute.772a34bb-0110-441d-b753-aa9f8f542466")
)
SELECT
    a.person_id,
    a.covid,
    a.sot,
    a.ms,
    a.asd,
    a.covid_dx_date,
    COALESCE(a.covid_dx_date, b.censor_date) covid_censor_date,
    b.first_seen_date,
    b.censor_date,
    c.death_date,
    case when c.death_date is not null then 1 else 0 end deceased,
    d.data_partner_id,
    d.age,
    case
        when d.age < 18 then '<18'
        when d.age < 46 then '18-45'
        when d.age < 66 then '45-65'
        when d.age > 65 then '>65'
        else 'Unknown'
    end age_strata,
    d.sex,
    case
        when d.sex = 'Male' and d.age < 18 then 'Male <18'
        when d.sex = 'Male' and d.age < 46 then 'Male 18-45'
        when d.sex = 'Male' and d.age < 66 then 'Male 45-65'
        when d.sex = 'Male' and d.age > 65 then 'Male >65'
        when d.sex = 'Female' and d.age < 18 then 'Female <18'
        when d.sex = 'Female' and d.age < 46 then 'Female 18-45'
        when d.sex = 'Female' and d.age < 66 then 'Female 45-65'
        when d.sex = 'Female' and d.age > 65 then 'Female >65'
        else 'Unknown'
    end age_sex_strata,
    d.race,
    d.ethnicity,
    case
        when d.ethnicity = 'Hispanic or Latino' then 'Hispanic or Latino'
        when d.race = 'White' then 'White'
        when d.race = 'Black or African American' then 'Black or African American'
        else 'Other/Unknown'
    end race_ethnicity,
    e.BMI bmi,
    case
        when e.BMI < 18.5 then '<18.5'
        when e.BMI < 25 then '18.5-24.9'
        when e.BMI < 30 then '25.0-29.9'
        when e.BMI >= 30 then '>30.0'
        else null
    end bmi_strata,    
    case 
        when e.BMI >= 30 then 1
        when e.BMI < 30 then 0
        else null
    end obesity,
    f.ckd,
    f.hypertension,
    f.diabetes,
    f.copd_asthma,
    f.cancer,
    f.cad,
    f.chf,
    f.pvd,
    f.liver,
    f.rheumatic,
    e.Q_Score q_score,
    f.comorbidity_history,

    e.Severity_Type covid_severity,
    e.Invasive_Ventilation covid_invasive_vent,
    e.InpatientOrED covid_hospitalization,
    e.length_of_stay covid_length_of_stay,
    e.ECMO covid_ecmo,
    case when a.covid=1 then e.visit_occurrence_id else null end covid_visit_occurrence_id,
    g.macrovisit_id covid_macrovisit_id,
    g.macrovisit_start_date covid_macrovisit_start_date,
    g.macrovisit_end_date covid_macrovisit_end_date
FROM cohort a
left join censor b on a.person_id = b.person_id
left join death_hospice c on a.person_id = c.person_id
left join demographics d on a.person_id = d.person_id
left join complete_patient_table_with_derived_scores e on a.person_id = e.person_id
left join comorbidity f on a.person_id = f.person_id
left join covid_macrovisits g on a.person_id = g.person_id

