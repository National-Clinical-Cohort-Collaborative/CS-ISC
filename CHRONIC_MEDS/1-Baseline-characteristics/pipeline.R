

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.cd82dccd-0beb-4786-a043-11efbc3ecdf8"),
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
    Output(rid="ri.foundry.main.dataset.7fb35fba-d59a-462e-8add-db53065f8299"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.cd82dccd-0beb-4786-a043-11efbc3ecdf8")
)
charlson <- function(Final_cohort_R) {
   library(tableone)
   library(tidyverse) 

small <- Final_cohort_R %>%
    select (immuno_flag, MI, CHF, PVD, stroke, dementia, pulmonary, rheumatic, PUD, liver_mild, diabetes, dmcx, paralysis, renal, cancer, mets, liversevere, hiv)

# Define categorical variables
catVars <- c("MI", "CHF", "PVD", "stroke", "dementia", "pulmonary", "rheumatic", "PUD", "liver_mild", "diabetes", "dmcx", "paralysis", "renal", "cancer", "mets", "liversevere", "hiv")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.497a0030-566f-42c2-8f42-74fef7d19209"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.cd82dccd-0beb-4786-a043-11efbc3ecdf8")
)
labs_vitals_before_match <- function(Final_cohort_R) {
   library(tableone)
   library(tidyverse) 

small <- Final_cohort_R %>%
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
    Output(rid="ri.foundry.main.dataset.0406b15f-54e2-4651-b81d-3bc20613e273"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.cd82dccd-0beb-4786-a043-11efbc3ecdf8")
)
table1 <- function(Final_cohort_R) {
   library(tableone)
   library(tidyverse) 

small <- Final_cohort_R %>%
    select (covid_status_name, immuno_flag, age, male, 
        asian, hispanic, nonhisp_black, nonhisp_white, another_race, missing_race, 
        underweight, normal_weight, overweight, obese, missing_bmi,
        ever_smoker,
        days_positive_to_admit,
        transplant_any
)

# Create a variable list which we want in Table 1
listVars <- c("age", "days_positive_to_admit")

# Define categorical variables
catVars <- c("covid_status_name", "male", 
    "asian", "hispanic", "nonhisp_black", "nonhisp_white", "another_race", "missing_race", 
    "underweight", "normal_weight", "overweight", "obese", "missing_bmi", 
    "ever_smoker", "transplant_any")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"), test=FALSE)
  as.data.frame(print(x, smd=TRUE)) %>%
    add_rownames("Name")
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.63d33131-74dc-4295-b1e6-b2c7a85ec055"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.cd82dccd-0beb-4786-a043-11efbc3ecdf8")
)
table2_counts <- function(Final_cohort_R) {
   library(tableone)
   library(tidyverse) 

small <- Final_cohort_R %>%
    select (immuno_flag, vent_flag, death_flag, death_after_vent)

# Define categorical variables
catVars <- c("vent_flag", "death_flag", "death_after_vent")

  x <- CreateTableOne(data = small, factorVars = catVars, strata=c("immuno_flag"))
  as.data.frame(print(x)) %>%
    add_rownames("Name")
    
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.31c9e00e-e66f-45db-a95f-815c3a9001fa"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.cd82dccd-0beb-4786-a043-11efbc3ecdf8")
)
weekly_admission <- function(Final_cohort_R) {
    library(tidyverse)
    library(ggplot2)
    library(scales)
    library(grid)
        
    a <- Final_cohort_R %>%
        mutate(weeks_since_jan1_2020 = as.numeric(weeks_since_jan1_2020)) %>%
        filter(weeks_since_jan1_2020 > 10) %>%
        filter(weeks_since_jan1_2020 < 74) %>%
        group_by(immuno_flag) %>%
        count(weeks_since_jan1_2020)

        gg <- ggplot(a, aes(x=weeks_since_jan1_2020, y=n)) +
            geom_line(aes(color=factor(immuno_flag)), size = 1.5, show.legend = FALSE) +
            geom_point(aes(color = factor(immuno_flag), shape=factor(immuno_flag)), size = 4, stroke = 1.8, fill = "white", show.legend = TRUE) +
            
            theme_minimal() +
            theme(axis.text.x = element_text(hjust=0.5, size=14),
                  axis.text.y = element_text(size=15),
                  panel.grid.minor = element_blank(),
                  panel.grid.major.x = element_blank(),
                  legend.title = element_text(colour="black", size=13, face="bold"), legend.text = element_text(size = 13),
                  legend.position = c(0.10,0.88),
                  axis.title.y = element_text(size = 16, face = "bold", margin = margin(t = 3, r = 20, b = 3, l = 5)),
                  axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 20, r = 3, b = 5, l = 3)),
                  legend.key.height = unit(0.8, "cm"),
                  legend.key.size = unit(15, "points")) +
            scale_x_continuous(breaks=c(11,21,35,48,61,73), labels=c("March \n 2020", "June \n 2020", "September \n 2020", "December \n 2020", "March \n 2021", "June \n 2021"), limits=c(11,73)) +
            labs(y="Weekly Admissions of Adults with COVID-19 in N3C", x=" ") +
            scale_colour_manual(breaks = c("1", "0"), 
                                labels = c("Immunosuppressed", "Not Immunosuppressed"), 
                                values = c('#DF8F44FF','#374E55FF'),
                                name="Immune System Status") +
            scale_shape_manual(breaks = c("1", "0"), 
                                labels = c("Immunosuppressed", "Not Immunosuppressed"), 
                                values = c(21, 22),
                                name="Immune System Status") 
    
    plot(gg)
    return(a)
     
}

