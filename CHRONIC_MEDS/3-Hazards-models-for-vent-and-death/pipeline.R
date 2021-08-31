

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.5ccbaded-e7e4-4592-bea3-2f35243d868b"),
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
    Output(rid="ri.foundry.main.dataset.c3c4f75a-a567-4d13-92ac-2058c64e9d4f"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.5ccbaded-e7e4-4592-bea3-2f35243d868b")
)
Matching <- function(Final_cohort_R) {
    library(MatchIt)

Final_cohort_R$data_partner_id <- as.factor(Final_cohort_R$data_partner_id)
Final_cohort_R$weeks_since_jan1_2020 <- as.factor(Final_cohort_R$weeks_since_jan1_2020)

ps <- matchit(immuno_flag ~
male + age + data_partner_id + 
days_positive_to_admit + weeks_since_jan1_2020 +
nonhisp_white + nonhisp_black + hispanic +  asian + another_race + missing_race +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = Final_cohort_R,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.83b59ef6-d647-41a1-9e13-2f1e8c01554e"),
    Matching=Input(rid="ri.foundry.main.dataset.c3c4f75a-a567-4d13-92ac-2058c64e9d4f")
)
balance_plot <- function(Matching) {
    library(ggplot2)

Matching$immuno_flag <- as.factor(Matching$immuno_flag)

a <- ggplot(Matching, aes(x = distance, group = immuno_flag, fill = immuno_flag)) + 
        geom_density(alpha=0.7) +     
        scale_fill_manual (values = c("#374E55FF", "#DF8F44FF"), 
                            breaks=c("0", "1"), 
                            labels=c("Not immunosuppressed", "Immunosuppressed")) +
        theme(legend.title=element_blank(), legend.position="bottom") +
        ggtitle("Propensity Score Distribution After Matching") +
            xlab("Propensity Score") + ylab ("Density")

plot(a)

df <- Matching
return(df)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.2b21f935-ff1a-4ce7-8e3e-7d88ed455dfa"),
    ps_unmatched_sample=Input(rid="ri.foundry.main.dataset.93d0a2fd-f164-4a50-a006-896ad341eaaa")
)
balance_plot_before_match <- function( ps_unmatched_sample) {
    library(ggplot2)

ps_unmatched_sample$immuno_flag <- as.factor(ps_unmatched_sample$immuno_flag)

a <- ggplot(ps_unmatched_sample, aes(x = pscore, group = immuno_flag, fill = immuno_flag)) + 
        geom_density(alpha=0.7) +     
        scale_fill_manual (values = c("#374E55FF", "#DF8F44FF"), 
                            breaks=c("0", "1"), 
                            labels=c("Not immunosuppressed", "Immunosuppressed")) +
        theme(legend.title=element_blank(), legend.position="bottom") +
        ggtitle("Propensity Score Distribution Before Matching") +
            xlab("Propensity Score") + ylab ("Density")

plot(a)

df <- ps_unmatched_sample
return(df)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.3fdbd215-5a35-45ab-a00a-b4bbb85b2ad7"),
    Matching=Input(rid="ri.foundry.main.dataset.c3c4f75a-a567-4d13-92ac-2058c64e9d4f")
)
death_match <- function(Matching) {
    library("survival")
    library(MatchIt)

Matching$data_partner_id <- as.factor(Matching$data_partner_id)

#June 15: imbalances updated     
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
        + transplant_any + pulmonary + renal + as.factor(data_partner_id) + CHF + rheumatic + rx_other_pulm + rx_renal + rx_laba + dmcx + diabetes + rx_inhaled_cs + cancer + liver_mild + mets
        + PVD + rx_insulin, 
        data=Matching, 
        robust=TRUE, 
        cluster=subclass, 
        method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.2f382ab4-0efd-4984-9a86-faa75c104d52"),
    Matching=Input(rid="ri.foundry.main.dataset.c3c4f75a-a567-4d13-92ac-2058c64e9d4f")
)
death_unadjusted <- function(Matching) {
    library(survival)
    library(dplyr)
    library(tibble)

    cox <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
        , data = Matching, method="efron" ) 

    summary <- data.frame(summary(cox)$conf.int) %>%
        rownames_to_column(var = "variables")  
    
    return(summary)

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.e8caea9b-f543-4222-b267-86513fab481f"),
    Matching=Input(rid="ri.foundry.main.dataset.c3c4f75a-a567-4d13-92ac-2058c64e9d4f")
)
labs_vitals_after_match <- function(Matching) {
   library(tableone)
   library(tidyverse) 

small <- Matching %>%
    select (immuno_flag, 
        fever_day_of_admit, mapressure_lt60, mapressure_gt100, o2_lt93_admit, pulse_gt99_admit, resp_gt22_admit,
        albumin_lt35_admit, alt_gt35_admit, ast_gt35_admit, crp_gt8_admit, creatinine_gt13_admit, troponin_detected_admit, wbc_lt4_admit, wbc_gt11_admit
)

# Define categorical variables
catVars <- c(
    "fever_day_of_admit", "mapressure_lt60", "mapressure_gt100", "o2_lt93_admit", "pulse_gt99_admit", "resp_gt22_admit", 
    "albumin_lt35_admit", "alt_gt35_admit", "ast_gt35_admit", "crp_gt8_admit", "creatinine_gt13_admit", "troponin_detected_admit", "wbc_lt4_admit", "wbc_gt11_admit")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.d0333c70-ea51-4f2e-af02-7a9acb10d355"),
    Matching=Input(rid="ri.foundry.main.dataset.c3c4f75a-a567-4d13-92ac-2058c64e9d4f")
)
matching_balance <- function(Matching) {
   library(tableone)
   library(tidyverse) 

small <- Matching %>%
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
    Output(rid="ri.foundry.main.dataset.93d0a2fd-f164-4a50-a006-896ad341eaaa"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.5ccbaded-e7e4-4592-bea3-2f35243d868b")
)
ps_unmatched_sample <- function(Final_cohort_R) {
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
        data = Final_cohort_R,
        family=binomial)

    a <- fitted(logit.ps)
    Final_cohort_R$pscore <- NA

    Final_cohort_R$pscore[as.numeric(names(a))] <- a

    return(Final_cohort_R)

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.25b3bd31-3667-4bfd-b3f9-c595b535c56e"),
    Matching=Input(rid="ri.foundry.main.dataset.c3c4f75a-a567-4d13-92ac-2058c64e9d4f")
)
vent_match <- function(Matching) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- Matching %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
        transplant_any, pulmonary, renal, data_partner_id, CHF, rheumatic, rx_other_pulm, rx_renal, rx_laba, dmcx, diabetes, rx_inhaled_cs, cancer, liver_mild, mets, PVD, rx_insulin)

small$data_partner_id <- as.factor(small$data_partner_id)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:21],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.edd79016-93aa-4f57-b757-ed1fa525240b"),
    Matching=Input(rid="ri.foundry.main.dataset.c3c4f75a-a567-4d13-92ac-2058c64e9d4f")
)
vent_unadjusted <- function(Matching) {
library(cmprsk)
library(tidyverse)

small <- Matching %>%
    select(time_vent_shortest, vent1censor0dead2, immuno_flag)

a <- crr(ftime=small[,1],fstatus=small[,2],cov1=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

