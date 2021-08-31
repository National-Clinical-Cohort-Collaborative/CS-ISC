

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6a705fbf-31d1-41ce-aab5-518d0f829303"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as ast_iuL, visit_start_date as ast_date,
CASE
    WHEN (daily_measurement > 35) THEN 1 ELSE 0
    END AS ast_gt35_admit
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='AST (SGOT), IU/L' AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.c58628a4-1e56-4270-aabf-b0c34e7df4a0"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as crp_mgL, visit_start_date as crp_date,
CASE
    WHEN (daily_measurement > 8) THEN 1 ELSE 0
    END AS crp_gt8_admit
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='c-reactive protein CRP, mg/L' AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.00a1fd26-c11e-4361-a2e2-113b5f046064"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, Alias, daily_measurement as mean_arterial_pressure, visit_start_date as map_date
FROM harmonized_qn_meas_by_day_w_scores
WHERE (Alias='Mean arterial pressure') AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.b22c1282-a679-41f8-8ea0-847f7f257b7e"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as albumin_gdL, visit_start_date as albumin_date,
CASE
    WHEN (daily_measurement < 3.5) THEN 1 ELSE 0
    END AS albumin_lt35_admit
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='Albumin (g/dL)' AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.d41d2928-7338-4a96-806f-11df455befc8"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as alt_iuL, visit_start_date as alt_date,
CASE
    WHEN (daily_measurement > 35) THEN 1 ELSE 0
    END AS alt_gt35_admit
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='ALT (SGPT), IU/L' AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.99816a8d-390a-4789-9953-68945ad2e9fd"),
    MAP=Input(rid="ri.foundry.main.dataset.00a1fd26-c11e-4361-a2e2-113b5f046064"),
    bp_combined=Input(rid="ri.foundry.main.dataset.e86aa09d-59f8-4f85-8273-26fba2059db1")
)
SELECT person_id, mean_arterial_pressure
FROM MAP
UNION
SELECT person_id, mean_arterial_pressure
FROM bp_combined

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.e86aa09d-59f8-4f85-8273-26fba2059db1"),
    dbp=Input(rid="ri.foundry.main.dataset.6a8dd82b-3cd7-4062-a750-986bc3b6cb1b"),
    sbp=Input(rid="ri.foundry.main.dataset.f4719cc4-0cc1-48f9-90c9-1c52ddf58a76")
)
SELECT s.*, d.dbp_admit, 
CASE
    WHEN (sbp_admit IS NOT NULL) THEN (((1/3)*sbp_admit) + ((2/3)*dbp_admit))
    END AS mean_arterial_pressure
FROM sbp s
INNER JOIN dbp d
    on s.person_id=d.person_id
    AND s.sbp_date = d.dbp_date

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.fd4799c4-7963-42d7-9ecc-be8536210de9"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as creatinine_mgdL, visit_start_date as creatinine_date,
CASE
    WHEN (daily_measurement > 1.3) THEN 1 ELSE 0
    END AS creatinine_gt13_admit
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='Creatinine, mg/dL' AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6a8dd82b-3cd7-4062-a750-986bc3b6cb1b"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as dbp_admit, visit_start_date as dbp_date
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='Diastolic blood pressure' AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.0cfc16b4-1910-44ce-8386-73a9546635cc"),
    bp_all=Input(rid="ri.foundry.main.dataset.99816a8d-390a-4789-9953-68945ad2e9fd")
)
SELECT *,
CASE
    WHEN (mean_arterial_pressure < 60) THEN 1 ELSE 0
    END AS mapressure_lt60, 
CASE
    WHEN (mean_arterial_pressure > 100) THEN 1 ELSE 0
    END AS mapressure_gt100
FROM bp_all

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.2fc25bcf-fae4-4049-a1bc-11f1c2f9b8ad"),
    map_sum=Input(rid="ri.vector.main.execute.efe7e2aa-a508-4db4-8729-c2f45dc7833b")
)
SELECT person_id, 
CASE WHEN (map_lt_sum > 0) THEN 1 ELSE 0
    END AS mapressure_lt60, 
CASE WHEN (map_gt_sum > 0) THEN 1 ELSE 0
    END AS mapressure_gt100
FROM map_sum

@transform_pandas(
    Output(rid="ri.vector.main.execute.efe7e2aa-a508-4db4-8729-c2f45dc7833b"),
    map_all=Input(rid="ri.foundry.main.dataset.0cfc16b4-1910-44ce-8386-73a9546635cc")
)
--February 23: some people have both a straight out MAP, as well as a calculated one, which was leading to double rows in the final cohort
---Will allow for extreme values to count, will need to drop the average because averaging the average without denominators of the measurements may be a problem
SELECT person_id, 
    SUM (mapressure_lt60) AS map_lt_sum, 
    SUM (mapressure_gt100) as map_gt_sum
FROM map_all
GROUP BY person_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.dacc170e-9b0f-4f76-b444-01de4fc3b479"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as pulse_admit, visit_start_date as pulse_date,
CASE
    WHEN (daily_measurement > 99) THEN 1 ELSE 0
    END AS pulse_gt99_admit
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='Heart rate' AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.20f454f8-f4e1-4a3b-b879-c83c204d7cdb"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as resp_rate_admit, visit_start_date as resp_rate_date,
CASE
    WHEN (daily_measurement > 22) THEN 1 ELSE 0
    END AS resp_gt22_admit
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='Respiratory rate' AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.f4719cc4-0cc1-48f9-90c9-1c52ddf58a76"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as sbp_admit, visit_start_date as sbp_date
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='Systolic blood pressure' AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.0cba3dba-4304-4976-a518-017a888f3c53"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as o2sat_admit, visit_start_date as o2_date,
CASE
    WHEN (daily_measurement < 93) THEN 1 ELSE 0
    END AS o2_lt93_admit
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='SpO2' AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.0a021c9e-0c87-473a-b39b-e2cb0aea0707"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as temp_in_c, visit_start_date as temp_date,
CASE
    WHEN (daily_measurement > 38) THEN 1 ELSE 0
    END AS fever_day_of_admit
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='Temperature' AND (measurement_day_of_visit=0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.b4a3ef05-c469-4a20-b254-bc8b37102ef5"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as troponin_ngmL, visit_start_date as troponin_date,
CASE
    WHEN (daily_measurement > 0.01) THEN 1 ELSE 0
    END AS troponin_detected_admit
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='Troponin all types, ng/mL' AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.16ee3d44-279a-4c5d-b2f9-c8e3abf28ec6"),
    harmonized_qn_meas_by_day_w_scores=Input(rid="ri.foundry.main.dataset.da48cf15-4cf6-4946-9ffc-cd80223a2be5")
)
SELECT person_id, daily_measurement as wbc_count, visit_start_date as wbc_date,
CASE
    WHEN (daily_measurement > 11) THEN 1 ELSE 0
    END AS wbc_gt11_admit, 
CASE
    WHEN (daily_measurement < 4) THEN 1 ELSE 0
    END AS wbc_lt4_admit
FROM harmonized_qn_meas_by_day_w_scores
WHERE Alias='White blood cell count,  x10E3/uL' AND (measurement_day_of_visit =0) AND visit_concept_name='Inpatient Visit'

