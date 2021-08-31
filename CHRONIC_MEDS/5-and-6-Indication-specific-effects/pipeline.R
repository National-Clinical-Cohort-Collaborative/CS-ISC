

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.265d0a15-1533-44f8-9295-e8133b50ec37"),
    matching_any_cancer=Input(rid="ri.foundry.main.dataset.24cad684-305c-4e0f-865c-e0cdf6474689")
)
Cancer_death <- function(matching_any_cancer) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
   
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + mets + cancer + as.factor(data_partner_id) + liver_mild, 
    data=matching_any_cancer, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6eee013a-e307-4d7e-a944-df16866118f0"),
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
    Output(rid="ri.foundry.main.dataset.0d3e9220-841e-4e83-a283-aa52140efe7d"),
    matching_any_rheum=Input(rid="ri.foundry.main.dataset.01984365-a6d6-40b1-b211-f1e697b61a7a")
)
any_rheum_vent <- function(matching_any_rheum) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_any_rheum %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    transplant_any, renal, data_partner_id, rx_renal, weeks_since_jan1_2020 
)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:9],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.47612336-a616-414b-983d-4742a7521739"),
    matching_any_cancer=Input(rid="ri.foundry.main.dataset.24cad684-305c-4e0f-865c-e0cdf6474689")
)
cancer_balance <- function(matching_any_cancer) {
   library(tableone)
   library(tidyverse) 

small <- matching_any_cancer %>%
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
    Output(rid="ri.foundry.main.dataset.24cad684-305c-4e0f-865c-e0cdf6474689"),
    subset_any_cancer=Input(rid="ri.foundry.main.dataset.24e8498a-74a6-430e-a82e-de4895ae4921")
)
matching_any_cancer <- function(subset_any_cancer) {
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
        data = subset_any_cancer,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.01984365-a6d6-40b1-b211-f1e697b61a7a"),
    subset_any_rheum=Input(rid="ri.foundry.main.dataset.5cb82214-723e-4d2d-a6a4-46d7026df84f")
)
matching_any_rheum <- function(subset_any_rheum) {
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
        data = subset_any_rheum,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.96989e3a-a6f2-40a4-b15b-436c4b0a2e92"),
    subset_any_sot=Input(rid="ri.foundry.main.dataset.cfc2c66d-6b39-4dc4-ba08-3e99f1275bc2")
)
matching_any_sot <- function(subset_any_sot) {
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
        data = subset_any_sot,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.e985fb80-9909-496f-bf82-522035c23c2c"),
    matching_any_rheum=Input(rid="ri.foundry.main.dataset.01984365-a6d6-40b1-b211-f1e697b61a7a")
)
rheum_balance_2 <- function(matching_any_rheum) {
   library(tableone)
   library(tidyverse) 

small <- matching_any_rheum %>%
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
    Output(rid="ri.foundry.main.dataset.a1d3c0a2-e668-49f7-9b92-d6af408e3d77"),
    matching_any_rheum=Input(rid="ri.foundry.main.dataset.01984365-a6d6-40b1-b211-f1e697b61a7a")
)
rheum_death <- function(matching_any_rheum) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
    
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + transplant_any + as.factor(data_partner_id) + renal  + rx_renal + as.factor(weeks_since_jan1_2020) , 
    data=matching_any_rheum, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.2d217c8b-4e5f-4718-b809-8069459b52b0"),
    matching_any_sot=Input(rid="ri.foundry.main.dataset.96989e3a-a6f2-40a4-b15b-436c4b0a2e92")
)
sot_balance <- function(matching_any_sot) {
   library(tableone)
   library(tidyverse)

small <- matching_any_sot %>%
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
    Output(rid="ri.foundry.main.dataset.7966a490-3358-4020-9588-d60373ad6c55"),
    matching_any_sot=Input(rid="ri.foundry.main.dataset.96989e3a-a6f2-40a4-b15b-436c4b0a2e92")
)
sot_death <- function(matching_any_sot) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
   
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + transplant_any + renal + as.factor(data_partner_id) + rx_renal + rx_insulin + as.factor(weeks_since_jan1_2020) + liversevere + liver_mild, 
    data=matching_any_sot, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.24e8498a-74a6-430e-a82e-de4895ae4921"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.6eee013a-e307-4d7e-a944-df16866118f0")
)
subset_any_cancer <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, anthracyclines==1 | checkpoint_inhibitor==1 | cyclophosphamide==1 | pk_inhibitor==1 | l01_other ==1 | is.na(anthracyclines)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.5cb82214-723e-4d2d-a6a4-46d7026df84f"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.6eee013a-e307-4d7e-a944-df16866118f0")
)
subset_any_rheum <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, il_inhibitor==1 | jak_inhibitor==1 | tnf_inhibitor==1 | l04_other==1 | is.na(il_inhibitor)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.cfc2c66d-6b39-4dc4-ba08-3e99f1275bc2"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.6eee013a-e307-4d7e-a944-df16866118f0")
)
subset_any_sot <- function(Final_cohort_R) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R, azathioprine==1 | calcineurin_inhibitor==1 | mycophenol==1 | is.na(azathioprine)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.2ccc4b46-748a-44bb-b4ce-1f2c12ac3802"),
    matching_any_cancer=Input(rid="ri.foundry.main.dataset.24cad684-305c-4e0f-865c-e0cdf6474689")
)
vent_cancer <- function(matching_any_cancer) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_any_cancer %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    mets, cancer, data_partner_id, liver_mild 
)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:8],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.fed1377f-e2e5-42ec-b0b8-4392fc798919"),
    matching_any_sot=Input(rid="ri.foundry.main.dataset.96989e3a-a6f2-40a4-b15b-436c4b0a2e92")
)
vent_sot <- function(matching_any_sot) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_any_sot %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    transplant_any, renal, data_partner_id, rx_renal, rx_insulin, weeks_since_jan1_2020, liversevere, liver_mild 
)

small$weeks_since_jan1_2020<- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:12],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

