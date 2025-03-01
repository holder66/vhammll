# Classification of Cancer Cases into Metastatic or Non-metastatic using Metabolomics, for the Oxford 2nd cohort Database
Using the Command Line Interface (CLI)

## Install V and set up to use the CLI
Follow the instructions in the [README](https://github.com/holder66/vhammll/blob/master/README.md). The following assumes you've named your directory or folder "vhamml".

## Compile the app
In your terminal, navigate to directory/folder `vhamml` containing the `main.v` file
(see the [README](https://github.com/holder66/vhammll/blob/master/README.md))
```sh
cd vhamml
v -prod .
```
Now you can run the app with command line entries starting with `% ./vhamml`, 

## Prepare a dataset containing separate training and testing tab-delimited files, using the "orange_newer" file format
Assuming the data file you're working with is an Excel spreadsheet, with the first row containing "ID", "Final Class", "Cancer v no cancer", and so on, and ending with "V_2_1" through "V_2_191":
1. Prepend the column labels with "m#" to give "m#ID", "m#Final Class" (ie, metadata), up to but not including column "WCC". Columns labeled as metadata will not be used in classification.
2. These instructions are to set up a classification exercise to identify cancer cases with metastases from all cancer cases.
3. Save the modified data as a new file "ox2_mets", so as to keep the original datafile intact.
4. Create a new column beside the "m#Final Class" column; label it "c#Cancer and Mets". The c# identifies this column as the class attribute.
5. Filter on column m#Final Class" on the value "Cancer". There should be 18 cases. For these 18, enter "No mets" in the new column.
6. Now filter on the value "Cancer Met". For these 24 cases, enter "Mets" in the new column.
7. Sort ascending on the new column. Delete all the rows without an entry in this column. Save.
8. If necessary, restore the original order of the cases (ie sorted by ID).
9. Export this to a tab-separated file (ie, with suffix .tsv)
10. Partition this file into a training file, and a separate validation file, using a 2/3, 1/3 split, with random picking of files.

`./vhamml partition -rand -p# 2,1 -ps ox2_mets_train.tsv,ox2_mets_validation.tsv ox2_mets.tsv`

## Analyzing the dataset
`./vhamml analyze ~/mets/ox2_mets_train.tsv`
The terminal readout should show a file type of "orange_newer", a count of 8 attributes of type "m", one attribute of type "c", and 195 attributes of type "C" (continuous). There may be missing data. The train file should have 28 cases, and the validation file 14 cases.

## Exploring the `ox2_mets_train.tsv` data
We will leave aside the `ox2_mets_validation.tsv` file, as it is to be used as an independent validation set after the classifier has been optimized.
For the explore, use an attribute number range from 1 to 10, and a binning range also from 1 to 16. There are several flags, and the explore should be done over every combination of those flags using the -af (all flags) option. Specify a new file to append the settings to.
`./vhamml explore -e -a 1,10 -b 1,16 -af -ms ox2_mets_train.opts ox2_mets_train.tsv`

Purge duplicate settings from the settings file, saving to a new file:
`./vhamml optimals -e -p -o ox2_mets_train-purged.opts`

It is important to note that the actual settings obtained in the explore process are dependent on which cases were picked to go into the train file. Since this is a random process, it is suggested that you create a file using the same cases, ie, rows
22,37,38,41,49,55,59,64,68,75,80,84,94,99,110,111,149,163,165,171,175,176,192,194,201,211,220,240,244,247,263,264,268,280,284,291,292,296,311,320,321,333 from the original datafile. 

This process helps us to identify the settings giving maximum values for balanced accuracy of 84.38%, Matthews Correlation Coefficient (MCC) of 0.710, sensitivity of 1.0, and specificity also of 1.0. 

## Using multiple classifiers on the training dataset

We can experiment with these settings using a multiple classifier paradigm. The best results, in terms of area under the Receiver Operating Characteristic curve (AUROC) are:
```
./vhamml cross -m ~/mets/ox2_mets_train-purged.opts -m# 19 -e  ~/mets/ox2_mets_train.tsv

Cross-validation of "/Users/henryolders/mets/ox2_mets_train.tsv" using multiple classifiers
Partitioning: leave-one-out
Classifier parameters are in file "/Users/henryolders/mets/ox2_mets_train-purged.opts"
break_on_all_flag: false     combined_radii_flag: false      total_nn_counts_flag: false     class_missing_purge_flag: false
Multiple Classifier Parameters:
               Classifier:   19           
     Number of attributes:   4            
                  Binning:   1, 2, 1      
   Exclude missing values:   false        
  Ranking using weighting:   true         
   Weighting of NN counts:   false        
      Balance prevalences:   false        
    Purge duplicate cases:   false        
    True / correct counts:   9      15    
 False / incorrect counts:   3      1     
             Raw accuracy:   85.71 %      
        Balanced accuracy:   84.38 %      
Matthews Correlation Coef:   0.710        
 Maximum Hamming Distance:   8            
Results:
    Class                     Instances    True Positives    Precision    Recall    F1 Score
    Mets                             16      15 ( 93.75%)        0.833     0.938       0.882
    No mets                          12       9 ( 75.00%)        0.900     0.750       0.818
        Totals                       28      24 (accuracy: raw: 85.71% balanced: 84.38%)
               Macro Averages:                                   0.867     0.844       0.850
            Weighted Averages:                                   0.862     0.857       0.855
A correct classification to "No mets" is a True Positive (TP);
A correct classification to "Mets" is a True Negative (TN).
   TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
    9     3    15     1   0.750  0.938  0.900  0.833     0.818         85.71%    84.38%   0.710
Confusion Matrix:
Predicted Classes (columns)         Mets    No mets
      Actual Classes (rows)
                       Mets           15          1
                    No mets            3          9
processing time: 0 hrs 0 min  0.122 sec

```


```
./vhamml cross  -m ~/mets/ox2_mets_train-purged.opts -m# 12,19 -ma -mt -e  ~/mets/ox2_mets_train.tsv

Cross-validation of "/Users/henryolders/mets/ox2_mets_train.tsv" using multiple classifiers
Partitioning: leave-one-out
Classifier parameters are in file "/Users/henryolders/mets/ox2_mets_train-purged.opts"
break_on_all_flag: true     combined_radii_flag: false      total_nn_counts_flag: true     class_missing_purge_flag: false
Multiple Classifier Parameters:
               Classifier:   12           19           
     Number of attributes:   1            4            
                  Binning:   1, 1, 1      1, 2, 1      
   Exclude missing values:   false        false        
  Ranking using weighting:   false        true         
   Weighting of NN counts:   true         false        
      Balance prevalences:   false        false        
    Purge duplicate cases:   false        false        
    True / correct counts:   12     1     9      15    
 False / incorrect counts:   0      15    3      1     
             Raw accuracy:   46.43 %      85.71 %      
        Balanced accuracy:   53.13 %      84.38 %      
Matthews Correlation Coef:   0.167        0.710        
 Maximum Hamming Distance:   1            8            
Results:
    Class                     Instances    True Positives    Precision    Recall    F1 Score
    Mets                             16       5 ( 31.25%)        0.833     0.313       0.455
    No mets                          12      11 ( 91.67%)        0.500     0.917       0.647
        Totals                       28      16 (accuracy: raw: 57.14% balanced: 61.46%)
               Macro Averages:                                   0.667     0.615       0.551
            Weighted Averages:                                   0.690     0.571       0.537
A correct classification to "No mets" is a True Positive (TP);
A correct classification to "Mets" is a True Negative (TN).
   TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
   11     1     5    11   0.917  0.313  0.500  0.833     0.647         57.14%    61.46%   0.276
Confusion Matrix:
Predicted Classes (columns)         Mets    No mets
      Actual Classes (rows)
                       Mets            5         11
                    No mets            1         11
processing time: 0 hrs 0 min  0.146 sec
```

```
./vhamml cross  -m ~/mets/ox2_mets_train-purged.opts -m# 12,19,74 -ma -mc -e  ~/mets/ox2_mets_train.tsv 

Cross-validation of "/Users/henryolders/mets/ox2_mets_train.tsv" using multiple classifiers
Partitioning: leave-one-out
Classifier parameters are in file "/Users/henryolders/mets/ox2_mets_train-purged.opts"
break_on_all_flag: true     combined_radii_flag: true      total_nn_counts_flag: false     class_missing_purge_flag: false
Multiple Classifier Parameters:
               Classifier:   12           19           74           
     Number of attributes:   1            4            6            
                  Binning:   1, 1, 1      1, 2, 1      2, 2, 1      
   Exclude missing values:   false        false        false        
  Ranking using weighting:   false        true         true         
   Weighting of NN counts:   true         false        false        
      Balance prevalences:   false        false        true         
    Purge duplicate cases:   false        false        true         
    True / correct counts:   12     1     9      15    9      15    
 False / incorrect counts:   0      15    3      1     3      1     
             Raw accuracy:   46.43 %      85.71 %      85.71 %      
        Balanced accuracy:   53.13 %      84.38 %      84.38 %      
Matthews Correlation Coef:   0.167        0.710        0.710        
 Maximum Hamming Distance:   1            8            12           
Results:
    Class                     Instances    True Positives    Precision    Recall    F1 Score
    Mets                             16      11 ( 68.75%)        0.846     0.688       0.759
    No mets                          12      10 ( 83.33%)        0.667     0.833       0.741
        Totals                       28      21 (accuracy: raw: 75.00% balanced: 76.04%)
               Macro Averages:                                   0.756     0.760       0.750
            Weighted Averages:                                   0.769     0.750       0.751
A correct classification to "No mets" is a True Positive (TP);
A correct classification to "Mets" is a True Negative (TN).
   TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
   10     2    11     5   0.833  0.688  0.667  0.846     0.741         75.00%    76.04%   0.517
Confusion Matrix:
Predicted Classes (columns)         Mets    No mets
      Actual Classes (rows)
                       Mets           11          5
                    No mets            2         10
processing time: 0 hrs 0 min  0.232 sec
```

## Applying these settings to the independent validation dataset

Unfortunately, this gives disappointing results:

```
{25-02-28 9:07}mbp2021:~/use_vhammll henryolders% v run main.v verify -t ~/mets/ox2_mets_validation.tsv -m ~/mets/ox2_mets_train-purged.opts -m# 19 -e -ea  ~/mets/ox2_mets_train.tsv

Verification of "/Users/henryolders/mets/ox2_mets_validation.tsv" using multiple classifiers from "/Users/henryolders/mets/ox2_mets_train.tsv"
Classifier parameters are in file "/Users/henryolders/mets/ox2_mets_train-purged.opts"
break_on_all_flag: false     combined_radii_flag: false      total_nn_counts_flag: false     class_missing_purge_flag: false
Multiple Classifier Parameters:
               Classifier:   19           
     Number of attributes:   4            
                  Binning:   1, 2, 1      
   Exclude missing values:   false        
  Ranking using weighting:   true         
   Weighting of NN counts:   false        
      Balance prevalences:   false        
    Purge duplicate cases:   false        
    True / correct counts:   9      15    
 False / incorrect counts:   3      1     
             Raw accuracy:   85.71 %      
        Balanced accuracy:   84.38 %      
Matthews Correlation Coef:   0.710        
 Maximum Hamming Distance:   8            
Trained attributes for classifier 19 on dataset "/Users/henryolders/mets/ox2_mets_train.tsv"
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
   16  V_2_4                       C          52.08                0.01       0.03     2
   46  V_2_34                      C          52.08                0.00       0.02     2
   97  V_2_85                      C          50.00                0.00       0.00     2
  153  V_2_141                     C          50.00                0.00       0.00     2
Results:
    Class                     Instances    True Positives    Precision    Recall    F1 Score
    Mets                              8       6 ( 75.00%)        0.545     0.750       0.632
    No mets                           6       1 ( 16.67%)        0.333     0.167       0.222
        Totals                       14       7 (accuracy: raw: 50.00% balanced: 45.83%)
               Macro Averages:                                   0.439     0.458       0.427
            Weighted Averages:                                   0.455     0.500       0.456
A correct classification to "No mets" is a True Positive (TP);
A correct classification to "Mets" is a True Negative (TN).
   TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
    1     5     6     2   0.167  0.750  0.333  0.545     0.222         50.00%    45.83%   -0.101
Confusion Matrix:
Predicted Classes (columns)         Mets    No mets
      Actual Classes (rows)
                       Mets            6          2
                    No mets            5          1
processing time: 0 hrs 0 min  0.107 sec



./vhamml verify -t ~/mets/ox2_mets_validation.tsv -m ~/mets/ox2_mets_train-purged.opts -m# 12,19 -ma -mt -e -ea ~/mets/ox2_mets_train.tsv 

Verification of "/Users/henryolders/mets/ox2_mets_validation.tsv" using multiple classifiers from "/Users/henryolders/mets/ox2_mets_train.tsv"
Classifier parameters are in file "/Users/henryolders/mets/ox2_mets_train-purged.opts"
break_on_all_flag: true     combined_radii_flag: false      total_nn_counts_flag: true     class_missing_purge_flag: false
Multiple Classifier Parameters:
               Classifier:   12           19           
     Number of attributes:   1            4            
                  Binning:   1, 1, 1      1, 2, 1      
   Exclude missing values:   false        false        
  Ranking using weighting:   false        true         
   Weighting of NN counts:   true         false        
      Balance prevalences:   false        false        
    Purge duplicate cases:   false        false        
    True / correct counts:   12     1     9      15    
 False / incorrect counts:   0      15    3      1     
             Raw accuracy:   46.43 %      85.71 %      
        Balanced accuracy:   53.13 %      84.38 %      
Matthews Correlation Coef:   0.167        0.710        
 Maximum Hamming Distance:   1            8            
Trained attributes for classifier 12 on dataset "/Users/henryolders/mets/ox2_mets_train.tsv"
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
    9  WCC                         C          14.29                2.89      15.80     1
Trained attributes for classifier 19 on dataset "/Users/henryolders/mets/ox2_mets_train.tsv"
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
   16  V_2_4                       C          52.08                0.01       0.03     2
   46  V_2_34                      C          52.08                0.00       0.02     2
   97  V_2_85                      C          50.00                0.00       0.00     2
  153  V_2_141                     C          50.00                0.00       0.00     2
Results:
    Class                     Instances    True Positives    Precision    Recall    F1 Score
    Mets                              8       2 ( 25.00%)        0.500     0.250       0.333
    No mets                           6       4 ( 66.67%)        0.400     0.667       0.500
        Totals                       14       6 (accuracy: raw: 42.86% balanced: 45.83%)
               Macro Averages:                                   0.450     0.458       0.417
            Weighted Averages:                                   0.457     0.429       0.405
A correct classification to "No mets" is a True Positive (TP);
A correct classification to "Mets" is a True Negative (TN).
   TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
    4     2     2     6   0.667  0.250  0.400  0.500     0.500         42.86%    45.83%   -0.091
Confusion Matrix:
Predicted Classes (columns)         Mets    No mets
      Actual Classes (rows)
                       Mets            2          6
                    No mets            2          4
processing time: 0 hrs 0 min  0.197 sec



./vhamml verify -t ~/mets/ox2_mets_validation.tsv -m ~/mets/ox2_mets_train-purged.opts -m# 12,19,74 -ma -mc -e -ea ~/mets/ox2_mets_train.tsv

Verification of "/Users/henryolders/mets/ox2_mets_validation.tsv" using multiple classifiers from "/Users/henryolders/mets/ox2_mets_train.tsv"
Classifier parameters are in file "/Users/henryolders/mets/ox2_mets_train-purged.opts"
break_on_all_flag: true     combined_radii_flag: true      total_nn_counts_flag: false     class_missing_purge_flag: false
Multiple Classifier Parameters:
               Classifier:   12           19           74           
     Number of attributes:   1            4            6            
                  Binning:   1, 1, 1      1, 2, 1      2, 2, 1      
   Exclude missing values:   false        false        false        
  Ranking using weighting:   false        true         true         
   Weighting of NN counts:   true         false        false        
      Balance prevalences:   false        false        true         
    Purge duplicate cases:   false        false        true         
    True / correct counts:   12     1     9      15    9      15    
 False / incorrect counts:   0      15    3      1     3      1     
             Raw accuracy:   46.43 %      85.71 %      85.71 %      
        Balanced accuracy:   53.13 %      84.38 %      84.38 %      
Matthews Correlation Coef:   0.167        0.710        0.710        
 Maximum Hamming Distance:   1            8            12           
Instances purged: 0 out of 28 (  0.00%)
Trained attributes for classifier 12 on dataset "/Users/henryolders/mets/ox2_mets_train.tsv"
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
    9  WCC                         C          14.29                2.89      15.80     1
Trained attributes for classifier 19 on dataset "/Users/henryolders/mets/ox2_mets_train.tsv"
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
   16  V_2_4                       C          52.08                0.01       0.03     2
   46  V_2_34                      C          52.08                0.00       0.02     2
   97  V_2_85                      C          50.00                0.00       0.00     2
  153  V_2_141                     C          50.00                0.00       0.00     2
Trained attributes for classifier 74 on dataset "/Users/henryolders/mets/ox2_mets_train.tsv"
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
   16  V_2_4                       C          52.08                0.01       0.03     2
   46  V_2_34                      C          52.08                0.00       0.02     2
   97  V_2_85                      C          50.00                0.00       0.00     2
  153  V_2_141                     C          50.00                0.00       0.00     2
  188  V_2_176                     C          50.00                0.00       0.00     2
  184  V_2_172                     C          43.75                0.00       0.00     2
Results:
    Class                     Instances    True Positives    Precision    Recall    F1 Score
    Mets                              8       4 ( 50.00%)        0.444     0.500       0.471
    No mets                           6       1 ( 16.67%)        0.200     0.167       0.182
        Totals                       14       5 (accuracy: raw: 35.71% balanced: 33.33%)
               Macro Averages:                                   0.322     0.333       0.326
            Weighted Averages:                                   0.340     0.357       0.347
A correct classification to "No mets" is a True Positive (TP);
A correct classification to "Mets" is a True Negative (TN).
   TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
    1     5     4     4   0.167  0.500  0.200  0.444     0.182         35.71%    33.33%   -0.344
Confusion Matrix:
Predicted Classes (columns)         Mets    No mets
      Actual Classes (rows)
                       Mets            4          4
                    No mets            5          1
processing time: 0 hrs 0 min  0.289 sec
```