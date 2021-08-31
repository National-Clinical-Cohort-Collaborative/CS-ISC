

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6f7f824a-7d57-4add-a693-09c525e67e75"),
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
    Output(rid="ri.foundry.main.dataset.8d729d93-c81f-413d-9bc8-2bd555222102"),
    Final_cohort_R=Input(rid="ri.foundry.main.dataset.6f7f824a-7d57-4add-a693-09c525e67e75")
)
immuno_drug_counts <- function(Final_cohort_R) {
   library(tableone)
   library(tidyverse) 

small <- Final_cohort_R %>%
    filter(immuno_flag==1) %>%
    select (any_rx_rheum, gluco_rheum, il_inhibitor, jak_inhibitor, ritux_rheum, tnf_inhibitor, l04_other, 
    any_rx_sot,  azathioprine, calcineurin_inhibitor, gluco_sot, mycophenol, 
    any_rx_cancer, anthracyclines, checkpoint_inhibitor, cyclophosphamide, pk_inhibitor, ritux_cancer, monoclonal_other, l01_other       
)

# Define categorical variables
catVars <- c( "any_rx_rheum", "gluco_rheum", "il_inhibitor", "jak_inhibitor", "ritux_rheum", "tnf_inhibitor", "l04_other",
    "any_rx_sot", "azathioprine", "calcineurin_inhibitor", "gluco_sot", "mycophenol", 
    "any_rx_cancer", "anthracyclines", "checkpoint_inhibitor", "cyclophosphamide", "pk_inhibitor", "ritux_cancer", "monoclonal_other", "l01_other" )

  x <- CreateTableOne(data = small, factorVars = catVars, test=FALSE)
  as.data.frame(print(x)) %>%
    add_rownames("Name")
    
}

