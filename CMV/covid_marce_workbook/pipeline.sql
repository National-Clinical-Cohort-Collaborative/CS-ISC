

@transform_pandas(
    Output(rid="ri.vector.main.execute.6e6a9823-0a02-46bf-a5a5-c008c9d2bc20"),
    cohort=Input(rid="ri.vector.main.execute.7538aed1-187c-44f7-a4f3-d426e1d8a0a9"),
    concept_set_members=Input(rid="ri.foundry.main.dataset.e670c5ad-42ca-46a2-ae55-e917e3e161b6"),
    condition_occurrence=Input(rid="ri.foundry.main.dataset.526c0452-7c18-46b6-8a5d-59be0b79a10b")
)
SELECT
    c.person_id,
    'AKI' outcome,
    min(b.condition_start_date) outcome_date
FROM concept_set_members a
inner join condition_occurrence b on a.concept_id = b.condition_concept_id
inner join cohort c on b.person_id = c.person_id
where a.is_most_recent_version = true 
    and a.concept_set_name = '[N3C] [ISC] AKI'
    and b.condition_start_date >= c.covid_dx_date
group by c.person_id

@transform_pandas(
    Output(rid="ri.vector.main.execute.7538aed1-187c-44f7-a4f3-d426e1d8a0a9"),
    covid_patients=Input(rid="ri.foundry.main.dataset.d5790855-853f-40fd-95d0-403a923c329d"),
    sot_cohort=Input(rid="ri.foundry.main.dataset.0a1855df-ad5b-49c1-96fc-5578897fc9aa")
)
SELECT
    a.*,
    case when b.person_id is null then 0 else 1 end covid_post_sot,
    case when b.kidney_transplant = 1 then 1 else 0 end kidney_transplant,
    case when b.liver_transplant = 1 then 1 else 0 end liver_transplant,
    case when b.lung_transplant = 1 then 1 else 0 end lung_transplant,
    case when b.kidney_transplant = 0 and b.liver_transplant = 0 and b.lung_transplant = 0 then 1 else 0 end other_transplant,
    b.most_recent_transplant_date sot_date,
    datediff(a.covid_dx_date, b.most_recent_transplant_date) days_sot_to_covid,
    datediff(a.censor_date, a.covid_dx_date) days_covid_to_censor
FROM covid_patients a
left join sot_cohort b 
    on a.person_id = b.person_id and b.most_recent_transplant_date <= a.covid_dx_date

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.51151ac6-7c5b-4943-a3c4-41cc115026ee"),
    covid_marce=Input(rid="ri.foundry.main.dataset.c10c19e8-0fe7-465d-8c7a-5efa0cef1991")
)
SELECT 'ckd' covariate, sum(marce)/count(*) percent_marce FROM covid_marce
where ckd = 1
union 
SELECT 'hypertension', sum(marce)/count(*) FROM covid_marce
where hypertension = 1
union 
SELECT 'diabetes', sum(marce)/count(*) FROM covid_marce
where diabetes = 1
union 
SELECT 'copd_asthma', sum(marce)/count(*) FROM covid_marce
where copd_asthma = 1
union 
SELECT 'cancer', sum(marce)/count(*) FROM covid_marce
where cancer = 1
union 
SELECT 'cad', sum(marce)/count(*) FROM covid_marce
where cad = 1
union 
SELECT 'chf', sum(marce)/count(*) FROM covid_marce
where chf = 1
union 
SELECT 'pvd', sum(marce)/count(*) FROM covid_marce
where pvd = 1
union 
SELECT 'liver', sum(marce)/count(*) FROM covid_marce
where liver = 1
union 
SELECT 'obesity', sum(marce)/count(*) FROM covid_marce
where obesity = 1

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.c10c19e8-0fe7-465d-8c7a-5efa0cef1991"),
    aki_outcomes=Input(rid="ri.vector.main.execute.6e6a9823-0a02-46bf-a5a5-c008c9d2bc20"),
    cohort=Input(rid="ri.vector.main.execute.7538aed1-187c-44f7-a4f3-d426e1d8a0a9"),
    dialysis_outcomes=Input(rid="ri.vector.main.execute.c88ff2e6-f65a-439e-964e-388d25290c25"),
    mace_outcomes=Input(rid="ri.vector.main.execute.0e031364-6a8d-4d57-89c6-3d10b94c3f4f")
)
SELECT
    a.*,
    case when b.person_id is not null then 1 else 0 end marce,
    case when c.person_id is not null then 1 else 0 end mace,
    case when d.person_id is not null then 1 else 0 end aki_dialysis,
    COALESCE(b.dialysis,0) dialysis,
    COALESCE(b.aki,0) aki,
    b.outcome_date marce_date,
    datediff(b.outcome_date, a.covid_dx_date) days_covid_to_marce,
    datediff(a.death_date, a.covid_dx_date) days_covid_to_death,
    datediff(c.outcome_date, a.covid_dx_date) days_covid_to_mace,
    datediff(d.aki_dialysis_date, a.covid_dx_date) days_covid_to_aki_dialysis,  
    case 
        when a.days_sot_to_covid > 730 then '>24m'
        when a.days_sot_to_covid > 180 then '6-24m'
        when a.days_sot_to_covid >= 0 then '<6m'
        else null 
    end sot_to_covid_strata
FROM cohort a
left join (
    select 
        person_id,
        min(outcome_date) outcome_date,
        max(mace) mace,
        max(dialysis) dialysis,
        max(aki) aki
    from  (
        select person_id, 1 mace, 0 dialysis, 0 aki, outcome_date from mace_outcomes
        union
        select person_id, 0 mace, 1 dialysis, 0 aki, outcome_date from dialysis_outcomes
        union
        select person_id, 0 mace, 0 dialysis, 1 aki, outcome_date from aki_outcomes
        union 
        select person_id, 0 mace, 0 dialysis, 0 aki, death_date outcome_date from cohort
        where deceased = 1
    ) x
    group by person_id 
) b on a.person_id = b.person_id
left join mace_outcomes c on a.person_id = c.person_id
left join (
    select 
        person_id,
        min(outcome_date) aki_dialysis_date
    from
    (
        select person_id, outcome_date from dialysis_outcomes
        union
        select person_id, outcome_date from aki_outcomes
    ) x
    group by x.person_id
) d on a.person_id = d.person_id

@transform_pandas(
    Output(rid="ri.vector.main.execute.c88ff2e6-f65a-439e-964e-388d25290c25"),
    cohort=Input(rid="ri.vector.main.execute.7538aed1-187c-44f7-a4f3-d426e1d8a0a9"),
    concept_set_members=Input(rid="ri.foundry.main.dataset.e670c5ad-42ca-46a2-ae55-e917e3e161b6"),
    procedure_occurrence=Input(rid="ri.foundry.main.dataset.f8826e21-741d-49bb-a7eb-47ea98bb2b5f")
)
SELECT
    c.person_id,
    'Dialysis' outcome,
    min(b.procedure_date) outcome_date
FROM concept_set_members a
inner join procedure_occurrence b on a.concept_id = b.procedure_concept_id
inner join cohort c on b.person_id = c.person_id
where 
      a.is_most_recent_version = true 
    and a.concept_set_name = '[AKI] Dialysis'
    and b.procedure_date >= c.covid_dx_date
group by c.person_id

@transform_pandas(
    Output(rid="ri.vector.main.execute.eed89817-a67b-42ba-b2cb-e47c902c0037"),
    cohort=Input(rid="ri.vector.main.execute.7538aed1-187c-44f7-a4f3-d426e1d8a0a9"),
    concept_set_members=Input(rid="ri.foundry.main.dataset.e670c5ad-42ca-46a2-ae55-e917e3e161b6"),
    condition_occurrence=Input(rid="ri.foundry.main.dataset.526c0452-7c18-46b6-8a5d-59be0b79a10b"),
    microvisits_to_macrovisits=Input(rid="ri.foundry.main.dataset.89927e78-e712-4dcd-a470-18c1620bd03e"),
    procedure_occurrence=Input(rid="ri.foundry.main.dataset.f8826e21-741d-49bb-a7eb-47ea98bb2b5f")
)
select
    a.person_id,
    'mace_hospital' outcome,
    min(a.outcome_date) outcome_date
from (
    SELECT
        b.person_id,
        b.visit_occurrence_id,
        b.condition_start_date outcome_date
    FROM concept_set_members a
    inner join condition_occurrence b on a.concept_id = b.condition_concept_id
    inner join cohort c on b.person_id = c.person_id
    where a.is_most_recent_version = true 
        and a.concept_set_name = '[N3C] [ISC] MACE Hospitalization Required'
        and b.condition_start_date >= c.covid_dx_date
        
    union

    SELECT
        b.person_id,
        b.visit_occurrence_id,
        b.procedure_date outcome_date
    FROM concept_set_members a
    inner join procedure_occurrence b on a.concept_id = b.procedure_concept_id
    inner join cohort c on b.person_id = c.person_id
    where a.is_most_recent_version = true 
        and a.concept_set_name = '[N3C] [ISC] MACE Hospitalization Required'
        and b.procedure_date >= c.covid_dx_date
) a
inner join microvisits_to_macrovisits b on a.visit_occurrence_id = b.visit_occurrence_id
where b.macrovisit_id is not null
group by a.person_id

@transform_pandas(
    Output(rid="ri.vector.main.execute.0d4eb453-b26b-4caa-9628-642575da9ad2"),
    cohort=Input(rid="ri.vector.main.execute.7538aed1-187c-44f7-a4f3-d426e1d8a0a9"),
    concept_set_members=Input(rid="ri.foundry.main.dataset.e670c5ad-42ca-46a2-ae55-e917e3e161b6"),
    condition_occurrence=Input(rid="ri.foundry.main.dataset.526c0452-7c18-46b6-8a5d-59be0b79a10b"),
    procedure_occurrence=Input(rid="ri.foundry.main.dataset.f8826e21-741d-49bb-a7eb-47ea98bb2b5f")
)
select 
    person_id,
    'mace_non_hospital' outcome,
    min(outcome_date) outcome_date
from (
    SELECT
        c.person_id,
        min(b.condition_start_date) outcome_date
    FROM concept_set_members a
    inner join condition_occurrence b on a.concept_id = b.condition_concept_id
    inner join cohort c on b.person_id = c.person_id
    where a.is_most_recent_version = true 
        and a.concept_set_name = '[N3C] [ISC] MACE'
        and b.condition_start_date >= c.covid_dx_date
    group by c.person_id

    union

    SELECT
        c.person_id,
        min(b.procedure_date) outcome_date
    FROM concept_set_members a
    inner join procedure_occurrence b on a.concept_id = b.procedure_concept_id
    inner join cohort c on b.person_id = c.person_id
    where a.is_most_recent_version = true 
        and a.concept_set_name = '[N3C] [ISC] MACE'
        and b.procedure_date >= c.covid_dx_date
    group by c.person_id
) x
group by person_id

@transform_pandas(
    Output(rid="ri.vector.main.execute.0e031364-6a8d-4d57-89c6-3d10b94c3f4f"),
    mace_hospital=Input(rid="ri.vector.main.execute.eed89817-a67b-42ba-b2cb-e47c902c0037"),
    mace_non_hospital=Input(rid="ri.vector.main.execute.0d4eb453-b26b-4caa-9628-642575da9ad2")
)
select
    person_id,
    'MACE' outcome,
    min(outcome_date) outcome_date
from (
    SELECT * FROM mace_hospital
    union
    SELECT * FROM mace_non_hospital
) x
group by person_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.0b0b394e-20ab-4d6a-a354-331e92a9d0c2"),
    covid_marce=Input(rid="ri.foundry.main.dataset.c10c19e8-0fe7-465d-8c7a-5efa0cef1991")
)
select 'all' cohort, count(*) pt_count, sum(marce) marce, sum(mace) mace, sum(dialysis) dialysis, sum(aki) aki, sum(deceased) deceased from covid_marce
union
select 'transplant' cohort, count(*) pt_count, sum(marce) marce, sum(mace) mace, sum(dialysis) dialysis, sum(aki) aki, sum(deceased) deceased from covid_marce
where covid_post_sot = 1 
union
select 'non-transplant' cohort, count(*) pt_count, sum(marce) marce, sum(mace) mace, sum(dialysis) dialysis, sum(aki) aki, sum(deceased) deceased from covid_marce
where covid_post_sot = 0

