

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.dcc75760-e210-49cf-90ec-1a89033a2b16"),
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
    Output(rid="ri.vector.main.execute.c39b072e-f3e2-4dc3-8d98-3f9309c6878f")
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
        data = prior_encounter,
        method="ps", 
        estimand="ATT", 
        stabilize=TRUE)

ps_trim <- trim(ps, at = .99, lower = TRUE)

cohort_iptw <- prior_encounter %>%
        mutate(ipw = ps_trim$weights)

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.a9788bd7-4f99-44a7-80d7-ac59521f43ba"),
    matching=Input(rid="ri.foundry.main.dataset.00b1e441-4856-4d1d-9f8c-5d140670d78d")
)
death_prior_encounter <- function(matching) {
    library("survival")
    library(MatchIt)
    library(tidyverse)

    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + transplant_any + pulmonary + as.factor(data_partner_id) + renal + rx_laba + rheumatic + rx_inhaled_cs + rx_other_pulm + CHF  + rx_renal + cancer + liver_mild + PVD + mets + dmcx
    , 
    data=matching, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.00b1e441-4856-4d1d-9f8c-5d140670d78d"),
    prior_encounter=Input(rid="ri.foundry.main.dataset.2b80d298-59cb-4955-82db-a01b817c4315")
)
matching <- function(prior_encounter) {
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
        data = prior_encounter,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.1c122289-8411-48ad-a4a5-8f77990ce3eb"),
    matching=Input(rid="ri.foundry.main.dataset.00b1e441-4856-4d1d-9f8c-5d140670d78d")
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
    Output(rid="ri.foundry.main.dataset.2b80d298-59cb-4955-82db-a01b817c4315"),
    Final_cohort_R_data_frame=Input(rid="ri.foundry.main.dataset.dcc75760-e210-49cf-90ec-1a89033a2b16")
)
prior_encounter <- function(Final_cohort_R_data_frame) {
    
library(dplyr)
   a <- filter (Final_cohort_R_data_frame, observation_period_start_date < covid_admission)
   
   return(a)
}

@transform_pandas(
    Output(rid="ri.vector.main.execute.951b943c-d01a-4b5e-9f67-16297809b3e4")
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
        data = prior_encounter,
        family=binomial)

    a <- fitted(logit.ps)
    prior_encounter$pscore <- NA

    prior_encounter$pscore[as.numeric(names(a))] <- a

    return(prior_encounter)

}

@transform_pandas(
    Output(rid="ri.vector.main.execute.34c86fcc-b4da-4122-a556-0228967de712"),
    IPTW_stabilized_trimmed=Input(rid="ri.vector.main.execute.c39b072e-f3e2-4dc3-8d98-3f9309c6878f")
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
    Output(rid="ri.foundry.main.dataset.c0b2330a-eca2-470c-9be7-e09a904daea1"),
    matching=Input(rid="ri.foundry.main.dataset.00b1e441-4856-4d1d-9f8c-5d140670d78d")
)
vent_match <- function(matching) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
           transplant_any, pulmonary, data_partner_id, renal, rx_laba, rheumatic, rx_inhaled_cs, rx_other_pulm, CHF, rx_renal, cancer, liver_mild, PVD, mets, dmcx)

small$data_partner_id <- as.factor(small$data_partner_id)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:19],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.vector.main.execute.b3c1123c-10cf-4e47-8d78-230beafa1e9a")
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
#Adding SES variables
+ sdi_score + population + percnt_black + percnt_crowding + percnt_dropout + percnt_frgnborn + percnt_hhnocar + percnt_highneeds + percnt_hispanic + percnt_lingisol + percnt_ltfpl100 + percnt_nonemp + percnt_rentoccup
+ percnt_singlparntfly + percnt_unemp 
        , data=prior_encounter)

    summary <- data.frame(tidy(multi1, conf.int=TRUE, conf.level=0.95, exponentiate=TRUE))
            
    return(summary)
              
}
   unnamed <- function(prior_encounter) {
    
}

@transform_pandas(
    Output(rid="ri.vector.main.execute.349447c9-8b8a-465f-af9f-8b8b0a8ddb84"),
    ps_adjustment=Input(rid="ri.vector.main.execute.951b943c-d01a-4b5e-9f67-16297809b3e4")
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
    Output(rid="ri.vector.main.execute.8a37ca02-956e-4a2e-8181-7f9e61a5a308")
)
vent_unadjusted <- function() {
    library(nnet)
    library(dplyr)
    library(tibble)
    library(broom)

    multi1 <- multinom (vent1censor0dead2 ~ immuno_flag, data=prior_encounter)

    summary <- data.frame(tidy(multi1, conf.int=TRUE, conf.level=0.95, exponentiate=TRUE))
            
    return(summary)
              
}

