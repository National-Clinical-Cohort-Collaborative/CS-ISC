

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.cedda6b1-b35c-4347-af4c-2da88649e101"),
    _person=Input(rid="ri.foundry.main.dataset.af5e5e91-6eeb-4b14-86df-18d84a5aa010"),
    asd_cohort=Input(rid="ri.foundry.main.dataset.bd334c63-b548-435c-bbe8-41781e6d2169"),
    covid_patients_with_earliest_diagnosis=Input(rid="ri.foundry.main.dataset.6e10a59e-5d0b-4177-9521-9bee4fd129c0"),
    ms_cohort=Input(rid="ri.foundry.main.dataset.25b27de2-2be6-4d4d-a69e-638918e06a9c"),
    sot_cohort=Input(rid="ri.foundry.main.dataset.0a1855df-ad5b-49c1-96fc-5578897fc9aa")
)
SELECT distinct
    a.person_id,
    case when b.date_of_earliest_covid_diagnosis is null then 0 else 1 end covid,
    case when c.person_id is null then 0 else 1 end sot,
    case when d.person_id is null then 0 else 1 end ms,
    case when e.person_id is null then 0 else 1 end asd,
    b.date_of_earliest_covid_diagnosis covid_dx_date
from _person a
left join covid_patients_with_earliest_diagnosis b on a.person_id = b.person_id
left join sot_cohort c on a.person_id = c.person_id
left join ms_cohort d on a.person_id = d.person_id
left join asd_cohort e on a.person_id = e.person_id
where b.person_id is not null or c.person_id is not null or d.person_id is not null or e.person_id is not null

