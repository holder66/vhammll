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
Now you can run the app with command line entries starting with `% ./main`, 

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

`./main partition -rand -p# 2,1 -ps ox2_mets_train.tsv,ox2_mets_validation.tsv ox2_mets.tsv`

## Analyzing the dataset
`./vhamml analyze ~/mets/ox2_mets_train.tsv`
The terminal readout should show a file type of "orange_newer", a count of 8 attributes of type "m", one attribute of type "c", and 195 attributes of type "C" (continuous). There may be missing data. The train file should have 28 cases (16 Mets, 12 No mets), and the validation file 14 cases. 

## Exploring the `ox2_mets_train.tsv` data
We will leave aside the `ox2_mets_validation.tsv` file, as it is to be used as an independent validation set after the classifier has been optimized.
For the explore, use an attribute number range from 1 to 8, and a binning range from 2 to 6. There are several flags, and the explore should be done over every combination of those flags using the -af (all flags) option. Specify a new file to append the settings to. Given that the Mets cases are the ones we are looking for, we will want to name the Mets class as the Positive class (using the -pos option).
```
./main explore -e -a 1,8 -b 2,6 -af -ms ~/mets/ox2_mets_train.opts -roc ~/mets/ox2_mets_train.opts -pos Mets ~/mets/ox2_mets_train.tsv
```

Purge duplicate settings from the settings file, saving to a new file:
`./main optimals -e -p -o ox2_mets_train-purged.opts`

It is important to note that the actual settings obtained in the explore process are dependent on which cases were picked to go into the train file. Since this is a random process, it is suggested that you create a file using the same cases, ie, rows
22,37,38,41,49,55,59,64,68,75,80,84,94,99,110,111,149,163,165,171,175,176,192,194,201,211,220,240,244,247,263,264,268,280,284,291,292,296,311,320,321,333 from the original datafile. 

This process helps us to identify the settings giving maximum values for balanced accuracy of 84.38% (classifier 13) and Matthews Correlation Coefficient (MCC) of 0.710, sensitivity of 0.938, and specificity of 0.833. 

## Using multiple classifiers on the training dataset

We can experiment with these settings using a multiple classifier paradigm. The best results, in terms of area under the Receiver Operating Characteristic curve (AUROC) are:
```
./main cross -m vhammll/src/testdata/ox2_mets_train-purged.opts -m# 48,16 -pos Mets -e  ~/mets/ox2_mets_train.tsv

Cross-validation of "/Users/henryolders/mets/ox2_mets_train.tsv" using multiple classifiers
Partitioning: leave-one-out
Classifier parameters are in file "vhammll/src/testdata/ox2_mets_train-purged.opts"
break_on_all_flag: false     combined_radii_flag: false      total_nn_counts_flag: false     class_missing_purge_flag: false
Multiple Classifier Parameters:
               Classifier:   48           16           
     Number of attributes:   4            4            
                  Binning:   5, 5, 1      1, 2, 1      
   Exclude missing values:   false        false        
  Ranking using weighting:   true         true         
   Weighting of NN counts:   false        false        
      Balance prevalences:   false        false        
    Purge duplicate cases:   false        true         
    True / correct counts:   13     10    14     9     
 False / incorrect counts:   3      2     2      3     
             Raw accuracy:   82.14 %      82.14 %      
        Balanced accuracy:   82.29 %      81.25 %      
Matthews Correlation Coef:   0.641        0.633        
 Maximum Hamming Distance:   20           8            
Results:
    Class                     Instances    True Positives    Precision    Recall    F1 Score
    Mets                             16      14 ( 87.50%)        0.875     0.875       0.875
    No mets                          12      10 ( 83.33%)        0.833     0.833       0.833
        Totals                       28      24 (accuracy: raw: 85.71% balanced: 85.42%)
               Macro Averages:                                   0.854     0.854       0.854
            Weighted Averages:                                   0.857     0.857       0.857
A correct classification to "Mets" is a True Positive (TP);
A correct classification to "No mets" is a True Negative (TN).
   TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
   14     2    10     2   0.875  0.833  0.875  0.833     0.875         85.71%    85.42%   0.708
Confusion Matrix:
Predicted Classes (columns)         Mets    No mets
      Actual Classes (rows)
                       Mets           14          2
                    No mets            2         10
processing time: 0 hrs 0 min  0.066 sec time: 0 hrs 0 min  0.122 sec

```

## Applying these settings to the independent validation dataset

Unfortunately, this gives disappointing results:

```
./main verify -t ~/mets/ox2_mets_validation.tsv  -m  vhammll/src/testdata/ox2_mets_train-purged.opts  -m# 13 -ea -e -pos Mets  ~/mets/ox2_mets_train.tsv

Verification of "/Users/henryolders/mets/ox2_mets_validation.tsv" using multiple classifiers from "/Users/henryolders/mets/ox2_mets_train.tsv"
Classifier parameters are in file "vhammll/src/testdata/ox2_mets_train-purged.opts"
break_on_all_flag: false     combined_radii_flag: false      total_nn_counts_flag: false     class_missing_purge_flag: false
Multiple Classifier Parameters:
               Classifier:   13           
     Number of attributes:   4            
                  Binning:   1, 2, 1      
   Exclude missing values:   false        
  Ranking using weighting:   true         
   Weighting of NN counts:   false        
      Balance prevalences:   false        
    Purge duplicate cases:   false        
    True / correct counts:   15     9     
 False / incorrect counts:   1      3     
             Raw accuracy:   85.71 %      
        Balanced accuracy:   84.38 %      
Matthews Correlation Coef:   0.710        
 Maximum Hamming Distance:   8            
Trained attributes for classifier 13 on dataset "/Users/henryolders/mets/ox2_mets_train.tsv"
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
A correct classification to "Mets" is a True Positive (TP);
A correct classification to "No mets" is a True Negative (TN).
   TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
    6     2     1     5   0.750  0.167  0.545  0.333     0.632         50.00%    45.83%   -0.101
Confusion Matrix:
Predicted Classes (columns)         Mets    No mets
      Actual Classes (rows)
                       Mets            6          2
                    No mets            5          1



./main verify -t ~/mets/ox2_mets_validation.tsv  -m  vhammll/src/testdata/ox2_mets_train-purged.opts  -m# 48 -ea -e -pos Mets  ~/mets/ox2_mets_train.tsv

Verification of "/Users/henryolders/mets/ox2_mets_validation.tsv" using multiple classifiers from "/Users/henryolders/mets/ox2_mets_train.tsv"
Classifier parameters are in file "vhammll/src/testdata/ox2_mets_train-purged.opts"
break_on_all_flag: false     combined_radii_flag: false      total_nn_counts_flag: false     class_missing_purge_flag: false
Multiple Classifier Parameters:
               Classifier:   48           
     Number of attributes:   4            
                  Binning:   5, 5, 1      
   Exclude missing values:   false        
  Ranking using weighting:   true         
   Weighting of NN counts:   false        
      Balance prevalences:   false        
    Purge duplicate cases:   false        
    True / correct counts:   13     10    
 False / incorrect counts:   3      2     
             Raw accuracy:   82.14 %      
        Balanced accuracy:   82.29 %      
Matthews Correlation Coef:   0.641        
 Maximum Hamming Distance:   20           
Trained attributes for classifier 48 on dataset "/Users/henryolders/mets/ox2_mets_train.tsv"
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
   32  V_2_20                      C          62.50                0.00       0.00     5
   97  V_2_85                      C          60.42                0.00       0.00     5
   64  V_2_52                      C          56.25                0.00       0.01     5
   46  V_2_34                      C          54.17                0.00       0.02     5
Results:
    Class                     Instances    True Positives    Precision    Recall    F1 Score
    Mets                              8       8 (100.00%)        0.615     1.000       0.762
    No mets                           6       1 ( 16.67%)        1.000     0.167       0.286
        Totals                       14       9 (accuracy: raw: 64.29% balanced: 58.33%)
               Macro Averages:                                   0.808     0.583       0.524
            Weighted Averages:                                   0.780     0.643       0.558
A correct classification to "Mets" is a True Positive (TP);
A correct classification to "No mets" is a True Negative (TN).
   TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
    8     0     1     5   1.000  0.167  0.615  1.000     0.762         64.29%    58.33%   0.320
Confusion Matrix:
Predicted Classes (columns)         Mets    No mets
      Actual Classes (rows)
                       Mets            8          0
                    No mets            5          1



./main verify -t ~/mets/ox2_mets_validation.tsv  -m  vhammll/src/testdata/ox2_mets_train-purged.opts  -m# 48,16 -ea -e -pos Mets  ~/mets/ox2_mets_train.tsv

Verification of "/Users/henryolders/mets/ox2_mets_validation.tsv" using multiple classifiers from "/Users/henryolders/mets/ox2_mets_train.tsv"
Classifier parameters are in file "vhammll/src/testdata/ox2_mets_train-purged.opts"
break_on_all_flag: false     combined_radii_flag: false      total_nn_counts_flag: false     class_missing_purge_flag: false
Multiple Classifier Parameters:
               Classifier:   48           16           
     Number of attributes:   4            4            
                  Binning:   5, 5, 1      1, 2, 1      
   Exclude missing values:   false        false        
  Ranking using weighting:   true         true         
   Weighting of NN counts:   false        false        
      Balance prevalences:   false        false        
    Purge duplicate cases:   false        true         
    True / correct counts:   13     10    14     9     
 False / incorrect counts:   3      2     2      3     
             Raw accuracy:   82.14 %      82.14 %      
        Balanced accuracy:   82.29 %      81.25 %      
Matthews Correlation Coef:   0.641        0.633        
 Maximum Hamming Distance:   20           8            
Instances purged: 0 out of 28 (  0.00%)
Trained attributes for classifier 48 on dataset "/Users/henryolders/mets/ox2_mets_train.tsv"
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
   32  V_2_20                      C          62.50                0.00       0.00     5
   97  V_2_85                      C          60.42                0.00       0.00     5
   64  V_2_52                      C          56.25                0.00       0.01     5
   46  V_2_34                      C          54.17                0.00       0.02     5
Trained attributes for classifier 16 on dataset "/Users/henryolders/mets/ox2_mets_train.tsv"
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
   16  V_2_4                       C          52.08                0.01       0.03     2
   46  V_2_34                      C          52.08                0.00       0.02     2
   97  V_2_85                      C          50.00                0.00       0.00     2
  153  V_2_141                     C          50.00                0.00       0.00     2
Results:
    Class                     Instances    True Positives    Precision    Recall    F1 Score
    Mets                              8       7 ( 87.50%)        0.636     0.875       0.737
    No mets                           6       2 ( 33.33%)        0.667     0.333       0.444
        Totals                       14       9 (accuracy: raw: 64.29% balanced: 60.42%)
               Macro Averages:                                   0.652     0.604       0.591
            Weighted Averages:                                   0.649     0.643       0.612
A correct classification to "Mets" is a True Positive (TP);
A correct classification to "No mets" is a True Negative (TN).
   TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
    7     1     2     4   0.875  0.333  0.636  0.667     0.737         64.29%    60.42%   0.251
Confusion Matrix:
Predicted Classes (columns)         Mets    No mets
      Actual Classes (rows)
                       Mets            7          1
                    No mets            4          2

```