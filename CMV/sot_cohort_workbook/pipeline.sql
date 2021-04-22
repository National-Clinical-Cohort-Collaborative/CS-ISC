

@transform_pandas(
    Output(rid="ri.vector.main.execute.8129520c-eaa6-4ca2-b01a-aab4a244fa2c"),
    sot_concept_occurrence=Input(rid="ri.vector.main.execute.75c33d07-597a-4214-bf88-e19bd1fcf066")
)
SELECT
    concept_set_name,
    COUNT(DISTINCT person_id) patient_count
FROM sot_concept_occurrence
group by concept_set_name
union
select 'Total', COUNT(DISTINCT person_id) patient_count
FROM sot_concept_occurrence

@transform_pandas(
    Output(rid="ri.vector.main.execute.123297bc-db04-4d2c-8ff8-abec93eb5c92"),
    sot_concept_occurrence=Input(rid="ri.vector.main.execute.75c33d07-597a-4214-bf88-e19bd1fcf066")
)
SELECT
    concept_set_name,
    concept_name,
    COUNT(DISTINCT person_id) patient_count
FROM sot_concept_occurrence
group by concept_set_name, concept_name

@transform_pandas(
    Output(rid="ri.vector.main.execute.11571603-227f-400b-a577-02bd683f6f9e"),
    concept_set_members=Input(rid="ri.foundry.main.dataset.e670c5ad-42ca-46a2-ae55-e917e3e161b6"),
    condition_occurrence=Input(rid="ri.foundry.main.dataset.526c0452-7c18-46b6-8a5d-59be0b79a10b")
)
SELECT
    b.person_id,
    case 
        when a.concept_set_name == '[N3C] [ISC] Kidney Transplant' then 'kidney'
        when a.concept_set_name == '[N3C] [ISC] Lung Transplant' then 'lung'
        when a.concept_set_name == '[N3C] [ISC] Liver Transplant' then 'liver'
        when a.concept_set_name == '[N3C] [ISC] Heart Transplant' then 'heart'
    end as transplant_type,
    case when a.concept_set_name == '[N3C] [ISC] Kidney Transplant' then 1 else 0 end kidney,
    case when a.concept_set_name == '[N3C] [ISC] Lung Transplant' then 1 else 0 end lung,
    case when a.concept_set_name == '[N3C] [ISC] Liver Transplant' then 1 else 0 end liver,
    case when a.concept_set_name == '[N3C] [ISC] Heart Transplant' then 1 else 0 end heart,
    case when a.concept_set_name == '[N3C] [ISC] Kidney Transplant' then min(b.condition_start_date) else null end kidney_date,
    case when a.concept_set_name == '[N3C] [ISC] Lung Transplant' then min(b.condition_start_date) else null end lung_date,
    case when a.concept_set_name == '[N3C] [ISC] Liver Transplant' then min(b.condition_start_date) else null end liver_date,
    case when a.concept_set_name == '[N3C] [ISC] Heart Transplant' then min(b.condition_start_date) else null end heart_date,
    min(b.condition_start_date) min_transplant_date
FROM concept_set_members a
inner join condition_occurrence b 
    on a.concept_id = b.condition_concept_id or a.concept_id = b.condition_source_concept_id
where is_most_recent_version == true
    and concept_set_name in ('[N3C] [ISC] Kidney Transplant', '[N3C] [ISC] Lung Transplant','[N3C] [ISC] Liver Transplant','[N3C] [ISC] Heart Transplant')
group by person_id, concept_set_name

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.0a1855df-ad5b-49c1-96fc-5578897fc9aa"),
    sot_concept_occurrence=Input(rid="ri.vector.main.execute.75c33d07-597a-4214-bf88-e19bd1fcf066")
)
select
    x.*,
    case when (kidney_transplant + lung_transplant + liver_transplant + heart_transplant + pancreas_transplant) > 1 then 1 else 0 end multiple_transplant,
    case when (kidney_transplant_rejection + kidney_transplant_failure) > 0 then 1 else 0 end kidney_transplant_rejection_failure,
    case when (lung_transplant_rejection + lung_transplant_failure) > 0 then 1 else 0 end lung_transplant_rejection_failure,
    case when (liver_transplant_rejection + liver_transplant_failure) > 0 then 1 else 0 end liver_transplant_rejection_failure,
    case when (heart_transplant_rejection + heart_transplant_failure) > 0 then 1 else 0 end heart_transplant_rejection_failure,
    case when (pancreas_transplant_rejection + pancreas_transplant_failure) > 0 then 1 else 0 end pancreas_transplant_rejection_failure,
    case when (transplant_rejection + transplant_failure) > 0 then 1 else 0 end transplant_rejection_failure
from (
    SELECT
        person_id,
        case when sum(case when concept_set_name = '[N3C] [ISC] Kidney Transplant' then 1 else 0 end) > 0 then 1 else 0 end kidney_transplant,
        max(case when concept_set_name = '[N3C] [ISC] Kidney Transplant' then concept_start_date else null end) kidney_transplant_date,
        case when sum(case when concept_set_name = '[N3C] [ISC] Kidney Transplant Rejection' then 1 else 0 end) > 0 then 1 else 0 end kidney_transplant_rejection,
        max(case when concept_set_name = '[N3C] [ISC] Kidney Transplant Rejection' then concept_start_date else null end) kidney_transplant_rejection_date,
        case when sum(case when concept_set_name = '[N3C] [ISC] Kidney Transplant Failure' then 1 else 0 end) > 0 then 1 else 0 end kidney_transplant_failure,
        max(case when concept_set_name = '[N3C] [ISC] Kidney Transplant Failure' then concept_start_date else null end) kidney_transplant_failure_date,

        case when sum(case when concept_set_name = '[N3C] [ISC] Lung Transplant' then 1 else 0 end) > 0 then 1 else 0 end lung_transplant,
        max(case when concept_set_name = '[N3C] [ISC] Lung Transplant' then concept_start_date else null end) lung_transplant_date,
        case when sum(case when concept_set_name = '[N3C] [ISC] Lung Transplant Rejection' then 1 else 0 end) > 0 then 1 else 0 end lung_transplant_rejection,
        max(case when concept_set_name = '[N3C] [ISC] Lung Transplant Rejection' then concept_start_date else null end) lung_transplant_rejection_date,
        case when sum(case when concept_set_name = '[N3C] [ISC] Lung Transplant Failure' then 1 else 0 end) > 0 then 1 else 0 end lung_transplant_failure,
        max(case when concept_set_name = '[N3C] [ISC] Lung Transplant Failure' then concept_start_date else null end) lung_transplant_failure_date,

        case when sum(case when concept_set_name = '[N3C] [ISC] Liver Transplant' then 1 else 0 end) > 0 then 1 else 0 end liver_transplant,
        max(case when concept_set_name = '[N3C] [ISC] Liver Transplant' then concept_start_date else null end) liver_transplant_date,
        case when sum(case when concept_set_name = '[N3C] [ISC] Liver Transplant Rejection' then 1 else 0 end) > 0 then 1 else 0 end liver_transplant_rejection,
        max(case when concept_set_name = '[N3C] [ISC] Liver Transplant Rejection' then concept_start_date else null end) liver_transplant_rejection_date,
        case when sum(case when concept_set_name = '[N3C] [ISC] Liver Transplant Failure' then 1 else 0 end) > 0 then 1 else 0 end liver_transplant_failure,
        max(case when concept_set_name = '[N3C] [ISC] Liver Transplant Failure' then concept_start_date else null end) liver_transplant_failure_date,

        case when sum(case when concept_set_name = '[N3C] [ISC] Heart Transplant' then 1 else 0 end) > 0 then 1 else 0 end heart_transplant,
        max(case when concept_set_name = '[N3C] [ISC] Heart Transplant' then concept_start_date else null end) heart_transplant_date,
        case when sum(case when concept_set_name = '[N3C] [ISC] Heart Transplant Rejection' then 1 else 0 end) > 0 then 1 else 0 end heart_transplant_rejection,
        max(case when concept_set_name = '[N3C] [ISC] Heart Transplant Rejection' then concept_start_date else null end) heart_transplant_rejection_date,
        case when sum(case when concept_set_name = '[N3C] [ISC] Heart Transplant Failure' then 1 else 0 end) > 0 then 1 else 0 end heart_transplant_failure,
        max(case when concept_set_name = '[N3C] [ISC] Heart Transplant Failure' then concept_start_date else null end) heart_transplant_failure_date,

        case when sum(case when concept_set_name = '[N3C] [ISC] Pancreas Transplant' then 1 else 0 end) > 0 then 1 else 0 end pancreas_transplant,
        max(case when concept_set_name = '[N3C] [ISC] Pancreas Transplant' then concept_start_date else null end) pancreas_transplant_date,
        case when sum(case when concept_set_name = '[N3C] [ISC] Pancreas Transplant Rejection' then 1 else 0 end) > 0 then 1 else 0 end pancreas_transplant_rejection,
        max(case when concept_set_name = '[N3C] [ISC] Pancreas Transplant Rejection' then concept_start_date else null end) pancreas_transplant_rejection_date,
        case when sum(case when concept_set_name = '[N3C] [ISC] Pancreas Transplant Failure' then 1 else 0 end) > 0 then 1 else 0 end pancreas_transplant_failure,
        max(case when concept_set_name = '[N3C] [ISC] Pancreas Transplant Failure' then concept_start_date else null end) pancreas_transplant_failure_date,

        max(case when concept_set_name like '[N3C] [ISC] % Transplant' then concept_start_date else null end) most_recent_transplant_date,
        max(case when concept_set_name like '[N3C] [ISC] % Transplant Rejection' then concept_start_date else null end) most_recent_transplant_rejection_date,
        max(case when concept_set_name like '[N3C] [ISC] % Transplant Failure' then concept_start_date else null end) most_recent_transplant_failure_date,
        case when sum(case when concept_set_name like '[N3C] [ISC] % Transplant Rejection' then 1 else 0 end) > 0 then 1 else 0 end transplant_rejection,
        case when sum(case when concept_set_name like '[N3C] [ISC] % Transplant Failure' then 1 else 0 end) > 0 then 1 else 0 end transplant_failure
    FROM sot_concept_occurrence
    group by person_id
) x
-- inner join isc_demographics y on x.person_id = y.person_id
where (kidney_transplant + lung_transplant + liver_transplant + heart_transplant + pancreas_transplant) > 0 --and y.age >= 18

@transform_pandas(
    Output(rid="ri.vector.main.execute.399b1d92-9c79-41a8-9229-d27c772020e9"),
    sot_cohort=Input(rid="ri.foundry.main.dataset.0a1855df-ad5b-49c1-96fc-5578897fc9aa")
)
SELECT
    'transplant' category,
    sum(heart_transplant) heart,
    sum(kidney_transplant) kidney,    
    sum(liver_transplant) liver,
    sum(lung_transplant) lung,
    sum(pancreas_transplant) pancreas,
    sum(multiple_transplant) multiple,
    count(*) any_type
FROM sot_cohort
union
SELECT
    'rejection' category,
    sum(heart_transplant_rejection) heart_rejection,
    sum(kidney_transplant_rejection) kidney_rejection,    
    sum(liver_transplant_rejection) liver_rejection,
    sum(lung_transplant_rejection) lung_rejection,
    sum(pancreas_transplant_rejection) pancreas_rejection,
    sum(case when (heart_transplant_rejection + kidney_transplant_rejection + liver_transplant_rejection + lung_transplant_rejection + pancreas_transplant_rejection) > 1 then 1 else 0 end) multiple_rejection,
    count(*) any_type_rejection
FROM sot_cohort
where heart_transplant_rejection = 1 
    or kidney_transplant_rejection = 1 
    or liver_transplant_rejection = 1 
    or lung_transplant_rejection = 1 
    or pancreas_transplant_rejection = 1
union
SELECT
    'failure' category,
    sum(heart_transplant_failure) heart_transplant_failure,
    sum(kidney_transplant_failure) kidney_transplant_failure,    
    sum(liver_transplant_failure) liver_transplant_failure,
    sum(lung_transplant_failure) lung_transplant_failure,
    sum(pancreas_transplant_failure) pancreas_transplant_failure,
    sum(case when (heart_transplant_failure + kidney_transplant_failure + liver_transplant_failure + lung_transplant_failure + pancreas_transplant_failure) > 1 then 1 else 0 end) multiple_failure,
    count(*) any_type_failure
FROM sot_cohort
where heart_transplant_failure = 1 
    or kidney_transplant_failure = 1 
    or liver_transplant_failure = 1 
    or lung_transplant_failure = 1 
    or pancreas_transplant_failure = 1
order by category desc

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.40508cb3-27f8-4f3e-9498-7b01be877f94"),
    sot_concept_occurrence=Input(rid="ri.vector.main.execute.75c33d07-597a-4214-bf88-e19bd1fcf066")
)
SELECT 
    concept_name,
    count(*) cnt
FROM sot_concept_occurrence
group by concept_name

@transform_pandas(
    Output(rid="ri.vector.main.execute.75c33d07-597a-4214-bf88-e19bd1fcf066"),
    condition_occurrence=Input(rid="ri.foundry.main.dataset.526c0452-7c18-46b6-8a5d-59be0b79a10b"),
    procedure_occurrence=Input(rid="ri.foundry.main.dataset.f8826e21-741d-49bb-a7eb-47ea98bb2b5f"),
    sot_transplant_concepts=Input(rid="ri.vector.main.execute.b974abb4-20b0-4ee5-88d4-37bf4625deaa")
)
select
    b.person_id,
    a.concept_set_name,
    min(b.condition_start_date) concept_start_date,
    b.condition_concept_name concept_name,
    'condition' code_type
FROM sot_transplant_concepts a
inner join condition_occurrence b 
    on a.concept_id = b.condition_concept_id or a.concept_id = b.condition_source_concept_id
where b.condition_start_date is not null
group by b.person_id, a.concept_set_name, b.condition_concept_name

union

select
    b.person_id,
    a.concept_set_name,
    max(b.procedure_date) concept_start_date,
    b.procedure_concept_name concept_name,
    'procedure' code_type
FROM sot_transplant_concepts a
inner join procedure_occurrence b 
    on a.concept_id = b.procedure_concept_id or a.concept_id = b.procedure_source_concept_id
where b.procedure_date is not null
group by b.person_id, a.concept_set_name, b.procedure_concept_name

@transform_pandas(
    Output(rid="ri.vector.main.execute.b974abb4-20b0-4ee5-88d4-37bf4625deaa"),
    concept_set_members=Input(rid="ri.foundry.main.dataset.e670c5ad-42ca-46a2-ae55-e917e3e161b6")
)
SELECT *
FROM concept_set_members
where is_most_recent_version = true 
    and concept_set_name in (
    '[N3C] [ISC] Kidney Transplant',
    '[N3C] [ISC] Kidney Transplant Rejection',
    '[N3C] [ISC] Kidney Transplant Failure',
    '[N3C] [ISC] Lung Transplant',
    '[N3C] [ISC] Lung Transplant Rejection',
    '[N3C] [ISC] Lung Transplant Failure',
    '[N3C] [ISC] Liver Transplant',
    '[N3C] [ISC] Liver Transplant Rejection',
    '[N3C] [ISC] Liver Transplant Failure',
    '[N3C] [ISC] Heart Transplant',
    '[N3C] [ISC] Heart Transplant Rejection',
    '[N3C] [ISC] Heart Transplant Failure',
    '[N3C] [ISC] Pancreas Transplant',
    '[N3C] [ISC] Pancreas Transplant Rejection',
    '[N3C] [ISC] Pancreas Transplant Failure'
)

