

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.bbeb54fe-6861-49c7-9cc2-b49be242be0b"),
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
    Output(rid="ri.vector.main.execute.e791c793-d9bc-42b7-8e2e-1c5b0f76999b")
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
        data = gluco_dose_known_high,
        method="ps", 
        estimand="ATT", 
        stabilize=TRUE)

ps_trim <- trim(ps, at = .99, lower = TRUE)

cohort_iptw <- gluco_dose_known_high %>%
        mutate(ipw = ps_trim$weights)

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.95ef8097-e889-47a6-bb55-a0efa9c7fb53"),
    Final_cohort_R_data_frame=Input(rid="ri.foundry.main.dataset.bbeb54fe-6861-49c7-9cc2-b49be242be0b")
)
gluco_dose_known_high <- function(Final_cohort_R_data_frame) {
    library(dplyr)
    ### People who have will be 1, people who have glucocorticoid but not at a known high dose 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R_data_frame, gluco_dose_known_high==1 | is.na(gluco_dose_known_high)) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.77e6de40-2489-418c-a28b-58407454fdc8"),
    gluco_dose_known_high=Input(rid="ri.foundry.main.dataset.95ef8097-e889-47a6-bb55-a0efa9c7fb53")
)
matching <- function(gluco_dose_known_high) {
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
        data = gluco_dose_known_high,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.df6dde41-8903-4a7f-9aa9-4a53c06caa32"),
    matching=Input(rid="ri.foundry.main.dataset.77e6de40-2489-418c-a28b-58407454fdc8")
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
    Output(rid="ri.foundry.main.dataset.4b2bf7f0-ca1a-41ae-8e95-f8de6b65f5a0"),
    matching=Input(rid="ri.foundry.main.dataset.77e6de40-2489-418c-a28b-58407454fdc8")
)
matching_gc_dose <- function(matching) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
   
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + transplant_any + as.factor(data_partner_id) + renal + liver_mild + rx_renal  + rx_other_pulm + mets + cancer + CHF 
    , 
    data=matching, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.vector.main.execute.f8db9dd6-dc36-4800-b8b7-9021798391b2")
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
        data = gluco_dose_known_high,
        family=binomial)

    a <- fitted(logit.ps)
    gluco_dose_known_high$pscore <- NA

    gluco_dose_known_high$pscore[as.numeric(names(a))] <- a

    return(gluco_dose_known_high)

}

@transform_pandas(
    Output(rid="ri.vector.main.execute.36bf734a-4d5d-4978-9447-81ed1ff5d149"),
    IPTW_stabilized_trimmed=Input(rid="ri.vector.main.execute.e791c793-d9bc-42b7-8e2e-1c5b0f76999b")
)
vent_iptw <- function(IPTW_stabilized_trimmed) {
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
    Output(rid="ri.foundry.main.dataset.d570da99-7eab-4aef-8b1d-1fd2a1d15df0"),
    matching=Input(rid="ri.foundry.main.dataset.77e6de40-2489-418c-a28b-58407454fdc8")
)
vent_match <- function(matching) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
   transplant_any, data_partner_id, renal, liver_mild, rx_renal, rx_other_pulm, mets, cancer, CHF)

small$data_partner_id <- as.factor(small$data_partner_id)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:13],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.vector.main.execute.9418af56-833a-438a-9583-62a716c67524")
)
vent_multivariable <- function() {
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
        , data=gluco_dose_known_high )

    summary <- data.frame(tidy(multi1, conf.int=TRUE, conf.level=0.95, exponentiate=TRUE))
            
    return(summary)
              
}
   

@transform_pandas(
    Output(rid="ri.vector.main.execute.309e4943-d4ce-4e37-a43d-f7da08f55fc4"),
    ps_adjustment=Input(rid="ri.vector.main.execute.f8db9dd6-dc36-4800-b8b7-9021798391b2")
)
vent_ps_adjust <- function(ps_adjustment) {
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
    Output(rid="ri.vector.main.execute.e90b305d-4612-48a0-a788-e70f8ac0ab7a")
)
vent_unadjusted <- function() {
    library(nnet)
    library(dplyr)
    library(tibble)
    library(broom)

    multi1 <- multinom (vent1censor0dead2 ~ immuno_flag, data=gluco_dose_known_high)

    summary <- data.frame(tidy(multi1, conf.int=TRUE, conf.level=0.95, exponentiate=TRUE))
            
    return(summary)
              
}

