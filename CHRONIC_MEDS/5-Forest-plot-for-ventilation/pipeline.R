

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.d5e463a9-be9e-4c53-9d49-f11c6ce2aabe"),
    Anthracyclines_ventilation=Input(rid="ri.foundry.main.dataset.000951ca-350d-4748-81c0-47d2bf477bd5"),
    Any_cancer_and_vent=Input(rid="ri.foundry.main.dataset.2ccc4b46-748a-44bb-b4ce-1f2c12ac3802"),
    Checkpoint_ventilation=Input(rid="ri.foundry.main.dataset.4ae0d7f8-fe62-47b9-8349-6506e91f1c2d"),
    Cyclophosphamide_ventilation=Input(rid="ri.foundry.main.dataset.8d6da753-a62c-450e-a93a-a012d3dca2ad"),
    L01_other_ventilation=Input(rid="ri.foundry.main.dataset.db5f29f1-05e9-4814-a86e-17223d1a3a6b"),
    Other_monoclonals_ventilation=Input(rid="ri.foundry.main.dataset.27c9a92d-3576-4f61-b1f2-f4f9c0b5bef1"),
    PK_inhibitors_ventilation=Input(rid="ri.foundry.main.dataset.52146a89-abd5-4691-a40e-5501faf146cb"),
    Vent_ritux_cancer=Input(rid="ri.foundry.main.dataset.3f31d5ae-5d31-415c-a543-4e9bf770c2f3")
)
all_cancer_vent <- function(Any_cancer_and_vent, Anthracyclines_ventilation, Checkpoint_ventilation, Cyclophosphamide_ventilation, PK_inhibitors_ventilation, L01_other_ventilation, Other_monoclonals_ventilation, Vent_ritux_cancer) {

    a <- Any_cancer_and_vent %>%        
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    a$drug <- c("Any Cancer Drug")
    a$qual <- 3
    
    b <- Anthracyclines_ventilation %>%
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    b$drug <- c("Anthracycline")
    b$qual <- 1

    c <- Checkpoint_ventilation %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    c$drug <- c("Checkpoint Inhibitor")
    c$qual <- 1

    d <- Cyclophosphamide_ventilation %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    d$drug <- c("Cyclophosphamide")
    d$qual <- 3

    e <- PK_inhibitors_ventilation %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    e$drug <- c("Protein Kinase Inhibitor")
    e$qual <- 1

    f <- L01_other_ventilation %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    f$drug <- c("Other Antineoplastics")    
    f$qual <- 3

    g <- Other_monoclonals_ventilation %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    g$drug <- c("Targeted Cancer Therapy")
    g$qual <- 1

    h <- Vent_ritux_cancer %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    h$drug <- c("Rituximab with Cancer")
    h$qual <- 1

    x <-rbind(a,d,b,c,e,f,g,h) 

    return(x)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4f430b87-d90d-465f-abd8-60e337e6435e"),
    Any_rheum_and_vent=Input(rid="ri.foundry.main.dataset.0d3e9220-841e-4e83-a283-aa52140efe7d"),
    Gluco_vent_rheum=Input(rid="ri.foundry.main.dataset.d5c372b0-c3ae-43a1-ae94-2b166e1e1fb7"),
    IL_inhibitor_ventilation=Input(rid="ri.foundry.main.dataset.d13e7f0a-542a-4fdf-bd00-26d1d383e01d"),
    JAK_ventilation=Input(rid="ri.foundry.main.dataset.23c603a0-10ce-4573-95a8-1971b5148b6a"),
    L04_other_ventilation=Input(rid="ri.foundry.main.dataset.7b2a9ce2-78a0-44ef-a7d9-cdc815449d13"),
    Ritux_vent_rheum=Input(rid="ri.foundry.main.dataset.c8d562db-57a0-4dcb-a0bf-0571ffb4881d"),
    TNF_ventilation=Input(rid="ri.foundry.main.dataset.eb9e42b8-329b-4476-b236-8df85104de48")
)
all_rheum_vent <- function(Any_rheum_and_vent, IL_inhibitor_ventilation, JAK_ventilation, Gluco_vent_rheum, Ritux_vent_rheum, TNF_ventilation, L04_other_ventilation) {

    a <- Any_rheum_and_vent %>%        
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    a$drug <- c("Any Rheumatologic Drug")
    a$qual <- 3
    
    b <- IL_inhibitor_ventilation %>%
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    b$drug <- c("IL Inhibitor")
    b$qual <- 1

    c <- JAK_ventilation %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    c$drug <- c("JAK Inhibitor")
    c$qual <- 1

    d <- Gluco_vent_rheum %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    d$drug <- c("Glucocorticoid with Rheumatologic Condition")
    d$qual <- 3

    e <- Ritux_vent_rheum %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    e$drug <- c("Rituximab with Rheumatologic Condition")
    e$qual <- 1

    f <- TNF_ventilation %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    f$drug <- c("TNF Inhibitor")    
    f$qual <- 1

    g <- L04_other_ventilation %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    g$drug <- c("Other Selective Immunosuppressants")
    g$qual <- 3
    
    x <-rbind(a,d,b,c,e,f,g) 

    return(x)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.1d9a3bf1-2919-47b6-bc30-3b2ac5d9b518"),
    Any_SOT_and_vent=Input(rid="ri.foundry.main.dataset.fed1377f-e2e5-42ec-b0b8-4392fc798919"),
    Azathioprine_ventilation=Input(rid="ri.foundry.main.dataset.7ad9e9b7-9334-487b-9af2-0b6b9b3882be"),
    Calcineurin_ventilation=Input(rid="ri.foundry.main.dataset.5d756a04-d606-437c-8564-36a72f9ad74d"),
    Mycophenol_ventilation=Input(rid="ri.foundry.main.dataset.4d9d7e2d-0fd8-44e4-a902-e2bf26f52854"),
    Vent_gluco_SOT=Input(rid="ri.foundry.main.dataset.45e29ac0-89f5-4c00-9519-a1ef7a5b0454")
)
all_sot_vent <- function(Any_SOT_and_vent, Azathioprine_ventilation, Calcineurin_ventilation, Mycophenol_ventilation, Vent_gluco_SOT) {

    a <- Any_SOT_and_vent %>%        
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    a$drug <- c("Any Antimetabolite Drug")
    a$qual <- 3
    
    b <- Azathioprine_ventilation %>%
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    b$drug <- c("Azathioprine")
    b$qual <- 3

    c <- Calcineurin_ventilation %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    c$drug <- c("Calcineurin Inhibitor")
    c$qual <- 3

    d <- Mycophenol_ventilation %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    d$drug <- c("Mycophenolic Acid")
    d$qual <- 1

    e <- Vent_gluco_SOT %>% 
        filter(variables=="1") %>%
        subset(select = c("exp_coef_", "X2_5_", "X97_5_"))
    e$drug <- c("Glucocorticoid with Organ Transplant")
    e$qual <- 3

    x <-rbind(a,b,c,e,d) 

    return(x)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.4dc3f15e-506b-4f1a-b11f-76f88b2804ea"),
    all_cancer_vent=Input(rid="ri.foundry.main.dataset.d5e463a9-be9e-4c53-9d49-f11c6ce2aabe"),
    all_rheum_vent=Input(rid="ri.foundry.main.dataset.4f430b87-d90d-465f-abd8-60e337e6435e"),
    all_sot_vent=Input(rid="ri.foundry.main.dataset.1d9a3bf1-2919-47b6-bc30-3b2ac5d9b518")
)
full_set <- function(all_sot_vent, all_rheum_vent, all_cancer_vent) {
   x <- rbind(all_rheum_vent, all_sot_vent, all_cancer_vent) 

    x$count <-row.names(x)
    x$qual<- as.factor(x$qual)

   return(x)
}

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.042d5095-f2d0-4483-8d75-52558630ba08"),
    full_set=Input(rid="ri.foundry.main.dataset.4dc3f15e-506b-4f1a-b11f-76f88b2804ea")
)
vent_plot <- function(full_set) {
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
    ggplot( aes(x = exp_coef_ , xmin = X2_5_, xmax = X97_5_ , y = count)) +
    ggtitle("Hazard Ratios for Invasive Mechanical Ventilation, \n by Immunosuppressive Drug Class") + 
    geom_point(aes(color=qual)) +
    geom_pointrange(aes(color = qual)) +
    geom_text(aes(label = drug), vjust=-1.1) +
    geom_errorbar(aes(xmin = X2_5_, xmax=X97_5_, color=qual),width=0.5,cex=1) + 
    scale_color_jama(labels=c("Confidence Interval Crosses 1", "Confidence Interval < 1")) +
    scale_fill_jama() +
    geom_vline(color="#80796B99", xintercept = 1, linetype = 2) +
    xlab('Hazard Ratio (95% Confidence Interval)')+ ylab("")+
    theme_classic() +
    theme(legend.title = element_blank(),
        legend.text = element_text (size = 12),
        legend.position= "bottom",
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        plot.title = element_text(hjust = 0.5))  
plot(a)

return(NULL)

}

