

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.490d40bb-082c-403c-a754-d1180c01fbcd"),
    rx_sum=Input(rid="ri.foundry.main.dataset.57e31b83-4641-484f-8138-d706e8f9e6b4")
)
SELECT *,
CASE WHEN (rx_baseline_chf_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_chf, 
CASE WHEN (rx_baseline_insulin_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_insulin, 
CASE WHEN (rx_baseline_metformin_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_metformin, 
CASE WHEN (rx_baseline_sulfonylurea_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_sulfonylurea, 
CASE WHEN (rx_baseline_acarbose_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_acarbose, 
CASE WHEN (rx_baseline_tzd_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_tzd, 
CASE WHEN (rx_baseline_dpp4_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_dpp4, 
CASE WHEN (rx_baseline_glp1_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_glp1, 
CASE WHEN (rx_baseline_sglt2_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_sglt2, 
CASE WHEN (rx_baseline_dm_other_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_dm_other,  
CASE WHEN (rx_baseline_dementia_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_dementia,

CASE WHEN (rx_baseline_laba_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_laba, 
CASE WHEN (rx_baseline_inhaled_cs_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_inhaled_cs, 
CASE WHEN (rx_baseline_saba_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_saba, 
CASE WHEN (rx_baseline_leukotriene_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_leukotriene, 
CASE WHEN (rx_baseline_other_pulm_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_other_pulm, 
CASE WHEN (rx_baseline_obesity_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_obesity, 
CASE WHEN (rx_baseline_renal_sum > 0) THEN 1 ELSE 0
    END AS rx_baseline_renal
FROM rx_sum

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.eb920f62-997f-434b-8500-6ce4869f5582"),
    concept=Input(rid="ri.foundry.main.dataset.5cb3c4a3-327a-47bf-a8bf-daf0cafe6772")
)
SELECT concept_id, concept_name
FROM concept
WHERE
/*chronic pulmonary, including inhaled corticosteroids*/
lcase(concept_name) like '%salbutamol%'
or lcase(concept_name) like '%terbutaline%'
or lcase(concept_name) like '%fenoterol%'
or lcase(concept_name) like '%rimiterol%'
or lcase(concept_name) like '%hexoprenaline%'
or lcase(concept_name) like '%isoetarine%'
or lcase(concept_name) like '%pirbuterol%'
or lcase(concept_name) like '%tretoquinol%'
or lcase(concept_name) like '%carbuterol%'
or lcase(concept_name) like '%tulobuterol%'
or lcase(concept_name) like '%salmeterol%'
or lcase(concept_name) like '%formoterol%'
or lcase(concept_name) like '%clenbuterol%'
or lcase(concept_name) like '%reproterol%'
or lcase(concept_name) like '%procaterol%'
or lcase(concept_name) like '%bitolterol%'
or lcase(concept_name) like '%indacaterol%'
or lcase(concept_name) like '%olodaterol%'
or lcase(concept_name) like '%beclometasone%'
or lcase(concept_name) like '%budesonide%'
or lcase(concept_name) like '%flunisolide%'
or lcase(concept_name) like '%betamethasone%'
or lcase(concept_name) like '%fluticasone%'
or lcase(concept_name) like '%triamcinolone%'
or lcase(concept_name) like '%mometasone%'
or lcase(concept_name) like '%ciclesonide%'
or lcase(concept_name) like '%fluticasone furoate%'
or lcase(concept_name) like '%ipratropium bromide%'
or lcase(concept_name) like '%oxitropium bromide'
or lcase(concept_name) like '%stramoni%'
or lcase(concept_name) like '%tiotropium bromide%'
or lcase(concept_name) like '%aclidinium bromide%'
or lcase(concept_name) like '%glycopyrronium bromide%'
or lcase(concept_name) like '%umeclidinium bromide%'
or lcase(concept_name) like '%revefenacin%'
or lcase(concept_name) like '%cromoglicic acid%'
or lcase(concept_name) like '%nedocromil%'
or lcase(concept_name) like '%fenspiride%'
or lcase(concept_name) like '%isoprenaline%'
or lcase(concept_name) like '%methoxyphenamine%'
or lcase(concept_name) like '%orciprenaline%'
or lcase(concept_name) like '%salbutamol%'
or lcase(concept_name) like '%terbutaline%'
or lcase(concept_name) like '%fenoterol%'
or lcase(concept_name) like '%hexoprenaline%'
or lcase(concept_name) like '%isoetarine%'
or lcase(concept_name) like '%pirbuterol%'
or lcase(concept_name) like '%procaterol%'
or lcase(concept_name) like '%tretoquinol%'
or lcase(concept_name) like '%carbuterol%'
or lcase(concept_name) like '%tulobuterol%'
or lcase(concept_name) like '%bambuterol%'
or lcase(concept_name) like '%clenbuterol%'
or lcase(concept_name) like '%reproterol%'
or lcase(concept_name) like '%diprophylline%'
or lcase(concept_name) like '%choline theophyllinate%'
or lcase(concept_name) like '%proxyphylline%'
or lcase(concept_name) like '%theophylline%'
or lcase(concept_name) like '%aminophylline%'
or lcase(concept_name) like '%etamiphylline%'
or lcase(concept_name) like '%theobromine%'
or lcase(concept_name) like '%bamifylline%'
or lcase(concept_name) like '%acefylline piperazine%'
or lcase(concept_name) like '%bufylline%'
or lcase(concept_name) like '%doxofylline%'
or lcase(concept_name) like '%mepyramine theophyllinacetate%'
or lcase(concept_name) like '%zafirlukast%'
or lcase(concept_name) like '%pranlukast%'
or lcase(concept_name) like '%montelukast%' 
/*congestive heart failure*/
or lcase(concept_name) like '%potassium canrenoate%'
or lcase(concept_name) like '%canrenone%'
or lcase(concept_name) like '%eplerenone%'
or lcase(concept_name) like '%metoprolol%' 
/*dementia*/
or lcase(concept_name) like '%donepezil%'
or lcase(concept_name) like '%galantamine%'
or lcase(concept_name) like '%rivastigmine%'
or lcase(concept_name) like '%memantine%' 
/*diabetes*/
or lcase(concept_name) like '%insulin%'
or lcase(concept_name) like '%phenformin%'
or lcase(concept_name) like '%metformin%'
or lcase(concept_name) like '%buformin%'
or lcase(concept_name) like '%glibenclamide%'
or lcase(concept_name) like '%chlorpropamide%'
or lcase(concept_name) like '%tolbutamide%'
or lcase(concept_name) like '%glibornuride%'
or lcase(concept_name) like '%tolazamide%'
or lcase(concept_name) like '%carbutamide%'
or lcase(concept_name) like '%glipizide%'
or lcase(concept_name) like '%gliquidone%'
or lcase(concept_name) like '%gliclazide%'
or lcase(concept_name) like '%metahexamide%'
or lcase(concept_name) like '%glisoxepide%'
or lcase(concept_name) like '%glimepiride%'
or lcase(concept_name) like '%acetohexamide%'
or lcase(concept_name) like '%glymidine%'
or lcase(concept_name) like '%acarbose%'
or lcase(concept_name) like '%miglitol%'
or lcase(concept_name) like '%voglibose%'
or lcase(concept_name) like '%troglitazone%'
or lcase(concept_name) like '%rosiglitazone%'
or lcase(concept_name) like '%pioglitazone%'
or lcase(concept_name) like '%sitagliptin%'
or lcase(concept_name) like '%vildagliptin%'
or lcase(concept_name) like '%saxagliptin%'
or lcase(concept_name) like '%alogliptin%'
or lcase(concept_name) like '%linagliptin%'
or lcase(concept_name) like '%gemigliptin%'
or lcase(concept_name) like '%evogliptin%'
or lcase(concept_name) like '%exenatide%'
or lcase(concept_name) like '%liraglutide%'
or lcase(concept_name) like '%lixisenatide%'
or lcase(concept_name) like '%albiglutide%'
or lcase(concept_name) like '%dulaglutide%'
or lcase(concept_name) like '%semaglutide%'
or lcase(concept_name) like '%dapagliflozin%'
or lcase(concept_name) like '%canagliflozin%'
or lcase(concept_name) like '%empagliflozin%'
or lcase(concept_name) like '%ertugliflozin%'
or lcase(concept_name) like '%ipragliflozin%'
or lcase(concept_name) like '%sotagliflozin%'
or lcase(concept_name) like '%guar gum%'
or lcase(concept_name) like '%repaglinide%'
or lcase(concept_name) like '%nateglinide%'
or lcase(concept_name) like '%pramlintide%'
or lcase(concept_name) like '%benfluorex%'
or lcase(concept_name) like '%mitiglinide%'
/*renal disease*/
or lcase(concept_name) like '%erythropoietin%'
or lcase(concept_name) like '%darbepoetin alfa%'
or lcase(concept_name) like '%methoxy polyethylene glycol-epoetin beta%'
or lcase(concept_name) like '%ergocalciferol%'
or lcase(concept_name) like '%dihydrotachysterol%'
or lcase(concept_name) like '%alfacalcidol%'
or lcase(concept_name) like '%calcitriol%'
or lcase(concept_name) like '%sevelamer%'
or lcase(concept_name) like '%lanthanum carbonate%'
or lcase(concept_name) like '%sucroferric oxyhydroxide%' 
/*obesity*/
or lcase(concept_name) like '%orlistat%'
or lcase(concept_name) like '%lorcaserin%'
or lcase(concept_name) like '%phentermine%'
or lcase(concept_name) like '%naltrexone%'
or lcase(concept_name) like '%liraglutide%'

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4877fa16-22fe-48e0-a8e5-eed66e7bc5b2"),
    drug_exposure=Input(rid="ri.foundry.main.dataset.ec252b05-8f82-4f7f-a227-b3bb9bc578ef"),
    rx_covariate_concepts=Input(rid="ri.foundry.main.dataset.eb920f62-997f-434b-8500-6ce4869f5582")
)
SELECT d.person_id, d.drug_exposure_start_date, d.drug_exposure_end_date, r.concept_name,
CASE WHEN /*long acting beta agonists*/
(lcase(concept_name) like '%bambuterol%'
or lcase(concept_name) like '%clenbuterol%'
or lcase(concept_name) like '%formoterol%'
or lcase(concept_name) like '%indacaterol%'
or lcase(concept_name) like '%olodaterol%'
or lcase(concept_name) like '%salmeterol%') THEN 1 ELSE 0
END AS rx_baseline_laba, 

CASE WHEN /*inhaled corticosteroids*/
(lcase(concept_name) like '%beclometasone%'
or lcase(concept_name) like '%budesonide%'
or lcase(concept_name) like '%flunisolide%'
or lcase(concept_name) like '%betamethasone valerate%'
or lcase(concept_name) like '%fluticasone%'
or lcase(concept_name) like '%triamcinolone acetonide%'
or lcase(concept_name) like '%mometasone%'
or lcase(concept_name) like '%ciclesonide%'
or lcase(concept_name) like '%fluticasone furoate%') THEN 1 ELSE 0
END AS rx_baseline_inhaled_cs, 

CASE WHEN /*short acting beta agonists*/
(lcase(concept_name) like '%carbuterol%'
or lcase(concept_name) like '%fenoterol%'
or lcase(concept_name) like '%hexoprenaline%'
or lcase(concept_name) like '%isoetarine%'
or lcase(concept_name) like '%pirbuterol%'
or lcase(concept_name) like '%procaterol%'
or lcase(concept_name) like '%tretoquinol%'
or lcase(concept_name) like '%reproterol%'
or lcase(concept_name) like '%rimiterol%'
or lcase(concept_name) like '%salbutamol%'
or lcase(concept_name) like '%terbutaline%'
or lcase(concept_name) like '%tulobuterol%') THEN 1 ELSE 0
END AS rx_baseline_saba,

CASE WHEN /*other pulm drugs*/
(lcase(concept_name) like '%hexoprenaline%'
or lcase(concept_name) like '%tretoquinol%'
or lcase(concept_name) like '%clenbuterol%'
or lcase(concept_name) like '%ipratropium bromide%'
or lcase(concept_name) like '%oxitropium bromide'
or lcase(concept_name) like '%stramoni%'
or lcase(concept_name) like '%tiotropium bromide%'
or lcase(concept_name) like '%aclidinium bromide%'
or lcase(concept_name) like '%glycopyrronium bromide%'
or lcase(concept_name) like '%umeclidinium bromide%'
or lcase(concept_name) like '%revefenacin%'
or lcase(concept_name) like '%cromoglicic acid%'
or lcase(concept_name) like '%nedocromil%'
or lcase(concept_name) like '%fenspiride%'
or lcase(concept_name) like '%isoprenaline%'
or lcase(concept_name) like '%methoxyphenamine%'
or lcase(concept_name) like '%orciprenaline%'
or lcase(concept_name) like '%fenoterol%'
or lcase(concept_name) like '%hexoprenaline%'
or lcase(concept_name) like '%tretoquinol%'
or lcase(concept_name) like '%reproterol%'
or lcase(concept_name) like '%diprophylline%'
or lcase(concept_name) like '%choline theophyllinate%'
or lcase(concept_name) like '%proxyphylline%'
or lcase(concept_name) like '%theophylline%'
or lcase(concept_name) like '%aminophylline%'
or lcase(concept_name) like '%etamiphylline%'
or lcase(concept_name) like '%theobromine%'
or lcase(concept_name) like '%bamifylline%'
or lcase(concept_name) like '%acefylline piperazine%'
or lcase(concept_name) like '%bufylline%'
or lcase(concept_name) like '%doxofylline%'
or lcase(concept_name) like '%mepyramine theophyllinacetate%') THEN 1 ELSE 0
END AS rx_baseline_other_pulm,

CASE WHEN /*leukotriene modifiers*/
(lcase(concept_name) like '%zafirlukast%'
or lcase(concept_name) like '%pranlukast%'
or lcase(concept_name) like '%montelukast%') THEN 1 ELSE 0
END AS rx_baseline_leukotriene,

CASE WHEN ( /*congestive heart failure*/
lcase(concept_name) like '%potassium canrenoate%'
or lcase(concept_name) like '%canrenone%'
or lcase(concept_name) like '%eplerenone%'
or lcase(concept_name) like '%metoprolol%' 
or lcase(concept_name) like '%sacubitril%'
or lcase(concept_name) like '%spironolactone%'
or lcase(concept_name) like '%digoxin%'
) THEN 1 ELSE 0
END AS rx_baseline_chf, 

CASE WHEN ( /*dementia*/
lcase(concept_name) like '%donepezil%'
or lcase(concept_name) like '%galantamine%'
or lcase(concept_name) like '%rivastigmine%'
or lcase(concept_name) like '%memantine%' ) THEN 1 ELSE 0
END AS rx_baseline_dementia,

CASE WHEN /*diabetes*/
lcase(concept_name) like '%insulin%' THEN 1 ELSE 0
END AS rx_baseline_insulin, 

CASE WHEN /*metformin and other biguanides*/
(lcase(concept_name) like '%phenformin%'
or lcase(concept_name) like '%metformin%'
or lcase(concept_name) like '%buformin%') THEN 1 ELSE 0
END AS rx_baseline_metformin, 

CASE WHEN /*sulfonylureas*/
(lcase(concept_name) like '%glibenclamide%'
or lcase(concept_name) like '%chlorpropamide%'
or lcase(concept_name) like '%tolbutamide%'
or lcase(concept_name) like '%glibornuride%'
or lcase(concept_name) like '%tolazamide%'
or lcase(concept_name) like '%carbutamide%'
or lcase(concept_name) like '%glipizide%'
or lcase(concept_name) like '%gliquidone%'
or lcase(concept_name) like '%gliclazide%'
or lcase(concept_name) like '%metahexamide%'
or lcase(concept_name) like '%glisoxepide%'
or lcase(concept_name) like '%glimepiride%'
or lcase(concept_name) like '%acetohexamide%'
or lcase(concept_name) like '%glymidine%') THEN 1 ELSE 0
END AS rx_baseline_sulfonylurea, 

CASE WHEN /*Alpha glucosidase inhibitors*/
(lcase(concept_name) like '%acarbose%'
or lcase(concept_name) like '%miglitol%'
or lcase(concept_name) like '%voglibose%') THEN 1 ELSE 0
END AS rx_baseline_acarbose, 

CASE WHEN /*thiazolidinediones*/
(lcase(concept_name) like '%troglitazone%'
or lcase(concept_name) like '%rosiglitazone%'
or lcase(concept_name) like '%pioglitazone%') THEN 1 ELSE 0
END AS rx_baseline_tzd, 

CASE WHEN /*DPP-4 inhibitors*/
(lcase(concept_name) like '%sitagliptin%'
or lcase(concept_name) like '%vildagliptin%'
or lcase(concept_name) like '%saxagliptin%'
or lcase(concept_name) like '%alogliptin%'
or lcase(concept_name) like '%linagliptin%'
or lcase(concept_name) like '%gemigliptin%'
or lcase(concept_name) like '%evogliptin%') THEN 1 ELSE 0
END AS rx_baseline_dpp4,

CASE WHEN /*GLP-1 agonists*/
(lcase(concept_name) like '%exenatide%'
or lcase(concept_name) like '%liraglutide%'
or lcase(concept_name) like '%lixisenatide%'
or lcase(concept_name) like '%albiglutide%'
or lcase(concept_name) like '%dulaglutide%'
or lcase(concept_name) like '%semaglutide%') THEN 1 ELSE 0
END AS rx_baseline_glp1, 

CASE WHEN /*SGLT-2 inhibitors*/
(lcase(concept_name) like '%dapagliflozin%'
or lcase(concept_name) like '%canagliflozin%'
or lcase(concept_name) like '%empagliflozin%'
or lcase(concept_name) like '%ertugliflozin%'
or lcase(concept_name) like '%ipragliflozin%'
or lcase(concept_name) like '%sotagliflozin%') THEN 1 ELSE 0
END AS rx_baseline_sglt2, 

CASE WHEN /*other non-insulin drugs*/
(lcase(concept_name) like '%guar gum%'
or lcase(concept_name) like '%repaglinide%'
or lcase(concept_name) like '%nateglinide%'
or lcase(concept_name) like '%pramlintide%'
or lcase(concept_name) like '%benfluorex%'
or lcase(concept_name) like '%mitiglinide%') THEN 1 ELSE 0
END AS rx_baseline_dm_other,

CASE WHEN (/*renal disease*/
lcase(concept_name) like '%erythropoietin%'
or lcase(concept_name) like '%darbepoetin alfa%'
or lcase(concept_name) like '%methoxy polyethylene glycol-epoetin beta%'
or lcase(concept_name) like '%ergocalciferol%'
or lcase(concept_name) like '%dihydrotachysterol%'
or lcase(concept_name) like '%alfacalcidol%'
or lcase(concept_name) like '%calcitriol%'
or lcase(concept_name) like '%sevelamer%'
or lcase(concept_name) like '%lanthanum carbonate%'
or lcase(concept_name) like '%sucroferric oxyhydroxide%' ) THEN 1 ELSE 0
END AS rx_baseline_renal, 

CASE WHEN (/*obesity*/
lcase(concept_name) like '%orlistat%'
or lcase(concept_name) like '%lorcaserin%'
or lcase(concept_name) like '%phentermine%'
or lcase(concept_name) like '%naltrexone%'
or lcase(concept_name) like '%liraglutide%') THEN 1 ELSE 0
END AS rx_baseline_obesity

FROM rx_covariate_concepts r
INNER JOIN drug_exposure d
    on d.drug_concept_id=r.concept_id

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.57e31b83-4641-484f-8138-d706e8f9e6b4"),
    rx_covariates_baseline=Input(rid="ri.foundry.main.dataset.4877fa16-22fe-48e0-a8e5-eed66e7bc5b2")
)
SELECT person_id,
    SUM (rx_baseline_chf) as rx_baseline_chf_sum,
    SUM (rx_baseline_dementia) as rx_baseline_dementia_sum,
    SUM (rx_baseline_insulin) as rx_baseline_insulin_sum,
    SUM (rx_baseline_metformin) as rx_baseline_metformin_sum,
    SUM (rx_baseline_sulfonylurea) as rx_baseline_sulfonylurea_sum,
    SUM (rx_baseline_acarbose) as rx_baseline_acarbose_sum,
    SUM (rx_baseline_tzd) as rx_baseline_tzd_sum, 
    SUM (rx_baseline_dpp4) as rx_baseline_dpp4_sum,
    SUM (rx_baseline_glp1) as rx_baseline_glp1_sum,
    SUM (rx_baseline_sglt2) as rx_baseline_sglt2_sum,
    SUM (rx_baseline_dm_other) as rx_baseline_dm_other_sum, 
    SUM (rx_baseline_obesity) as rx_baseline_obesity_sum,
    SUM (rx_baseline_laba) as rx_baseline_laba_sum,
    SUM (rx_baseline_inhaled_cs) as rx_baseline_inhaled_cs_sum,
    SUM (rx_baseline_saba) as rx_baseline_saba_sum,
    SUM (rx_baseline_leukotriene) as rx_baseline_leukotriene_sum,
    SUM (rx_baseline_other_pulm) as rx_baseline_other_pulm_sum, 
    SUM (rx_baseline_renal) as rx_baseline_renal_sum
FROM rx_covariates_baseline    
    GROUP BY person_id

