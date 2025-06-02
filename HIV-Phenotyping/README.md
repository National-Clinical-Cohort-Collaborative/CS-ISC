# HIV Phenotyping Repo

This algorithm was built for use in the secure All of Us Research Hub Researcher Workbench, a cloud-based platform that supports analysis of All of Us Research Program data. Individuals interested in analyzing the data must be registered users of the All of Us Program. If you are not registered as an All of Us researcher, please check out the All of Us Research Hub (https://www.researchallofus.org/). Registration includes, 1) confirming your affiliation with an institution that has a Data Use and Registration Agreement (DURA), 2) creating an account and verifying your identity with Login.gov or ID.me, 3) completing the mandatory training focusing on responsible and ethical conduct of research, and 4) signing the Data User Code of Conduct (DUCC).

This work is an extension of the algorithm developed by Hurwitz et al to define people living with HIV (PLWH) in the National Clinical Cohort Collaborative (N3C). Both the N3C data and the All of Us Research Program are mapped to the Observational Medical Outcomes Partnership (OMOP) Common Data Model (CDM).

# Description of files in this repo
In this repository, we provide an .ipynb file (Jupyter notebook) displaying the HIV phenotyping pipeline in R in All of Us. We also shared excel files containing OMOP concept sets that were used in N3C to generate the HIV cohort. These OMOP concept IDs were copied into All of Us for usage. 

# How to use files
**N3C:** We are working on creating a Knowledge store object of our HIV phenotyping pipeline to automatically update with each new data release. 
**All of Us:** 1. In your all of us workspace, select "Analysis" along the top tab
2. Open a new Jupyter Notebook
3. In the Jupyter ribbon, select File > Open.
4. In the above header, select 'Upload', and select the .ipynb file.
5. Open the workbook "HIV_phenotyping.ipynb".
6. Run the notebook "HIV_phenotyping.ipynb". You will need to save a csv file of specific cohorts created. We have created cohorts of people living with HIV, PrEP users (pre-exposure prophylaxis), PEP users (post-exposure prophylaxis), and HIV negative individuals.

We created a column of the confidence_level representing our degree of certainty in the status of someone living with HIV. Confidence levels range from 1-4 with 1 being the most confident and 4 being the least confident. Note, we dropped individuals in confidence level 4 from our HIV cohort because these individuals were likely using ritonavir as part of nirmatrelvir/ritonavir (i.e., Paxlovid) as a COVID-19 therapeutic. Depending on the analysis and required confidence level, we recommend including individuals classified as confidence levels 1 and 2. However, in certain use cases, researchers may also choose to include individuals from confidence level 3 at their discretion.

# References
Hurwitz E*, Varley CD*, Anzolone AJ, Madhira V, Olex AL, Sun J, Vaidya D, Fadul N, Islam JY, Jackson LE, Wilkins KJ, Butzin-Dozier Z, Li D, Safo SE, McMurry JA, Maheria P, Williams T, Hassan SA, Haendel MA, Patel RC, The National Clinical Cohort Collaborative (N3C) Consortium. Identifying people living with or those at risk for HIV in a nationally-sampled electronic health record repository called the National Clinical Cohort Collaborative (N3C): A cohort study. *authors contributed equally to this work. JMIR Med Inf (accepted and forthcoming). 29/10/2024:68143. DOI: 10.2196/preprints.68143  
