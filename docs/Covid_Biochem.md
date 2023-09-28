## Predicting Survival and Kidney Injury of COVID-19 Patients from Clinical and Biochemistry Data
A recent [paper](x) by Hossein Aboutalebi and colleagues details a process they went through to build machine learning models for the prediction of survival and acute kidney injury of COVID-19 patients, based on clinical and biochemistry data. The framework they developed consists of a collaborative effort between machine learning experts and clinicians in which models are progressively refined by clinician inputs in an "explainability-driven" approach to help identify those clinical and biochemical markers which may help to improve prediction performance, clinical validity, and trustworthiness of the final machine learning models.

In contrast to this approach, the VHamMLL algorithm attempts to build a model using only the available data, with the goal of helping clinicians to better understand which variables are useful in predicting outcomes, so that their energies can be better directed towards collecting useful information and informing the design of treatment approaches which can potentially improve those outcomes. 

Here is the process which I followed.

### Massage the dataset so it can be read by the VHamMLL library
The [dataset](https://github.com/h-aboutalebi/CovidBiochem/blob/master/Covid_biochem/pytorch_tabular_main/data/clinical_data.csv) used by Aboutalebi and colleagues is derived from clinical data collected by Stony Brook University for 1335 COVID-19 positive patients and anonymized. 

1. Copy the contents from the github file and paste into a new file in a text editor;
2. In the editor, replace all the commas with tabs;
3. Save the file as datasets/covid_biochem.tab;
4. Following the Orange-newer format (`v run . orange`), add the prefix `i#` to the first attribute name `to_patient_id` to obtain `i#to_patient_id` (so that this attribute will be ignored by HamNN);
5. Add the prefix `c#` to the target variable to identify it as the class attribute. For survival prediction, the target variable is `last.status` which then becomes `c#last.status`. Save the file.

### Examine the dataset
```sh
% v -prod .
% ./vhamml analyze ~/.vmodules/holder66/vhammll/datasets/covid_biochem.tab 


Analysis of Dataset: /Users/henryolders/.vmodules/holder66/vhammll/datasets/covid_biochem.tab (File Type: orange_newer)
All Attributes:
 Index  Name                                    Count  Uniques  Missing      %  Type
     0  to_patient_id                            1365     1365        0    0.0     i
     1  covid19_statuses                         1365        1        0    0.0     i
     2  last.status                              1365        2        0    0.0     c
     3  age.splits                               1365        3        0    0.0     D
     4  gender_concept_name                      1365        3        0    0.0     C
     5  visit_start_datetime                     1365        3       32    2.3     D
     6  visit_concept_name                       1365       30        0    0.0     C
     7  is_icu                                   1365        3        0    0.0     D
     8  was_ventilated                           1365        2        0    0.0     D
     9  invasive_vent_days                       1365        2        0    0.0     D
    10  length_of_stay                           1365       39     1152   84.4     C
    .
    .
    .
    .
   129  therapeutic.exnox.Boolean                1365        3       92    6.7     D
   130  therapeutic.heparin.Boolean              1365        3       92    6.7     D
   131  Other.anticoagulation.therapy            1365        8       92    6.7     D
______                                        _______           _______  _____
Totals (less Class attribute)                  180180             47487  26.36%
Counts of Attributes by Type
Type        Count
i               4
c               1
D              86
C              41
Total:        132
Discrete Attributes for Training (86 attributes)
 Index  Name                                  Uniques  Missing      %
     3  age.splits                                  3        0    0.0
     5  visit_start_datetime                        3       32    2.3
     7  is_icu                                      3        0    0.0
     8  was_ventilated                              2        0    0.0
     9  invasive_vent_days                          2        0    0.0
     .
     .
     .
    92  8331-1_Oral temperature                     3     1153   84.5
   129  therapeutic.exnox.Boolean                   3       92    6.7
   130  therapeutic.heparin.Boolean                 3       92    6.7
   131  Other.anticoagulation.therapy               8       92    6.7
Continuous Attributes for Training (41 attributes)
 Index  Name                                  Uniques  Missing      %         Min        Max       Mean     Median
     4  gender_concept_name                         3        0    0.0         59         90     68.786         59
     6  visit_concept_name                         30        0    0.0          1         12      4.018          1
    10  length_of_stay                             39     1152   84.4          1         40     16.432         12
    .
    .
    .
   127  2571-8_Triglyceride [Mass/volume] in Serum or Plasma     159     1054   77.2         10       3524    145.772        117
   128  2085-9_Cholesterol in HDL [Mass/volume] in Serum or Plasma      55     1065   78.0         10         98     32.627         31
The Class Attribute: "last.status" (2 classes)
Class Value           Cases
discharged             1183
deceased                182
processing time: 0 hrs 0 min  0.146 sec

```

### Explore the dataset to determine useful values for classification parameters

The parameter of interest are attribute number, bin range, uniform bins, excluding or including missing values, and weighting by class prevalence. Try `% ./vhamml explore --help`

In the paper by Aboutabeli et al, each of the models was trained on 80% of the cases in the dataset and tested on the remaining 20%, with random selection of cases. The corresponding VHamMLL library settings are for 5-fold cross-validation, with random selection of cases (obtained by setting the -r parameter to a value >1). For speed of processing, we will choose 10, ie 10 complete 5-fold cross-validations at each parameter setting, with the results averaged.

Also, VHamMLL typically considers the class having fewer cases as the "positive" class. So, to find the settings giving the best accuracy for predicting survival (ie, "discharged"), we need to find high values for true negatives (TN).
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