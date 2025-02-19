# Classification of Cancer using Metabolomics
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
Assuming the data file you're working with is an Excel spreadsheet, with the first row containing "ID", "Class", "Model", followed by attribute labels "V1" through "V917":
1. Prepend "ID" with "m#" to give "m#ID" (ie, metadata), do the same with "Model". Prepend "Class" with "c#" to give "c#Class", thus specifying the class variable.
2. Sort on the column "m#Model". Select all the rows containing "TEST" and copy and paste these to a new spreadsheet. Make sure the new spreadsheet has the same header row.
3. Export the new spreadsheet as a tab-delimited file, with the name `test.tab`.
4. In the old spreadsheet, delete all the rows containing "TEST", leaving only rows containing "TRAIN". Export this also as a tab-delimited file, named `train.tab`.
For the purposes of this instruction set, the two files were saved in a directory named "metabolomics" in the user's home directory.

## Analyzing the dataset
`./vhamml analyze ~/metabolomics/train.tab`
The terminal readout should show a file type of "orange_newer", a count of 2 attributes of type "m", one attribute of type "c", and 917 attributes of type "C" (continuous). No missing data. The Class Attribute should show 175 "Non" cases and 17 "Can" cases.
For the `test.tab` file, the corresponding class counts should be 85 "Non" and 7 "Can".

## Continue with `oxford_test.v`
At this point, you have the option of continuing to work through the steps below, or running the `oxford_test.v` file which produces the same results. To do so, type 
```sh
cd ~/.vmodules/holder66/vhammll
v -prod -stats src/oxford_test.v
```

## Exploring the `train.tab` data
We will leave aside the `test.tab` file, as it is to be used as an independent test set after the classifier has been optimized.
For the explore, use an attribute number range from 1 to 10, and a binning range also from 1 to 10. There are several flags, and the explore should be done over every combination of those flags, using the -af (--all-flags) option (but read ahead to avoid these time-consuming steps):
```sh
./vhamml explore -e -a 1,10 -b 1,10 -af ~/metabolomics/train.tab
```

This would take a couple of days to run, depending on the speed of your computer. Since we already know what the settings should be to achieve good results with classification, it will be faster to build the settings file using the "cross" command with parameters obtained by prior experimentation (remember to delete any pre-existing metabolomics.opts file first):
```sh
./vhamml cross -e -ms ~/metabolomics/metabolomics.opts -a 4 -b 8,8 -w -bp -p ~/metabolomics/train.tab;
./vhamml cross -e -ms ~/metabolomics/metabolomics.opts -a 1 -b 3,3 -wr -w -bp ~/metabolomics/train.tab;
./vhamml cross -e -ms ~/metabolomics/metabolomics.opts -a 3 -b 3,3 -w ~/metabolomics/train.tab;
./vhamml cross -e -ms ~/metabolomics/metabolomics.opts -a 9 -b 1,4 -w ~/metabolomics/train.tab
```

Verify that the newly generated settings file contains the settings for all 4 classifiers, and in the correct order (the -ea flag is to display the trained
attributes for each classifier):
```sh
./vhamml display -ea ~/metabolomics/metabolomics.opts
```
Which should give:
```
Multiple Classifier Options file: /Users/henryolders/metabolomics/metabolomics.opts
               Classifier:   0            1            2            3            
     Number of attributes:   4            1            3            9            
                  Binning:   8, 8, 1      3, 3, 1      3, 3, 1      1, 4, 1      
   Exclude missing values:   false        false        false        false        
  Ranking using weighting:   false        true         false        false        
   Weighting of NN counts:   true         true         true         true         
      Balance prevalences:   true         true         false        false        
    Purge duplicate cases:   true         false        false        false        
    True / correct counts:   13     146   13     120   15     52    13     152   
 False / incorrect counts:   4      29    4      55    2      123   4      23    
             Raw accuracy:   82.81 %      69.27 %      34.90 %      85.94 %      
        Balanced accuracy:   79.95 %      72.52 %      58.97 %      81.66 %      
Matthews Correlation Coef:   0.412        0.268        0.113        0.461        
 Maximum Hamming Distance:   32           3            9            34           
Trained attributes for classifier 0 on dataset /Users/henryolders/metabolomics/train.tab
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
  355  V353                        C          60.58           768053.81 2574747.75     8
  720  V718                        C          59.42            28240.63  259493.11     8
  361  V359                        C          58.26          1024783.94 3172615.75     8
  360  V358                        C          57.10           704953.38 3185761.25     8
Trained attributes for classifier 1 on dataset /Users/henryolders/metabolomics/train.tab
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
  166  V164                        C          52.07           731680.56 1664189.75     3
Trained attributes for classifier 2 on dataset /Users/henryolders/metabolomics/train.tab
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
  648  V646                        C          83.33            50983.67  499521.50     3
  773  V771                        C          83.33             2486.28  413975.19     3
    3  V1                          C          82.29           -26149.29   58297.68     3
Trained attributes for classifier 3 on dataset /Users/henryolders/metabolomics/train.tab
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
  341  V339                        C          85.42          1767316.75 4797437.00     4
  332  V330                        C          84.38           983358.94 2721019.00     4
  354  V352                        C          84.38           722747.31 3308507.00     4
  603  V601                        C          84.38           -27177.89   43638.25     4
  648  V646                        C          83.33            50983.67  499521.50     3
  773  V771                        C          83.33             2486.28  413975.19     3
  331  V329                        C          83.33          1032925.38 3304490.50     4
  340  V338                        C          83.33          1751390.00 5038233.00     4
  355  V353                        C          83.33           768053.81 2574747.75     4
```
Use all four classifiers in a multiple-classifier cross-validation of train.tab:
```sh
./vhamml cross -e -m ~/metabolomics/metabolomics.opts ~/metabolomics/train.tab
```
This gives the highest balanced accuracy of 86.32%.:
```
TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
14     3   158    17   0.824  0.903  0.452  0.981     0.583         89.58%    86.32%   0.561
```  

To obtain the highest sensitivity, use only the first 3 classifiers:
```sh
./vhamml cross -e -m ~/metabolomics/metabolomics.opts -m# 0,1,2 ~/metabolomics/train.tab
```
giving:
```
TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
15     2   124    51   0.882  0.709  0.227  0.984     0.361         72.40%    79.55%   0.353
```

Add the combined_radii_flag, -mc, to give a higher specificity without a loss of sensitivity:
```sh
./vhamml cross -e -m ~/metabolomics/metabolomics.opts -m# 0,1,2 -mc ~/metabolomics/train.tab
```
which gives:
```
TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
15     2   132    43   0.882  0.754  0.259  0.985     0.400         76.56%    81.83%   0.394
```
Feel free to experiment. You may be able to improve on these settings, either by using different classifier settings, or different flags for the cross-validation.

If these are the best settings we can find for optimizing classification using the training data only, let's try them when applied to the entire training set (192 cases, instead of the 191 cases for each leave-one-out cross-validation) and then to classify the 92 cases in the independent test set `test.tab`.

First, we will use all four classifiers which gave the highest balanced accuracy for the training dataset:

```sh
./vhamml verify -e -m ~/metabolomics/metabolomics.opts -t ~/metabolomics/test.tab ~/metabolomics/train.tab
```
This gives a good specificity of 0.847, but a poor sensitivity of only 0.571:
```
TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
 4     3    72    13   0.571  0.847  0.235  0.960     0.333         82.61%    70.92%   0.286
```

Using the first three classifiers only, and again setting the combined_radii-flag:
```sh
./vhamml verify -e -m ~/metabolomics/metabolomics.opts -t ~/metabolomics/test.tab -m# 0,1,2 -mc ~/metabolomics/train.tab
```
We now get:
```
Verification of "/Users/henryolders/metabolomics/test.tab" using multiple classifiers from "/Users/henryolders/metabolomics/train.tab"
Classifier parameters are in file "/Users/henryolders/metabolomics/metabolomics.opts"
break_on_all_flag: false     combined_radii_flag: true      total_nn_counts_flag: false     class_missing_purge_flag: false
Multiple Classifier Parameters:
Results:
    Class                     Instances    True Positives    Precision    Recall    F1 Score
    Non                              85      61 ( 71.76%)        0.968     0.718       0.824
    Can                               7       5 ( 71.43%)        0.172     0.714       0.278
        Totals                       92      66 (accuracy: raw: 71.74% balanced: 71.60%)
               Macro Averages:                                   0.570     0.716       0.551
            Weighted Averages:                                   0.908     0.717       0.783
A correct classification to "Can" is a True Positive (TP);
A correct classification to "Non" is a True Negative (TN).
   TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC
    5     2    61    24   0.714  0.718  0.172  0.968     0.278         71.74%    71.60%   0.246
Confusion Matrix:
Predicted Classes (columns)          Non        Can
      Actual Classes (rows)
                        Non           61         24
                        Can            2          5
processing time: 0 hrs 0 min  0.809 sec
```