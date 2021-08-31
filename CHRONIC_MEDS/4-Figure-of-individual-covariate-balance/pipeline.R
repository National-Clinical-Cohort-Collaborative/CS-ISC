

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.bb4ce24b-3b72-4beb-a81a-95983330e281"),
    Matching=Input(rid="ri.foundry.main.dataset.c3c4f75a-a567-4d13-92ac-2058c64e9d4f")
)
after_balance <- function(Matching) {
   library(tableone)
   library(tidyverse)

small <- Matching %>%
    select (immuno_flag, age, male, 
        days_positive_to_admit, 
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
catVars <- c("male", 
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
    Output(rid="ri.foundry.main.dataset.9844588b-7f7f-4edc-bea6-c4b6f1f4f782"),
    smd_before_after=Input(rid="ri.foundry.main.dataset.12e92dda-d8be-435d-83d4-0cf66f32be4e")
)
balance_plot <- function(smd_before_after) {
    library(ggplot2)
    library(ggalt)

smd_before_after$new.names <- c("pulmonary = 1 (%)" = "Pulmonary disease", 
    "rx_inhaled_cs = 1 (%)" = "Inhaled corticosteroids", "Missing BMI", "Renal disease", "Organ transplant", "Uncomplicated diabetes", "Cancer", "Other pulmonary drugs", 
    "Drugs for renal disease", "Congestive Heart Failure", "Long acting beta agonist", "Rheumatologic disease", "Complicated diabetes", "Insulin", "Peripheral vascular disease", "Mild liver disease", 
    "Drugs for CHF", "Leukotriene modifier", "Stroke", "Obesity", "Myocardial infarction", "Metastatic cancer", "History of smoking", "Normal weight", "Peptic ulcer", "Severe liver disease", "Overweight", 
    "Obese", "Hispanic", "Paralysis", "GLP1 agonist", "Male", "Metformin", "DPP4 inhibitor", "Age", "Non-hispanic Black", "Other diabetes drugs", "Underweight", "SGLT2 inhibitor", "Sulfonylurea", "Asian", 
    "HIV", "Non-hispanic white", "Short acting beta agonist", "Missing race", "Days positive to admission", "Dementia", "Acarbose", "Another race", "TZD", "Drugs for dementia")

smd_before_after$new.names <- factor(smd_before_after$new.names, levels=rev(smd_before_after$new.names))

gg <- ggplot()

gg <- gg + 
    geom_dumbbell(data=smd_before_after, aes(y=new.names, x=After, xend=Before),
                    size=1, color="#374E5599", 
                    colour_x="#DF8F44FF", colour_xend="#00A1D5FF", show.legend=TRUE) +

    geom_vline(xintercept=0.1, linetype="dashed", color = "#374E5599") +

    geom_text(data=filter(smd_before_after, new.names=="Pulmonary disease"),
                    aes(x=After, y=new.names, label="After \n Matching"), 
                    color="#DF8F44FF", size=3, fontface="bold") +

    geom_text(data=filter(smd_before_after, new.names=="Pulmonary disease"),
                    aes(x=Before, y=new.names, label="Before \n Matching"), 
                    color="#00A1D5FF", size=3, fontface="bold") +

    scale_x_continuous(breaks=c(0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9), labels=c("0.0","0.1 \nthreshold", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9")) +

    scale_y_discrete(expand = expansion(add = 1)) +

    labs(x="Standardized Mean Difference", 
         y=NULL, 
         title="Absolute Standardized Mean Differences") +
         
    theme_classic()
    
plot(gg)

return(smd_before_after)
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6d61ea93-7b5e-4538-be3b-9ccff93dad02"),
    Final_cohort_R_data_frame=Input(rid="ri.foundry.main.dataset.5ccbaded-e7e4-4592-bea3-2f35243d868b")
)
before_balance <- function(Final_cohort_R_data_frame) {
   library(tableone)
   library(tidyverse)

small <- Final_cohort_R_data_frame %>%
    select (immuno_flag, age, male, 
        days_positive_to_admit,   
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
catVars <- c("male", 
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
    Output(rid="ri.foundry.main.dataset.12e92dda-d8be-435d-83d4-0cf66f32be4e"),
    after_balance=Input(rid="ri.foundry.main.dataset.bb4ce24b-3b72-4beb-a81a-95983330e281"),
    before_balance=Input(rid="ri.foundry.main.dataset.6d61ea93-7b5e-4538-be3b-9ccff93dad02")
)
smd_before_after <- function(before_balance, after_balance) {
    # library (tidyverse)

    a <- rename(before_balance, "Before" = SMD) %>%
        subset(select = c("Name", "Before"))

    b <- rename(after_balance, "After" = SMD) %>%
        subset(select = c("Name", "After"))

    c <-merge(a,b,by="Name") 
    
    d <- c[!(c$Name=="immuno_flag (mean (SD))" | c$Name=="n"),]

    d$Before <- as.numeric(d$Before)
    d$After <- as.numeric(d$After)

    e <- d[order(-d$Before),]

    return(e)

}

