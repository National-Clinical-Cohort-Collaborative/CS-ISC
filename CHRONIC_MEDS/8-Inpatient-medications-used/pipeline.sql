

@transform_pandas(
    Output(rid="ri.vector.main.execute.2480b87a-aeb8-4f85-a97b-37da03aee449"),
    concept=Input(rid="ri.foundry.main.dataset.5cb3c4a3-327a-47bf-a8bf-daf0cafe6772")
)
---rem, dex and hcq
SELECT *
FROM concept
WHERE
lcase(concept_name) like '%remdesivir%'
or lcase(concept_name) like '%dexamethasone%'
or lcase(concept_name) like '%bamlanivimab%'
or lcase(concept_name) like '%etesevimab%'
or lcase(concept_name) like '%casirivimab%'
or lcase(concept_name) like '%imdevimab%'
or lcase(concept_name) like '%sotrovimab%'
or lcase(concept_name) like '%tocilizumab%'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.8888482b-2c07-45db-a4db-aa93ce794337"),
    dex_during=Input(rid="ri.vector.main.execute.b2da041f-1f91-4324-ac7e-d7067b78a22f")
)
SELECT person_id, immuno_flag,
MAX(drug_dex) as dex
FROM dex_during
GROUP BY person_id, immuno_flag

@transform_pandas(
    Output(rid="ri.vector.main.execute.b2da041f-1f91-4324-ac7e-d7067b78a22f"),
    drugs_of_interest=Input(rid="ri.foundry.main.dataset.578cf1a7-8fe1-4071-b2df-159b53b7efd1")
)
SELECT *
FROM drugs_of_interest
WHERE drug_dex=1 and
    (covid_admission <= drug_exposure_start_date
    AND  drug_exposure_start_date <= covid_discharge)

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.16c9989b-1db2-4f1d-9cf4-a529e9043184"),
    Matching=Input(rid="ri.foundry.main.dataset.c3c4f75a-a567-4d13-92ac-2058c64e9d4f"),
    drug_exposure=Input(rid="ri.foundry.main.dataset.ec252b05-8f82-4f7f-a227-b3bb9bc578ef")
)
SELECT m.immuno_flag, m.covid_admission, m.covid_discharge, d.drug_concept_id, d.drug_exposure_start_date, d.drug_exposure_end_date, d.person_id
FROM Matching m
LEFT JOIN drug_exposure d 
on d.person_id = m.person_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.578cf1a7-8fe1-4071-b2df-159b53b7efd1"),
    concepts=Input(rid="ri.vector.main.execute.2480b87a-aeb8-4f85-a97b-37da03aee449"),
    drugs_in_matches=Input(rid="ri.foundry.main.dataset.16c9989b-1db2-4f1d-9cf4-a529e9043184")
)
---Keeping rem, dex, hcq drug records (at any time)
SELECT d.*, i.concept_name, 
    case 
        when (lcase(concept_name) like '%remdesivir%' or lcase(concept_name) like '%venklury%')          then 1 else 0
    end as drug_rem ,
    case
        when (lcase(concept_name) like '%dexamethasone%')       then 1 else 0
    end as drug_dex , 
    case
        when (lcase(concept_name) like '%bamlanivimab%'
            or lcase(concept_name) like '%etesevimab%'
            or lcase(concept_name) like '%casirivimab%'
            or lcase(concept_name) like '%imdevimab%'
            or lcase(concept_name) like '%sotrovimab%'
            or lcase(concept_name) like '%tocilizumab%')  then 1 else 0
    end as drug_monoclonal
FROM drugs_in_matches d
INNER JOIN concepts i
    on d.drug_concept_id = i.concept_id

@transform_pandas(
    Output(rid="ri.vector.main.execute.8f7acbe0-9fe3-4757-aed4-44cc27798d87"),
    drugs_of_interest=Input(rid="ri.foundry.main.dataset.578cf1a7-8fe1-4071-b2df-159b53b7efd1")
)
SELECT *
FROM drugs_of_interest
WHERE drug_monoclonal=1 and drug_exposure_start_date < covid_admission

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.261b5e9d-2171-4ff3-8561-5c906b262480"),
    mab_pre_admission=Input(rid="ri.vector.main.execute.8f7acbe0-9fe3-4757-aed4-44cc27798d87")
)
SELECT person_id, immuno_flag,
MAX(drug_monoclonal) as mab
FROM mab_pre_admission
GROUP BY person_id, immuno_flag

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.3e622cd2-3aee-45aa-9ef3-4248caf4c9ad"),
    rem_during=Input(rid="ri.vector.main.execute.4f405287-774b-436c-9b21-290ce4338103")
)
SELECT person_id, immuno_flag,
MAX(drug_rem) as rem
FROM rem_during
GROUP BY person_id, immuno_flag

@transform_pandas(
    Output(rid="ri.vector.main.execute.4f405287-774b-436c-9b21-290ce4338103"),
    drugs_of_interest=Input(rid="ri.foundry.main.dataset.578cf1a7-8fe1-4071-b2df-159b53b7efd1")
)
SELECT *
FROM drugs_of_interest
WHERE drug_rem=1 and
    (covid_admission <= drug_exposure_start_date
    AND  drug_exposure_start_date <= covid_discharge)

