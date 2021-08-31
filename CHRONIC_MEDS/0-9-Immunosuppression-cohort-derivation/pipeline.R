citation()

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.df317adb-f831-40fd-b70a-59646f7d8e87"),
    pre_charlson=Input(rid="ri.foundry.main.dataset.3d98a420-bf36-4a78-9b96-ec7c42cf18ec")
)
pre_charslon_R <- function(pre_charlson) {
    library(dplyr)
    df <- pre_charlson %>%
            mutate(person_id = as.character(person_id),
                   MI = as.integer(MI),
                   CHF = as.integer(CHF),
                   PVD = as.integer(PVD),
                   stroke = as.integer(stroke),
                   dementia = as.integer(dementia),
                   pulmonary = as.integer(pulmonary),
                   rheumatic = as.integer(rheumatic),
                   PUD = as.integer(PUD),
                   liver_mild = as.integer(liver_mild),
                   diabetes = as.integer(diabetes),
                   dmcx = as.integer(dmcx),
                   paralysis = as.integer(paralysis),
                   renal = as.integer(renal),
                   cancer = as.integer(cancer),
                   liversevere = as.integer(liversevere),
                   mets = as.integer(mets),
                   hiv = as.integer(hiv),
                   multiple = as.integer(multiple),
                   CCI_INDEX = as.integer(CCI_INDEX)) 

    return(df)
}

