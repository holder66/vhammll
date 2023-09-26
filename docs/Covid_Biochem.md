## Predicting Survival and Kidney Injury of COVID-19 Patients from Clinical and Biochemistry Data
A recent [paper](https://arxiv.org/pdf/2204.11210.pdf) by Hossein Aboutalebi and colleagues details a process they went through to build machine learning models for the prediction of survival and acute kidney injury of COVID-19 patients, based on clinical and biochemistry data. The framework they developed consists of a collaborative effort between machine learning experts and clinicians in which models are progressively refined by clinician inputs in an "explainability-driven" approach to help identify those clinical and biochemical markers which may help to improve prediction performance, clinical validity, and trustworthiness of the final machine learning models.

In contrast to this approach, the HamNN algorithm attempts to build a model using only the available data, with the goal of helping clinicians to better understand which variables are useful in predicting outcomes, so that their energies can be better directed towards collecting useful information and informing the design of treatment approaches which can potentially improve those outcomes. 

Here is the process which I followed.

### Massage the dataset so it can be read by the HamNN library
The [dataset](https://github.com/h-aboutalebi/CovidBiochem/blob/master/Covid_biochem/pytorch_tabular_main/data/clinical_data.csv) used by Aboutalebi and colleagues is derived from clinical data collected by Stony Brook University for 1335 COVID-19 positive patients and anonymized. 

1. Copy the contents from the github file and paste into a new file in a text editor;
2. In the editor, eplace all the commas with tabs;
3. Save the file as datasets/covid_biochem.tab;
4. Following the Orange-newer format (`./vhamnn orange`), add the prefix `i#` to the first attribute name `to_patient_id` to obtain `i#to_patient_id` (so that this attribute will be ignored by HamNN);
5. Add the prefix `c#` to the target variable to identify it as the class attribute. For survival prediction, the target variable is `last.status` which then becomes `c#last.status`. Save the file.

### Examine the dataset
```sh
➜  vhamnn git:(master) ✗ v -prod .
➜  vhamnn git:(master) ✗ ./vhamnn analyze datasets/covid_biochem.tab 


Analysis of Dataset "datasets/covid_biochem.tab" (File Type orange_newer)
All Attributes
 Index  Name                          Count  Uniques  Missing      %  Type
     0  to_patient_id                  1365     1365        0    0.0     i
     1  covid19_statuses               1365        1        0    0.0     i
     2  last.status                    1365        2        0    0.0     c
     3  age.splits                     1365        3        0    0.0     D
     4  gender_concept_name            1365        3        0    0.0     C
     5  visit_start_datetime           1365        3       32    2.3     D
     6  visit_concept_name             1365       30        0    0.0     C
     7  is_icu                         1365        3        0    0.0     D
     8  was_ventilated                 1365        2        0    0.0     D
     9  invasive_vent_days             1365        2        0    0.0     D
    10  length_of_stay                 1365       39     1152   84.4     C
    11  Acute.Hepatic.Injury..during.hospitalization.    1365       67        0    0.0     C
    12  Acute.Kidney.Injury..during.hospitalization.    1365        3      246   18.0     D
    13  Urine.protein                  1365        2        0    0.0     D
    14  kidney_replacement_therapy     1365        3      826   60.5     D
    15  kidney_transplant              1365        2     1295   94.9     D
    16  htn_v                          1365        2     1343   98.4     D
    17  dm_v                           1365        3      266   19.5     D
    18  cad_v                          1365        3      264   19.3     D
    19  hf_ef_v                        1365        3      268   19.6     D
    20  ckd_v                          1365        4      277   20.3     D
    21  malignancies_v                 1365        3      267   19.6     D
    22  copd_v                         1365        3      277   20.3     D
    23  other_lung_disease_v           1365        3      268   19.6     D
    24  acei_v                         1365        3      268   19.6     D
    25  arb_v                          1365        3      276   20.2     D
    26  antibiotics_use_v              1365        3      274   20.1     D
    27  nsaid_use_v                    1365        3      298   21.8     D
    28  days_prior_sx                  1365        3      320   23.4     D
    29  smoking_status_v               1365       27      346   25.3     C
    30  cough_v                        1365        4      324   23.7     D
    31  dyspnea_admission_v            1365        3      322   23.6     D
    32  nausea_v                       1365        3      309   22.6     D
    33  vomiting_v                     1365        3      353   25.9     D
    34  diarrhea_v                     1365        3      346   25.3     D
    35  abdominal_pain_v               1365        3      337   24.7     D
    36  fever_v                        1365        3      350   25.6     D
    37  BMI.over30                     1365        3      307   22.5     D
    38  BMI.over35                     1365        3      422   30.9     D
    39  temperature.over38             1365        3      422   30.9     D
    40  pulseOx.under90                1365        3       35    2.6     D
    41  Respiration.over24             1365        3        5    0.4     D
    42  HeartRate.over100              1365        3        5    0.4     D
    43  Lymphocytes.under1k            1365        3        6    0.4     D
    44  Aspartate.over40               1365        3      403   29.5     D
    45  Alanine.over60                 1365        3      257   18.8     D
    46  A1C.over6.5                    1365        3      257   18.8     D
    47  A1C.under6.5                   1365        3      937   68.6     D
    48  A1C.6.6to7.9                   1365        3      937   68.6     D
    49  A1C.8to9.9                     1365        3      937   68.6     D
    50  A1C.over10                     1365        3      937   68.6     D
    51  Sodium.above145                1365        3      937   68.6     D
    52  Sodium.between135and145        1365        3      207   15.2     D
    53  Sodium.below135                1365        3      207   15.2     D
    54  Potassium.above5.2             1365        3      207   15.2     D
    55  Potassium.between3.5and5.2     1365        3      263   19.3     D
    56  Potassium.below3.5             1365        3      263   19.3     D
    57  Chloride.above107              1365        3      263   19.3     D
    58  Chloride.between96and107       1365        3      207   15.2     D
    59  Chloride.below96               1365        3      207   15.2     D
    60  Bicarbonate.above31            1365        3      207   15.2     D
    61  Bicarbonate.between21and31     1365        3      208   15.2     D
    62  Bicarbonate.below21            1365        3      208   15.2     D
    63  Blood_Urea_Nitrogen.above20    1365        3      208   15.2     D
    64  Blood_Urea_Nitrogen.between5and20    1365        3      207   15.2     D
    65  Blood_Urea_Nitrogen.below5     1365        3      207   15.2     D
    66  Creatinine.above1.2            1365        3      207   15.2     D
    67  Creatinine.between0.5and1.2    1365        3      207   15.2     D
    68  Creatinine.below0.5            1365        3      207   15.2     D
    69  eGFR.above60                   1365        3      207   15.2     D
    70  eGFR.between30and60            1365        3      225   16.5     D
    71  eGFR.below30                   1365        3      225   16.5     D
    72  blood_pH.above7.45             1365        3      225   16.5     D
    73  blood_pH.between7.35and7.45    1365        3     1140   83.5     D
    74  blood_pH.below7.35             1365        3     1140   83.5     D
    75  Troponin.above0.01             1365        3     1140   83.5     D
    76  D_dimer.above3000              1365        3      406   29.7     D
    77  D_dimer.between500and3000      1365        3      415   30.4     D
    78  D_dimer.below500               1365        3      415   30.4     D
    79  ESR.above30                    1365        3      415   30.4     D
    80  Microscopic_hematuria.above2    1365        3      764   56.0     D
    81  SBP.below120                   1365        3      835   61.2     D
    82  SBP.between120and139           1365        3        4    0.3     D
    83  SBP.above139                   1365        3        4    0.3     D
    84  MAP.below65                    1365        3        4    0.3     D
    85  MAP.between65and90             1365        3      198   14.5     D
    86  MAP.above90                    1365        3      198   14.5     D
    87  procalcitonin.below0.25        1365        3      198   14.5     D
    88  procalcitonin.between0.25and0.5    1365        3      330   24.2     D
    89  procalcitonin.above0.5         1365        3      330   24.2     D
    90  ferritin.above1k               1365        3      330   24.2     D
    91  Proteinuria.above80            1365        3      480   35.2     D
    92  8331-1_Oral temperature        1365        3     1153   84.5     D
    93  59408-5_Oxygen saturation in Arterial blood by Pulse oximetry    1365       41       35    2.6     C
    94  9279-1_Respiratory rate        1365       39        5    0.4     C
    95  76282-3_Heart rate.beat-to-beat by EKG    1365       43        5    0.4     C
    96  8480-6_Systolic blood pressure    1365      108        6    0.4     C
    97  76536-2_Mean blood pressure by Noninvasive    1365      128        4    0.3     C
    98  33256-9_Leukocytes [*/volume] corrected for nucleated erythrocytes in Blood by Automated count    1365       88      198   14.5     C
    99  751-8_Neutrophils [*/volume] in Blood by Automated count    1365      739      205   15.0     C
   100  731-0_Lymphocytes [*/volume] in Blood by Automated count    1365      602      403   29.5     C
   101  2951-2_Sodium [Moles/volume] in Serum or Plasma    1365      232      403   29.5     C
   102  1920-8_Aspartate aminotransferase [Enzymatic activity/volume] in Serum or Plasma    1365       47      207   15.2     C
   103  1744-2_Alanine aminotransferase [Enzymatic activity/volume] in Serum or Plasma by No addition of P-5'-P    1365      173      257   18.8     C
   104  2157-6_Creatine kinase [Enzymatic activity/volume] in Serum or Plasma    1365      160      257   18.8     C
   105  2524-7_Lactate [Moles/volume] in Serum or Plasma    1365      277      920   67.4     C
   106  6598-7_Troponin T.cardiac [Mass/volume] in Serum or Plasma    1365       72      340   24.9     C
   107  33762-6_Natriuretic peptide.B prohormone N-Terminal [Mass/volume] in Serum or Plasma    1365       36      406   29.7     C
   108  75241-0_Procalcitonin [Mass/volume] in Serum or Plasma by Immunoassay    1365      498      592   43.4     C
   109  48058-2_Fibrin D-dimer DDU [Mass/volume] in Platelet poor plasma by Immunoassay    1365      183      330   24.2     C
   110  2276-4_Ferritin [Mass/volume] in Serum or Plasma    1365      557      415   30.4     C
   111  1988-5_C reactive protein [Mass/volume] in Serum or Plasma    1365      849      480   35.2     C
   112  4548-4_Hemoglobin A1c/Hemoglobin.total in Blood    1365      295      316   23.2     C
   113  39156-5_Body mass index (BMI) [Ratio]    1365       88      937   68.6     C
   114  2951-2_Sodium [Moles/volume] in Serum or Plasma.1    1365      665      422   30.9     C
   115  2823-3_Potassium [Moles/volume] in Serum or Plasma    1365       47      207   15.2     C
   116  2075-0_Chloride [Moles/volume] in Serum or Plasma    1365       48      263   19.3     C
   117  1963-8_Bicarbonate [Moles/volume] in Serum or Plasma    1365       51      207   15.2     C
   118  3094-0_Urea nitrogen [Mass/volume] in Serum or Plasma    1365       34      208   15.2     C
   119  2160-0_Creatinine [Mass/volume] in Serum or Plasma    1365       99      207   15.2     C
   120  "62238-1_Glomerular filtration rate/1.73 sq M.predicted [Volume Rate/Area] in Serum    1365      252      207   15.2     C
   121   Plasma or Blood by Creatinine-based formula (CKD-EPI)"    1365      119      225   16.5     C
   122  33254-4_pH of Arterial blood adjusted to patient's actual temperature    1365       54     1140   83.5     C
   123  30341-2_Erythrocyte sedimentation rate    1365      118      764   56.0     C
   124  2345-7_Glucose [Mass/volume] in Serum or Plasma    1365      239      207   15.2     C
   125  13457-7_Cholesterol in LDL [Mass/volume] in Serum or Plasma by calculation    1365      104     1068   78.2     C
   126  13458-5_Cholesterol in VLDL [Mass/volume] in Serum or Plasma by calculation    1365       55     1067   78.2     C
   127  2571-8_Triglyceride [Mass/volume] in Serum or Plasma    1365      159     1054   77.2     C
   128  2085-9_Cholesterol in HDL [Mass/volume] in Serum or Plasma    1365       55     1065   78.0     C
   129  therapeutic.exnox.Boolean      1365        3       92    6.7     D
   130  therapeutic.heparin.Boolean    1365        3       92    6.7     D
   131  Other.anticoagulation.therapy    1365        8       92    6.7     D
_______                             _______           _______  _____
Totals (less Class attribute)        180180             47487  26.36%
Counts of Attributes by Type
Type        Count
i               2
c               1
D              88
C              41
Total:        132
Discrete Attributes for Training (88 attributes)
 Index  Name                        Uniques
     3  age.splits                        3
     5  visit_start_datetime              3
     7  is_icu                            3
     8  was_ventilated                    2
     9  invasive_vent_days                2
    12  Acute.Kidney.Injury..during.hospitalization.       3
    13  Urine.protein                     2
    14  kidney_replacement_therapy        3
    15  kidney_transplant                 2
    16  htn_v                             2
    17  dm_v                              3
    18  cad_v                             3
    19  hf_ef_v                           3
    20  ckd_v                             4
    21  malignancies_v                    3
    22  copd_v                            3
    23  other_lung_disease_v              3
    24  acei_v                            3
    25  arb_v                             3
    26  antibiotics_use_v                 3
    27  nsaid_use_v                       3
    28  days_prior_sx                     3
    30  cough_v                           4
    31  dyspnea_admission_v               3
    32  nausea_v                          3
    33  vomiting_v                        3
    34  diarrhea_v                        3
    35  abdominal_pain_v                  3
    36  fever_v                           3
    37  BMI.over30                        3
    38  BMI.over35                        3
    39  temperature.over38                3
    40  pulseOx.under90                   3
    41  Respiration.over24                3
    42  HeartRate.over100                 3
    43  Lymphocytes.under1k               3
    44  Aspartate.over40                  3
    45  Alanine.over60                    3
    46  A1C.over6.5                       3
    47  A1C.under6.5                      3
    48  A1C.6.6to7.9                      3
    49  A1C.8to9.9                        3
    50  A1C.over10                        3
    51  Sodium.above145                   3
    52  Sodium.between135and145           3
    53  Sodium.below135                   3
    54  Potassium.above5.2                3
    55  Potassium.between3.5and5.2        3
    56  Potassium.below3.5                3
    57  Chloride.above107                 3
    58  Chloride.between96and107          3
    59  Chloride.below96                  3
    60  Bicarbonate.above31               3
    61  Bicarbonate.between21and31        3
    62  Bicarbonate.below21               3
    63  Blood_Urea_Nitrogen.above20       3
    64  Blood_Urea_Nitrogen.between5and20       3
    65  Blood_Urea_Nitrogen.below5        3
    66  Creatinine.above1.2               3
    67  Creatinine.between0.5and1.2       3
    68  Creatinine.below0.5               3
    69  eGFR.above60                      3
    70  eGFR.between30and60               3
    71  eGFR.below30                      3
    72  blood_pH.above7.45                3
    73  blood_pH.between7.35and7.45       3
    74  blood_pH.below7.35                3
    75  Troponin.above0.01                3
    76  D_dimer.above3000                 3
    77  D_dimer.between500and3000         3
    78  D_dimer.below500                  3
    79  ESR.above30                       3
    80  Microscopic_hematuria.above2       3
    81  SBP.below120                      3
    82  SBP.between120and139              3
    83  SBP.above139                      3
    84  MAP.below65                       3
    85  MAP.between65and90                3
    86  MAP.above90                       3
    87  procalcitonin.below0.25           3
    88  procalcitonin.between0.25and0.5       3
    89  procalcitonin.above0.5            3
    90  ferritin.above1k                  3
    91  Proteinuria.above80               3
    92  8331-1_Oral temperature           3
   129  therapeutic.exnox.Boolean         3
   130  therapeutic.heparin.Boolean       3
   131  Other.anticoagulation.therapy       8
Continuous Attributes for Training (41 attributes)
 Index  Name                               Min         Max
     4  gender_concept_name                 59          90
     6  visit_concept_name                   1          12
    10  length_of_stay                       1          40
    11  Acute.Hepatic.Injury..during.hospitalization.          1          96
    29  smoking_status_v                     0          60
    93  59408-5_Oxygen saturation in Arterial blood by Pulse oximetry     34.400      39.800
    94  9279-1_Respiratory rate             55         100
    95  76282-3_Heart rate.beat-to-beat by EKG         11          95
    96  8480-6_Systolic blood pressure          6         245
    97  76536-2_Mean blood pressure by Noninvasive         55         222
    98  33256-9_Leukocytes [*/volume] corrected for nucleated erythrocytes in Blood by Automated count         40         168
    99  751-8_Neutrophils [*/volume] in Blood by Automated count      0.920      89.470
   100  731-0_Lymphocytes [*/volume] in Blood by Automated count      0.360      16.390
   101  2951-2_Sodium [Moles/volume] in Serum or Plasma      0.050       4.970
   102  1920-8_Aspartate aminotransferase [Enzymatic activity/volume] in Serum or Plasma        112         169
   103  1744-2_Alanine aminotransferase [Enzymatic activity/volume] in Serum or Plasma by No addition of P-5'-P          8        2786
   104  2157-6_Creatine kinase [Enzymatic activity/volume] in Serum or Plasma          5        2909
   105  2524-7_Lactate [Moles/volume] in Serum or Plasma         11        6139
   106  6598-7_Troponin T.cardiac [Mass/volume] in Serum or Plasma      0.500      23.800
   107  33762-6_Natriuretic peptide.B prohormone N-Terminal [Mass/volume] in Serum or Plasma      0.010       1.810
   108  75241-0_Procalcitonin [Mass/volume] in Serum or Plasma by Immunoassay          5      267600
   109  48058-2_Fibrin D-dimer DDU [Mass/volume] in Platelet poor plasma by Immunoassay      0.020     193.500
   110  2276-4_Ferritin [Mass/volume] in Serum or Plasma        150       63670
   111  1988-5_C reactive protein [Mass/volume] in Serum or Plasma      5.300       16291
   112  4548-4_Hemoglobin A1c/Hemoglobin.total in Blood      0.100      62.700
   113  39156-5_Body mass index (BMI) [Ratio]      4.200          17
   114  2951-2_Sodium [Moles/volume] in Serum or Plasma.1     11.950      92.800
   115  2823-3_Potassium [Moles/volume] in Serum or Plasma        112         169
   116  2075-0_Chloride [Moles/volume] in Serum or Plasma          2       7.700
   117  1963-8_Bicarbonate [Moles/volume] in Serum or Plasma         60         134
   118  3094-0_Urea nitrogen [Mass/volume] in Serum or Plasma          6          43
   119  2160-0_Creatinine [Mass/volume] in Serum or Plasma          3         231
   120  "62238-1_Glomerular filtration rate/1.73 sq M.predicted [Volume Rate/Area] in Serum      0.340      27.790
   121   Plasma or Blood by Creatinine-based formula (CKD-EPI)"          2         120
   122  33254-4_pH of Arterial blood adjusted to patient's actual temperature      6.880       7.550
   123  30341-2_Erythrocyte sedimentation rate          5         145
   124  2345-7_Glucose [Mass/volume] in Serum or Plasma         28         943
   125  13457-7_Cholesterol in LDL [Mass/volume] in Serum or Plasma by calculation         12         399
   126  13458-5_Cholesterol in VLDL [Mass/volume] in Serum or Plasma by calculation          8          79
   127  2571-8_Triglyceride [Mass/volume] in Serum or Plasma         10        3524
   128  2085-9_Cholesterol in HDL [Mass/volume] in Serum or Plasma         10          98
The Class Attribute: "last.status" (2 classes)
Class Value           Cases
discharged             1183
deceased                182
processing time: 0 hrs 0 min  0.120 sec
```

We can see that the there are many missing values in this dataset, 26.36%, and that the two outcome classes are highly unbalanced (1183 patients were discharged, ie survived, while 182 died).
There are also many categorical variables which relate to laboratory values being inside or outside of specific ranges of values. These could probably be ignored, because the "binning" process for the underlying numeric lab values accomplishes essentially the same thing.

### Rank order the dataset's attributes
```
➜  vhamnn git:(master) ✗ ./vhamnn rank datasets/covid_biochem.tab       


Attributes Sorted by Rank Value, for "datasets/covid_biochem.tab"
Missing values: included
Bin range for continuous attributes: from 2 to 16 with interval 1
 Index  Name                         Type   Rank Value   Bins
    13  Urine.protein                D           58.20      0
     8  was_ventilated               D           49.03      0
     9  invasive_vent_days           D           46.66      0
    10  length_of_stay               C           46.66      2
   119  2160-0_Creatinine [Mass/volume] in Serum or Plasma  C           46.32     16
     3  age.splits                   D           44.80      0
     4  gender_concept_name          C           44.80      3
   121   Plasma or Blood by Creatinine-based formula (CKD-EPI)"  C           43.70     10
    64  Blood_Urea_Nitrogen.between5and20  D           43.15      0
    65  Blood_Urea_Nitrogen.below5   D           42.52      0
    70  eGFR.between30and60          D           39.22      0
    67  Creatinine.between0.5and1.2  D           38.72      0
    68  Creatinine.below0.5          D           36.98      0
    88  procalcitonin.between0.25and0.5  D           35.46      0
   130  therapeutic.heparin.Boolean  D           35.00      0
   122  33254-4_pH of Arterial blood adjusted to patient's actual temperature  C           34.95     11
    73  blood_pH.between7.35and7.45  D           34.87      0
    74  blood_pH.below7.35           D           34.87      0
    75  Troponin.above0.01           D           34.87      0
    76  D_dimer.above3000            D           34.74      0
   106  6598-7_Troponin T.cardiac [Mass/volume] in Serum or Plasma  C           33.98     16
   112  4548-4_Hemoglobin A1c/Hemoglobin.total in Blood  C           33.77     16
    79  ESR.above30                  D           32.71      0
    95  76282-3_Heart rate.beat-to-beat by EKG  C           32.16     14
    11  Acute.Hepatic.Injury..during.hospitalization.  C           31.23     11
   124  2345-7_Glucose [Mass/volume] in Serum or Plasma  C           30.47      9
    94  9279-1_Respiratory rate      C           29.88      6
   118  3094-0_Urea nitrogen [Mass/volume] in Serum or Plasma  C           29.21      6
    90  ferritin.above1k             D           28.66      0
     7  is_icu                       D           28.32      0
    41  Respiration.over24           D           28.23      0
    17  dm_v                         D           27.68      0
    42  HeartRate.over100            D           27.47      0
    45  Alanine.over60               D           26.67      0
    99  751-8_Neutrophils [*/volume] in Blood by Automated count  C           26.54     11
   109  48058-2_Fibrin D-dimer DDU [Mass/volume] in Platelet poor plasma by Immunoassay  C           25.70     11
   108  75241-0_Procalcitonin [Mass/volume] in Serum or Plasma by Immunoassay  C           25.57     14
    89  procalcitonin.above0.5       D           25.36      0
    71  eGFR.below30                 D           24.85      0
    98  33256-9_Leukocytes [*/volume] corrected for nucleated erythrocytes in Blood by Automated count  C           24.77     14
   107  33762-6_Natriuretic peptide.B prohormone N-Terminal [Mass/volume] in Serum or Plasma  C           24.30      6
   102  1920-8_Aspartate aminotransferase [Enzymatic activity/volume] in Serum or Plasma  C           24.22     16
   115  2823-3_Potassium [Moles/volume] in Serum or Plasma  C           24.22     16
     6  visit_concept_name           C           24.18      2
   116  2075-0_Chloride [Moles/volume] in Serum or Plasma  C           24.05     11
    14  kidney_replacement_therapy   D           23.96      0
   129  therapeutic.exnox.Boolean    D           22.99      0
    78  D_dimer.below500             D           22.78      0
   117  1963-8_Bicarbonate [Moles/volume] in Serum or Plasma  C           22.74     15
   113  39156-5_Body mass index (BMI) [Ratio]  C           21.98     15
   111  1988-5_C reactive protein [Mass/volume] in Serum or Plasma  C           21.43     12
   123  30341-2_Erythrocyte sedimentation rate  C           21.30     15
   101  2951-2_Sodium [Moles/volume] in Serum or Plasma  C           20.71      7
    91  Proteinuria.above80          D           20.29      0
    62  Bicarbonate.below21          D           19.95      0
    81  SBP.below120                 D           19.86      0
   104  2157-6_Creatine kinase [Enzymatic activity/volume] in Serum or Plasma  C           19.78     16
    97  76536-2_Mean blood pressure by Noninvasive  C           19.48     13
   103  1744-2_Alanine aminotransferase [Enzymatic activity/volume] in Serum or Plasma by No addition of P-5'-P  C           19.15      9
    12  Acute.Kidney.Injury..during.hospitalization.  D           18.89      0
    69  eGFR.above60                 D           18.60      0
    46  A1C.over6.5                  D           18.55      0
    51  Sodium.above145              D           18.55      0
    19  hf_ef_v                      D           18.17      0
    93  59408-5_Oxygen saturation in Arterial blood by Pulse oximetry  C           18.09     16
    47  A1C.under6.5                 D           17.71      0
    48  A1C.6.6to7.9                 D           17.71      0
    49  A1C.8to9.9                   D           17.71      0
    50  A1C.over10                   D           17.71      0
    63  Blood_Urea_Nitrogen.above20  D           17.67      0
    66  Creatinine.above1.2          D           17.50      0
   120  "62238-1_Glomerular filtration rate/1.73 sq M.predicted [Volume Rate/Area] in Serum  C           17.46      7
    53  Sodium.below135              D           17.24      0
   110  2276-4_Ferritin [Mass/volume] in Serum or Plasma  C           17.20     13
    59  Chloride.below96             D           17.12      0
    30  cough_v                      D           17.03      0
    80  Microscopic_hematuria.above2  D           16.99      0
    52  Sodium.between135and145      D           16.86      0
    54  Potassium.above5.2           D           16.86      0
    58  Chloride.between96and107     D           16.86      0
    60  Bicarbonate.above31          D           16.86      0
    85  MAP.between65and90           D           16.74      0
    86  MAP.above90                  D           16.74      0
    87  procalcitonin.below0.25      D           16.74      0
    77  D_dimer.between500and3000    D           16.69      0
     5  visit_start_datetime         D           16.31      0
    61  Bicarbonate.between21and31   D           16.31      0
    15  kidney_transplant            D           16.27      0
    72  blood_pH.above7.45           D           15.85      0
   100  731-0_Lymphocytes [*/volume] in Blood by Automated count  C           15.77     15
    44  Aspartate.over40             D           15.05      0
    20  ckd_v                        D           15.00      0
    36  fever_v                      D           14.79      0
   126  13458-5_Cholesterol in VLDL [Mass/volume] in Serum or Plasma by calculation  C           14.54     13
   114  2951-2_Sodium [Moles/volume] in Serum or Plasma.1  C           14.29     15
    33  vomiting_v                   D           14.07      0
    55  Potassium.between3.5and5.2   D           13.99      0
    56  Potassium.below3.5           D           13.99      0
    57  Chloride.above107            D           13.99      0
    96  8480-6_Systolic blood pressure  C           13.44     16
   125  13457-7_Cholesterol in LDL [Mass/volume] in Serum or Plasma by calculation  C           12.72      6
    34  diarrhea_v                   D           12.60      0
   105  2524-7_Lactate [Moles/volume] in Serum or Plasma  C           12.47     16
    35  abdominal_pain_v             D           12.09      0
    31  dyspnea_admission_v          D           11.96      0
    18  cad_v                        D           11.71      0
   127  2571-8_Triglyceride [Mass/volume] in Serum or Plasma  C           11.20      2
    40  pulseOx.under90              D           10.99      0
    37  BMI.over30                   D           10.95      0
   128  2085-9_Cholesterol in HDL [Mass/volume] in Serum or Plasma  C           10.86     16
    29  smoking_status_v             C           10.82     10
    39  temperature.over38           D            9.93      0
    82  SBP.between120and139         D            9.17      0
   131  Other.anticoagulation.therapy  D            8.88      0
    83  SBP.above139                 D            8.24      0
    38  BMI.over35                   D            8.20      0
    23  other_lung_disease_v         D            7.99      0
    21  malignancies_v               D            7.73      0
    22  copd_v                       D            7.27      0
    92  8331-1_Oral temperature      D            7.06      0
    32  nausea_v                     D            6.68      0
    25  arb_v                        D            6.64      0
    27  nsaid_use_v                  D            6.09      0
    28  days_prior_sx                D            4.10      0
    43  Lymphocytes.under1k          D            3.85      0
    26  antibiotics_use_v            D            3.51      0
    24  acei_v                       D            3.00      0
    16  htn_v                        D            1.86      0
    84  MAP.below65                  D            1.27      0
processing time: 0 hrs 0 min  0.094 sec
```

### Explore the dataset to determine useful values for classification parameters

The parameter of interest are attribute number, bin range, uniform bins, excluding or including missing values, and weighting by class prevalence. Try `./vhamnn explore -h`

In the paper by Aboutabeli et al, each of the models was trained on 80% of the cases in the dataset and tested on the remaining 20%, with random selection of cases. The corresponding HamNN library settings are for 5-fold cross-validation, with random selection of cases (obtained by setting the -r parameter to a value >1). For speed of processing, we will choose 10, ie 10 complete 5-fold cross-validations at each parameter setting, with the results averaged.

Also, HamNN typically considers the class having fewer cases as the "positive" class. So, to find the settings giving the best accuracy for predicting survival, we need to find low values for "FN", ie false negatives.
```sh
./vhamnn explore -f 5 -r 10 -s -e -g -c  -u -p datasets/covid_biochem.tab

Explore 5-fold cross-validation
 (10 repetitions) using classifiers from "datasets/covid_biochem.tab"
Binning range for continuous attributes: from 2 to 16 with interval 1
(same number of bins for all continous attributes)
Missing values: included
Not weighting nearest neighbor counts by class prevalences
Over attribute range from 1 to 129 by interval 1
Purging of duplicate instances: on
A correct classification to "deceased" is a True Positive (TP);
A correct classification to "discharged" is a True Negative (TN).
Note: for binary classification, balanced accuracy = (sensitivity + specificity) / 2
Attributes    Bins      Purged instances      (%)     TP    FP    TN    FN  Sens'y Spec'y PPV    NPV    F1 Score  Raw Acc'y  Bal'd


5       6      937.6 out of 1092 ( 85.9%)     71   111  1150    33  0.683  0.912  0.390  0.972  0.497      89.45%   79.73%
```

However, if we weight nearest neighbour counts by class prevalences:
```sh
./vhamnn explore -f 5 -r 10 -s -e -g -c -w -u -p datasets/covid_biochem.tab


Explore 5-fold cross-validation
 (10 repetitions) using classifiers from "datasets/covid_biochem.tab"
Binning range for continuous attributes: from 2 to 16 with interval 1
(same number of bins for all continous attributes)
Missing values: included
Weighting nearest neighbor counts by class prevalences
Over attribute range from 1 to 129 by interval 1
Purging of duplicate instances: on
A correct classification to "deceased" is a True Positive (TP);
A correct classification to "discharged" is a True Negative (TN).
Note: for binary classification, balanced accuracy = (sensitivity + specificity) / 2
Attributes    Bins      Purged instances      (%)     TP    FP    TN    FN  Sens'y Spec'y PPV    NPV    F1 Score  Raw Acc'y  Bal'd

      7       2      891.8 out of 1092 ( 81.7%)    168    14   752   431  0.280  0.982  0.923  0.636  0.430      67.40%   63.11%
```