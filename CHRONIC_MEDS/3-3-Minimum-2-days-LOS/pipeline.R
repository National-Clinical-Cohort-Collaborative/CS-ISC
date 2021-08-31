

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.94f50694-d599-4252-be2c-7744fdad4ce6"),
    Final_cohort=Input(rid="ri.foundry.main.dataset.8608fdc2-8890-4ad1-a3cc-5e11ac62782f")
)
Final_cohort_R_data_frame <- function(Final_cohort) {
    library(dplyr)

    df <- Final_cohort %>%
        mutate(weeks_since_jan1_2020 = as.factor(weeks_since_jan1_2020)) %>%
        mutate(data_partner_id = as.factor(data_partner_id))
    return(df)
}

@transform_pandas(
    Output(rid="ri.vector.main.execute.89e25c85-0841-4832-9f62-665a10fc874d")
)
IPTW_stabilized_trimmed <- function() {
#resource: cran.r-project.org/web/packages/WeightIt/vignettes/WeightIt.html and cran.r-project.org/web/packages/coxphw/vignettes/jss_2018_example_code.html
### Built heavily from KMA's Causal Inference course notes
library(tibble)
library("WeightIt")

ps <- weightit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = two_days,
        method="ps", 
        estimand="ATT", 
        stabilize=TRUE)

ps_trim <- trim(ps, at = .99, lower = TRUE)

cohort_iptw <- two_days %>%
        mutate(ipw = ps_trim$weights)

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.7bade1d0-f56b-4876-b00e-b6b27af6fd1c"),
    two_days_los_match=Input(rid="ri.foundry.main.dataset.28b89828-bd16-4dc1-97a7-8ec3c168357e")
)
death_2day_los <- function(two_days_los_match) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
  
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag +
    transplant_any + pulmonary + renal + as.factor(data_partner_id) + rheumatic + CHF + rx_laba + rx_inhaled_cs + liver_mild + rx_other_pulm + mets + cancer + rx_renal + diabetes + dmcx + PVD
    , 
    data=two_days_los_match, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.aa064bf2-6373-46d4-a773-da7b1f5f9c61"),
    two_days_los_match=Input(rid="ri.foundry.main.dataset.28b89828-bd16-4dc1-97a7-8ec3c168357e")
)
matching_balance <- function(two_days_los_match) {
   library(tableone)
   library(tidyverse) 

small <- two_days_los_match %>%
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
    Output(rid="ri.vector.main.execute.89285646-365e-44aa-9dfd-8e9b02c033c7")
)
ps_adjustment <- function() {
    logit.ps <- glm(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = two_days,
        family=binomial)

    a <- fitted(logit.ps)
    two_days$pscore <- NA

    two_days$pscore[as.numeric(names(a))] <- a

    return(two_days)

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.1e3b54bb-e7a5-4c63-977b-5f965c5e2a9c"),
    Final_cohort_R_data_frame=Input(rid="ri.foundry.main.dataset.94f50694-d599-4252-be2c-7744fdad4ce6")
)
two_days <- function(Final_cohort_R_data_frame) {
    
library(dplyr)
filter (Final_cohort_R_data_frame, length_of_stay >= 2) 
}

@transform_pandas(
    Output(rid="ri.vector.main.execute.6a11dce4-b31d-402b-9703-4f0ad5cac78c")
)
two_days_LOS_unadjusted <- function() {
    library(nnet)
    library(dplyr)
    library(tibble)
    library(broom)

    multi1 <- multinom (vent1censor0dead2 ~ immuno_flag, data=two_days)

    summary <- data.frame(tidy(multi1, conf.int=TRUE, conf.level=0.95, exponentiate=TRUE))
            
    return(summary)
              
}

@transform_pandas(
    Output(rid="ri.vector.main.execute.4950165e-e3f3-4d06-a0a1-22e877041268"),
    IPTW_stabilized_trimmed=Input(rid="ri.vector.main.execute.89e25c85-0841-4832-9f62-665a10fc874d")
)
two_days_los_iptw <- function(IPTW_stabilized_trimmed) {
    library(nnet)
    library(dplyr)
    library(tibble)
    library(broom)

    multi1 <- multinom (vent1censor0dead2 ~ immuno_flag 
    + rheumatic + CHF + pulmonary + renal + cancer + transplant_any
    , data=IPTW_stabilized_trimmed,
    weights=ipw)

    summary <- data.frame(tidy(multi1, conf.int=TRUE, conf.level=0.95, exponentiate=TRUE))
            
    return(summary)
              
}
   

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.28b89828-bd16-4dc1-97a7-8ec3c168357e"),
    two_days=Input(rid="ri.foundry.main.dataset.1e3b54bb-e7a5-4c63-977b-5f965c5e2a9c")
)
two_days_los_match <- function(two_days) {
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
        data = two_days,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.vector.main.execute.ba950d22-108d-41ea-a985-a51f80bcafa1")
)
two_days_los_mv <- function() {
    library(nnet)
    library(dplyr)
    library(tibble)
    library(broom)

    multi1 <- multinom (vent1censor0dead2 ~ immuno_flag + 
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any 
        , data=two_days )

    summary <- data.frame(tidy(multi1, conf.int=TRUE, conf.level=0.95, exponentiate=TRUE))
            
    return(summary)
              
}
   

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.0a68a9c8-41cd-4a70-a1f0-6d7798844320"),
    ps_adjustment=Input(rid="ri.vector.main.execute.89285646-365e-44aa-9dfd-8e9b02c033c7")
)
two_days_los_ps_adjust <- function(ps_adjustment) {
    library(nnet)
    library(dplyr)
    library(tibble)
    library(broom)

    multi1 <- multinom (vent1censor0dead2 ~ immuno_flag + pscore
    , data=ps_adjustment)

    summary <- data.frame(tidy(multi1, conf.int=TRUE, conf.level=0.95, exponentiate=TRUE))
            
    return(summary)
              
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.645ca731-bb59-40c6-9f3b-fd9cd4f9883e"),
    two_days_los_match=Input(rid="ri.foundry.main.dataset.28b89828-bd16-4dc1-97a7-8ec3c168357e")
)
vent_match <- function(two_days_los_match) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- two_days_los_match %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    transplant_any, pulmonary, renal, data_partner_id, rheumatic, CHF, rx_laba, rx_inhaled_cs, liver_mild, rx_other_pulm, mets, cancer, rx_renal, diabetes, dmcx, PVD)

small$data_partner_id <- as.factor(small$data_partner_id)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:20],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

