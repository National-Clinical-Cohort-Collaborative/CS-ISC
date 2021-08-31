

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6b94e03a-e559-4420-a485-1554bb24e824"),
    transplant_sums=Input(rid="ri.foundry.main.dataset.a370e190-afb8-4ab3-bc04-e5a3913d6e34")
)
SELECT *, 
CASE WHEN (transplant_kidney_sum > 0) THEN 1 ELSE 0
    END AS transplant_kidney, 
CASE WHEN (transplant_lung_sum > 0) THEN 1 ELSE 0
    END AS transplant_lung, 
CASE WHEN (transplant_heart_sum > 0) THEN 1 ELSE 0
    END AS transplant_heart, 
CASE WHEN (transplant_liver_sum > 0) THEN 1 ELSE 0
    END AS transplant_liver
FROM transplant_sums

/*March 23: concerns about multiple overlapping transplants (like someone with both a kidney and a heart, or all pancreas recipients also having a kidney transplant)
1. The concept for kidney transplant, from Richard Moffitt, includes Evan French's as well as descendants. Nothing looks amiss
2. Searched a few random individual patients - the individual codes being pulled look appropriate (nothing like "transplant of unspecified organ" that was causing doubles)
3. Also looked into people with kidney transplant - while they should be getting the drug, it's not in the dataset so it's not my code making the error

Solution: drop the pancreas, and do a sensitivity analysis for at least 1 med present at admission*/

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.2a87e103-6556-44c3-8411-99e39592412a"),
    concept_set_members=Input(rid="ri.foundry.main.dataset.e670c5ad-42ca-46a2-ae55-e917e3e161b6")
)
---March 11: Kayte using codesets developed by Richard Moffitt (kidney 913893613) and Evan French (liver 204996696, heart 976928531, lung 402177099, pancreas 335991647)
SELECT concept_id, codeset_id
FROM concept_set_members
WHERE codeset_id in (913893613, 204996696, 976928531, 402177099)

/*March 23: decided to not pursue pancreas transplant because all 85 of these people were also getting coded as having a kidney transplant --> implausible
Also we ran into < 20 in a cell*/

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.f05c3550-86ed-4d34-a22b-b4ee41b54686"),
    condition_occurrence=Input(rid="ri.foundry.main.dataset.900fa2ad-87ea-4285-be30-c6b5bab60e86"),
    sot_indicators=Input(rid="ri.foundry.main.dataset.5b11c623-8cdb-4fb3-ab70-0e6b1d40a43f")
)
SELECT s.*, c.person_id
FROM condition_occurrence c
INNER JOIN sot_indicators s
    on s.concept_id = c.condition_concept_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4e31e151-240e-4fe2-9a24-e45c9529999f"),
    sot_condition=Input(rid="ri.foundry.main.dataset.f05c3550-86ed-4d34-a22b-b4ee41b54686"),
    sot_observation=Input(rid="ri.foundry.main.dataset.43493e91-e8a8-4b61-8a02-dcaceb5d1835"),
    sot_procedure=Input(rid="ri.foundry.main.dataset.3f5dafa3-0456-4310-b2ec-c50ab7f8160d")
)
---Appending the three tables (stacked on top of each other, they have the exact same format)
SELECT *
FROM sot_procedure
UNION
SELECT *
FROM sot_observation
UNION 
SELECT *
FROM sot_condition

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.5b11c623-8cdb-4fb3-ab70-0e6b1d40a43f"),
    sot_codeset=Input(rid="ri.foundry.main.dataset.2a87e103-6556-44c3-8411-99e39592412a")
)
SELECT *,
CASE 
    WHEN codeset_id=913893613 THEN 1 ELSE 0
    END AS transplant_kidney,
CASE
    WHEN codeset_id=204996696 THEN 1 ELSE 0
    END AS transplant_liver, 
CASE
    WHEN codeset_id=976928531 THEN 1 ELSE 0
    END AS transplant_heart, 
CASE
    WHEN codeset_id=402177099 THEN 1 ELSE 0
    END AS transplant_lung
FROM sot_codeset

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.43493e91-e8a8-4b61-8a02-dcaceb5d1835"),
    observation=Input(rid="ri.foundry.main.dataset.b998b475-b229-471c-800e-9421491409f3"),
    sot_indicators=Input(rid="ri.foundry.main.dataset.5b11c623-8cdb-4fb3-ab70-0e6b1d40a43f")
)
SELECT s.*, c.person_id
FROM observation c
INNER JOIN sot_indicators s
    on s.concept_id = c.observation_concept_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.3f5dafa3-0456-4310-b2ec-c50ab7f8160d"),
    procedure_occurrence=Input(rid="ri.foundry.main.dataset.f6f0b5e0-a105-403a-a98f-0ee1c78137dc"),
    sot_indicators=Input(rid="ri.foundry.main.dataset.5b11c623-8cdb-4fb3-ab70-0e6b1d40a43f")
)
SELECT s.*, c.person_id
FROM procedure_occurrence c
INNER JOIN sot_indicators s
    on s.concept_id = c.procedure_concept_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.a370e190-afb8-4ab3-bc04-e5a3913d6e34"),
    sot_duplicates=Input(rid="ri.foundry.main.dataset.4e31e151-240e-4fe2-9a24-e45c9529999f")
)
SELECT person_id,
    sum (transplant_kidney) as transplant_kidney_sum, 
    sum (transplant_lung) as transplant_lung_sum, 
    sum (transplant_heart) as transplant_heart_sum, 
    sum (transplant_liver) as transplant_liver_sum
FROM sot_duplicates
    GROUP BY person_id

