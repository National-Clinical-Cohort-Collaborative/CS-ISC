

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.a89d21fd-508a-4cba-93ec-99d26c00f1c2"),
    pred_reason_sum=Input(rid="ri.vector.main.execute.fd170ca6-4cbd-4d1e-94ff-81d997c1bfa0")
)
SELECT *,
CASE 
    WHEN (psoriasis_sum != 0) then 1
    ELSE 0
    END AS psoriasis, 
CASE
    WHEN (colitis_sum != 0) then 1
    ELSE 0
    END AS colitis, 
CASE
    WHEN (crohns_sum != 0) then 1
    ELSE 0
    END AS crohns, 
CASE
    WHEN (rheum_arthritis_sum != 0) then 1
    ELSE 0
    END AS rheum_arthritis, 
CASE
    WHEN (emphysema_copd_sum != 0) then 1
    ELSE 0
    END AS emphysema_copd, 
CASE
    WHEN (asthma_sum != 0) then 1
    ELSE 0
    END AS asthma, 
CASE
    WHEN (lupus_sum != 0) then 1
    ELSE 0
    END AS lupus,
CASE
    WHEN (vasculitis_sum != 0) then 1
    ELSE 0
    END AS vasculitis, 
CASE
    WHEN (as_axspa_sum != 0) then 1
    ELSE 0
    END AS as_axspa, 
CASE
    WHEN (psa_sum != 0) then 1
    ELSE 0
    END AS psa
FROM pred_reason_sum

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.84100de9-e0dc-4141-b768-91dfaa273667"),
    concept=Input(rid="ri.foundry.main.dataset.5cb3c4a3-327a-47bf-a8bf-daf0cafe6772")
)
---January 29, 2021: made this its own code workbook because this is the largest step, and was causing a crash when the full code workbook was set to refresh with new data. So removing into its own step and importing the result of this into the "1 Cohort derivation" workbook should solve that

---February 10: expanding prednisone to include all glucocorticoids

---using workflow from Kayte, Hemal and Richard Boyce meeting on November 24, 2020
---note: we are doing it this way 1) for reproducibility; 2) it picked up 40% more than searching the atc class alone
SELECT concept_id, concept_name
FROM concept
WHERE /*atc code l04aa - selective immunosuppressants*/ 
lcase(concept_name) like '%muromonab-cd3%'
or lcase(concept_name) like '%antilymphocyte immunoglobulin (horse)%'
or lcase(concept_name) like '%antithmyocyte immunoglobulin (rabbit)%'
or lcase(concept_name) like '%mycophenolic acid%'
or lcase(concept_name) like '%mycophenolate sodium%'
or lcase(concept_name) like '%mycophenolate mofetil%'
or lcase(concept_name) like '%sirolimus%'
or lcase(concept_name) like '%leflunomide%'
or lcase(concept_name) like '%alefacept%'
or lcase(concept_name) like '%everolimus%'
or lcase(concept_name) like '%gusperimus%'
or lcase(concept_name) like '%efalizumab%'
or lcase(concept_name) like '%abetimus%' 
or lcase(concept_name) like '%natalizumab%'
or lcase(concept_name) like '%abatacept%'
or lcase(concept_name) like '%eculizumab%'
or lcase(concept_name) like '%belimumab%'
or lcase(concept_name) like '%fingolimod%'
or lcase(concept_name) like '%belatacept%'
or lcase(concept_name) like '%tofacitinib%'
or lcase(concept_name) like '%teriflunomide%'
or lcase(concept_name) like '%apremilast%'
or lcase(concept_name) like '%vedolizumab%'
or lcase(concept_name) like '%alemtuzumab%'
or lcase(concept_name) like '%begelomab%'
or lcase(concept_name) like '%ocrelizumab%'
or lcase(concept_name) like '%baricitinib%'
or lcase(concept_name) like '%ozanimod%'
or lcase(concept_name) like '%emapalumab%'
or lcase(concept_name) like '%cladribine%'
or lcase(concept_name) like '%imlifidase%'
or lcase(concept_name) like '%siponimod%'
or lcase(concept_name) like '%ravulizumab%'
or lcase(concept_name) like '%upadacitinib%' 
/*atc code l04ab - tnf alpha inhibitors*/
or lcase(concept_name) like '%etanercept%'
or lcase(concept_name) like '%infliximab%'
or lcase(concept_name) like '%afelimomab%'
or lcase(concept_name) like '%adalimumab%'
or lcase(concept_name) like '%certolizumab pegol%'
or lcase(concept_name) like '%golimumab%'
or lcase(concept_name) like '%opinercept%' 
/*atc code l04ac - interleukin inhibitors*/
or lcase(concept_name) like '%daciluzumab%'
or lcase(concept_name) like '%basiliximab%'
or lcase(concept_name) like '%anakinra%'
or lcase(concept_name) like '%rilonacept%'
or lcase(concept_name) like '%ustekinumab%'
or lcase(concept_name) like '%tocilizumab%'
or lcase(concept_name) like '%canakinumab%'
or lcase(concept_name) like '%briakinumab%'
or lcase(concept_name) like '%secukinumab%'
or lcase(concept_name) like '%siltuximab%'
or lcase(concept_name) like '%brodalumab%'
or lcase(concept_name) like '%ixekizumab%'
or lcase(concept_name) like '%sarilumab%'
or lcase(concept_name) like '%sirukumab%'
or lcase(concept_name) like '%guselkumab%'
or lcase(concept_name) like '%tildrakizumab%'
or lcase(concept_name) like '%risankizumab%'
/*atc code l04ad - calcineurin inhibitors*/
or lcase(concept_name) like '%ciclosporin%'
or lcase(concept_name) like '%cyclosporin%'
or lcase(concept_name) like '%tacrolimus%'
or lcase(concept_name) like '%voclosporin%' 
/*atc code l04ax - other immunosuppressants*/
or lcase(concept_name) like '%azathioprine%'
or lcase(concept_name) like '%thalidomide%'
or lcase(concept_name) like '%lenalidomide%'
or lcase(concept_name) like '%pirfenidone%'
or lcase(concept_name) like '%pomalidomide%'
or lcase(concept_name) like '%dimethyl fumarate%'
or lcase(concept_name) like '%darvadstrocel%'
/*oral glucocorticoids*/
or lcase(concept_name) like '%dexamethasone%'
or lcase(concept_name) like '%prednisone%'
or lcase(concept_name) like '%prednisolone%'
or lcase(concept_name) like '%methylprednisolone%'
/*l01aa nitrogen mustard analogues*/
or lcase(concept_name) like '%cyclophosphamide%'
or lcase(concept_name) like '%chlorambucil%'
or lcase(concept_name) like '%melphalan%'
or lcase(concept_name) like '%chlormethine%'
or lcase(concept_name) like '%ifosfamide%'
or lcase(concept_name) like '%trofosfamide%'
or lcase(concept_name) like '%prednimustine%'
or lcase(concept_name) like '%bendamustine%' 
/*l01ab alkyl sulfonates*/
or lcase(concept_name) like '%busulfan%'
or lcase(concept_name) like '%treosulfan%'
or lcase(concept_name) like '%mannosulfan%' 
/*l01ac ethylene imines*/
or lcase(concept_name) like '%thiotepa%'
or lcase(concept_name) like '%triaziquone%'
or lcase(concept_name) like '%carboquone%' 
/*l01ad nitrosoureas*/
or lcase(concept_name) like '%carmustine%'
or lcase(concept_name) like '%lomustine%'
or lcase(concept_name) like '%semustine%'
or lcase(concept_name) like '%streptozocin%'
or lcase(concept_name) like '%fotemustine%'
or lcase(concept_name) like '%nimustine%'
or lcase(concept_name) like '%ranimustine%'
or lcase(concept_name) like '%uramustine%' 
/*l01ag epoxides*/
or lcase(concept_name) like '%etoglucid%'
/*l01ax other alkylating agents*/
or lcase(concept_name) like '%mitobronitol%'
or lcase(concept_name) like '%pipobroman%'
or lcase(concept_name) like '%temozolomide%'
or lcase(concept_name) like '%dacarbazine%' 
/*l01ba folic acid analogues*/
or lcase(concept_name) like '%methotrexate%'
or lcase(concept_name) like '%raltitrexed%'
or lcase(concept_name) like '%pemetrexed%'
or lcase(concept_name) like '%pralatrexate%' 
/*l01bb purine analogues*/
or lcase(concept_name) like '%mercaptopurine%'
or lcase(concept_name) like '%tioguanine%'
or lcase(concept_name) like '%cladribine%'
or lcase(concept_name) like '%fludarabine%'
or lcase(concept_name) like '%clofarabine%'
or lcase(concept_name) like '%nelarabine%'
or lcase(concept_name) like '%rabacfosadine%' 
/*l01bc pyrimidine analogues*/
or lcase(concept_name) like '%cytarabine%'
or lcase(concept_name) like '%fluorouracil%'
or lcase(concept_name) like '%tegafur%'
or lcase(concept_name) like '%carmofur%'
or lcase(concept_name) like '%gemcitabine%'
or lcase(concept_name) like '%capecitabine%'
or lcase(concept_name) like '%azacitidine%'
or lcase(concept_name) like '%decitabine%'
or lcase(concept_name) like '%floxuridine%'
or lcase(concept_name) like '%fluorouracil%'
or lcase(concept_name) like '%tegafur%'
or lcase(concept_name) like '%trifluridine%' 
/*l01ca vinca alkaloids and analogues*/
or lcase(concept_name) like '%vinblastine%'
or lcase(concept_name) like '%vincristine%'
or lcase(concept_name) like '%vindesine%'
or lcase(concept_name) like '%vinorelbine%'
or lcase(concept_name) like '%vinflunine%'
or lcase(concept_name) like '%vintafolide%' 
/*l01cb podophyllotoxin derivatives*/
or lcase(concept_name) like '%etoposide%'
or lcase(concept_name) like '%teniposide%' 
/*l01cc colchicine derivatives*/
or lcase(concept_name) like '%demecolcine%' 
/*l01cd taxanes*/
or lcase(concept_name) like '%paclitaxel%'
or lcase(concept_name) like '%docetaxel%'
or lcase(concept_name) like '%paclitaxel poliglumex%'
or lcase(concept_name) like '%cabazitaxel%' 
/*l01cx other plant alkaloids and natural products*/
or lcase(concept_name) like '%trabectedin%' 
/*l01da actinomycines*/
or lcase(concept_name) like '%dactinomycin%' 
/*l01db anthracyclines and related substances*/
or lcase(concept_name) like '%doxorubicin%'
or lcase(concept_name) like '%daunorubicin%'
or lcase(concept_name) like '%epirubicin%'
or lcase(concept_name) like '%aclarubicin%'
or lcase(concept_name) like '%zorubicin%'
or lcase(concept_name) like '%idarubicin%'
or lcase(concept_name) like '%mitoxantrone%'
or lcase(concept_name) like '%pirarubicin%' 
or lcase(concept_name) like '%valrubicin%'
or lcase(concept_name) like '%amrubicin%'
or lcase(concept_name) like '%pixantrone%' 
/*l01dc other cytotoxic antibiotics*/
or lcase(concept_name) like '%bleomycin%'
or lcase(concept_name) like '%plicamycin%'
or lcase(concept_name) like '%mitomycin%'
or lcase(concept_name) like '%ixabepilone%' 
/*l01xa platinum compounds*/
or lcase(concept_name) like '%cisplatin%'
or lcase(concept_name) like '%carboplatin%'
or lcase(concept_name) like '%oxaliplatin%'
or lcase(concept_name) like '%satraplatin%'
or lcase(concept_name) like '%polyplatillen%' 
/*l01xb methylhydrazines*/
or lcase(concept_name) like '%procarbazine%' 
/*l01xc monoclonal antibodies*/ 
or lcase(concept_name) like '%edrecolomab%'
or lcase(concept_name) like '%rituximab%'
or lcase(concept_name) like '%trastuzumab%'
or lcase(concept_name) like '%gemtuzumab ozogamicin%'
or lcase(concept_name) like '%cetuximab%'
or lcase(concept_name) like '%bevacizumab%'
or lcase(concept_name) like '%panitumumab%'
or lcase(concept_name) like '%catumaxomab%'
or lcase(concept_name) like '%ofatumumab%' 
or lcase(concept_name) like '%ipilimumab%'
or lcase(concept_name) like '%brentuximab vedotin%'
or lcase(concept_name) like '%pertuzumab%'
or lcase(concept_name) like '%trastuzumab emtansine%'
or lcase(concept_name) like '%obinutuzumab%'
or lcase(concept_name) like '%dinutuximab beta%'
or lcase(concept_name) like '%nivolumab%'
or lcase(concept_name) like '%pembrolizumab%'
or lcase(concept_name) like '%blinatumomab%' 
or lcase(concept_name) like '%ramucirumab%'
or lcase(concept_name) like '%necitumumab%'
or lcase(concept_name) like '%elotuzumab%'
or lcase(concept_name) like '%daratumumab%'
or lcase(concept_name) like '%mogamulizumab%'
or lcase(concept_name) like '%inotuzumab ozogamicin%'
or lcase(concept_name) like '%olaratumab%'
or lcase(concept_name) like '%durvalumab%'
or lcase(concept_name) like '%bermekimab%'
or lcase(concept_name) like '%avelumab%' 
or lcase(concept_name) like '%atezolizumab%'
or lcase(concept_name) like '%cemiplimab%' 
/*l01xd sensitizers used in photodynamic/radiation therapy*/
or lcase(concept_name) like '%porfimer sodium%'
or lcase(concept_name) like '%methyl aminolevulinate%'
or lcase(concept_name) like '%aminolevulinic acid%'
or lcase(concept_name) like '%temoporfin%'
or lcase(concept_name) like '%efaproxiral%'
or lcase(concept_name) like '%padeliporfin%' 
/*l01xe protein kinase inhibitors*/
or lcase(concept_name) like '%imatinib%'
or lcase(concept_name) like '%gefitinib%'
or lcase(concept_name) like '%erlotinib%'
or lcase(concept_name) like '%sunitinib%'
or lcase(concept_name) like '%sorafenib%'
or lcase(concept_name) like '%dasatinib%'
or lcase(concept_name) like '%lapatinib%'
or lcase(concept_name) like '%nilotinib%'
or lcase(concept_name) like '%temsirolimus%'
or lcase(concept_name) like '%everolimus%' 
or lcase(concept_name) like '%pazopanib%'
or lcase(concept_name) like '%vandetanib%'
or lcase(concept_name) like '%afatinib%'
or lcase(concept_name) like '%bosutinib%'
or lcase(concept_name) like '%vemurafenib%'
or lcase(concept_name) like '%crizotinib%'
or lcase(concept_name) like '%axitinib%'
or lcase(concept_name) like '%ruxolitinib%'
or lcase(concept_name) like '%ridaforolimus%'
or lcase(concept_name) like '%regorafenib%'
or lcase(concept_name) like '%masitinib%' 
or lcase(concept_name) like '%dabrafenib%'
or lcase(concept_name) like '%ponatinib%'
or lcase(concept_name) like '%trametinib%'
or lcase(concept_name) like '%cabozantinib%'
or lcase(concept_name) like '%ibrutinib%'
or lcase(concept_name) like '%ceritinib%'
or lcase(concept_name) like '%lenvatinib%'
or lcase(concept_name) like '%nintedanib%'
or lcase(concept_name) like '%cediranib%'
or lcase(concept_name) like '%palbociclib%'
or lcase(concept_name) like '%tivozanib%' 
or lcase(concept_name) like '%osimertinib%'
or lcase(concept_name) like '%alectinib%'
or lcase(concept_name) like '%rociletinib%'
or lcase(concept_name) like '%cobimetinib%'
or lcase(concept_name) like '%midostaurin%'
or lcase(concept_name) like '%olmutinib%'
or lcase(concept_name) like '%binimetinib%'
or lcase(concept_name) like '%ribociclib%'
or lcase(concept_name) like '%brigatinib%'
or lcase(concept_name) like '%lorlatinib%'
or lcase(concept_name) like '%neratinib%' 
or lcase(concept_name) like '%encorafenib%'
or lcase(concept_name) like '%dacomitinib%'
or lcase(concept_name) like '%icotinib%'
or lcase(concept_name) like '%abemaciclib%'
or lcase(concept_name) like '%acalabrutinib%'
or lcase(concept_name) like '%quizartinib%'
or lcase(concept_name) like '%larotrectinib%'
or lcase(concept_name) like '%gilteritinib%'
or lcase(concept_name) like '%entrectinib%'
or lcase(concept_name) like '%fedratinib%' 
or lcase(concept_name) like '%toceranib%' 
/*l01xx other antineoplastic agents*/
or lcase(concept_name) like '%amsacrine%'
or lcase(concept_name) like '%asparaginase%'
or lcase(concept_name) like '%altretamine%'
or lcase(concept_name) like '%hydroxycarbamide%'
or lcase(concept_name) like '%lonidamine%'
or lcase(concept_name) like '%pentostatin%'
or lcase(concept_name) like '%masoprocol%'
or lcase(concept_name) like '%estramustine%'
/*'tretinoin',*/ 
or lcase(concept_name) like '%mitoguazone%'
or lcase(concept_name) like '%topotecan%'
or lcase(concept_name) like '%tiazofurine%'
or lcase(concept_name) like '%irinotecan%'
or lcase(concept_name) like '%alitretinoin%'
or lcase(concept_name) like '%mitotane%'
or lcase(concept_name) like '%pegaspargase%'
or lcase(concept_name) like '%bexarotene%'
or lcase(concept_name) like '%arsenic trioxide%'
or lcase(concept_name) like '%denileukin diftitox%' 
or lcase(concept_name) like '%bortezomib%'
or lcase(concept_name) like '%anagrelide%'
or lcase(concept_name) like '%oblimersen%'
or lcase(concept_name) like '%sitimagene ceradenovec%'
or lcase(concept_name) like '%vorinostat%'
or lcase(concept_name) like '%romidepsin%'
or lcase(concept_name) like '%omacetaxine mepesuccinate%'
or lcase(concept_name) like '%eribulin%'
or lcase(concept_name) like '%panobinostat%' 
or lcase(concept_name) like '%vismodegib%'
or lcase(concept_name) like '%aflibercept%'
or lcase(concept_name) like '%carfilzomib%'
or lcase(concept_name) like '%olaparib%'
or lcase(concept_name) like '%idelalisib%'
or lcase(concept_name) like '%sonidegib%'
or lcase(concept_name) like '%belinostat%'
or lcase(concept_name) like '%ixazomib%'
or lcase(concept_name) like '%talimogene laherparepvec%'
or lcase(concept_name) like '%venetoclax%' 
or lcase(concept_name) like '%vosaroxin%'
or lcase(concept_name) like '%niraparib%'
or lcase(concept_name) like '%rucaparib%'
or lcase(concept_name) like '%etirinotecan pegol%'
or lcase(concept_name) like '%plitidepsin%'
or lcase(concept_name) like '%epacadostat%'
or lcase(concept_name) like '%enasidenib%'
or lcase(concept_name) like '%talazoparib%'
or lcase(concept_name) like '%copanlisib%'
or lcase(concept_name) like '%ivosidenib%' 
or lcase(concept_name) like '%glasdegib%'
or lcase(concept_name) like '%entinostat%'
or lcase(concept_name) like '%alpelisib%'
or lcase(concept_name) like '%selinexor%'
or lcase(concept_name) like '%tagraxofusp%'
or lcase(concept_name) like '%belotecan%'
or lcase(concept_name) like '%tigilanol tiglate%' 
/*l01xy combinations of antineoplastic agents*/
or lcase(concept_name) like '%cytarabine%'

---303 unique drugs

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.6c39da89-9af9-4c61-8b55-800beb8ba01b"),
    immuno_extract=Input(rid="ri.foundry.main.dataset.90d892f4-9e09-45d3-bfad-2efbc3d68788")
)
---have to do this as a separate step - was causing a crash when part of the join step before

select *,
case when /*l01db anthracyclines and related substances*/
(lcase(concept_name) like '%doxorubicin%'
or lcase(concept_name) like '%daunorubicin%'
or lcase(concept_name) like '%epirubicin%'
or lcase(concept_name) like '%aclarubicin%'
or lcase(concept_name) like '%zorubicin%'
or lcase(concept_name) like '%idarubicin%'
or lcase(concept_name) like '%mitoxantrone%'
or lcase(concept_name) like '%pirarubicin%' 
or lcase(concept_name) like '%valrubicin%'
or lcase(concept_name) like '%amrubicin%'
or lcase(concept_name) like '%pixantrone%') then 1 else 0
end as anthracyclines,

case when /*selected from l01xc*/
(lcase(concept_name) like '%ipilimumab%'
or lcase(concept_name) like '%nivolumab%'
or lcase(concept_name) like '%pembrolizumab%'
or lcase(concept_name) like '%avelumab%' 
or lcase(concept_name) like '%atezolizumab%'
or lcase(concept_name) like '%cemiplimab%' 
or lcase(concept_name) like '%durvalumab%') then 1 else 0
end as checkpoint_inhibitor,

case when lcase(concept_name) like '%cyclophosphamide%' then 1 else 0
end as cyclophosphamide,

case when /*l01xe protein kinase inhibitors*/
(lcase(concept_name) like '%imatinib%'
or lcase(concept_name) like '%gefitinib%'
or lcase(concept_name) like '%erlotinib%'
or lcase(concept_name) like '%sunitinib%'
or lcase(concept_name) like '%sorafenib%'
or lcase(concept_name) like '%dasatinib%'
or lcase(concept_name) like '%lapatinib%'
or lcase(concept_name) like '%nilotinib%'
or lcase(concept_name) like '%temsirolimus%'
or lcase(concept_name) like '%everolimus%' 
or lcase(concept_name) like '%pazopanib%'
or lcase(concept_name) like '%vandetanib%'
or lcase(concept_name) like '%afatinib%'
or lcase(concept_name) like '%bosutinib%'
or lcase(concept_name) like '%vemurafenib%'
or lcase(concept_name) like '%crizotinib%'
or lcase(concept_name) like '%axitinib%'
or lcase(concept_name) like '%ruxolitinib%'
or lcase(concept_name) like '%ridaforolimus%'
or lcase(concept_name) like '%regorafenib%'
or lcase(concept_name) like '%masitinib%' 
or lcase(concept_name) like '%dabrafenib%'
or lcase(concept_name) like '%ponatinib%'
or lcase(concept_name) like '%trametinib%'
or lcase(concept_name) like '%cabozantinib%'
or lcase(concept_name) like '%ibrutinib%'
or lcase(concept_name) like '%ceritinib%'
or lcase(concept_name) like '%lenvatinib%'
or lcase(concept_name) like '%nintedanib%'
or lcase(concept_name) like '%cediranib%'
or lcase(concept_name) like '%palbociclib%'
or lcase(concept_name) like '%tivozanib%' 
or lcase(concept_name) like '%osimertinib%'
or lcase(concept_name) like '%alectinib%'
or lcase(concept_name) like '%rociletinib%'
or lcase(concept_name) like '%cobimetinib%'
or lcase(concept_name) like '%midostaurin%'
or lcase(concept_name) like '%olmutinib%'
or lcase(concept_name) like '%binimetinib%'
or lcase(concept_name) like '%ribociclib%'
or lcase(concept_name) like '%brigatinib%'
or lcase(concept_name) like '%lorlatinib%'
or lcase(concept_name) like '%neratinib%' 
or lcase(concept_name) like '%encorafenib%'
or lcase(concept_name) like '%dacomitinib%'
or lcase(concept_name) like '%icotinib%'
or lcase(concept_name) like '%abemaciclib%'
or lcase(concept_name) like '%acalabrutinib%'
or lcase(concept_name) like '%quizartinib%'
or lcase(concept_name) like '%larotrectinib%'
or lcase(concept_name) like '%gilteritinib%'
or lcase(concept_name) like '%entrectinib%'
or lcase(concept_name) like '%fedratinib%' 
or lcase(concept_name) like '%toceranib%' ) then 1 else 0
end as pk_inhibitor,

case when
lcase(concept_name) like '%rituximab%' then 1 else 0
end as rituximab,

case when ( /*other monoclonals: will separate out when sample size permits*/
/*l01xc monoclonal antibodies*/ 
lcase(concept_name) like '%edrecolomab%'
or lcase(concept_name) like '%trastuzumab%'
or lcase(concept_name) like '%gemtuzumab ozogamicin%'
or lcase(concept_name) like '%cetuximab%'
or lcase(concept_name) like '%bevacizumab%'
or lcase(concept_name) like '%panitumumab%'
or lcase(concept_name) like '%catumaxomab%'
or lcase(concept_name) like '%ofatumumab%' 
or lcase(concept_name) like '%brentuximab vedotin%'
or lcase(concept_name) like '%pertuzumab%'
or lcase(concept_name) like '%trastuzumab emtansine%'
or lcase(concept_name) like '%obinutuzumab%'
or lcase(concept_name) like '%dinutuximab beta%'
or lcase(concept_name) like '%blinatumomab%' 
or lcase(concept_name) like '%ramucirumab%'
or lcase(concept_name) like '%necitumumab%'
or lcase(concept_name) like '%elotuzumab%'
or lcase(concept_name) like '%daratumumab%'
or lcase(concept_name) like '%mogamulizumab%'
or lcase(concept_name) like '%inotuzumab ozogamicin%'
or lcase(concept_name) like '%olaratumab%'
or lcase(concept_name) like '%bermekimab%') then 1 else 0
end as monoclonal_other,

case when /*leftover from the l01 category*/
(/*l01aa nitrogen mustard analogues*/
lcase(concept_name) like '%chlorambucil%'
or lcase(concept_name) like '%melphalan%'
or lcase(concept_name) like '%chlormethine%'
or lcase(concept_name) like '%ifosfamide%'
or lcase(concept_name) like '%trofosfamide%'
or lcase(concept_name) like '%prednimustine%'
or lcase(concept_name) like '%bendamustine%' 
/*l01ab alkyl sulfonates*/
or lcase(concept_name) like '%busulfan%'
or lcase(concept_name) like '%treosulfan%'
or lcase(concept_name) like '%mannosulfan%' 
/*l01ac ethylene imines*/
or lcase(concept_name) like '%thiotepa%'
or lcase(concept_name) like '%triaziquone%'
or lcase(concept_name) like '%carboquone%' 
/*l01ad nitrosoureas*/
or lcase(concept_name) like '%carmustine%'
or lcase(concept_name) like '%lomustine%'
or lcase(concept_name) like '%semustine%'
or lcase(concept_name) like '%streptozocin%'
or lcase(concept_name) like '%fotemustine%'
or lcase(concept_name) like '%nimustine%'
or lcase(concept_name) like '%ranimustine%'
or lcase(concept_name) like '%uramustine%' 
/*l01ag epoxides*/
or lcase(concept_name) like '%etoglucid%'
/*l01ax other alkylating agents*/
or lcase(concept_name) like '%mitobronitol%'
or lcase(concept_name) like '%pipobroman%'
or lcase(concept_name) like '%temozolomide%'
or lcase(concept_name) like '%dacarbazine%' 
/*l01ba folic acid analogues*/
or lcase(concept_name) like '%methotrexate%'
or lcase(concept_name) like '%raltitrexed%'
or lcase(concept_name) like '%pemetrexed%'
or lcase(concept_name) like '%pralatrexate%' 
/*l01bb purine analogues*/
or lcase(concept_name) like '%mercaptopurine%'
or lcase(concept_name) like '%tioguanine%'
or lcase(concept_name) like '%cladribine%'
or lcase(concept_name) like '%fludarabine%'
or lcase(concept_name) like '%clofarabine%'
or lcase(concept_name) like '%nelarabine%'
or lcase(concept_name) like '%rabacfosadine%' 
/*l01bc pyrimidine analogues*/
or lcase(concept_name) like '%cytarabine%'
or lcase(concept_name) like '%fluorouracil%'
or lcase(concept_name) like '%tegafur%'
or lcase(concept_name) like '%carmofur%'
or lcase(concept_name) like '%gemcitabine%'
or lcase(concept_name) like '%capecitabine%'
or lcase(concept_name) like '%azacitidine%'
or lcase(concept_name) like '%decitabine%'
or lcase(concept_name) like '%floxuridine%'
or lcase(concept_name) like '%fluorouracil%'
or lcase(concept_name) like '%tegafur%'
or lcase(concept_name) like '%trifluridine%' 
/*l01ca vinca alkaloids and analogues*/
or lcase(concept_name) like '%vinblastine%'
or lcase(concept_name) like '%vincristine%'
or lcase(concept_name) like '%vindesine%'
or lcase(concept_name) like '%vinorelbine%'
or lcase(concept_name) like '%vinflunine%'
or lcase(concept_name) like '%vintafolide%' 
/*l01cb podophyllotoxin derivatives*/
or lcase(concept_name) like '%etoposide%'
or lcase(concept_name) like '%teniposide%' 
/*l01cc colchicine derivatives*/
or lcase(concept_name) like '%demecolcine%' 
/*l01cd taxanes*/
or lcase(concept_name) like '%paclitaxel%'
or lcase(concept_name) like '%docetaxel%'
or lcase(concept_name) like '%paclitaxel poliglumex%'
or lcase(concept_name) like '%cabazitaxel%' 
/*l01cx other plant alkaloids and natural products*/
or lcase(concept_name) like '%trabectedin%' 
/*l01da actinomycines*/
or lcase(concept_name) like '%dactinomycin%' 
/*l01dc other cytotoxic antibiotics*/
or lcase(concept_name) like '%bleomycin%'
or lcase(concept_name) like '%plicamycin%'
or lcase(concept_name) like '%mitomycin%'
or lcase(concept_name) like '%ixabepilone%' 
/*l01xa platinum compounds*/
or lcase(concept_name) like '%cisplatin%'
or lcase(concept_name) like '%carboplatin%'
or lcase(concept_name) like '%oxaliplatin%'
or lcase(concept_name) like '%satraplatin%'
or lcase(concept_name) like '%polyplatillen%' 
/*l01xb methylhydrazines*/
or lcase(concept_name) like '%procarbazine%'
/*l01xd sensitizers used in photodynamic/radiation therapy*/
or lcase(concept_name) like '%porfimer sodium%'
or lcase(concept_name) like '%methyl aminolevulinate%'
or lcase(concept_name) like '%aminolevulinic acid%'
or lcase(concept_name) like '%temoporfin%'
or lcase(concept_name) like '%efaproxiral%'
or lcase(concept_name) like '%padeliporfin%' 
/*l01xx other antineoplastic agents*/
or lcase(concept_name) like '%amsacrine%'
or lcase(concept_name) like '%asparaginase%'
or lcase(concept_name) like '%altretamine%'
or lcase(concept_name) like '%hydroxycarbamide%'
or lcase(concept_name) like '%lonidamine%'
or lcase(concept_name) like '%pentostatin%'
or lcase(concept_name) like '%masoprocol%'
or lcase(concept_name) like '%estramustine%'
/*'tretinoin',*/ 
or lcase(concept_name) like '%mitoguazone%'
or lcase(concept_name) like '%topotecan%'
or lcase(concept_name) like '%tiazofurine%'
or lcase(concept_name) like '%irinotecan%'
or lcase(concept_name) like '%alitretinoin%'
or lcase(concept_name) like '%mitotane%'
or lcase(concept_name) like '%pegaspargase%'
or lcase(concept_name) like '%bexarotene%'
or lcase(concept_name) like '%arsenic trioxide%'
or lcase(concept_name) like '%denileukin diftitox%' 
or lcase(concept_name) like '%bortezomib%'
or lcase(concept_name) like '%anagrelide%'
or lcase(concept_name) like '%oblimersen%'
or lcase(concept_name) like '%sitimagene ceradenovec%'
or lcase(concept_name) like '%vorinostat%'
or lcase(concept_name) like '%romidepsin%'
or lcase(concept_name) like '%omacetaxine mepesuccinate%'
or lcase(concept_name) like '%eribulin%'
or lcase(concept_name) like '%panobinostat%' 
or lcase(concept_name) like '%vismodegib%'
or lcase(concept_name) like '%aflibercept%'
or lcase(concept_name) like '%carfilzomib%'
or lcase(concept_name) like '%olaparib%'
or lcase(concept_name) like '%idelalisib%'
or lcase(concept_name) like '%sonidegib%'
or lcase(concept_name) like '%belinostat%'
or lcase(concept_name) like '%ixazomib%'
or lcase(concept_name) like '%talimogene laherparepvec%'
or lcase(concept_name) like '%venetoclax%' 
or lcase(concept_name) like '%vosaroxin%'
or lcase(concept_name) like '%niraparib%'
or lcase(concept_name) like '%rucaparib%'
or lcase(concept_name) like '%etirinotecan pegol%'
or lcase(concept_name) like '%plitidepsin%'
or lcase(concept_name) like '%epacadostat%'
or lcase(concept_name) like '%enasidenib%'
or lcase(concept_name) like '%talazoparib%'
or lcase(concept_name) like '%copanlisib%'
or lcase(concept_name) like '%ivosidenib%' 
or lcase(concept_name) like '%glasdegib%'
or lcase(concept_name) like '%entinostat%'
or lcase(concept_name) like '%alpelisib%'
or lcase(concept_name) like '%selinexor%'
or lcase(concept_name) like '%tagraxofusp%'
or lcase(concept_name) like '%belotecan%'
or lcase(concept_name) like '%tigilanol tiglate%' 
/*l01xy combinations of antineoplastic agents*/
or lcase(concept_name) like '%cytarabine%') then 1 else 0
end as l01_other,

case when (lcase(concept_name) like '%azathioprine%') then 1 else 0
end as azathioprine,

case
    when (lcase(concept_name) like '%ciclosporin%'
or lcase(concept_name) like '%cyclosporin%'
or lcase(concept_name) like '%tacrolimus%'
or lcase(concept_name) like '%voclosporin%') then 1 else 0
end as calcineurin_inhibitor,

case
    when (lcase(concept_name) like '%daciluzumab%'
or lcase(concept_name) like '%basiliximab%'
or lcase(concept_name) like '%anakinra%'
or lcase(concept_name) like '%rilonacept%'
or lcase(concept_name) like '%ustekinumab%'
or lcase(concept_name) like '%tocilizumab%'
or lcase(concept_name) like '%canakinumab%'
or lcase(concept_name) like '%briakinumab%'
or lcase(concept_name) like '%secukinumab%'
or lcase(concept_name) like '%siltuximab%'
or lcase(concept_name) like '%brodalumab%'
or lcase(concept_name) like '%ixekizumab%'
or lcase(concept_name) like '%sarilumab%'
or lcase(concept_name) like '%sirukumab%'
or lcase(concept_name) like '%guselkumab%'
or lcase(concept_name) like '%tildrakizumab%'
or lcase(concept_name) like '%risankizumab%') then 1 else 0
end as il_inhibitor ,

case when (/*janus kinase (jak) inhibitors*/
lcase(concept_name) like '%tofacitinib%'
or lcase(concept_name) like '%baricitinib%'
or lcase(concept_name) like '%upadacitinib%' ) then 1 else 0
end as jak_inhibitor,

case when /*mycophenolate and derivates*/
(lcase(concept_name) like '%mycophenolic acid%'
or lcase(concept_name) like '%mycophenolate sodium%'
or lcase(concept_name) like '%mycophenolate mofetil%') then 1 else 0
end as mycophenol,

case 
    when (lcase(concept_name) like '%etanercept%'
or lcase(concept_name) like '%infliximab%'
or lcase(concept_name) like '%afelimomab%'
or lcase(concept_name) like '%adalimumab%'
or lcase(concept_name) like '%certolizumab pegol%'
or lcase(concept_name) like '%golimumab%'
or lcase(concept_name) like '%opinercept%')  then 1 else 0
end as tnf_inhibitor,

case when /*all else left from l04*/
(/*atc code l04aa - selective immunosuppressants*/ 
lcase(concept_name) like '%muromonab-cd3%'
or lcase(concept_name) like '%antilymphocyte immunoglobulin (horse)%'
or lcase(concept_name) like '%antithmyocyte immunoglobulin (rabbit)%'
or lcase(concept_name) like '%sirolimus%'
or lcase(concept_name) like '%leflunomide%'
or lcase(concept_name) like '%alefacept%'
or lcase(concept_name) like '%everolimus%'
or lcase(concept_name) like '%gusperimus%'
or lcase(concept_name) like '%efalizumab%'
or lcase(concept_name) like '%abetimus%' 
or lcase(concept_name) like '%natalizumab%'
or lcase(concept_name) like '%abatacept%'
or lcase(concept_name) like '%eculizumab%'
or lcase(concept_name) like '%belimumab%'
or lcase(concept_name) like '%fingolimod%'
or lcase(concept_name) like '%belatacept%'
or lcase(concept_name) like '%teriflunomide%'
or lcase(concept_name) like '%apremilast%'
or lcase(concept_name) like '%vedolizumab%'
or lcase(concept_name) like '%alemtuzumab%'
or lcase(concept_name) like '%begelomab%'
or lcase(concept_name) like '%ocrelizumab%'
or lcase(concept_name) like '%ozanimod%'
or lcase(concept_name) like '%emapalumab%'
or lcase(concept_name) like '%cladribine%'
or lcase(concept_name) like '%imlifidase%'
or lcase(concept_name) like '%siponimod%'
or lcase(concept_name) like '%ravulizumab%'
/*atc code l04ax - other immunosuppressants*/
or lcase(concept_name) like '%thalidomide%'
or lcase(concept_name) like '%lenalidomide%'
or lcase(concept_name) like '%pirfenidone%'
or lcase(concept_name) like '%pomalidomide%'
or lcase(concept_name) like '%dimethyl fumarate%'
or lcase(concept_name) like '%darvadstrocel%') then 1 else 0
end as l04_other,

case when (lcase(concept_name) like '%dexamethasone%'
or lcase(concept_name) like '%prednisone%'
or lcase(concept_name) like '%prednisolone%'
or lcase(concept_name) like '%methylprednisolone%') then 1 else 0
end as glucocorticoid, 

case when (
    lcase(drug_concept_name) like '%prednisone 5 mg delayed release oral tablet%' 
    or lcase(drug_concept_name) like'prednisone 10 mg oral tablet'
    or lcase(drug_concept_name) like 'prednisone 20 mg oral tablet [deltasone]'
    or lcase(drug_concept_name) like 'prednisone 50 mg oral tablet'
    or lcase(drug_concept_name) like 'prednisone 20 mg oral tablet [predone]'
    or lcase(drug_concept_name) like 'prednisone 10 mg oral tablet [predone]'
    or lcase(drug_concept_name) like '{21 (prednisone 10 mg oral tablet{ } pack'
    or lcase(drug_concept_name) like '{10 (prednisone 10 mg oral tablet) } pack'
    or lcase(drug_concept_name) like 'prednisone 50 mg oral tablet [orasone]'
    or lcase(drug_concept_name) like 'methylprednisolone 8 mg oral tablet'
    or lcase(drug_concept_name) like 'methylprednisolone 32 mg oral tablet'
    or lcase(drug_concept_name) like 'prednisone 10 mg oral tablet [deltasone]'
    or lcase(drug_concept_name) like 'methylprednisolone 16 mg oral tablet'
    or lcase(drug_concept_name) like '{25 (prednisone 10 mg oral tablet) } pack'
    or lcase(drug_concept_name) like 'methylprednisolone 16 mg oral tablet [medrol]'
    or lcase(drug_concept_name) like '{48 (prednisone 10 mg oral tablet) } pack'
    or lcase(drug_concept_name) like 'methylprednisolone 8 mg oral tablet [medrol]'
    or lcase(drug_concept_name) like 'methylprednisolone 32 mg oral tablet [medrol]'
    or lcase(drug_concept_name) like 'prednisolone 10 mg disintegrating oral tablet [orapred]'
    or lcase(drug_concept_name) like 'prednisone 50 mg oral tablet [deltasone]'
    or lcase(drug_concept_name) like 'prednisolone 30 mg disintegrating oral tablet [orapred]'
    or lcase(drug_concept_name) like 'prednisolone 15 mg disintegrating oral tablet'
    or lcase(drug_concept_name) like 'prednisolone 10 mg disintegrating oral tablet'
    or lcase(drug_concept_name) like 'prednisolone 30 mg disintegrating oral tablet'
    or lcase(drug_concept_name) like 'prednisolone 15 mg disintegrating oral tablet [orapred]'
    or lcase(drug_concept_name) like '{21 (prednisone 10 mg oral tablet [sterapred ds]) } pack [sterapred ds uni-pack]'
    or lcase(drug_concept_name) like 'methylprednisolone 100 mg'
    or lcase(drug_concept_name) like 'methylprednisolone 40 mg'
    or lcase(drug_concept_name) like 'dexamethasone 4 mg oral tablet'
    or lcase(drug_concept_name) like 'dexamethasone 2 mg oral tablet'
    or lcase(drug_concept_name) like 'dexamethaonse 6 mg oral tablet [decadron]'
    or lcase(drug_concept_name) like 'dexamethasone 4 mg oral tablet [hexadrol]'
    or lcase(drug_concept_name) like 'dexamethasone 4 mg oral tablet [decadron]'
    or lcase(drug_concept_name) like 'dexamethasone 6 mg oral tablet'
    or lcase(drug_concept_name) like 'dexamethasone 1.5 mg oral tablet [decadron]'
    or lcase(drug_concept_name) like 'dexamethasone 20 mg oral tablet'
    or lcase(drug_concept_name) like '{21 (dexamethasone 1.5 mg oral tablet) } pack'
    or lcase(drug_concept_name) like '{25 (dexamethasone 1.5 mg oral tablet) } pack'
    or lcase(drug_concept_name) like 'dexamethasone 20 mg oral tablet [hemady]'
    or lcase(drug_concept_name) like '{21 (dexamethasone 1.5 mg oral tablet) } pack [dexpak taperpak 6 day]'
    or lcase(drug_concept_name) like '{35 (dexamethasone 1.5 mg oral tablet) } pack'
    or lcase(drug_concept_name) like '{21 (dexamethasone 1.5 mg oral tablet) } pack [zema pak 6 day]'
    or lcase(drug_concept_name) like '{41 (dexamethasone 1.5 mg oral tablet) } pack'
    or lcase(drug_concept_name) like '{51 (dexamethasone 1.5 mg oral tablet) } pack'
    or lcase(drug_concept_name) like '25 (dexamethasone 1.5 mg oral tablet) } pack [zcort 7 day taper]'
) then 1 else 0
end as gluco_dose_known_high

from immuno_extract

@transform_pandas(
    Output(rid="ri.foundry.main.dataset.90d892f4-9e09-45d3-bfad-2efbc3d68788"),
    drug_exposure=Input(rid="ri.foundry.main.dataset.ec252b05-8f82-4f7f-a227-b3bb9bc578ef"),
    immuno_concepts=Input(rid="ri.foundry.main.dataset.84100de9-e0dc-4141-b768-91dfaa273667")
)
---Keeping immunosuppression drug records (at any time)
SELECT d.person_id, d.drug_concept_name, d.drug_exposure_start_date, d.drug_exposure_end_date, i.concept_name
FROM drug_exposure d
inner join immuno_concepts i
    on d.drug_concept_id = i.concept_id

@transform_pandas(
    Output(rid="ri.vector.main.execute.fd170ca6-4cbd-4d1e-94ff-81d997c1bfa0"),
    pred_reasons_conditions=Input(rid="ri.vector.main.execute.7b54d92b-4a19-4943-8928-ffa43d8ad065")
)
SELECT person_id,
    SUM (psoriasis) as psoriasis_sum,
    SUM (colitis) as colitis_sum,
    SUM (crohns) as crohns_sum, 
    SUM (rheum_arthritis) as rheum_arthritis_sum,
    SUM (emphysema_copd) as emphysema_copd_sum, 
    SUM (asthma) as asthma_sum, 
    SUM (lupus) as lupus_sum, 
    SUM (vasculitis) as vasculitis_sum, 
    SUM (as_axspa) as as_axspa_sum, 
    SUM (psa) as psa_sum
FROM pred_reasons_conditions
    GROUP BY person_id

@transform_pandas(
    Output(rid="ri.vector.main.execute.7b54d92b-4a19-4943-8928-ffa43d8ad065"),
    condition_occurrence=Input(rid="ri.foundry.main.dataset.900fa2ad-87ea-4285-be30-c6b5bab60e86"),
    prednisone_reasons_concepts=Input(rid="ri.vector.main.execute.c77608e8-95ff-4950-af04-3671347dfbde")
)
---Pulling all instances of any of the prednisone reasons
---ALso tried the observations table, but this was pulling rheumatoid factor test results rather than RA diagnoses, etc. So I left it out.
SELECT a.*, c.concept_name,
CASE
    WHEN (
        lcase(concept_name) like '%psoriasis%'
        OR lcase(concept_name) like '%acrodermatitis%'
        OR lcase(concept_name) like '%pustulosis%'
        ) THEN 1 ELSE 0
    END AS psoriasis,
CASE
    WHEN (lcase(concept_name) like '%ulcerative colitis%'
        OR lcase(concept_name) like '%pancolitis%'
        OR lcase(concept_name) like '%proctitis%'
        OR lcase(concept_name) like '%rectosigmoiditis%'
        or lcase(concept_name) like '%inflammatory polyps%'
        or lcase(concept_name) like '%colitis%'
    ) THEN 1 ELSE 0
    END AS colitis,
CASE
    WHEN (lcase(concept_name) like '%crohn%') THEN 1 ELSE 0
    END AS crohns,
CASE
    WHEN (lcase(concept_name) like '%rheumatoid%'
        or lcase(concept_name) like '%Felty%'
        or lcase(concept_name) like '%Still%'
        or lcase(concept_name) like '%polyarthropathy'
    ) THEN 1 ELSE 0
    END AS rheum_arthritis,
CASE
    WHEN (lcase(concept_name) like '%emphysema%'
        OR lcase(concept_name) like '%chronic obstructive pulmonary disease%'
    ) THEN 1 ELSE 0
    END AS emphysema_copd,
CASE
    WHEN (lcase(concept_name) like '%asthma%'
        OR lcase(concept_name) like '%bronchospasm%'
    ) THEN 1 ELSE 0
    END AS asthma, 
CASE 
    WHEN (lcase(concept_name) like '%lupus%') THEN 1 ELSE 0
    END AS lupus,
CASE 
    WHEN (lcase(concept_name) like '%vasculitis%') THEN 1 ELSE 0
    END AS vasculitis,
CASE 
    WHEN (lcase(concept_name) like '%ankylosing spondylitis%'
        OR lcase(concept_name) like '%axial spondyloarthritis%')
    THEN 1 ELSE 0
    END AS as_axspa, 
CASE
    WHEN (lcase(concept_name) like '%psoriatic arthritis%'
    or lcase(concept_name) like '%arthropathic psoriasis%'
    or lcase(concept_name) like '%psoriatic spondylarthropathy%')
    THEN 1 ELSE 0
    END AS psa

FROM prednisone_reasons_concepts c
inner join condition_occurrence a
    on c.concept_id = a.condition_concept_id

@transform_pandas(
    Output(rid="ri.vector.main.execute.c77608e8-95ff-4950-af04-3671347dfbde"),
    concept=Input(rid="ri.foundry.main.dataset.5cb3c4a3-327a-47bf-a8bf-daf0cafe6772")
)
---January 29: here I'm searching key words as identified from the ICD listing of these diagnoses
SELECT concept_id, concept_name
FROM concept
WHERE /*L40 - psoriasis*/ 
lcase(concept_name) like '%psoriasis%'
OR lcase(concept_name) like '%acrodermatitis%'
OR lcase(concept_name) like '%pustulosis%'
OR lcase(concept_name) like '%psoriatic%'
/*K51 - ulcerative colitis*/
OR lcase(concept_name) like '%ulcerative colitis%'
OR lcase(concept_name) like '%pancolitis%'
OR lcase(concept_name) like '%proctitis%'
OR lcase(concept_name) like '%rectosigmoiditis%'
or lcase(concept_name) like '%inflammatory polyps%'
or lcase(concept_name) like '%colitis%'
/*K50 - Crohn's, all branches underneath this umbrella have the term Crohn*/
OR lcase(concept_name) like '%crohn%'
/*M05 and M06 - Rheumatoid arthritis*/
OR lcase(concept_name) like '%rheumatoid%'
or lcase(concept_name) like '%Felty%'
or lcase(concept_name) like '%Still%'
or lcase(concept_name) like '%polyarthropathy'
/*J43 and J44 - Emphysema and other COPD*/
OR lcase(concept_name) like '%emphysema%'
OR lcase(concept_name) like '%chronic obstructive pulmonary disease%'
/*asthma*/
OR lcase(concept_name) like '%asthma%'
OR lcase(concept_name) like '%bronchospasm%'
/*lupus*/
or lcase(concept_name) like '%lupus%'
/*vasculitis*/
or lcase(concept_name) like '%vasculitis%'
/*AxSpa or AS*/
or lcase(concept_name) like '%ankylosing spondylitis%'
or lcase(concept_name) like '%axial spondyloarthritis%'
/*PsA*/
or lcase(concept_name) like '%psoriatic arthritis%'
or lcase(concept_name) like '%arthropathic psoriasis%'
or lcase(concept_name) like '%psoriatic spondylarthropathy%'

