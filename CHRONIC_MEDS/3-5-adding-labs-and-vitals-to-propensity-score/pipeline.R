

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.798bd331-d986-4632-b4b2-6b340b4929ad"),
    matching=Input(rid="ri.foundry.main.dataset.6000e318-f0f5-4e6f-a4cd-eb6bf6d5ba61")
)
Death <- function(matching) {
    library("survival")
    library(MatchIt)
    library(tidyverse)

    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag +
    + transplant_any + pulmonary + renal + as.factor(data_partner_id) + rheumatic + rx_other_pulm + rx_laba + CHF + rx_renal + dmcx + rx_inhaled_cs 
    + diabetes + cancer + liver_mild + mets + rx_insulin + PVD
    , 
    data=matching, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.e14d1953-2c3d-4a64-87bc-d1837446c711"),
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
    Output(rid="ri.foundry.main.dataset.b1b8889d-c938-43ac-bdf0-01bb03eae798"),
    Final_cohort_R_data_frame=Input(rid="ri.foundry.main.dataset.e14d1953-2c3d-4a64-87bc-d1837446c711")
)
labs_vitals <- function(Final_cohort_R_data_frame) {

#Creating missing data indicators for the labs and vitals
#Didn't do this in the final cohort stage, because it simplifies the denominators for the tables to have the missings be missing    
library(tidyverse)

   a <- Final_cohort_R_data_frame %>%
        mutate(fever_missing = ifelse (!is.na(fever_day_of_admit), 0, 1)) %>%
        mutate(map_missing = ifelse (!is.na(mapressure_lt60), 0, 1)) %>%
        mutate(o2_missing = ifelse (!is.na(o2_lt93_admit), 0, 1)) %>%
        mutate(pulse_missing = ifelse (!is.na(pulse_gt99_admit), 0, 1)) %>%
        mutate(rr_missing = ifelse (!is.na(resp_gt22_admit), 0, 1)) %>%
        mutate(albumin_missing = ifelse (!is.na(albumin_lt35_admit), 0, 1)) %>%
        mutate(alt_missing = ifelse (!is.na(alt_gt35_admit), 0, 1)) %>%
        mutate(ast_missing = ifelse (!is.na(ast_gt35_admit), 0, 1)) %>%
        mutate(crp_missing = ifelse (!is.na(crp_gt8_admit), 0, 1)) %>%
        mutate(creatinine_missing = ifelse (!is.na(creatinine_gt13_admit), 0, 1)) %>%
        mutate(troponin_missing = ifelse (!is.na(troponin_detected_admit), 0, 1)) %>%
        mutate(wbc_missing = ifelse (!is.na(wbc_lt4_admit), 0, 1))  %>% 
        replace_na(list(fever_day_of_admit=0, mapressure_lt60=0, mapressure_gt100=0, o2_lt93_admit=0, pulse_gt99_admit=0, resp_gt22_admit=0, 
            albumin_lt35_admit=0, alt_gt35_admit=0, ast_gt35_admit=0, crp_gt8_admit=0, 
            creatinine_gt13_admit=0, troponin_detected_admit=0, wbc_lt4_admit=0, wbc_gt11_admit=0))

   return(a)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6000e318-f0f5-4e6f-a4cd-eb6bf6d5ba61"),
    ps_calc=Input(rid="ri.foundry.main.dataset.55760304-7408-4464-b3e4-80bf75f74f9f")
)
matching <- function(ps_calc) {
    library(MatchIt)

ps <- matchit(immuno_flag ~ pscore, 
        data = ps_calc,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.cec4bdfd-1774-4b61-9eea-aec9cc80bb09"),
    matching=Input(rid="ri.foundry.main.dataset.6000e318-f0f5-4e6f-a4cd-eb6bf6d5ba61")
)
matching_balance <- function(matching) {
   library(tableone)
   library(tidyverse) 

small <- matching %>%
    select (immuno_flag, age, male, data_partner_id,
        days_positive_to_admit, weeks_since_jan1_2020,  
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race,
        ever_smoker,  
        underweight, normal_weight, overweight, obese, missing_bmi,
        MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, liversevere, mets, hiv,
        rx_chf, rx_dementia, rx_insulin, rx_metformin, rx_sulfonylurea, rx_acarbose, rx_tzd, rx_dpp4, rx_glp1, rx_sglt2, rx_dm_other, rx_obesity, rx_laba,  
        rx_inhaled_cs, rx_saba, rx_leukotriene, rx_other_pulm, rx_renal, 
        transplant_any, 
        fever_day_of_admit, mapressure_lt60, mapressure_gt100, o2_lt93_admit, pulse_gt99_admit, resp_gt22_admit,
        albumin_lt35_admit, alt_gt35_admit, ast_gt35_admit, crp_gt8_admit, creatinine_gt13_admit, troponin_detected_admit, wbc_lt4_admit, wbc_gt11_admit)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("male", "data_partner_id", "weeks_since_jan1_2020",
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "ever_smoker", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi",
    "MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv",
    "rx_chf", "rx_dementia", "rx_insulin", "rx_metformin", "rx_sulfonylurea", "rx_acarbose", "rx_tzd", "rx_dpp4", "rx_glp1", "rx_sglt2", "rx_dm_other", "rx_obesity", "rx_laba",    "rx_inhaled_cs", "rx_saba", "rx_leukotriene", "rx_other_pulm", "rx_renal",
    "transplant_any", 
    "fever_day_of_admit", "mapressure_lt60", "mapressure_gt100", "o2_lt93_admit", "pulse_gt99_admit", "resp_gt22_admit", 
    "albumin_lt35_admit", "alt_gt35_admit", "ast_gt35_admit", "crp_gt8_admit", "creatinine_gt13_admit", "troponin_detected_admit", "wbc_lt4_admit", "wbc_gt11_admit")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.55760304-7408-4464-b3e4-80bf75f74f9f"),
    labs_vitals=Input(rid="ri.foundry.main.dataset.b1b8889d-c938-43ac-bdf0-01bb03eae798")
)
#Was taking > 6 hours to run the match without success - too many variables
## Mathematically equivalent: run the PS as a logistic regression, then match on that one variable 
#This is NOT adjusting for the propensity score, it's just speeding up the process as MatchIt is known to be very slow
ps_calc <- function(labs_vitals) {
    logit.ps <- glm(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any +
        fever_day_of_admit + mapressure_lt60 + mapressure_gt100 + o2_lt93_admit + pulse_gt99_admit + resp_gt22_admit +
        albumin_lt35_admit + alt_gt35_admit + ast_gt35_admit + crp_gt8_admit + creatinine_gt13_admit + troponin_detected_admit+ wbc_lt4_admit + wbc_gt11_admit +
        fever_missing + map_missing + o2_missing + pulse_missing + rr_missing +
        albumin_missing + alt_missing + ast_missing + crp_missing + creatinine_missing + troponin_missing + wbc_missing
        , 
        data = labs_vitals,
        family=binomial)

    a <- fitted(logit.ps)
    labs_vitals$pscore <- NA

    labs_vitals$pscore[as.numeric(names(a))] <- a

    return(labs_vitals)

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.ad44d50a-6ace-4a02-be4b-f2e225b33ebe"),
    matching=Input(rid="ri.foundry.main.dataset.6000e318-f0f5-4e6f-a4cd-eb6bf6d5ba61")
)
vent_labs_vitals <- function(matching) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    transplant_any, pulmonary, renal, data_partner_id, rheumatic, rx_other_pulm, rx_laba, CHF, rx_renal, dmcx, rx_inhaled_cs, 
    diabetes, cancer, liver_mild, mets, rx_insulin, PVD)

small$data_partner_id <- as.factor(small$data_partner_id)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:21],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

