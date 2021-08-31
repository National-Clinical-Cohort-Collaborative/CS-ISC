

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.b51e66ff-5bcd-42d0-931d-b3deed0f03d8"),
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
    Output(rid="ri.vector.main.execute.5940ff18-49dc-4242-a01e-ce08a18b50d8")
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
#Adding SES variables
+ sdi_score + population + percnt_black + percnt_crowding + percnt_dropout + percnt_frgnborn + percnt_hhnocar + percnt_highneeds + percnt_hispanic + percnt_lingisol + percnt_ltfpl100 + percnt_nonemp + percnt_rentoccup
+ percnt_singlparntfly + percnt_unemp 
        , 
        data = zipcode,
        method="ps", 
        estimand="ATT", 
        stabilize=TRUE)

ps_trim <- trim(ps, at = .99, lower = TRUE)

cohort_iptw <- zipcode %>%
        mutate(ipw = ps_trim$weights)

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.d120d18b-e0fe-46ab-96fc-2c4f278444c3"),
    zipcode=Input(rid="ri.foundry.main.dataset.6ae191ff-67f9-48db-bc0e-29e28dd03a09")
)
matching <- function(zipcode) {
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
#Adding SES variables
+ sdi_score + population + percnt_black + percnt_crowding + percnt_dropout + percnt_frgnborn + percnt_hhnocar + percnt_highneeds + percnt_hispanic + percnt_lingisol + percnt_ltfpl100 + percnt_nonemp + percnt_rentoccup
+ percnt_singlparntfly + percnt_unemp
        , 
        data = zipcode,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.035740d4-8038-448f-9102-2d0af907d767"),
    matching=Input(rid="ri.foundry.main.dataset.d120d18b-e0fe-46ab-96fc-2c4f278444c3")
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
    Output(rid="ri.vector.main.execute.ce9cf23f-dccf-4747-8254-6f3a00c85dd3")
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
#Adding SES variables
+ sdi_score + population + percnt_black + percnt_crowding + percnt_dropout + percnt_frgnborn + percnt_hhnocar + percnt_highneeds + percnt_hispanic + percnt_lingisol + percnt_ltfpl100 + percnt_nonemp + percnt_rentoccup
+ percnt_singlparntfly + percnt_unemp
        , 
        data = zipcode,
        family=binomial)

    a <- fitted(logit.ps)
    zipcode$pscore <- NA

    zipcode$pscore[as.numeric(names(a))] <- a

    return(zipcode)

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6292ad76-1449-4e1a-b93c-38404156a720"),
    matching=Input(rid="ri.foundry.main.dataset.d120d18b-e0fe-46ab-96fc-2c4f278444c3")
)
ses <- function(matching) {
    library("survival")
    library(MatchIt)
    library(tidyverse)

    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag +
    + transplant_any + pulmonary + as.factor(data_partner_id) + renal + rheumatic + rx_other_pulm + rx_laba + rx_inhaled_cs + CHF + mets + cancer + diabetes + dmcx + rx_renal + PVD + rx_insulin
    , 
    data=matching, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.vector.main.execute.f5d4d74f-4483-4526-9541-73b61b77e526"),
    IPTW_stabilized_trimmed=Input(rid="ri.vector.main.execute.5940ff18-49dc-4242-a01e-ce08a18b50d8")
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
    Output(rid="ri.foundry.main.dataset.a2726ec4-3428-4749-b97e-7840de8f51cb"),
    matching=Input(rid="ri.foundry.main.dataset.d120d18b-e0fe-46ab-96fc-2c4f278444c3")
)
vent_match <- function(matching) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
    transplant_any, pulmonary, data_partner_id, renal, rheumatic, rx_other_pulm, rx_laba, rx_inhaled_cs, CHF, mets, cancer, diabetes, dmcx, rx_renal, PVD, rx_insulin)

small$data_partner_id <- as.factor(small$data_partner_id)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:20],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.vector.main.execute.f00fa71d-c373-4d6e-a3a5-9b080c488b96")
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
        , data=zipcode)

    summary <- data.frame(tidy(multi1, conf.int=TRUE, conf.level=0.95, exponentiate=TRUE))
            
    return(summary)
              
}
   

@transform_pandas(
    Output(rid="ri.vector.main.execute.58cab042-21f8-4f42-ba4c-b3940ca0b4f4"),
    ps_adjustment=Input(rid="ri.vector.main.execute.ce9cf23f-dccf-4747-8254-6f3a00c85dd3")
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
    Output(rid="ri.vector.main.execute.d2a865f0-beae-40bb-bf5b-09a0ed5179ea")
)
vent_unadjusted <- function() {
    library(nnet)
    library(dplyr)
    library(tibble)
    library(broom)

    multi1 <- multinom (vent1censor0dead2 ~ immuno_flag, data=zipcode)

    summary <- data.frame(tidy(multi1, conf.int=TRUE, conf.level=0.95, exponentiate=TRUE))
            
    return(summary)
              
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6ae191ff-67f9-48db-bc0e-29e28dd03a09"),
    Final_cohort_R_data_frame=Input(rid="ri.foundry.main.dataset.b51e66ff-5bcd-42d0-931d-b3deed0f03d8")
)
#Some people have a missing zip code --> filter out
###Some people have a zip code that isn't mapped to the SDI --> filter out (using percnt_ltfpl100 as missing as being a flag for this)
zipcode <- function(Final_cohort_R_data_frame) {
    
library(dplyr)
   a <- filter (Final_cohort_R_data_frame, !is.na(percnt_ltfpl100))
   
   b <- filter (a, !is.na(sdi_score)) 

   return(b)
}

