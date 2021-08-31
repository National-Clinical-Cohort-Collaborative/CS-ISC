

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.096205f3-15f2-4ba6-8f4e-357dad58839d"),
    vent_condition=Input(rid="ri.foundry.main.dataset.72971e76-2d81-4fff-a050-86eaf0672d70"),
    vent_observation=Input(rid="ri.vector.main.execute.a61a8d34-63fa-4de1-829d-6c3621b40968"),
    vent_procedure=Input(rid="ri.foundry.main.dataset.371c2232-4065-4b9c-aa6d-20f66e487145")
)
---Appending the three tables (stacked on top of each other, they have the exact same format)
SELECT *
FROM vent_procedure
UNION
SELECT *
FROM vent_observation
UNION 
SELECT *
FROM vent_condition

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.613ed30d-6384-4545-a6c9-73f20056fc7a"),
    concept_set_members=Input(rid="ri.foundry.main.dataset.e670c5ad-42ca-46a2-ae55-e917e3e161b6")
)
---From Jacob Wooldridge: cohort paper team used codeset 179437741
SELECT *, 
CASE 
    WHEN concept_name = "Respiratory Ventilation, 24-96 Consecutive Hours" THEN 1
    WHEN concept_name = "Assistance with Respiratory Ventilation, 24-96 Consecutive Hours" THEN 1
    WHEN concept_name = "Extracorporeal or Systemic Assistance and Performance @ Physiological Systems @ Assistance @ Respiratory @ 24-96 Consecutive Hours @ Ventilation" THEN 1
    WHEN concept_name = "Extracorporeal or Systemic Assistance and Performance @ Physiological Systems @ Performance @ Respiratory @ 24-96 Consecutive Hours @ Ventilation" THEN 1
    ELSE 0
END AS vent_24_96hours,
CASE 
    WHEN concept_name = "Respiratory Ventilation, Greater than 96 Consecutive Hours" THEN 1
    WHEN concept_name = "Assistance with Respiratory Ventilation, Greater than 96 Consecutive Hours" THEN 1
    WHEN concept_name = "Extracorporeal or Systemic Assistance and Performance @ Physiological Systems @ Assistance @ Respiratory @ Greater than 96 Consecutive Hours @ Ventilation" THEN 1
    WHEN concept_name = "Extracorporeal or Systemic Assistance and Performance @ Physiological Systems @ Performance @ Respiratory @ Greater than 96 Consecutive Hours @ Ventilation" THEN 1
    ELSE 0
END AS vent_gt_96hours 
FROM concept_set_members
WHERE codeset_id=179437741

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.72971e76-2d81-4fff-a050-86eaf0672d70"),
    condition_occurrence=Input(rid="ri.foundry.main.dataset.900fa2ad-87ea-4285-be30-c6b5bab60e86"),
    vent_concepts=Input(rid="ri.foundry.main.dataset.613ed30d-6384-4545-a6c9-73f20056fc7a")
)
---From the cohort paper mapping: invasive_respiratory_support table shows majority of vents in procedure, some in condition, few in observation tables
SELECT v.concept_name as vent_concept_name, c.person_id, c.condition_start_date as vent_date, c.data_partner_id, v.vent_24_96hours, v.vent_gt_96hours 
FROM vent_concepts v
INNER JOIN condition_occurrence c on v.concept_id=c.condition_concept_id

@transform_pandas(
    Output(rid="ri.vector.main.execute.a61a8d34-63fa-4de1-829d-6c3621b40968"),
    observation=Input(rid="ri.foundry.main.dataset.b998b475-b229-471c-800e-9421491409f3"),
    vent_concepts=Input(rid="ri.foundry.main.dataset.613ed30d-6384-4545-a6c9-73f20056fc7a")
)
---From the cohort paper mapping: invasive_respiratory_support table shows majority of vents in procedure, some in condition, few in observation tables
SELECT v.concept_name as vent_concept_name, o.person_id, o.observation_date as vent_date, o.data_partner_id, v.vent_24_96hours, v.vent_gt_96hours 
FROM vent_concepts v
INNER JOIN observation o on v.concept_id=o.observation_concept_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.371c2232-4065-4b9c-aa6d-20f66e487145"),
    procedure_occurrence=Input(rid="ri.foundry.main.dataset.f6f0b5e0-a105-403a-a98f-0ee1c78137dc"),
    vent_concepts=Input(rid="ri.foundry.main.dataset.613ed30d-6384-4545-a6c9-73f20056fc7a")
)
---From the cohort paper mapping: invasive_respiratory_support table shows majority of vents in procedure, some in condition, few in observation tables
SELECT v.concept_name as vent_concept_name, p.person_id, p.procedure_date as vent_date, p.data_partner_id, v.vent_24_96hours, v.vent_gt_96hours 
FROM vent_concepts v
INNER JOIN procedure_occurrence p on v.concept_id=p.procedure_concept_id

