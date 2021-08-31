

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad"),
    Final_cohort=Input(rid="ri.foundry.main.dataset.8608fdc2-8890-4ad1-a3cc-5e11ac62782f")
)
Final_cohort_R <- function(Final_cohort) {
    library(dplyr)

    df <- Final_cohort %>%
        mutate(weeks_since_jan1_2020 = as.factor(weeks_since_jan1_2020)) %>%
        mutate(data_partner_id = as.factor(data_partner_id))
    return(df)
}

@transform_pandas(
    Output(rid="ri.vector.main.execute.cfc1d202-12f0-4c7a-b3df-0cc0c54506f7")
)

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.9d39cce2-4914-4a54-bebf-e9e3da6c2818"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
JAK_subset_for_counts <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, jak_inhibitor==1 | is.na(jak_inhibitor)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.d54a74a7-dbe3-4830-b6cc-8795f08c9e10"),
    matching_anthracyclines=Input(rid="ri.foundry.main.dataset.6190a5fd-bc6c-415b-90a1-95f1d609dec5")
)
anthracyclines <- function(matching_anthracyclines) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
  
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + as.factor(weeks_since_jan1_2020) + as.factor(data_partner_id) + age + mets, 
    data=matching_anthracyclines, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.fa13de6c-5d10-4572-84fd-1e5c25b77bc2"),
    matching_anthracyclines=Input(rid="ri.foundry.main.dataset.6190a5fd-bc6c-415b-90a1-95f1d609dec5")
)
anthracyclines_balance <- function(matching_anthracyclines) {
   library(tableone)
   library(tidyverse) 

small <- matching_anthracyclines %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.d4ca19d0-782d-4c0c-ae67-51d5e2ced55b"),
    matching_azathioprine=Input(rid="ri.foundry.main.dataset.4a9994a3-2326-4da0-a559-88d6bfe628b8")
)
azathioprine <- function(matching_azathioprine) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
#death1discharge0 has the 1% trimmed survival events (1% censored, if they died >241 days as of May 12)
#time_death_discharge has the trimmed survival times (1% censored at 241 days)     
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + as.factor(weeks_since_jan1_2020) + as.factor(data_partner_id) + transplant_any, 
    data=matching_azathioprine, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.90f61eef-80da-4198-85b8-e42397e3825c"),
    matching_azathioprine=Input(rid="ri.foundry.main.dataset.4a9994a3-2326-4da0-a559-88d6bfe628b8")
)
azathioprine_balance <- function(matching_azathioprine) {
   library(tableone)
   library(tidyverse) 

small <- matching_azathioprine %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.198c5ae3-8631-4962-9db8-cd3a04d3f093"),
    matching_calcineurin_inhibitor=Input(rid="ri.foundry.main.dataset.f12d2277-0e1f-4e0b-b036-74d2cea2ae78")
)
calcineurin_balance <- function(matching_calcineurin_inhibitor) {
   library(tableone)
   library(tidyverse) 

small <- matching_calcineurin_inhibitor %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.9d7c6d82-8fee-4573-8bd6-ad1e779b32e1"),
    matching_calcineurin_inhibitor=Input(rid="ri.foundry.main.dataset.f12d2277-0e1f-4e0b-b036-74d2cea2ae78")
)
calcineurin_inhibitors <- function(matching_calcineurin_inhibitor) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
    
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + transplant_any + as.factor(data_partner_id) + renal + as.factor(weeks_since_jan1_2020) + liversevere + liver_mild + age + rx_insulin + missing_bmi, 
    data=matching_calcineurin_inhibitor, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4b20d6a6-3026-401b-a0b3-1ef74661082d"),
    matching_checkpoint=Input(rid="ri.foundry.main.dataset.7f5045da-831b-4980-a3c6-df5574213e63")
)
checkpoint_balance <- function(matching_checkpoint) {
   library(tableone)
   library(tidyverse) 

#Removed cancer from model: perfectly predicted
small <- matching_checkpoint %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.625bb6d6-befd-4c8b-a504-e6e3c3f7ee99"),
    matching_checkpoint=Input(rid="ri.foundry.main.dataset.7f5045da-831b-4980-a3c6-df5574213e63")
)
checkpoint_inhibitors <- function(matching_checkpoint) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
  
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag 
    + as.factor(weeks_since_jan1_2020) + mets + as.factor(data_partner_id) + pulmonary + liver_mild + rx_tzd + rx_dm_other + rx_metformin + rx_sulfonylurea + rx_renal + dementia + asian, 
    data=matching_checkpoint, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4ae0d7f8-fe62-47b9-8349-6506e91f1c2d"),
    matching_checkpoint=Input(rid="ri.foundry.main.dataset.7f5045da-831b-4980-a3c6-df5574213e63")
)
checkpoint_vent <- function(matching_checkpoint) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

matching_checkpoint$data_partner_id <- as.factor(matching_checkpoint$data_partner_id)
matching_checkpoint$weeks_since_jan1_2020 <- as.factor(matching_checkpoint$weeks_since_jan1_2020)

small <- matching_checkpoint %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    weeks_since_jan1_2020, mets, data_partner_id, pulmonary, liver_mild, rx_tzd, rx_dm_other, rx_metformin, rx_sulfonylurea, rx_renal, dementia, asian)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:16],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.696de187-caf2-4ec5-bab5-019c49b2d0af"),
    matching_cyclophosphamide=Input(rid="ri.foundry.main.dataset.7c90c492-47b8-47d4-9ff2-40da85fcd836")
)
cyclophosphamide <- function(matching_cyclophosphamide) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
 
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag 
    + as.factor(weeks_since_jan1_2020) + as.factor(data_partner_id) + diabetes
    , 
    data=matching_cyclophosphamide, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.bc1c5ee9-dffc-46f3-8e30-cb4a566f2445"),
    matching_cyclophosphamide=Input(rid="ri.foundry.main.dataset.7c90c492-47b8-47d4-9ff2-40da85fcd836")
)
cyclophosphamide_balance <- function(matching_cyclophosphamide) {
   library(tableone)
   library(tidyverse) 

small <- matching_cyclophosphamide %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.100c79ef-22a4-413a-a50c-2e5e2bf11283"),
    matching_gluco_rheum=Input(rid="ri.foundry.main.dataset.3a0c14e9-f909-495d-a789-e970884c345a")
)
gluco_balance_rheum <- function(matching_gluco_rheum) {
   library(tableone)
   library(tidyverse) 

small <- matching_gluco_rheum %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.52989384-01a0-4a0f-9556-38ec7e401aae"),
    matching_gluco_sot=Input(rid="ri.foundry.main.dataset.37c8b605-abf1-4912-92f5-da034087950c")
)
gluco_balance_sot <- function(matching_gluco_sot) {
   library(tableone)
   library(tidyverse) 

small <- matching_gluco_sot %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.a8e914f1-9250-4f1b-92ce-85fb1410641e"),
    matching_gluco_rheum=Input(rid="ri.foundry.main.dataset.3a0c14e9-f909-495d-a789-e970884c345a")
)
gluco_death_rheum <- function(matching_gluco_rheum) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
 
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + rheumatic + as.factor(data_partner_id) + as.factor(weeks_since_jan1_2020)
    , 
    data=matching_gluco_rheum, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.729256b0-9afb-439b-abe2-fa367fb93151"),
    matching_gluco_sot=Input(rid="ri.foundry.main.dataset.37c8b605-abf1-4912-92f5-da034087950c")
)
gluco_death_sot <- function(matching_gluco_sot) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
 
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag +
    as.factor(data_partner_id) + as.factor(weeks_since_jan1_2020) + renal + missing_bmi
    , 
    data=matching_gluco_sot, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.a45cf68c-9227-4af0-b37e-854070a71051"),
    subset_gluco=Input(rid="ri.foundry.main.dataset.dd76d631-67e1-42ea-aa8b-01be420b35ff")
)
gluco_rheum <- function(subset_gluco) {
    library(dplyr)

    filter (subset_gluco, 
        immuno_flag==0 | (glucocorticoid==1 & rheumatic==1) | (glucocorticoid==1 & psoriasis==1) |  (glucocorticoid==1 & colitis==1) | 
                        (glucocorticoid==1 & rheum_arthritis==1) | (glucocorticoid==1 & lupus==1) | (glucocorticoid==1 & vasculitis==1) |
                        (glucocorticoid==1 & as_axspa==1) | (glucocorticoid==1 & psa==1) )     
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.e42a8c1e-85be-4d49-8749-50af8f1f5ff2"),
    subset_gluco=Input(rid="ri.foundry.main.dataset.dd76d631-67e1-42ea-aa8b-01be420b35ff")
)
gluco_sot <- function(subset_gluco) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (subset_gluco, immuno_flag==0 | (glucocorticoid==1 & transplant_any==1))     
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.80342327-0751-435b-9372-3c99b1713c23"),
    matching_il_inhibitor=Input(rid="ri.foundry.main.dataset.19b921fc-4a05-4e41-8b16-811741bbb20e")
)
il_inhibitor_balance <- function(matching_il_inhibitor) {
   library(tableone)
   library(tidyverse) 

small <- matching_il_inhibitor %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.2725ee32-14f2-4609-865e-9e08b311e813"),
    matching_il_inhibitor=Input(rid="ri.foundry.main.dataset.19b921fc-4a05-4e41-8b16-811741bbb20e")
)
il_inhibitors <- function(matching_il_inhibitor) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
  
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + as.factor(weeks_since_jan1_2020) + as.factor(data_partner_id) + transplant_any + liver_mild + dmcx + rx_renal, 
    data=matching_il_inhibitor, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.a6aa35bd-337a-4b6c-82e1-88454ca58717"),
    matching_jak=Input(rid="ri.foundry.main.dataset.af52861c-7b91-4a75-9062-05a018886dc6")
)
jak <- function(matching_jak) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
#death1discharge0 has the 1% trimmed survival events (1% censored, if they died >241 days as of May 12)
#time_death_discharge has the trimmed survival times (1% censored at 241 days)     
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag 
    + as.factor(data_partner_id) + as.factor(weeks_since_jan1_2020) + rx_glp1 + mets + rx_saba + normal_weight + nonhisp_white + renal + rx_laba, 
    data=matching_jak, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.2fda6f7a-001f-46b9-ac14-5fb569415ff6"),
    matching_jak=Input(rid="ri.foundry.main.dataset.af52861c-7b91-4a75-9062-05a018886dc6")
)
jak_balance <- function(matching_jak) {
   library(tableone)
   library(tidyverse) 

small <- matching_jak %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.0bd1c04b-34ef-4f48-a994-9afdb012cb7e"),
    matching_l01_other=Input(rid="ri.foundry.main.dataset.ce8cdf42-bf7b-459a-9eb0-b084628297d7")
)
l01_other <- function(matching_l01_other) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
 
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + mets + as.factor(data_partner_id) + cancer + weeks_since_jan1_2020
    , 
    data=matching_l01_other, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.988fa8e7-3012-4707-b36d-705c9da6aeb7"),
    matching_l01_other=Input(rid="ri.foundry.main.dataset.ce8cdf42-bf7b-459a-9eb0-b084628297d7")
)
l01_other_balance <- function(matching_l01_other) {
   library(tableone)
   library(tidyverse) 

small <- matching_l01_other %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.ac909d0b-0891-4ab6-b4f0-900fd947eb1b"),
    matching_l04_other=Input(rid="ri.foundry.main.dataset.598b453f-5f3d-445e-8c0d-5cb6575a42b8")
)
l04_other <- function(matching_l04_other) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
 
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + transplant_any + rx_renal + as.factor(data_partner_id) + as.factor(weeks_since_jan1_2020) + renal, 
    data=matching_l04_other, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.e1f9230b-64f4-4acf-a0e5-5c49848eab23"),
    matching_l04_other=Input(rid="ri.foundry.main.dataset.598b453f-5f3d-445e-8c0d-5cb6575a42b8")
)
l04_other_balance <- function(matching_l04_other) {
   library(tableone)
   library(tidyverse) 

small <- matching_l04_other %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6190a5fd-bc6c-415b-90a1-95f1d609dec5"),
    subset_anthracyclines=Input(rid="ri.foundry.main.dataset.de341b92-bfda-4211-bfec-45af4f29c341")
)
matching_anthracyclines <- function(subset_anthracyclines) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = subset_anthracyclines,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4a9994a3-2326-4da0-a559-88d6bfe628b8"),
    subset_azathioprine=Input(rid="ri.foundry.main.dataset.62fa8905-e3d7-4847-be80-9acf5d07680e")
)
matching_azathioprine <- function(subset_azathioprine) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = subset_azathioprine,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.f12d2277-0e1f-4e0b-b036-74d2cea2ae78"),
    subset_calcineurin_inhibitor=Input(rid="ri.foundry.main.dataset.63448438-2ed4-48b8-bd1b-611454c81429")
)
matching_calcineurin_inhibitor <- function(subset_calcineurin_inhibitor) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = subset_calcineurin_inhibitor,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.7f5045da-831b-4980-a3c6-df5574213e63"),
    subset_checkpoint_inhibitor=Input(rid="ri.foundry.main.dataset.802a507c-98e6-43a6-b6a0-95274201d4d4")
)
matching_checkpoint <- function(subset_checkpoint_inhibitor) {
    library(MatchIt)

#removing cancer from the model: the SMD was > 1000% which was really skewing everything, and checkpoint inhibitors are singular in indication

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + 
cancer + 
liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = subset_checkpoint_inhibitor,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.7c90c492-47b8-47d4-9ff2-40da85fcd836"),
    subset_cyclophosphamide=Input(rid="ri.foundry.main.dataset.399895c8-da0d-40d0-9a51-9cf3de72abd1")
)
matching_cyclophosphamide <- function(subset_cyclophosphamide) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = subset_cyclophosphamide,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.3a0c14e9-f909-495d-a789-e970884c345a"),
    gluco_rheum=Input(rid="ri.foundry.main.dataset.a45cf68c-9227-4af0-b37e-854070a71051")
)
matching_gluco_rheum <- function(gluco_rheum) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = gluco_rheum,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.37c8b605-abf1-4912-92f5-da034087950c"),
    gluco_sot=Input(rid="ri.foundry.main.dataset.e42a8c1e-85be-4d49-8749-50af8f1f5ff2")
)
matching_gluco_sot <- function(gluco_sot) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = gluco_sot,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.19b921fc-4a05-4e41-8b16-811741bbb20e"),
    subset_il_inhibitor=Input(rid="ri.foundry.main.dataset.3d8c8ed3-b9d7-407e-8051-11570a9dda85")
)
matching_il_inhibitor <- function(subset_il_inhibitor) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = subset_il_inhibitor,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.af52861c-7b91-4a75-9062-05a018886dc6"),
    JAK_subset_for_counts=Input(rid="ri.foundry.main.dataset.9d39cce2-4914-4a54-bebf-e9e3da6c2818")
)
matching_jak <- function(JAK_subset_for_counts) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = JAK_subset_for_counts,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.ce8cdf42-bf7b-459a-9eb0-b084628297d7"),
    subset_l01_other=Input(rid="ri.foundry.main.dataset.b00884f2-2d24-432f-912c-05c1debdac65")
)
matching_l01_other <- function(subset_l01_other) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = subset_l01_other,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.598b453f-5f3d-445e-8c0d-5cb6575a42b8"),
    subset_l04_other=Input(rid="ri.foundry.main.dataset.7f1c93b0-3fb4-4910-99f8-5cba59322ca7")
)
matching_l04_other <- function(subset_l04_other) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = subset_l04_other,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.8a4d539d-82d9-4c1e-baef-7b534529b022"),
    subset_monoclonal_other=Input(rid="ri.foundry.main.dataset.1d82bde8-7fcc-41f1-acc4-9abb5cee074b")
)
matching_monoclonal_other <- function(subset_monoclonal_other) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = subset_monoclonal_other,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.752996c1-7fc6-4614-8f32-091e7ba377a3"),
    subset_mycophenol=Input(rid="ri.foundry.main.dataset.f28369d9-d794-4c6a-9c7a-3ad4c3d7981c")
)
matching_mycophenol <- function(subset_mycophenol) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = subset_mycophenol,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.7a97dee4-06f2-4621-b6c9-7fabfb79c8ac"),
    subset_pk_inhibitor=Input(rid="ri.foundry.main.dataset.fb91279b-f411-4a57-bed5-a63b6275ea23")
)
matching_pk_inhibitor <- function(subset_pk_inhibitor) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = subset_pk_inhibitor,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4f8d9067-9fb3-480c-a1cc-54633fa8ec31"),
    ritux_cancer=Input(rid="ri.foundry.main.dataset.257a1249-bacb-44a6-81f0-143f7a0bf1e4")
)
matching_rituximab_cancer <- function(ritux_cancer) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = ritux_cancer,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.5afee16d-66c1-4af8-975a-524c564ee09a"),
    ritux_rheum=Input(rid="ri.foundry.main.dataset.a38bf930-2b24-4c9e-97ea-73fec63b5543")
)
matching_rituximab_rheum <- function(ritux_rheum) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = ritux_rheum,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.95738595-32d3-4b34-aeec-ee7583dc8178"),
    subset_tnf_inhibitor=Input(rid="ri.foundry.main.dataset.f3387041-791d-4ba7-ae0e-4363dbc33787")
)
matching_tnf_inhibitor <- function(subset_tnf_inhibitor) {
    library(MatchIt)

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = subset_tnf_inhibitor,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.ecc66258-f762-4584-a0f7-db65be2c1f96"),
    matching_monoclonal_other=Input(rid="ri.foundry.main.dataset.8a4d539d-82d9-4c1e-baef-7b534529b022")
)
monoclonal_other <- function(matching_monoclonal_other){
    library("survival")
    library(MatchIt)
    library(tidyverse)
   
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag 
    + as.factor(weeks_since_jan1_2020) + mets + as.factor(data_partner_id) 
    , 
    data=matching_monoclonal_other, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.52339249-1fd2-4713-8c8a-384e3034a64a"),
    matching_monoclonal_other=Input(rid="ri.foundry.main.dataset.8a4d539d-82d9-4c1e-baef-7b534529b022")
)
monoclonal_other_balance <- function(matching_monoclonal_other) {
   library(tableone)
   library(tidyverse) 

small <- matching_monoclonal_other %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.f1fb34ed-2176-4bc9-b514-d68c03fa630a"),
    matching_mycophenol=Input(rid="ri.foundry.main.dataset.752996c1-7fc6-4614-8f32-091e7ba377a3")
)
mycophenol_balance <- function(matching_mycophenol) {
   library(tableone)
   library(tidyverse) 

small <- matching_mycophenol %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.cdcaacd9-94d3-4ea6-ad83-2e953a96629d"),
    matching_mycophenol=Input(rid="ri.foundry.main.dataset.752996c1-7fc6-4614-8f32-091e7ba377a3")
)
mycophenolate <- function(matching_mycophenol) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
 
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + transplant_any + as.factor(data_partner_id) + renal  + rx_renal + as.factor(weeks_since_jan1_2020) + liver_mild + rheumatic + rx_insulin
    , 
    data=matching_mycophenol, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.5da460b8-4aed-4fca-991b-67d8cf4ca93f"),
    matching_pk_inhibitor=Input(rid="ri.foundry.main.dataset.7a97dee4-06f2-4621-b6c9-7fabfb79c8ac")
)
pk_inhibitors <- function(matching_pk_inhibitor) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
#death1discharge0 has the 1% trimmed survival events (1% censored, if they died >241 days as of May 12)
#time_death_discharge has the trimmed survival times (1% censored at 241 days)     
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
     + as.factor(weeks_since_jan1_2020) + transplant_any + as.factor(data_partner_id), 
    data=matching_pk_inhibitor, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.77b36dce-87c2-4ca7-8caa-a6c67d6bf247"),
    matching_pk_inhibitor=Input(rid="ri.foundry.main.dataset.7a97dee4-06f2-4621-b6c9-7fabfb79c8ac")
)
pki_balance <- function(matching_pk_inhibitor) {
   library(tableone)
   library(tidyverse) 

small <- matching_pk_inhibitor %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.257a1249-bacb-44a6-81f0-143f7a0bf1e4"),
    subset_rituximab=Input(rid="ri.foundry.main.dataset.dc4ec2a3-5c6e-48ed-9959-1731efe0585a")
)
ritux_cancer <- function(subset_rituximab) {
    library(dplyr)

    filter (subset_rituximab, 
        immuno_flag==0 | (rituximab==1 & cancer==1) | (rituximab==1 & mets==1) )     
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.a38bf930-2b24-4c9e-97ea-73fec63b5543"),
    subset_rituximab=Input(rid="ri.foundry.main.dataset.dc4ec2a3-5c6e-48ed-9959-1731efe0585a")
)
ritux_rheum <- function(subset_rituximab) {
    library(dplyr)

    filter (subset_rituximab, 
        immuno_flag==0 | (rituximab==1 & rheumatic==1) | (rituximab==1 & psoriasis==1) |  (rituximab==1 & colitis==1) | 
                        (rituximab==1 & rheum_arthritis==1) | (rituximab==1 & lupus==1) | (rituximab==1 & vasculitis==1) |
                        (rituximab==1 & as_axspa==1) | (rituximab==1 & psa==1) )     
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.3898a400-3685-4ebd-8070-fbaaf59d0497"),
    matching_rituximab_cancer=Input(rid="ri.foundry.main.dataset.4f8d9067-9fb3-480c-a1cc-54633fa8ec31")
)
rituximab_Death_cancer <- function(matching_rituximab_cancer){
    library("survival")
    library(MatchIt)
 
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + as.factor(weeks_since_jan1_2020) + as.factor(data_partner_id) + male, 
    data=matching_rituximab_cancer, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4b8fdbd6-df9e-4da1-9950-e2fcd58ed1b8"),
    matching_rituximab_rheum=Input(rid="ri.foundry.main.dataset.5afee16d-66c1-4af8-975a-524c564ee09a")
)
rituximab_Death_rheum <- function(matching_rituximab_rheum){
    library("survival")
    library(MatchIt)
 
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + as.factor(weeks_since_jan1_2020) + as.factor(data_partner_id) + overweight + rx_sulfonylurea + asian + rx_dpp4 + obese + stroke, 
    data=matching_rituximab_rheum, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4e552038-d38e-4380-ae19-b62628bea60b"),
    matching_rituximab_cancer=Input(rid="ri.foundry.main.dataset.4f8d9067-9fb3-480c-a1cc-54633fa8ec31")
)
rituximab_balance_cancer <- function(matching_rituximab_cancer) {
   library(tableone)
   library(tidyverse) 

small <- matching_rituximab_cancer %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.a5648eb8-d9e5-4615-9242-a4de03d9a8d9"),
    matching_rituximab_rheum=Input(rid="ri.foundry.main.dataset.5afee16d-66c1-4af8-975a-524c564ee09a")
)
rituximab_balance_rheum <- function(matching_rituximab_rheum) {
   library(tableone)
   library(tidyverse) 

small <- matching_rituximab_rheum %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.de341b92-bfda-4211-bfec-45af4f29c341"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_anthracyclines <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, anthracyclines==1 | is.na(anthracyclines))  
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.62fa8905-e3d7-4847-be80-9acf5d07680e"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_azathioprine <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, azathioprine==1 | is.na(azathioprine))  
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.63448438-2ed4-48b8-bd1b-611454c81429"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_calcineurin_inhibitor <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, calcineurin_inhibitor==1 | is.na(calcineurin_inhibitor)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.802a507c-98e6-43a6-b6a0-95274201d4d4"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_checkpoint_inhibitor <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, checkpoint_inhibitor==1 | is.na(checkpoint_inhibitor))  
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.399895c8-da0d-40d0-9a51-9cf3de72abd1"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_cyclophosphamide <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, cyclophosphamide==1 | is.na(cyclophosphamide)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.dd76d631-67e1-42ea-aa8b-01be420b35ff"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_gluco <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, glucocorticoid==1 | is.na(glucocorticoid)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.3d8c8ed3-b9d7-407e-8051-11570a9dda85"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_il_inhibitor <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, il_inhibitor==1 | is.na(il_inhibitor)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.b00884f2-2d24-432f-912c-05c1debdac65"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_l01_other <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, l01_other==1 | is.na(l01_other))  
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.7f1c93b0-3fb4-4910-99f8-5cba59322ca7"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_l04_other <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, l04_other==1 | is.na(l04_other)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.1d82bde8-7fcc-41f1-acc4-9abb5cee074b"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_monoclonal_other <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, monoclonal_other==1 | is.na(monoclonal_other)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.f28369d9-d794-4c6a-9c7a-3ad4c3d7981c"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_mycophenol <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, mycophenol==1 | is.na(mycophenol)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.fb91279b-f411-4a57-bed5-a63b6275ea23"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_pk_inhibitor <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, pk_inhibitor==1 | is.na(pk_inhibitor)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.dc4ec2a3-5c6e-48ed-9959-1731efe0585a"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_rituximab <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, rituximab==1 | is.na(rituximab))  
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.f3387041-791d-4ba7-ae0e-4363dbc33787"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.c752ab58-4b08-4731-a6d1-4cca041fc5ad")
)
subset_tnf_inhibitor <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have a TNF will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, tnf_inhibitor==1 | is.na(tnf_inhibitor)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.10181ce3-1cd8-40f1-adb0-c3d241f8245b"),
    matching_tnf_inhibitor=Input(rid="ri.foundry.main.dataset.95738595-32d3-4b34-aeec-ee7583dc8178")
)
tnf <- function(matching_tnf_inhibitor) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
    
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + as.factor(weeks_since_jan1_2020) + as.factor(data_partner_id), 
    data=matching_tnf_inhibitor, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6c99e266-17f0-4c04-b585-4ecff9140a46"),
    matching_tnf_inhibitor=Input(rid="ri.foundry.main.dataset.95738595-32d3-4b34-aeec-ee7583dc8178")
)
tnf_balance <- function(matching_tnf_inhibitor) {
   library(tableone)
   library(tidyverse) 

small <- matching_tnf_inhibitor %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba", "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
     "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.000951ca-350d-4748-81c0-47d2bf477bd5"),
    matching_anthracyclines=Input(rid="ri.foundry.main.dataset.6190a5fd-bc6c-415b-90a1-95f1d609dec5")
)
vent_anthracyclines <- function(matching_anthracyclines) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_anthracyclines %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    weeks_since_jan1_2020, data_partner_id, age, mets 
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:8],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.7ad9e9b7-9334-487b-9af2-0b6b9b3882be"),
    matching_azathioprine=Input(rid="ri.foundry.main.dataset.4a9994a3-2326-4da0-a559-88d6bfe628b8")
)
vent_azathioprine <- function(matching_azathioprine) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_azathioprine %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    weeks_since_jan1_2020, data_partner_id, transplant_any 
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:7],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.5d756a04-d606-437c-8564-36a72f9ad74d"),
    matching_calcineurin_inhibitor=Input(rid="ri.foundry.main.dataset.f12d2277-0e1f-4e0b-b036-74d2cea2ae78")
)
vent_calcineurin <- function(matching_calcineurin_inhibitor) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_calcineurin_inhibitor %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    transplant_any, data_partner_id, renal, rx_renal, weeks_since_jan1_2020, liversevere, liver_mild, age, rx_insulin, missing_bmi 
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:14],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.8d6da753-a62c-450e-a93a-a012d3dca2ad"),
    matching_cyclophosphamide=Input(rid="ri.foundry.main.dataset.7c90c492-47b8-47d4-9ff2-40da85fcd836")
)
vent_cyclophosphamide <- function(matching_cyclophosphamide) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_cyclophosphamide %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    weeks_since_jan1_2020, data_partner_id, diabetes
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:7],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.45e29ac0-89f5-4c00-9519-a1ef7a5b0454"),
    matching_gluco_sot=Input(rid="ri.foundry.main.dataset.37c8b605-abf1-4912-92f5-da034087950c")
)
vent_gluco_SOT <- function(matching_gluco_sot) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_gluco_sot %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    data_partner_id, weeks_since_jan1_2020, missing_bmi
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:7],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.d5c372b0-c3ae-43a1-ae94-2b166e1e1fb7"),
    matching_gluco_rheum=Input(rid="ri.foundry.main.dataset.3a0c14e9-f909-495d-a789-e970884c345a")
)
vent_gluco_rheum <- function(matching_gluco_rheum) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_gluco_rheum %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    rheumatic, data_partner_id, weeks_since_jan1_2020
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:7],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.d13e7f0a-542a-4fdf-bd00-26d1d383e01d"),
    matching_il_inhibitor=Input(rid="ri.foundry.main.dataset.19b921fc-4a05-4e41-8b16-811741bbb20e")
)
vent_il <- function(matching_il_inhibitor) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_il_inhibitor %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    weeks_since_jan1_2020, data_partner_id, transplant_any, liver_mild, dmcx, rx_renal
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:9],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.23c603a0-10ce-4573-95a8-1971b5148b6a"),
    matching_jak=Input(rid="ri.foundry.main.dataset.af52861c-7b91-4a75-9062-05a018886dc6")
)
vent_jak <- function(matching_jak) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_jak %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    data_partner_id, weeks_since_jan1_2020, rx_glp1, mets, rx_saba, normal_weight, nonhisp_white, renal, rx_laba
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:13],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.db5f29f1-05e9-4814-a86e-17223d1a3a6b"),
    matching_l01_other=Input(rid="ri.foundry.main.dataset.ce8cdf42-bf7b-459a-9eb0-b084628297d7")
)
vent_l01_other <- function(matching_l01_other) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_l01_other %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    mets, data_partner_id, cancer, weeks_since_jan1_2020
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:7],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.7b2a9ce2-78a0-44ef-a7d9-cdc815449d13"),
    matching_l04_other=Input(rid="ri.foundry.main.dataset.598b453f-5f3d-445e-8c0d-5cb6575a42b8")
)
vent_l04_other <- function(matching_l04_other) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_l04_other %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    transplant_any, rx_renal, data_partner_id, weeks_since_jan1_2020, renal 
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:9],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.27c9a92d-3576-4f61-b1f2-f4f9c0b5bef1"),
    matching_monoclonal_other=Input(rid="ri.foundry.main.dataset.8a4d539d-82d9-4c1e-baef-7b534529b022")
)
vent_mab <- function(matching_monoclonal_other) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_monoclonal_other %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    weeks_since_jan1_2020, mets, data_partner_id
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:7],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4d9d7e2d-0fd8-44e4-a902-e2bf26f52854"),
    matching_mycophenol=Input(rid="ri.foundry.main.dataset.752996c1-7fc6-4614-8f32-091e7ba377a3")
)
vent_mycophenol <- function(matching_mycophenol) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_mycophenol %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    transplant_any, data_partner_id, renal, rx_renal, weeks_since_jan1_2020, liver_mild, rheumatic, rx_insulin
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:12],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.52146a89-abd5-4691-a40e-5501faf146cb"),
    matching_pk_inhibitor=Input(rid="ri.foundry.main.dataset.7a97dee4-06f2-4621-b6c9-7fabfb79c8ac")
)
vent_pk <- function(matching_pk_inhibitor) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_pk_inhibitor %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    weeks_since_jan1_2020, transplant_any, data_partner_id 
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:7],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.3f31d5ae-5d31-415c-a543-4e9bf770c2f3"),
    matching_rituximab_cancer=Input(rid="ri.foundry.main.dataset.4f8d9067-9fb3-480c-a1cc-54633fa8ec31")
)
vent_rituximab_cancer <- function(matching_rituximab_cancer) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_rituximab_cancer %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    weeks_since_jan1_2020, data_partner_id, male 
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:7],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.c8d562db-57a0-4dcb-a0bf-0571ffb4881d"),
    matching_rituximab_rheum=Input(rid="ri.foundry.main.dataset.5afee16d-66c1-4af8-975a-524c564ee09a")
)
vent_rituximab_rheum <- function(matching_rituximab_rheum) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_rituximab_rheum %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    weeks_since_jan1_2020, data_partner_id, overweight, rx_sulfonylurea, rheumatic, asian, rx_dpp4, obese, stroke 
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:13],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.eb9e42b8-329b-4476-b236-8df85104de48"),
    matching_tnf_inhibitor=Input(rid="ri.foundry.main.dataset.95738595-32d3-4b34-aeec-ee7583dc8178")
)
vent_tnf <- function(matching_tnf_inhibitor) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_tnf_inhibitor %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    weeks_since_jan1_2020, data_partner_id 
)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:6],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

