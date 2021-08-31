from pyspark.sql import functions as F

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.185e3386-a7b9-45fd-b2cc-f5339392f6f2"),
    condition_occurrence=Input(rid="ri.foundry.main.dataset.900fa2ad-87ea-4285-be30-c6b5bab60e86"),
    measurement=Input(rid="ri.foundry.main.dataset.d6054221-ee0c-4858-97de-22292458fa19")
)
#Purpose: extract the COVID+ people from N3C
#Creator: Kayte Andersen implementing code from Kate Bradwell sent in Immunosuppressed team training on September 30, 2020
#We are using this definition of COVID+ (there are many, including Jeremy Harper, Immuno data team, among others) because it exactly matches the number of people on the N3C homepage 
def Covid_19_positive_patients(measurement, condition_occurrence):

    df_measurement = measurement

    df_condition_occurrence = condition_occurrence

 

    covid_measurement_concept_ids = [

        '757680', '757679', '757678', '757677', '723459', '715262', '715261', '715260', '706181',

        '706180', '706179', '706178', '706177', '706176', '706175', '706174', '706173', '706172',

        '706171', '706170', '706169', '706168', '706167', '706166', '706165', '706163', '706161',

        '706160', '706159', '706158', '706157', '706156', '706155', '706154', '586526', '586523',

        '586522', '586521', '586520', '586519', '586518', '586517', '586516', '586515'

    ]

 

    covid_measurement_value_as_concept_ids = ['4126681', '45877985', '45884084', '9191']

 

    persons_with_covid_measurement = df_measurement.where(

        (df_measurement.measurement_concept_id.isin(covid_measurement_concept_ids))

        & (df_measurement.value_as_concept_id.isin(covid_measurement_value_as_concept_ids))

    ).selectExpr("person_id", "data_partner_id", "measurement_date as date").distinct().withColumn("covid_diagnosis", F.lit(1))

 

    persons_with_covid_condition_occurrence = df_condition_occurrence.where(

        df_condition_occurrence.condition_concept_id == '37311061'

    ).selectExpr("person_id", "data_partner_id", "condition_start_date as date").distinct().withColumn("covid_diagnosis", F.lit(1))

 

    persons_with_covid = persons_with_covid_measurement.unionByName(

        persons_with_covid_condition_occurrence

    ).distinct().groupBy("person_id", "data_partner_id", "covid_diagnosis").agg(F.min("date").alias("date_of_first_covid_diagnosis"))

 

    return persons_with_covid

