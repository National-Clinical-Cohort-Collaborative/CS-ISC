

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.571f84cd-8ab8-4f13-8ded-a7c53fc21a78"),
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
    Output(rid="ri.foundry.main.dataset.ddd367de-d95e-485b-977c-1f2bec5b7c98"),
    Final_cohort_R_data_frame=Input(rid="ri.foundry.main.dataset.571f84cd-8ab8-4f13-8ded-a7c53fc21a78")
)
another <- function(Final_cohort_R_data_frame) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R_data_frame, another_race==1) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.64185dfe-b913-43a9-a397-637b27dcae54"),
    Final_cohort_R_data_frame=Input(rid="ri.foundry.main.dataset.571f84cd-8ab8-4f13-8ded-a7c53fc21a78")
)
asian <- function(Final_cohort_R_data_frame) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R_data_frame, asian==1) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6cf58bc4-d72b-4784-8deb-95cd890fdf66"),
    Final_cohort_R_data_frame=Input(rid="ri.foundry.main.dataset.571f84cd-8ab8-4f13-8ded-a7c53fc21a78")
)
black <- function(Final_cohort_R_data_frame) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R_data_frame, nonhisp_black==1) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.27a3ce95-9cee-4d23-b2d6-4525ffc9d2c4"),
    Final_cohort_R_data_frame=Input(rid="ri.foundry.main.dataset.571f84cd-8ab8-4f13-8ded-a7c53fc21a78")
)
hispanic <- function(Final_cohort_R_data_frame) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R_data_frame, hispanic==1) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.477806d8-9d73-4bc1-9fca-c808f62dcdf9"),
    matching_another=Input(rid="ri.foundry.main.dataset.1e9d60c8-0e26-4e85-929b-854ed233d801")
)
hr_another <- function(matching_another) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
#death1discharge0 has the 1% trimmed survival events (1% censored, if they died >241 days as of May 12)
#time_death_discharge has the trimmed survival times (1% censored at 241 days)     
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + as.factor(weeks_since_jan1_2020) + as.factor(data_partner_id) + transplant_any + rx_other_pulm + rx_leukotriene + pulmonary + cancer + rx_inhaled_cs + rx_dpp4 + rx_insulin + missing_bmi + rx_laba + rx_sulfonylurea 
    + liver_mild + PUD + liversevere + days_positive_to_admit + paralysis + mets + stroke + diabetes + dmcx
    , 
    data=matching_another, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.c94bf994-d2cc-4f69-b89e-cb2d2a43e5c0"),
    matching_asian=Input(rid="ri.foundry.main.dataset.1054c69b-d727-4acd-b930-409e75421984")
)
hr_asian <- function(matching_asian) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
    
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag 
    + as.factor(weeks_since_jan1_2020) + transplant_any + as.factor(data_partner_id) + renal + pulmonary + PVD + liver_mild + diabetes
    , 
    data=matching_asian, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.48e392d8-8832-430b-af0a-c127885d83a2"),
    matching_black=Input(rid="ri.foundry.main.dataset.2376aa00-f5a8-41d1-8617-3df462f2b50e")
)
hr_black <- function(matching_black) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
#death1discharge0 has the 1% trimmed survival events (1% censored, if they died >241 days as of May 12)
#time_death_discharge has the trimmed survival times (1% censored at 241 days)     
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + transplant_any + pulmonary + renal + as.factor(data_partner_id) + rx_inhaled_cs + rx_other_pulm + rx_laba + rheumatic + CHF + rx_leukotriene + dmcx + diabetes 
    , 
    data=matching_black, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.f5cfe2e7-6544-4c35-893a-47d3a7f61ebd"),
    matching_hispanic=Input(rid="ri.foundry.main.dataset.42de39fe-d1b9-421d-9956-7c22171240bf")
)
hr_hispanic <- function(matching_hispanic) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
   
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag 
    + transplant_any + renal + as.factor(data_partner_id) + rheumatic + rx_renal + as.factor(weeks_since_jan1_2020)  + dmcx + PVD + stroke + liver_mild
    , 
    data=matching_hispanic, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.c328e627-9203-4690-a2fc-3c854b703868"),
    matching_missing_race=Input(rid="ri.foundry.main.dataset.4030dd92-ac7e-40c7-9562-212a282bff4b")
)
hr_missing_race <- function(matching_missing_race) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
   
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + transplant_any + pulmonary + renal + as.factor(data_partner_id) + CHF + rheumatic + dmcx + PVD + cancer + rx_renal + liver_mild + MI + as.factor(weeks_since_jan1_2020) + diabetes + rx_leukotriene, 
    data=matching_missing_race, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.9872d817-61b7-475d-9ee8-56a69b739a0c"),
    matching_white=Input(rid="ri.foundry.main.dataset.8b99313e-c08a-4189-8143-760cfdccef5b")
)
hr_white <- function(matching_white) {
    library("survival")
    library(MatchIt)
    library(tidyverse)
    
    cox_model <- coxph(Surv(time_death_discharge, death1discharge0) ~ immuno_flag
    + transplant_any + pulmonary + as.factor(data_partner_id) + renal + rx_inhaled_cs + rx_other_pulm + cancer + rx_laba + rheumatic + liver_mild + mets + CHF + rx_insulin + diabetes, 
    data=matching_white, robust=TRUE, cluster=subclass, method="efron")

    summary <- data.frame(summary(cox_model)$conf.int) %>%
        rownames_to_column(var = "variables")  

    return(summary)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.1e9d60c8-0e26-4e85-929b-854ed233d801"),
    another=Input(rid="ri.foundry.main.dataset.ddd367de-d95e-485b-977c-1f2bec5b7c98")
)
matching_another <- function(another) {
library(MatchIt)

#Have to remove race from the model: singular within the stratification

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = another,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.b618340a-5438-4542-98dd-92a36edea1af"),
    matching_another=Input(rid="ri.foundry.main.dataset.1e9d60c8-0e26-4e85-929b-854ed233d801")
)
matching_another_balance <- function(matching_another) {
   library(tableone)
   library(tidyverse) 

small <- matching_another %>%
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
    Output(rid="ri.foundry.main.dataset.1054c69b-d727-4acd-b930-409e75421984"),
    asian=Input(rid="ri.foundry.main.dataset.64185dfe-b913-43a9-a397-637b27dcae54")
)
matching_asian <- function(asian) {
library(MatchIt)

#Have to remove race from the model: singular within the stratification

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = asian,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.0467f5e9-fc94-436b-a849-915a2b9878ad"),
    matching_asian=Input(rid="ri.foundry.main.dataset.1054c69b-d727-4acd-b930-409e75421984")
)
matching_asian_balance <- function(matching_asian) {
   library(tableone)
   library(tidyverse) 

small <- matching_asian %>%
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
    Output(rid="ri.foundry.main.dataset.8c490e08-438f-42d6-b298-4967f543a789"),
    matching_missing_race=Input(rid="ri.foundry.main.dataset.4030dd92-ac7e-40c7-9562-212a282bff4b")
)
matching_balance_missing <- function(matching_missing_race) {
   library(tableone)
   library(tidyverse) 

small <- matching_missing_race %>%
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
    Output(rid="ri.foundry.main.dataset.2376aa00-f5a8-41d1-8617-3df462f2b50e"),
    black=Input(rid="ri.foundry.main.dataset.6cf58bc4-d72b-4784-8deb-95cd890fdf66")
)
matching_black <- function(black) {
library(MatchIt)

#Have to remove race from the model: singular within the stratification

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = black,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.5f430156-1b93-4933-abe2-f9539d7ec5c8"),
    matching_black=Input(rid="ri.foundry.main.dataset.2376aa00-f5a8-41d1-8617-3df462f2b50e")
)
matching_black_balance <- function(matching_black) {
   library(tableone)
   library(tidyverse) 

small <- matching_black %>%
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
    Output(rid="ri.foundry.main.dataset.42de39fe-d1b9-421d-9956-7c22171240bf"),
    hispanic=Input(rid="ri.foundry.main.dataset.27a3ce95-9cee-4d23-b2d6-4525ffc9d2c4")
)
matching_hispanic <- function(hispanic) {
library(MatchIt)

#Have to remove race from the model: singular within the stratification

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = hispanic,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.c65c3510-6421-455a-ab9d-a837467fd38c"),
    matching_hispanic=Input(rid="ri.foundry.main.dataset.42de39fe-d1b9-421d-9956-7c22171240bf")
)
matching_hispanic_balance <- function(matching_hispanic) {
   library(tableone)
   library(tidyverse) 

small <- matching_hispanic %>%
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
    Output(rid="ri.foundry.main.dataset.4030dd92-ac7e-40c7-9562-212a282bff4b"),
    missing_race=Input(rid="ri.foundry.main.dataset.69e70abc-b418-42ef-ac0b-e854ed2aa8d0")
)
matching_missing_race <- function(missing_race) {
library(MatchIt)

#Have to remove race from the model: singular within the stratification

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = missing_race,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.8b99313e-c08a-4189-8143-760cfdccef5b"),
    white=Input(rid="ri.foundry.main.dataset.d402d8ad-76c3-435c-9ea3-7dd7e2471d32")
)
matching_white <- function(white) {
library(MatchIt)

#Have to remove race from the model: singular within the stratification

ps <- matchit(immuno_flag ~
male + age + as.factor(data_partner_id) + 
days_positive_to_admit + as.factor(weeks_since_jan1_2020) +
ever_smoker + 
underweight + normal_weight + overweight + obese + missing_bmi + 
MI + CHF + PVD + stroke + dementia + pulmonary + rheumatic + PUD + liver_mild + diabetes + dmcx + paralysis + renal + cancer + liversevere + mets + hiv +
rx_chf + rx_dementia + rx_insulin + rx_metformin + rx_sulfonylurea + rx_acarbose + rx_tzd + rx_dpp4 + rx_glp1 + rx_sglt2 + rx_dm_other + rx_obesity + rx_laba + rx_inhaled_cs + rx_saba + rx_leukotriene + rx_other_pulm + rx_renal + 
transplant_any
        , 
        data = white,
        method="nearest", 
        caliper=0.2, 
        ratio=4)

matched1 <-match.data(ps)

return(matched1)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.d4a256dd-2a2e-4423-9858-600f23ce2a01"),
    matching_white=Input(rid="ri.foundry.main.dataset.8b99313e-c08a-4189-8143-760cfdccef5b")
)
matching_white_balance <- function(matching_white) {
   library(tableone)
   library(tidyverse) 

small <- matching_white %>%
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
    Output(rid="ri.foundry.main.dataset.69e70abc-b418-42ef-ac0b-e854ed2aa8d0"),
    Final_cohort_R_data_frame=Input(rid="ri.foundry.main.dataset.571f84cd-8ab8-4f13-8ded-a7c53fc21a78")
)
missing_race <- function(Final_cohort_R_data_frame) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R_data_frame, missing_race==1) 
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.32351c60-443c-4fd6-b0be-22f6b572630b"),
    matching_another=Input(rid="ri.foundry.main.dataset.1e9d60c8-0e26-4e85-929b-854ed233d801")
)
vent_another <- function(matching_another) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_another %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
   weeks_since_jan1_2020, data_partner_id, transplant_any, rx_other_pulm, rx_leukotriene, pulmonary, cancer, rx_inhaled_cs, rx_dpp4, rx_insulin, missing_bmi, rx_laba, rx_sulfonylurea, liver_mild, PUD, liversevere, 
   days_positive_to_admit, paralysis, mets, stroke, diabetes, dmcx)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:26],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.479a2bb3-8761-4d73-9d5a-fe8d8cae1581"),
    matching_asian=Input(rid="ri.foundry.main.dataset.1054c69b-d727-4acd-b930-409e75421984")
)
vent_asian <- function(matching_asian) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_asian %>%
   select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
   weeks_since_jan1_2020, transplant_any, data_partner_id, renal, pulmonary, PVD, liver_mild, diabetes)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:12],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.a7625f9a-5aac-431c-a8ff-66c0f56a6612"),
    matching_black=Input(rid="ri.foundry.main.dataset.2376aa00-f5a8-41d1-8617-3df462f2b50e")
)
vent_black <- function(matching_black) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_black %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
   transplant_any, pulmonary, renal, data_partner_id, rx_inhaled_cs, rx_other_pulm, rx_laba, rheumatic, CHF, rx_leukotriene, dmcx, diabetes)

small$data_partner_id <- as.factor(small$data_partner_id)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:16],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.a6b01440-6a74-4e55-bc74-46c7113ecef0"),
    matching_hispanic=Input(rid="ri.foundry.main.dataset.42de39fe-d1b9-421d-9956-7c22171240bf")
)
vent_hispanic <- function(matching_hispanic) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_hispanic %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
   transplant_any, renal, data_partner_id, rheumatic, rx_renal, weeks_since_jan1_2020, dmcx, PVD, stroke, liver_mild)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:14],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.104bfe4a-4b89-466f-8e28-e11827127741"),
    matching_missing_race=Input(rid="ri.foundry.main.dataset.4030dd92-ac7e-40c7-9562-212a282bff4b")
)
vent_missing_race <- function(matching_missing_race) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_missing_race %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
       transplant_any, pulmonary, renal, data_partner_id, CHF, rheumatic, dmcx, PVD, cancer, rx_renal, liver_mild, MI, weeks_since_jan1_2020, diabetes, rx_leukotriene)

small$data_partner_id <- as.factor(small$data_partner_id)
small$weeks_since_jan1_2020 <- as.factor(small$weeks_since_jan1_2020)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:19],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.2ce7d272-41f0-4289-9d2e-d37d0e9756be"),
    matching_white=Input(rid="ri.foundry.main.dataset.8b99313e-c08a-4189-8143-760cfdccef5b")
)
vent_white <- function(matching_white) {
library(cmprsk)
library(crrSC) 
library(tidyverse)

small <- matching_white %>%
    select(time_vent_shortest, vent1censor0dead2, subclass, immuno_flag, 
   transplant_any, pulmonary, data_partner_id, renal, rx_inhaled_cs, rx_other_pulm, cancer, rx_laba, rheumatic, liver_mild, mets, CHF, rx_insulin, diabetes)

small$data_partner_id <- as.factor(small$data_partner_id)

a <- crrc(ftime=small[,1],fstatus=small[,2],cov1=small[,4:18],cluster=small[,3])

    summary <- data.frame(summary(a)$conf.int) %>%
        rownames_to_column(var = "variables")  

return(summary)   
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.d402d8ad-76c3-435c-9ea3-7dd7e2471d32"),
    Final_cohort_R_data_frame=Input(rid="ri.foundry.main.dataset.571f84cd-8ab8-4f13-8ded-a7c53fc21a78")
)
white <- function(Final_cohort_R_data_frame) {
    library(dplyr)
    ### People who have will be 1, people who have some other form of immunosuppression will be 0, people who are not immunosuppressed will be blank
    filter (Final_cohort_R_data_frame, nonhisp_white==1) 
}

