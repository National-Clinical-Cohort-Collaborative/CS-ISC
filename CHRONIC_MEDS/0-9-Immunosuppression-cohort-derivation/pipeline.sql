

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.733f61f4-a21d-4d9f-b3f4-5d97dd74506e"),
    ALT=Input(rid="ri.foundry.main.dataset.d41d2928-7338-4a96-806f-11df455befc8"),
    AST=Input(rid="ri.foundry.main.dataset.6a705fbf-31d1-41ce-aab5-518d0f829303"),
    Albumin=Input(rid="ri.foundry.main.dataset.b22c1282-a679-41f8-8ea0-847f7f257b7e"),
    CRP=Input(rid="ri.foundry.main.dataset.c58628a4-1e56-4270-aabf-b0c34e7df4a0"),
    Creatinine=Input(rid="ri.foundry.main.dataset.fd4799c4-7963-42d7-9ecc-be8536210de9"),
    MAP_for_merge=Input(rid="ri.foundry.main.dataset.2fc25bcf-fae4-4049-a1bc-11f1c2f9b8ad"),
    Pulse=Input(rid="ri.foundry.main.dataset.dacc170e-9b0f-4f76-b444-01de4fc3b479"),
    Resp_rate=Input(rid="ri.foundry.main.dataset.20f454f8-f4e1-4a3b-b879-c83c204d7cdb"),
    SpO2=Input(rid="ri.foundry.main.dataset.0cba3dba-4304-4976-a518-017a888f3c53"),
    Temperature=Input(rid="ri.foundry.main.dataset.0a021c9e-0c87-473a-b39b-e2cb0aea0707"),
    Troponin=Input(rid="ri.foundry.main.dataset.b4a3ef05-c469-4a20-b254-bc8b37102ef5"),
    WBC=Input(rid="ri.foundry.main.dataset.16ee3d44-279a-4c5d-b2f9-c8e3abf28ec6"),
    cohort_1=Input(rid="ri.foundry.main.dataset.db08b2a2-d0f7-4223-b158-36610cb8ee97"),
    location_2=Input(rid="ri.foundry.main.dataset.4c349534-135a-478d-a44a-0cddaf308a49")
)
---February 17: Caleb suggested to drop bilirubin, least important and we need to reduce missingness
---Need to keep each lab as a separate file, to allow for the different dates to be treated differently (like keeping CRP but having the albumin be out of time window, etc)
SELECT a.*, b.albumin_gdL, b.albumin_lt35_admit, c.crp_mgL, c.crp_gt8_admit, 
    e.temp_in_c, e.fever_day_of_admit, f.creatinine_mgdL, f.creatinine_gt13_admit, g.alt_iuL, g.alt_gt35_admit, x.ast_iuL, x.ast_gt35_admit,
    h.o2sat_admit, h.o2_lt93_admit, p.pulse_admit, p.pulse_gt99_admit,
    r.resp_rate_admit, r.resp_gt22_admit, 
    m.mapressure_lt60, m.mapressure_gt100,
    t.troponin_ngmL, t.troponin_detected_admit, w.wbc_count, w.wbc_gt11_admit, w.wbc_lt4_admit, 
    ---Adding in zip code here (had to have the location added to prior step before merging on it)
    z.zip
FROM cohort_1 a
LEFT JOIN Albumin b
    on a.person_id=b.person_id
    AND b.albumin_date=a.covid_admission
LEFT JOIN CRP c
    on a.person_id=c.person_id
    AND c.crp_date=a.covid_admission
LEFT JOIN Temperature e
    on a.person_id=e.person_id
    AND e.temp_date=a.covid_admission
LEFT JOIN Creatinine f
    on a.person_id=f.person_id
    AND f.creatinine_date=a.covid_admission
LEFT JOIN ALT g
    on a.person_id=g.person_id
    AND g.alt_date=a.covid_admission
LEFT JOIN SpO2 h
    on a.person_id=h.person_id
    AND h.o2_date=a.covid_admission
LEFT JOIN Pulse p
    on a.person_id=p.person_id
    AND p.pulse_date=a.covid_admission
LEFT JOIN Resp_rate r
    on a.person_id=r.person_id
    AND r.resp_rate_date=a.covid_admission
LEFT JOIN Troponin t
    on a.person_id=t.person_id
    AND t.troponin_date=a.covid_admission
LEFT JOIN WBC w
    on a.person_id=w.person_id
    AND w.wbc_date=a.covid_admission
LEFT JOIN location_2 z
    on a.location_id=z.location_id
LEFT JOIN MAP_for_merge m
    on a.person_id=m.person_id
LEFT JOIN AST x
    on a.person_id=x.person_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.a4902172-1702-496c-bec8-928a9a4550aa"),
    Age_sex_not_missing=Input(rid="ri.foundry.main.dataset.c8c9543f-abaa-4ba0-9859-f5eec7a217e8")
)
SELECT *
FROM Age_sex_not_missing
WHERE age >= 18

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.c8c9543f-abaa-4ba0-9859-f5eec7a217e8"),
    Full_hospitalized_cohort=Input(rid="ri.foundry.main.dataset.7ae560c1-b87e-422a-9fe1-3b8900fb5cbe")
)
---Dropping people with missing sex or age --> these are currently the most important risk factors that we know of
SELECT *
FROM Full_hospitalized_cohort
WHERE (age IS NOT NULL AND gender_concept_name != 'Other')

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.31a46e11-c81c-4328-b78e-fecff2c5393e"),
    on_vent_at_admission=Input(rid="ri.foundry.main.dataset.843d011b-818a-43f0-8162-3cd40813c421")
)
---Site 808 as having substantial data quality issues (confirmed by Richard Moffitt that cohort paper dropped it too)
---From Cohort 1 and the manifest tables, we decided to exclude site 325 because they shift dates before sending to N3C (even in the LDS) by up to 90 days
---Sites with >100 patients but reporting 0 deaths "impossible": site 411 (785 people as of January 8), 134 (369 people on January 29), 353 (871 people)
---Site 243 had 157 people on January 29, but had zero on a ventilator --> not likely, probably missing data
SELECT * 
FROM on_vent_at_admission
WHERE data_partner_id not in ('808','325','411','134','353','243')

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.eee2850a-a5d8-4895-884c-7a91eb686d41"),
    Data_partner_drop=Input(rid="ri.foundry.main.dataset.31a46e11-c81c-4328-b78e-fecff2c5393e")
)
---January 25: noticed some extreme length of stays, eminating from COVID diagnosis dates in 2018 or 2019 (not possible)
---From manifest table: we are accepting sites up to 45 days of shifting, so allowing January 1, 2020 as a generous cutoff and anything before excluding due to date inaccuracies
---Also some death dates before January 1 2020, and/or before date of admission, which created very weird days_to_death
SELECT * 
FROM Data_partner_drop
WHERE date_of_first_covid_diagnosis >= '2020-01-01'
AND ((death_date IS NULL) OR (death_date >= '2020-01-01'))
AND ((death_date IS NULL) OR (death_date >= covid_admission))

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.29707340-1343-4700-9ca6-f82e9a9f7041"),
    Date_inaccuracies=Input(rid="ri.foundry.main.dataset.eee2850a-a5d8-4895-884c-7a91eb686d41")
)
---This step is to drop people who get steroids for the first time as a part of their COVID episode. So they are somewhere in between chronic users (because they are coming into the hospital on it) and unexposed (because they received after their diagnosis, mechanism of interaction probably quite different)

---SQL doesn't do "drop if " type queries, so instead just have to explicitly keep everything but
SELECT *
FROM Date_inaccuracies
---Null if no immunosuppressing drugs at all, zero if some immunosuppression but not just acute steroids
WHERE (only_acute_steroids IS NULL) OR (only_acute_steroids=0)

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.7ae560c1-b87e-422a-9fe1-3b8900fb5cbe"),
    ACS2015_zctaallvars=Input(rid="ri.foundry.main.dataset.05788cef-3273-4bc8-a9a3-82584807aece"),
    Add_labs=Input(rid="ri.foundry.main.dataset.733f61f4-a21d-4d9f-b3f4-5d97dd74506e")
)
--Purpose: creating flag indicators and cleaning up other variables for analyses
---February 12: noticed there were ~1100 people with multiple rows (one person has 20 exact duplicate rows...)
---April 22: adding Social Deprivation Index at this step because needed the zip code step before
SELECT DISTINCT a.*, b.sdi_score, b.population, b.percnt_ltfpl100, b.percnt_singlparntfly, b.percnt_black, b.percnt_dropout, b.percnt_hhnocar, b.percnt_rentoccup, b.percnt_crowding, 
    b.percnt_nonemp, b.percnt_unemp, b.percnt_highneeds, b.percnt_hispanic, b.percnt_frgnborn, b.percnt_lingisol,
CASE 
    WHEN (covid_admission IS NOT NULL) THEN DATEDIFF (covid_admission, date_of_first_covid_diagnosis)
    END AS days_positive_to_admit,
CASE
    WHEN (covid_admission IS NOT NULL) THEN DATEDIFF(covid_admission, '2020-01-01')
    END AS days_since_jan1_2020,
---For sex: we already dropped people with missing sex information, and I'm doing male=1 because male sex is a risk factor for worse outcomes
CASE 
    WHEN (gender_concept_name='MALE') THEN 1 ELSE 0
    END AS male,
CASE
    WHEN (death_date IS NOT NULL) THEN 1 ELSE 0
    END AS death_flag, 
CASE 
    WHEN (vent_first_record IS NOT NULL) THEN 1 ELSE 0
    END AS vent_flag, 
CASE
    WHEN (immunosupp IS NOT NULL) then 1 ELSE 0
    END AS immuno_flag, 
CASE
    WHEN (AKI_in_hospital IS NOT NULL) then 1 ELSE 0
    END AS aki_flag,
CASE
    WHEN (ECMO IS NOT NULL) then 1 ELSE 0
    END AS ecmo_flag,  
CASE
    WHEN (Race="White" AND Ethnicity="Not Hispanic or Latino") THEN 1 ELSE 0
    END AS nonhisp_white, 
CASE
    WHEN (Race="Black or African American" AND Ethnicity="Not Hispanic or Latino") THEN 1 ELSE 0
    END AS nonhisp_black, 
CASE
    WHEN (Ethnicity="Hispanic or Latino") THEN 1 ELSE 0
    END AS hispanic,
CASE 
    WHEN (Race="Asian" AND Ethnicity="Not Hispanic or Latino") THEN 1 ELSE 0
    END AS asian, 
CASE 
    WHEN (Race="Other" OR Race="American Indian or Alaska Native" or Race="Native Hawaiian or Other Pacific Islander") AND Ethnicity="Not Hispanic or Latino" THEN 1 ELSE 0
    END AS another_race, 
--Taking conservative approach: someone who is white with missing ethnicity will be left as missing (cannot reliably put them non-Hisp white or Hispanic)
CASE 
    WHEN (Race="Missing/Unknown" AND Ethnicity="Missing/Unknown") THEN 1
    WHEN (Race="Missing/Unknown" AND Ethnicity="Not Hispanic or Latino") THEN 1 
    WHEN (Race="Missing/Unknown" AND Ethnicity="Hispanic or Latino") THEN 0
    WHEN (Race="White" AND Ethnicity="Missing/Unknown") THEN 1
    WHEN (Race="Black or African American" AND Ethnicity="Missing/Unknown") THEN 1
    WHEN (Race="Asian" AND Ethnicity="Missing/Unknown") THEN 1
    WHEN (Race="Other" OR Race="American Indian or Alaska Native" or Race="Native Hawaiian or Other Pacific Islander") AND Ethnicity="Missing/Unknown" THEN 1
    ELSE 0 
    END AS missing_race, 
---Adding a very low lower limit to avoid data quality errors like a BMI of 2 kg/m2
CASE 
    WHEN (15 <= BMI AND BMI < 18.5) THEN 1 ELSE 0
    END AS underweight,
CASE 
    WHEN (18.5 <= BMI AND BMI < 25) THEN 1 ELSE 0
    END AS normal_weight,
CASE 
    WHEN (25 <= BMI AND BMI < 30) THEN 1 ELSE 0
    END AS overweight,
---Adding a very high upper limit so that we can avoid a data quality error like a BMI of 200
CASE 
    WHEN (30 <= BMI AND BMI < 70) THEN 1 ELSE 0
    END AS obese,
CASE 
    WHEN (BMI IS NULL OR BMI < 15 OR BMI >= 70) THEN 1 ELSE 0
    END AS missing_bmi, 
CASE
    WHEN (smoking_status="Current or Former") THEN 1
    WHEN (smoking_status="Non smoker") THEN 0
    END AS ever_smoker,
CASE
    WHEN (covid_discharge IS NULL) THEN 1 ELSE 0
    END AS still_hospitalized, 
CASE 
    WHEN (death_date IS NOT NULL) THEN DATEDIFF (death_date, covid_admission)
    END AS days_to_death, 
CASE
    WHEN (death_date IS NULL) THEN DATEDIFF(covid_discharge, covid_admission)
    END AS days_to_discharge_alive, 
CASE 
    WHEN (transplant_heart=1 OR transplant_kidney=1 OR transplant_liver=1 OR transplant_lung=1) then 1 else 0
    END AS transplant_any, 
CASE
    WHEN (rx_baseline_chf=1) THEN 1 ELSE 0
    END AS rx_chf,
CASE
    WHEN (rx_baseline_dementia=1) THEN 1 ELSE 0
    END AS rx_dementia,
CASE
    WHEN (rx_baseline_insulin=1) THEN 1 ELSE 0
    END AS rx_insulin,
CASE
    WHEN (rx_baseline_metformin=1) THEN 1 ELSE 0
    END AS rx_metformin,
CASE
    WHEN (rx_baseline_sulfonylurea=1) THEN 1 ELSE 0
    END AS rx_sulfonylurea,
CASE
    WHEN (rx_baseline_acarbose=1) THEN 1 ELSE 0
    END AS rx_acarbose,
CASE
    WHEN (rx_baseline_tzd=1) THEN 1 ELSE 0
    END AS rx_tzd,
CASE
    WHEN (rx_baseline_dpp4=1) THEN 1 ELSE 0
    END AS rx_dpp4,
CASE
    WHEN (rx_baseline_glp1=1) THEN 1 ELSE 0
    END AS rx_glp1,
CASE
    WHEN (rx_baseline_sglt2=1) THEN 1 ELSE 0
    END AS rx_sglt2,
CASE
    WHEN (rx_baseline_dm_other=1) THEN 1 ELSE 0
    END AS rx_dm_other,
CASE
    WHEN (rx_baseline_obesity=1) THEN 1 ELSE 0
    END AS rx_obesity,
CASE
    WHEN (rx_baseline_laba=1) THEN 1 ELSE 0
    END AS rx_laba,
CASE
    WHEN (rx_baseline_inhaled_cs=1) THEN 1 ELSE 0
    END AS rx_inhaled_cs,
CASE
    WHEN (rx_baseline_saba=1) THEN 1 ELSE 0
    END AS rx_saba,
CASE
    WHEN (rx_baseline_leukotriene=1) THEN 1 ELSE 0
    END AS rx_leukotriene,
CASE
    WHEN (rx_baseline_other_pulm=1) THEN 1 ELSE 0
    END AS rx_other_pulm,
CASE
    WHEN (rx_baseline_renal=1) THEN 1 ELSE 0
    END AS rx_renal, 
CASE 
    WHEN (vent_24_96hour=0 and vent_gt_96hour=0) THEN 0
    WHEN (vent_24_96hour=1) THEN -1
    WHEN (vent_gt_96hour=1) then -4
    END AS vent_earliest_shift, 
CASE 
    WHEN (glucocorticoid=1 and rheumatic=1) THEN 1
    WHEN (glucocorticoid=1 and psoriasis=1) THEN 1
    WHEN (glucocorticoid=1 and colitis=1) THEN 1
    WHEN (glucocorticoid=1 and rheum_arthritis=1) THEN 1
    WHEN (glucocorticoid=1 and lupus=1) THEN 1
    WHEN (glucocorticoid=1 and vasculitis=1) THEN 1
    WHEN (glucocorticoid=1 and as_axspa=1) THEN 1
    WHEN (glucocorticoid=1 and psa=1) THEN 1 
    ELSE 0
    END AS gluco_rheum, 
CASE 
    WHEN (glucocorticoid=1 and transplant_heart=1) THEN 1
    WHEN (glucocorticoid=1 and transplant_kidney=1) THEN 1
    WHEN (glucocorticoid=1 and transplant_liver=1) THEN 1
    WHEN (glucocorticoid=1 and transplant_lung=1) THEN 1 
    ELSE 0
    END AS gluco_sot,    
CASE 
    WHEN (rituximab=1 and rheumatic=1) THEN 1
    WHEN (rituximab=1 and psoriasis=1) THEN 1
    WHEN (rituximab=1 and colitis=1) THEN 1
    WHEN (rituximab=1 and rheum_arthritis=1) THEN 1
    WHEN (rituximab=1 and lupus=1) THEN 1
    WHEN (rituximab=1 and vasculitis=1) THEN 1
    WHEN (rituximab=1 and as_axspa=1) THEN 1
    WHEN (rituximab=1 and psa=1) THEN 1 
    else 0
    END AS ritux_rheum, 
CASE 
    WHEN (rituximab=1 
    and (cancer=1 or mets=1)) THEN 1 ELSE 0
    END AS ritux_cancer
FROM Add_labs a
LEFT JOIN ACS2015_zctaallvars b
    on a.zip = b.zcta

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.db08b2a2-d0f7-4223-b158-36610cb8ee97"),
    Covid_nearest_max_hospitalization=Input(rid="ri.foundry.main.dataset.7f73e0c3-d705-40c3-8d6e-787318822e54"),
    Rx_baseline_indicators=Input(rid="ri.foundry.main.dataset.490d40bb-082c-403c-a754-d1180c01fbcd"),
    SOT_all_indicators=Input(rid="ri.foundry.main.dataset.6b94e03a-e559-4420-a485-1554bb24e824"),
    complete_patient_table_with_derived_scores=Input(rid="ri.foundry.main.dataset.d467585c-53b3-4f10-b09e-8e86a4796a1a"),
    death=Input(rid="ri.foundry.main.dataset.d8cc2ad4-215e-4b5d-bc80-80ffb3454875"),
    immuno_for_merge=Input(rid="ri.foundry.main.dataset.c226d0c4-af07-4ddf-ae4c-e6df12496123"),
    observation_relevant=Input(rid="ri.foundry.main.dataset.13af7a8b-a184-419f-9c12-c4c320c83258"),
    person=Input(rid="ri.foundry.main.dataset.50cae11a-4afb-457d-99d4-55b4bc2cbe66"),
    pre_charslon_R=Input(rid="ri.foundry.main.dataset.df317adb-f831-40fd-b70a-59646f7d8e87"),
    vent_first_in_cohort=Input(rid="ri.foundry.main.dataset.825d305b-4edc-4881-9205-c390d0df95f6")
)
--Joining the immunosuppression information back to the full hospitalized cohort
SELECT a.*, 
    b.immunosupp, b.anthracyclines, b.checkpoint_inhibitor, b.cyclophosphamide, b.pk_inhibitor, b.monoclonal_other, b.l01_other, b.rituximab, 
    b.azathioprine, b.calcineurin_inhibitor, b.il_inhibitor, b.jak_inhibitor, b.mycophenol, b.tnf_inhibitor, b.l04_other, 
    b.glucocorticoid, b.gluco_dose_known_high, b.steroids_before_covid, b.steroids_during_covid, b.only_acute_steroids,
    b.psoriasis, b.colitis, b.rheum_arthritis, b.emphysema_copd, b.asthma, b.lupus, b.vasculitis, b.as_axspa, b.psa, b.gluco_without_reason,
    p.data_partner_id, p.AKI_in_hospital, p.ECMO, p.Invasive_Ventilation, p.age_at_visit_start_in_years_int as age, p.length_of_stay, p.Race, p.Ethnicity, p.gender_concept_name, p.smoking_status, p.covid_status_name, p.Q_Score, p.BMI, p.Height, p.Weight, p.in_death_table,
c.MI, c.CHF, c.PVD, c.stroke, c.dementia, c.pulmonary, c.rheumatic, c.PUD, c.liver_mild, c.diabetes, c.dmcx, c.paralysis, c.renal, c.cancer, c.liversevere, c.mets, c.hiv, c.multiple, c.CCI_INDEX, 
r.rx_baseline_chf, r.rx_baseline_dementia, r.rx_baseline_insulin, r.rx_baseline_metformin, r.rx_baseline_sulfonylurea, r.rx_baseline_acarbose, r.rx_baseline_tzd, 
r.rx_baseline_dpp4, r.rx_baseline_glp1, r.rx_baseline_sglt2, r.rx_baseline_dm_other, r.rx_baseline_obesity, r.rx_baseline_laba, r.rx_baseline_inhaled_cs, r.rx_baseline_saba, r.rx_baseline_leukotriene, r.rx_baseline_other_pulm, r.rx_baseline_renal,
t.transplant_kidney, t.transplant_heart, t.transplant_liver, t.transplant_lung, 
d.death_date, 
v.vent_24_96hour, v.vent_gt_96hour, v.vent_first_record,
    date_sub(v.vent_first_record,1) as vent_minus_1day, 
    date_sub(v.vent_first_record,2) as vent_minus_2days,
    date_sub(v.vent_first_record,4) as vent_minus_4days,
z.location_id, 
o.observation_period_start_date, o.observation_period_end_date
FROM Covid_nearest_max_hospitalization a
left join immuno_for_merge b
    on a.person_id = b.person_id
left join complete_patient_table_with_derived_scores p
    on a.person_id=p.person_id 
inner join pre_charslon_R c
    on a.person_id = c.person_id
left join death d
    on a.person_id = d.person_id
left join vent_first_in_cohort v
    on a.person_id = v.person_id
left join person z
    on a.person_id=z.person_id
left join Rx_baseline_indicators r
    on a.person_id= r.person_id
left join SOT_all_indicators t
    on a.person_id=t.person_id
left join observation_relevant o
    on a.person_id=o.person_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.8608fdc2-8890-4ad1-a3cc-5e11ac62782f"),
    drop_pred_without_reason=Input(rid="ri.foundry.main.dataset.c3877901-7d32-4762-b93e-bed448979fc1")
)
---Couldn't do this data management in the same step where we were creating these flags
SELECT *,
CASE
    WHEN (days_since_jan1_2020 IS NOT NULL) THEN FLOOR(((days_since_jan1_2020) /7 ) +1 )
    END AS weeks_since_jan1_2020,
CASE
---VENT: they were either on a vent (1),  never ventilated and discharged alive (0), or died without ever having been ventilated (2)
    WHEN (vent_flag=1) THEN 1
    WHEN (vent_flag=0 AND death_flag=0) THEN 0
    WHEN (vent_flag=0 AND death_flag=1) THEN 2
        END AS vent1censor0dead2,
CASE
    --- DEATH AFTER VENT: for Figure 1
    WHEN vent_flag=0 THEN NULL
    WHEN vent_flag=1 AND death_flag=0 THEN 0
    WHEN vent_flag=1 and death_flag=1 THEN 1
    END AS death_after_vent,
CASE
    WHEN death_flag=0 THEN 0
    WHEN death_flag=1 THEN 1
        END AS death1discharge0, 
CASE
    WHEN time_death_discharge_untrimmed > 77 THEN 77
    WHEN time_death_discharge_untrimmed <= 77 THEN time_death_discharge_untrimmed
        END AS time_death_discharge, 
---1% was defined using a filter on the full dataset to keep only dates > (x), where the remaining pool was ~1% of cohort size
CASE
    WHEN time_vent_shortest_untrimmed > 63 THEN 63
    WHEN time_vent_shortest_untrimmed <= 63 THEN time_vent_shortest_untrimmed
        END AS time_vent_shortest,
CASE
    WHEN time_vent_longest_untrimmed > 63 THEN 63
    WHEN time_vent_longest_untrimmed <= 63 THEN time_vent_longest_untrimmed
        END AS time_vent_longest, 
CASE
    WHEN (gluco_rheum=1 or il_inhibitor=1 or jak_inhibitor=1 or ritux_rheum=1 or tnf_inhibitor=1 or l04_other=1) THEN 1 ELSE 0
    END AS any_rx_rheum,
CASE 
    WHEN (azathioprine=1 or calcineurin_inhibitor=1 or gluco_sot=1 or mycophenol=1) THEN 1 ELSE 0
    END AS any_rx_sot, 
CASE
    WHEN (anthracyclines=1 or checkpoint_inhibitor=1 or cyclophosphamide=1 or pk_inhibitor=1 or ritux_cancer=1 or monoclonal_other=1 or l01_other=1) THEN 1 ELSE 0
    END AS any_rx_cancer
FROM drop_pred_without_reason

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.c3877901-7d32-4762-b93e-bed448979fc1"),
    Drop_acute_steroids=Input(rid="ri.foundry.main.dataset.29707340-1343-4700-9ca6-f82e9a9f7041")
)
---Dropping people with prednisone without a record of indication for treatment: this is our workaround because any of these conditious would suggest chronic use
SELECT *, 
CASE
    --- For the people with a usable date
    WHEN (vent_flag=1 AND vent_24_96hour=0 AND vent_gt_96hour=0) THEN DATEDIFF (vent_first_record, covid_admission) 
    --- Time to death without a vent = competing risk of death
    WHEN (vent_flag=0 AND death_flag=1) THEN DATEDIFF (death_date, covid_admission)
    --- Time to discharge alive without ever having a vent (censor)
    WHEN (vent_flag=0 AND death_flag=0) THEN DATEDIFF (covid_discharge, covid_admission)
    ---For people with the 24-96 hour code, the earliest date their vent could have been placed was 24 hours
    WHEN (vent_24_96hour=1) THEN DATEDIFF(vent_minus_1day, covid_admission)
    ---For people with the 96+ hour code, the earliest date their vent could have been placed was 96 hours (4 days)
    WHEN (vent_gt_96hour=1) THEN DATEDIFF(vent_minus_4days, covid_admission)
    END AS time_vent_shortest_untrimmed,

CASE
    --- For the people with a usable date
    WHEN (vent_flag=1 AND vent_24_96hour=0 AND vent_gt_96hour=0) THEN DATEDIFF (vent_first_record, covid_admission) 
    --- Time to death without a vent = competing risk of death
    WHEN (vent_flag=0 AND death_flag=1) THEN DATEDIFF (death_date, covid_admission)
    --- Time to discharge alive without ever having a vent (censor)
    WHEN (vent_flag=0 AND death_flag=0) THEN DATEDIFF (covid_discharge, covid_admission)
    ---For people with the 24-96 hour code, the latest date their vent could have been placed was 96 hours (4 days)
    WHEN (vent_24_96hour=1) THEN DATEDIFF(vent_minus_4days, covid_admission)
    ---For people with the 96+ hour code, the earliest date their vent could have been placed was the date of admission, don't want a 0 because they will be dropped
    WHEN (vent_gt_96hour=1) THEN 0.1
    END AS time_vent_longest_untrimmed,

CASE
    ---DEATH: time to discharge, or time to death
    WHEN (death_flag=0) THEN DATEDIFF (covid_discharge, covid_admission)
    WHEN (death_flag=1 ) THEN DATEDIFF (death_date, covid_admission)
        END AS time_death_discharge_untrimmed

FROM Drop_acute_steroids
---Spark SQL doesn't drop, if it did we would do KEEP if pred_without_reason ne 1
---so we just keep what we want (Null if no immunosuppressing drugs at all, zero if some immunosuppression but not prednisone in the absence of an indication)
---June 17: adding Solid organ transplantation as a valid reason for glucocorticoid use
WHERE (gluco_without_reason IS NULL) OR (gluco_without_reason=0) or (gluco_sot=1)

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.58593115-9127-4db6-84b8-f2fbea611cbe"),
    immuno_preadmission=Input(rid="ri.foundry.main.dataset.9f393f73-a9d9-4492-a70c-7677ba57a75f")
)
SELECT *
FROM immuno_preadmission
WHERE days_immuno_before_admit >= 14

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.c226d0c4-af07-4ddf-ae4c-e6df12496123"),
    Gluco_reasons_indicators=Input(rid="ri.foundry.main.dataset.a89d21fd-508a-4cba-93ec-99d26c00f1c2"),
    immuno_indicators=Input(rid="ri.foundry.main.dataset.4ed8d618-e946-49c3-b087-b1994f961d60")
)
SELECT i.person_id, i.immunosupp, 
    i.anthracyclines, i.checkpoint_inhibitor, i.cyclophosphamide, i.pk_inhibitor, i.monoclonal_other, i.l01_other, 
    i.azathioprine, i.calcineurin_inhibitor, i.il_inhibitor, i.jak_inhibitor, i.mycophenol, i.tnf_inhibitor, i.l04_other, i.rituximab,
    i.glucocorticoid, i.gluco_dose_known_high, i.steroids_before_covid, i.steroids_during_covid,
    p.psoriasis, p.colitis, p.rheum_arthritis, p.emphysema_copd, p.asthma, p.lupus, p.vasculitis, p.as_axspa, p.psa,
---Flag for acute steroids as the sole "immunosuppression" - see the step where I drop this for full explanation
CASE
    WHEN (steroids_during_covid=1 AND steroids_before_covid=0 AND 
    anthracyclines=0 and checkpoint_inhibitor=0 and cyclophosphamide=0 and pk_inhibitor=0 and monoclonal_other=0 and l01_other=0 and
    azathioprine=0 and calcineurin_inhibitor=0 and il_inhibitor=0 and jak_inhibitor=0 and mycophenol=0 and tnf_inhibitor=0 and l04_other=0 and rituximab=0) THEN 1 
    ELSE 0
    END AS only_acute_steroids, 
---Flag for prednisone without an indication as their only immunosuppressant
CASE
    WHEN (psoriasis IS NULL AND colitis IS NULL AND rheum_arthritis IS NULL AND emphysema_copd IS NULL AND asthma IS NULL 
    AND lupus IS NULL AND vasculitis IS NULL AND as_axspa IS NULL AND psa IS NULL
        AND glucocorticoid=1 and
    anthracyclines=0 and checkpoint_inhibitor=0 and cyclophosphamide=0 and pk_inhibitor=0 and monoclonal_other=0 and l01_other=0 and
    azathioprine=0 and calcineurin_inhibitor=0 and il_inhibitor=0 and jak_inhibitor=0 and mycophenol=0 and tnf_inhibitor=0 and l04_other=0 and rituximab=0
    ) THEN 1 ELSE 0
    END AS gluco_without_reason
FROM immuno_indicators i
LEFT JOIN Gluco_reasons_indicators p
    ON i.person_id = p.person_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4ed8d618-e946-49c3-b087-b1994f961d60"),
    immuno_sums=Input(rid="ri.foundry.main.dataset.3b9ee000-e79d-4110-bbc3-f25d2f7c51b9")
)
---Purpose: the summation in the previous step counts drug records, but we just want an indicator of yes/no so anything >=1 is present and null means not present
SELECT *,
CASE 
    WHEN (immunosupp_sum >0 ) then 1
    END AS immunosupp, 
CASE
    WHEN (anthracyclines_sum >0 ) then 1
    ELSE 0
    END AS anthracyclines, 
CASE
    WHEN (checkpoint_inhibitor_sum >0 ) then 1
    ELSE 0
    END AS checkpoint_inhibitor,
CASE
    WHEN (cyclophosphamide_sum >0 ) then 1
    ELSE 0
    END AS cyclophosphamide,  
CASE
    WHEN (pk_inhibitor_sum >0 ) then 1
    ELSE 0
    END AS pk_inhibitor, 
CASE
    WHEN (monoclonal_other_sum >0 ) then 1
    ELSE 0
    END AS monoclonal_other, 
CASE
    WHEN (rituximab_sum >0 ) then 1
    ELSE 0
    END AS rituximab, 
CASE
    WHEN (l01_other_sum >0 ) then 1
    ELSE 0
    END AS l01_other, 
CASE
    WHEN (azathioprine_sum >0 ) then 1
    ELSE 0
    END AS azathioprine,
CASE
    WHEN (calcineurin_inhibitor_sum >0 ) then 1
    ELSE 0
    END AS calcineurin_inhibitor, 
CASE
    WHEN (il_inhibitor_sum >0 ) then 1
    ELSE 0
    END AS il_inhibitor, 
CASE
    WHEN (jak_inhibitor_sum >0 ) then 1
    ELSE 0
    END AS jak_inhibitor,
CASE
    WHEN (mycophenol_sum >0 ) then 1
    ELSE 0
    END AS mycophenol,  
CASE
    WHEN (tnf_inhibitor_sum >0 ) then 1
    ELSE 0
    END AS tnf_inhibitor, 
CASE
    WHEN (l04_other_sum >0 ) then 1
    ELSE 0
    END AS l04_other, 
CASE
    WHEN (glucocorticoid_sum >0 ) then 1
    ELSE 0
    END AS glucocorticoid, 
CASE
    WHEN (steroids_before_covid_sum >0 ) then 1
    ELSE 0
    END AS steroids_before_covid,
CASE
    WHEN (steroids_during_covid_sum >0 ) then 1
    ELSE 0
    END AS steroids_during_covid, 
CASE
    WHEN (gluco_dose_known_high_sum >0 ) then 1
    ELSE 0
    END AS gluco_dose_known_high
FROM immuno_sums

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.9f393f73-a9d9-4492-a70c-7677ba57a75f"),
    Covid_nearest_max_hospitalization=Input(rid="ri.foundry.main.dataset.7f73e0c3-d705-40c3-8d6e-787318822e54"),
    Immuno_exposures=Input(rid="ri.foundry.main.dataset.6c39da89-9af9-4c61-8b55-800beb8ba01b")
)
----January 29: importing the immuno exposures from a different sheet because that step was so intense it would cause the "refresh all" to crash

---PURPOSE: Immunosuppression present at the time of admisssion
SELECT i.person_id, i.drug_concept_name, i.drug_exposure_start_date, c.date_of_first_covid_diagnosis, c.covid_admission, i.drug_exposure_end_date, 
    i.anthracyclines, i.checkpoint_inhibitor, i.cyclophosphamide, i.pk_inhibitor, i.monoclonal_other, i.l01_other, i.rituximab,
    i.azathioprine, i.calcineurin_inhibitor, i.il_inhibitor, i.jak_inhibitor, i.mycophenol, i.tnf_inhibitor, i.l04_other, 
    i.glucocorticoid, i.gluco_dose_known_high, DATEDIFF(covid_admission, drug_exposure_start_date) as days_immuno_before_admit,
---Creating indicator variable for immunosuppression
CASE 
    WHEN (i.drug_exposure_start_date IS NOT NULL) then 1 else 0
    END AS immunosupp, 
---To help rule out steroids FOR covid, we are interested in chronic prescriptions present before COVID
---June 14: adding the 14 days prior to admission criteria, to get rid of precipitating factors like pred for COPD flare which is really COVID
CASE WHEN (i.glucocorticoid=1 AND i.drug_exposure_start_date < c.date_of_first_covid_diagnosis) then 1 else 0
    END AS steroids_before_covid,
CASE WHEN (i.glucocorticoid=1 AND i.drug_exposure_start_date >= c.date_of_first_covid_diagnosis) then 1 else 0
    END AS steroids_during_covid
---Merging the immunosuppression exposures table with the COVID+ hospitalizations 
FROM Immuno_exposures i
inner join Covid_nearest_max_hospitalization c
    on i.person_id = c.person_id
---Restricting to pre-admission meds
and c.covid_admission > i.drug_exposure_start_date
---Making sure they weren't stopped prior to admisssion
and (i.drug_exposure_end_date is NULL or c.covid_admission <= i.drug_exposure_end_date)

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.3b9ee000-e79d-4110-bbc3-f25d2f7c51b9"),
    immuno_14d_prior=Input(rid="ri.foundry.main.dataset.58593115-9127-4db6-84b8-f2fbea611cbe")
)
---Creating a table with the person_id for unique people with an immunosuppressive drug present at admission, and an indicator variable for immunosuppressed for the joining
SELECT person_id,
    SUM (immunosupp) as immunosupp_sum,
    SUM (anthracyclines) as anthracyclines_sum,
    SUM (checkpoint_inhibitor) as checkpoint_inhibitor_sum,
    SUM (cyclophosphamide) as cyclophosphamide_sum, 
    SUM (pk_inhibitor) as pk_inhibitor_sum,
    SUM (monoclonal_other) as monoclonal_other_sum,
    SUM (l01_other) as l01_other_sum,
    SUM (azathioprine) as azathioprine_sum,
    SUM (calcineurin_inhibitor) as calcineurin_inhibitor_sum, 
    SUM (il_inhibitor) as il_inhibitor_sum,
    SUM (jak_inhibitor) as jak_inhibitor_sum,
    SUM (rituximab) as rituximab_sum,
    SUM (mycophenol) as mycophenol_sum,
    SUM (tnf_inhibitor) as tnf_inhibitor_sum, 
    SUM (l04_other) as l04_other_sum,
    SUM (glucocorticoid) as glucocorticoid_sum,
    SUM (steroids_before_covid) as steroids_before_covid_sum,
    SUM (steroids_during_covid) as steroids_during_covid_sum, 
    SUM (gluco_dose_known_high) as gluco_dose_known_high_sum
    FROM immuno_14d_prior
    GROUP BY person_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4c349534-135a-478d-a44a-0cddaf308a49"),
    location=Input(rid="ri.foundry.main.dataset.efac41e8-cc64-49bf-9007-d7e22a088318")
)
--- some zip codes were more detailed than 5 digits, but the ACS data is 5 digit level
SELECT LEFT(zip, 5) as zip, location_id
FROM location

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.13af7a8b-a184-419f-9c12-c4c320c83258"),
    observation_period=Input(rid="ri.foundry.main.dataset.430ecb64-9836-45f5-9c33-41a5bcb582d3")
)
---Noticed redundancies for a small number of people, like an observation period from January to March 1951, which could be completely solved with a date limit for the relevant period
SELECT *
FROM observation_period
WHERE observation_period_end_date >= '2020-01-01'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.843d011b-818a-43f0-8162-3cd40813c421"),
    Age18up=Input(rid="ri.foundry.main.dataset.a4902172-1702-496c-bec8-928a9a4550aa")
)
---Dropping people on a vent at admission (some time to vent times were looking negative)
SELECT *
FROM Age18up
WHERE (
    vent_flag=0
    OR (vent_24_96hour=0 and vent_gt_96hour=0)
    OR (vent_24_96hour=1 and vent_minus_1day > covid_admission)
    OR (vent_gt_96hour=1 and vent_minus_4days > covid_admission)
   )

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.3d98a420-bf36-4a78-9b96-ec7c42cf18ec"),
    Covid_nearest_max_hospitalization=Input(rid="ri.foundry.main.dataset.7f73e0c3-d705-40c3-8d6e-787318822e54"),
    concept_set_members=Input(rid="ri.foundry.main.dataset.e670c5ad-42ca-46a2-ae55-e917e3e161b6"),
    condition_occurrence_1=Input(rid="ri.foundry.main.dataset.900fa2ad-87ea-4285-be30-c6b5bab60e86")
)
---This code came from Vithal
---Updated April 21 to use the "hiv_infection" codeset 382527336 instead of 73549360, as suggested by Vithal over email to Kayte
SELECT
distinct
x.* ,
(x.MI*1 + x.CHF*1 + x.PVD*1 + x.stroke*1 + x.dementia*1 + x.pulmonary*1 + x.rheumatic*1 + x.PUD*1 + x.liver_mild*1 + x.diabetes*1 + x.dmcx*2 + x.paralysis*2 + x.renal*2 + x.cancer*2 
 + x.liversevere*3 + x.mets*6 + x.hiv*6) CCI_INDEX
FROM
(
SELECT
distinct
    person_id, 
    sum(case when comorbidity = 'MI' then 1 else 0 end) MI ,
    sum(case when comorbidity = 'CHF' then 1 else 0 end) CHF ,
    sum(case when comorbidity = 'PVD' then 1 else 0 end) PVD ,
    sum(case when comorbidity = 'Stroke' then 1 else 0 end) stroke ,
    sum(case when comorbidity = 'Dementia' then 1 else 0 end) dementia ,
    sum(case when comorbidity = 'Pulmonary' then 1 else 0 end) pulmonary ,
    sum(case when comorbidity = 'Rheumatic' then 1 else 0 end) rheumatic ,
    sum(case when comorbidity = 'PUD' then 1 else 0 end) PUD ,
    sum(case when comorbidity = 'LiverMild' then 1 else 0 end) liver_mild ,
    sum(case when comorbidity = 'DM' then 1 else 0 end) diabetes ,
    sum(case when comorbidity = 'DMcx' then 1 else 0 end) dmcx ,
    sum(case when comorbidity = 'Paralysis' then 1 else 0 end) paralysis ,
    sum(case when comorbidity = 'Renal' then 1 else 0 end) renal ,
    sum(case when comorbidity = 'Cancer' then 1 else 0 end) cancer ,
    sum(case when comorbidity = 'LiverSevere' then 1 else 0 end) liversevere ,
    sum(case when comorbidity = 'Mets' then 1 else 0 end) mets ,   
    sum(case when comorbidity = 'hiv infection' then 1 else 0 end) hiv,    
    case when count(*) > 1 then 1 else 0 end multiple
FROM (
SELECT 
distinct
cp.person_id ,
replace(cs.concept_set_name, 'Charlson - ','') comorbidity 
FROM 
Covid_nearest_max_hospitalization cp
left outer join condition_occurrence_1 co on cp.person_id = co.person_id and co.condition_start_date < cp.covid_admission
left outer join concept_set_members cs on ( cs.concept_id = co.condition_source_concept_id or cs.concept_id = co.condition_concept_id )
and cs.is_most_recent_version = true
    and cs.codeset_id in ( 535274723, 359043664, 78746470, 719585646, 403438288, 382527336, 494981955, 248333963, 378462283, 259495957, 489555336, 510748896, 514953976, 376881697, 
    220495690, 765004404, 652711186
    )
) t
group by t.person_id
) x

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.825d305b-4edc-4881-9205-c390d0df95f6"),
    vent_in_cohort=Input(rid="ri.foundry.main.dataset.43a40a26-6317-44e4-b4b6-f6b2f84f5d5a")
)
--Adding the first statement because we don't want to group by these --> people could contribute 3 dates (their vent_24_96hours=0 and vent_gt_96=0, their vent_24_96hours and their vent_gt_96hours)
---Palantir error code suggested using the first "if you don't care which"
SELECT person_id, first(vent_24_96hours) as vent_24_96hour, first(vent_gt_96hours) as vent_gt_96hour, 
    MIN(vent_date) AS vent_first_record
FROM vent_in_cohort
GROUP BY person_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.43a40a26-6317-44e4-b4b6-f6b2f84f5d5a"),
    Covid_nearest_max_hospitalization=Input(rid="ri.foundry.main.dataset.7f73e0c3-d705-40c3-8d6e-787318822e54"),
    Vent_all_people=Input(rid="ri.foundry.main.dataset.096205f3-15f2-4ba6-8f4e-357dad58839d")
)
---Keeping only the COVID+ people, during their admission, from the merged three inputs
SELECT distinct c.*, o.vent_date, o.vent_concept_name, o.data_partner_id, o.vent_24_96hours, o.vent_gt_96hours
FROM Covid_nearest_max_hospitalization c
INNER JOIN Vent_all_people o on c.person_id=o.person_id
    AND covid_admission <= vent_date AND vent_date <= covid_discharge
ORDER BY person_id, vent_date, vent_24_96hours, vent_gt_96hours

