

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.7f73e0c3-d705-40c3-8d6e-787318822e54"),
    covid_nearest_hospitalization=Input(rid="ri.foundry.main.dataset.78dd9b7e-bb70-4a47-b2d4-527282a1e90d")
)
---From Huijun and Hemal
select distinct person_id, date_of_first_covid_diagnosis, covid_admission, covid_discharge
    from covid_nearest_hospitalization inner join (select person_id as ps_id, max(covid_admission) as max_covid_admission from covid_nearest_hospitalization group by ps_id) mn
    on (covid_nearest_hospitalization.covid_admission = mn.max_covid_admission and covid_nearest_hospitalization.person_id = mn.ps_id)
    order by person_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.95de6457-1211-4646-8748-c39da0172a20"),
    microvisit_to_macrovisit_lds=Input(rid="ri.foundry.main.dataset.5af2c604-51e0-4afa-b1ae-1e5fa2f4b905")
)
SELECT *
FROM microvisit_to_macrovisit_lds
where macrovisit_id IS NOT NULL

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.78dd9b7e-bb70-4a47-b2d4-527282a1e90d"),
    hospitalized_covid_patients=Input(rid="ri.foundry.main.dataset.a758d3bd-6df2-45f2-a947-1c8da2376849")
)
--Purpose: to keep the hospitalization nearest to COVID+ date
--Created by Huijun
select distinct person_id, date_of_first_covid_diagnosis, macrovisit_start_date as covid_admission, macrovisit_end_date as covid_discharge
    from hospitalized_covid_patients inner join (select person_id as ps_id, min(diff_covid_hosp) as min_diff from hospitalized_covid_patients group by ps_id) mn
    on (hospitalized_covid_patients.diff_covid_hosp = mn.min_diff and hospitalized_covid_patients.person_id = mn.ps_id)
    order by person_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.a758d3bd-6df2-45f2-a947-1c8da2376849"),
    Covid_19_positive_patients=Input(rid="ri.foundry.main.dataset.185e3386-a7b9-45fd-b2cc-f5339392f6f2"),
    Inpatient=Input(rid="ri.foundry.main.dataset.95de6457-1211-4646-8748-c39da0172a20")
)
--Purpose: to merge the COVID+ table with hospitalized table
--Creator: Kayte and Huijun, January 2021
SELECT distinct c.*, v.macrovisit_start_date, v.macrovisit_end_date, v.visit_concept_name, v.visit_source_value, v.macrovisit_id, abs(DATEDIFF (c.date_of_first_covid_diagnosis, v.macrovisit_start_date)) as diff_covid_hosp
FROM Inpatient v 
--Inner join, because we only want the hospitalized COVID+, not people who are hospitalized without COVID or outpatient COVID
inner join Covid_19_positive_patients c
    on c.person_id = v.person_id 
--Restricting to hospitalizations within 21 from COVID diagnosis up until 5 days after hospitalization (as per Brian Garibaldi)
    and DATEDIFF (c.date_of_first_covid_diagnosis, v.macrovisit_start_date) between -21 and 5

