

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.851bf328-dd88-46f6-88f8-f562fc441d7a"),
    Anthracycline=Input(rid="ri.foundry.main.dataset.d54a74a7-dbe3-4830-b6cc-8795f08c9e10"),
    Any_cancer_and_death=Input(rid="ri.foundry.main.dataset.265d0a15-1533-44f8-9295-e8133b50ec37"),
    Checkpoint_Inhibitors=Input(rid="ri.foundry.main.dataset.625bb6d6-befd-4c8b-a504-e6e3c3f7ee99"),
    Cyclophosphamide=Input(rid="ri.foundry.main.dataset.696de187-caf2-4ec5-bab5-019c49b2d0af"),
    L01_other=Input(rid="ri.foundry.main.dataset.0bd1c04b-34ef-4f48-a994-9afdb012cb7e"),
    Monoclonal_other=Input(rid="ri.foundry.main.dataset.ecc66258-f762-4584-a0f7-db65be2c1f96"),
    PK_inhibitors=Input(rid="ri.foundry.main.dataset.5da460b8-4aed-4fca-991b-67d8cf4ca93f"),
    Ritux_death_cancer=Input(rid="ri.foundry.main.dataset.3898a400-3685-4ebd-8070-fbaaf59d0497")
)
all_cancer_death <- function(Any_cancer_and_death, Anthracycline, Checkpoint_Inhibitors, Cyclophosphamide, PK_inhibitors, L01_other, Monoclonal_other, Ritux_death_cancer) {

    a <- Any_cancer_and_death %>%        
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    a$drug <- c("Any Cancer Drug")
    a$qual <- 1
    
    b <- Anthracycline %>%
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    b$drug <- c("Anthracycline")
    b$qual <- 1

    c <- Checkpoint_Inhibitors %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    c$drug <- c("Checkpoint Inhibitor")
    c$qual <- 1

    d <- Cyclophosphamide %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    d$drug <- c("Cyclophosphamide")
    d$qual <- 1

    e <- PK_inhibitors %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    e$drug <- c("Protein Kinase Inhibitor")
    e$qual <- 1

    f <- L01_other %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    f$drug <- c("Other Antineoplastics")    
    f$qual <- 1

    g <- Monoclonal_other %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    g$drug <- c("Targeted Cancer Therapy")
    g$qual <- 1

    h <- Ritux_death_cancer %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    h$drug <- c("Rituximab with Cancer")
    h$qual <- 3

    x <-rbind(a,d,b,c,e,f,g,h) 

    return(x)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.1f5bfbc6-4cdc-47e9-bfb8-326c06147f51"),
    Any_rheum_and_death=Input(rid="ri.foundry.main.dataset.a1d3c0a2-e668-49f7-9b92-d6af408e3d77"),
    Gluco_death_rheum=Input(rid="ri.foundry.main.dataset.a8e914f1-9250-4f1b-92ce-85fb1410641e"),
    IL_inhibitors=Input(rid="ri.foundry.main.dataset.2725ee32-14f2-4609-865e-9e08b311e813"),
    JAK_inhibitors=Input(rid="ri.foundry.main.dataset.a6aa35bd-337a-4b6c-82e1-88454ca58717"),
    L04_other=Input(rid="ri.foundry.main.dataset.ac909d0b-0891-4ab6-b4f0-900fd947eb1b"),
    Rituximab_death_rheum=Input(rid="ri.foundry.main.dataset.4b8fdbd6-df9e-4da1-9950-e2fcd58ed1b8"),
    TNF_inhibitors=Input(rid="ri.foundry.main.dataset.10181ce3-1cd8-40f1-adb0-c3d241f8245b")
)
all_rheum_death <- function(Any_rheum_and_death, IL_inhibitors, JAK_inhibitors, Gluco_death_rheum, Rituximab_death_rheum, TNF_inhibitors, L04_other) {

    a <- Any_rheum_and_death %>%        
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    a$drug <- c("Any Rheumatologic Drug")
    a$qual <- 1
    
    b <- IL_inhibitors %>%
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    b$drug <- c("IL Inhibitor")
    b$qual <- 1

    c <- JAK_inhibitors %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    c$drug <- c("JAK Inhibitor")
    c$qual <- 2

    d <- Gluco_death_rheum %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    d$drug <- c("Glucocorticoid with Rheumatologic Condition")
    d$qual <- 1

    e <- Rituximab_death_rheum %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    e$drug <- c("Rituximab with Rheumatologic Condition")
    e$qual <- 3

    f <- TNF_inhibitors %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    f$drug <- c("TNF Inhibitor")    
    f$qual <- 1

    g <- L04_other %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    g$drug <- c("Other Selective Immunosuppressants")
    g$qual <- 1
    
    x <-rbind(a,d,b,c,e,f,g) 

    return(x)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.44ddd7ba-2d94-418d-aabf-8f5ebab9649e"),
    Any_SOT_and_death=Input(rid="ri.foundry.main.dataset.7966a490-3358-4020-9588-d60373ad6c55"),
    Azathioprine=Input(rid="ri.foundry.main.dataset.d4ca19d0-782d-4c0c-ae67-51d5e2ced55b"),
    Calcineurin_inhibitors=Input(rid="ri.foundry.main.dataset.9d7c6d82-8fee-4573-8bd6-ad1e779b32e1"),
    Gluco_SOT_death=Input(rid="ri.foundry.main.dataset.729256b0-9afb-439b-abe2-fa367fb93151"),
    Mycophenolate=Input(rid="ri.foundry.main.dataset.cdcaacd9-94d3-4ea6-ad83-2e953a96629d")
)
all_sot_death <- function(Any_SOT_and_death, Azathioprine, Calcineurin_inhibitors, Mycophenolate, Gluco_SOT_death) {

    a <- Any_SOT_and_death %>%        
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    a$drug <- c("Any Antimetabolite Drug")
    a$qual <- 1
    
    b <- Azathioprine %>%
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    b$drug <- c("Azathioprine")
    b$qual <- 1

    c <- Calcineurin_inhibitors %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    c$drug <- c("Calcineurin Inhibitor")
    c$qual <- 1

    d <- Mycophenolate %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    d$drug <- c("Mycophenolic Acid")
    d$qual <- 1

    e <- Gluco_SOT_death %>% 
        filter(variables=="immuno_flag") %>%
        subset(select = c("exp_coef_", "lower__95", "upper__95"))
    e$drug <- c("Glucocorticoid with Organ Transplant")
    e$qual <- 1

    x <-rbind(a,b,c,e,d) 

    return(x)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.924c1eb2-9ed2-41a3-9f32-f44b8d45b7bc"),
    full_set=Input(rid="ri.foundry.main.dataset.47decdca-8b4f-4580-a5bf-7f7e14be9096")
)
death_plot <- function(full_set) {
library(ggplot2)
library(ggsci)
library(tidyverse)    

a <- full_set %>%
#The order here is from the bottom of the chart up 
    mutate(count = fct_relevel(drug, 
            "Rituximab with Cancer", "Targeted Cancer Therapy", "Other Antineoplastics", 
            "Protein Kinase Inhibitor", "Checkpoint Inhibitor", "Anthracycline", 
            "Cyclophosphamide", "Any Cancer Drug", "Mycophenolic Acid", "Glucocorticoid with Organ Transplant", 
            "Calcineurin Inhibitor", "Azathioprine", "Any Antimetabolite Drug", 
            "Other Selective Immunosuppressants", "TNF Inhibitor", "Rituximab with Rheumatologic Condition", 
            "JAK Inhibitor", "IL Inhibitor", "Glucocorticoid with Rheumatologic Condition", 
            "Any Rheumatologic Drug")) %>%
    ggplot( aes(x = exp_coef_ , xmin = lower__95, xmax = upper__95 , y = count)) +
    ggtitle("Hazard Ratios for In-Hospital Death, \n by Immunosuppressive Drug Class") + 
    geom_point(aes(color=qual)) +
    geom_pointrange(aes(color = qual)) +
    geom_text(aes(label = drug), vjust=-1.1) +
    geom_errorbar(aes(xmin = lower__95, xmax=upper__95, color=qual),width=0.5,cex=1) + 
    scale_color_jama(labels=c("Confidence Interval Crosses 1", "Confidence Interval < 1", "Confidence Interval > 1")) +
    scale_fill_jama() +
    geom_vline(color="#80796B99", xintercept = 1, linetype = 2) +
    xlab('Hazard Ratio (95% Confidence Interval)')+ ylab("")+
    theme_classic() +
    theme(legend.title = element_blank(),
        legend.text = element_text (size = 12),
        legend.position="bottom",
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        plot.title = element_text(hjust = 0.5))  

plot(a)

return(NULL)

}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.47decdca-8b4f-4580-a5bf-7f7e14be9096"),
    all_cancer_death=Input(rid="ri.foundry.main.dataset.851bf328-dd88-46f6-88f8-f562fc441d7a"),
    all_rheum_death=Input(rid="ri.foundry.main.dataset.1f5bfbc6-4cdc-47e9-bfb8-326c06147f51"),
    all_sot_death=Input(rid="ri.foundry.main.dataset.44ddd7ba-2d94-418d-aabf-8f5ebab9649e")
)
full_set <- function(all_sot_death, all_rheum_death, all_cancer_death) {
   x <- rbind(all_rheum_death, all_sot_death, all_cancer_death) 

    x$count <-row.names(x)
    x$qual<- as.factor(x$qual)

   return(x)
}

