## Example: typical use case, a clinical risk calculator

Health care professionals frequently make use of calculators to inform clinical decision-making. Data regarding symptoms, findings on physical examination, laboratory and imaging results, and outcome information such as diagnosis, risk for developing a condition, or response to specific treatments, is collected for a sample of patients, and then used to form the basis of a formula that can be used to predict the outcome information of interest for a new patient, based on how their symptoms and findings, etc. compare to those in the dataset.

Here we use the HamNN classifier to generate a clinical risk calculator, using the [Wisconsin Breast Cancer dataset](https://archive.ics.uci.edu/ml/datasets/Breast+Cancer+Wisconsin+%28Original%29). This data consists of the pathological findings on biopsies of breast lumps from 699 women; subsequent surgery in these patients determined whether the lump was benign or cancerous. Each case includes values for nine attributes (rating various aspects of the cell nucleus when examined under a microscope, on a scale from 1 to 10).

First, display information about the dataset:

```sh
v run . analyze -s datasets/breast-cancer-wisconsin-disc.tab
```
```sh


Analysis of Dataset "datasets/breast-cancer-wisconsin-disc.tab" (File Type orange_older)
All Attributes
 Index  Name                          Count  Uniques  Missing      %  Type
     0  Sample ID                       699      645        0    0.0     i
     1  Clump Thickness                 699       10        0    0.0     D
     2  Uniformity of Cell Size         699       10        0    0.0     D
     3  Uniformity of Cell Shape        699       10        0    0.0     D
     4  Marginal Adhesion               699       10        0    0.0     D
     5  Single Epithelial Cell Size     699       10        0    0.0     D
     6  Bare Nuclei                     699       11       16    2.3     D
     7  Bland Chromatin                 699       10        0    0.0     D
     8  Normal Nucleoli                 699       10        0    0.0     D
     9  Mitoses                         699        9        0    0.0     D
    10  Class                           699        2        0    0.0     c
_______                             _______           _______  _____
Totals (less Class attribute)          7689                16   0.21%
Counts of Attributes by Type
Type        Count
i               1
D               9
c               1
Total:         11
Discrete Attributes for Training (9 attributes)
 Index  Name                        Uniques
     1  Clump Thickness                  10
     2  Uniformity of Cell Size          10
     3  Uniformity of Cell Shape         10
     4  Marginal Adhesion                10
     5  Single Epithelial Cell Size      10
     6  Bare Nuclei                      11
     7  Bland Chromatin                  10
     8  Normal Nucleoli                  10
     9  Mitoses                           9
Continuous Attributes for Training (0 attributes)
 Index  Name                               Min         Max
The Class Attribute: "Class" (2 classes)
Class Value           Cases
benign                  458
malignant               241
processing time: 0 hrs 0 min  0.086 sec

```

Rank order the attributes according to their contribution to separating the classes (flag -s: display the output on the console): 

```sh
v run . rank  -s datasets/breast-cancer-wisconsin-disc.tab 
```
```sh

Attributes Sorted by Rank Value, for "datasets/breast-cancer-wisconsin-disc.tab"
Missing values: included
Bin range for continuous attributes: from 0 to 0 with interval 0
Unweighted by class prevalences
         Name                         Index  Type   Rank Value   Bins
     1   Uniformity of Cell Size          2  D           85.41      0
     2   Uniformity of Cell Shape         3  D           84.55      0
     3   Bare Nuclei                      6  D           82.26      0
     4   Bland Chromatin                  7  D           81.40      0
     5   Single Epithelial Cell Size      5  D           79.11      0
     6   Normal Nucleoli                  8  D           79.11      0
     7   Marginal Adhesion                4  D           72.82      0
     8   Clump Thickness                  1  D           72.25      0
     9   Mitoses                          9  D           57.94      0
processing time: 0 hrs 0 min  0.007 sec

```

We can run a set of exploratory cross-validations using leave-one-out
folding, and with the -w flag to weight the results using class prevalences.

```sh
v run . explore -w -wr -x -c -e -g datasets/breast-cancer-wisconsin-disc.tab
```
Note the additional flags: -w to prevalence-weight nearest neighbor counts; -wr to prevalence-weight when ranking attributes; -x to exclude missing values; -c to exploit parallel processing by using all the available CPU cores on your machine; -e to show extended results; -g to have plots of the results.
```sh

Explore leave-one-out cross-validation using classifiers from "datasets/breast-cancer-wisconsin-disc.tab"
Number of attributes: all
Binning range for continuous attributes: not applicable (no continuous attributes used)
Missing values: excluded
Purging of duplicate instances: false
Prevalence weighting for ranking attributes: true
Prevalence weighting for nearest neighbor counts: true
Add instances to balance class prevalences: false
Over attribute range from 1 to 9 by interval 1
A correct classification to "malignant" is a True Positive (TP);
A correct classification to "benign" is a True Negative (TN).
Attributes    Bins     TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced
         1            229    12   417    41   0.950  0.910  0.848  0.972     0.896         92.42%    93.03%
         2            231    10   428    30   0.959  0.934  0.885  0.977     0.920         94.28%    94.65%
         3            226    15   439    19   0.938  0.959  0.922  0.967     0.930         95.14%    94.81%
         4            227    14   439    19   0.942  0.959  0.923  0.969     0.932         95.28%    95.02%
         5            224    17   442    16   0.929  0.965  0.933  0.963     0.931         95.28%    94.73%
         6            218    23   444    14   0.905  0.969  0.940  0.951     0.922         94.71%    93.70%
         7            221    20   445    13   0.917  0.972  0.944  0.957     0.931         95.28%    94.43%
         8            224    17   445    13   0.929  0.972  0.945  0.963     0.937         95.71%    95.05%
         9            227    14   445    13   0.942  0.972  0.946  0.969     0.944         96.14%    95.68%
Command line arguments: ['explore', '-w', '-wr', '-x', '-c', '-e', '-g', 'datasets/breast-cancer-wisconsin-disc.tab']
Maximum accuracies obtained:
                raw accuracy:  96.14% [227, 14, 445, 13] using 9 attributes
           balanced accuracy:  95.68% [227, 14, 445, 13] using 9 attributes
              true positives:     231 [231, 10, 428, 30] using 2 attributes
              true negatives:     445 [221, 20, 445, 13] using 7 attributes



processing time: 0 hrs 0 min  8.043 sec

```

While using all 9 attributes gives the best classification result (balanced accuracy 95.68%; F1 Score 0.944) using only 2 attributes gives the lowest false positive rate.
It is possible that a number of the instances in this dataset are duplicates, ie have the same values. Let's redo the explore but with the -p or --purge flag:

```sh
v run . explore -w -wr -x -c -e -g -p datasets/breast-cancer-wisconsin-disc.tab
```
```sh

Explore leave-one-out cross-validation using classifiers from "datasets/breast-cancer-wisconsin-disc.tab"
Number of attributes: all
Binning range for continuous attributes: not applicable (no continuous attributes used)
Missing values: excluded
Purging of duplicate instances: true
Prevalence weighting for ranking attributes: true
Prevalence weighting for nearest neighbor counts: true
Add instances to balance class prevalences: false
Over attribute range from 1 to 9 by interval 1
A correct classification to "malignant" is a True Positive (TP);
A correct classification to "benign" is a True Negative (TN).
Attributes    Bins        Purged instances     (%)     TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced
         1              624.1 out of 698.0 (89.41)    229    12   414    44   0.950  0.904  0.839  0.972     0.891         91.99%    92.71%
         2              551.0 out of 698.0 (78.94)    229    12   427    31   0.950  0.932  0.881  0.973     0.914         93.85%    94.13%
         3              468.2 out of 698.0 (67.08)    226    15   431    27   0.938  0.941  0.893  0.966     0.915         93.99%    93.94%
         4              402.3 out of 698.0 (57.64)    227    14   439    19   0.942  0.959  0.923  0.969     0.932         95.28%    95.02%
         5              335.4 out of 698.0 (48.05)    224    17   441    17   0.929  0.963  0.929  0.963     0.929         95.14%    94.62%
         6              312.5 out of 698.0 (44.76)    220    21   443    15   0.913  0.967  0.936  0.955     0.924         94.85%    94.01%
         7              284.5 out of 698.0 (40.76)    221    20   444    14   0.917  0.969  0.940  0.957     0.929         95.14%    94.32%
         8              212.6 out of 698.0 (30.46)    224    17   444    14   0.929  0.969  0.941  0.963     0.935         95.57%    94.94%
         9              209.6 out of 698.0 (30.03)    227    14   444    14   0.942  0.969  0.942  0.969     0.942         95.99%    95.57%
Command line arguments: ['explore', '-w', '-wr', '-x', '-c', '-e', '-g', '-p', 'datasets/breast-cancer-wisconsin-disc.tab']
Maximum accuracies obtained:
                raw accuracy:  95.99% [227, 14, 444, 14] using 9 attributes, 30.03% instances purged.
           balanced accuracy:  95.57% [227, 14, 444, 14] using 9 attributes, 30.03% instances purged.
              true positives:     229 [229, 12, 414, 44] using 1 attributes, 89.41% instances purged.
              true negatives:     444 [221, 20, 444, 14] using 7 attributes, 40.76% instances purged.



processing time: 0 hrs 0 min 41.292 sec

```

We can see that deleting duplicate instances each time a classifier is built increases processing time, and reduces balaned accuracy by a small amount. Nevertheless, deleting so many instances will make the eventual classifier considerably smaller in terms of memory footprint, and therefore faster classifications.

Picking the best combination of attributes to be used, and bin range when there are continuous attributes, is often a matter of experience and judgment.
For the purposes of this example, however, let us train our classifier using 4 attributes, with purging of duplicates:

```sh
v run . make -a 4 -w -wr -s -p datasets/breast-cancer-wisconsin-disc.tab
```
```sh


Classifier from "datasets/breast-cancer-wisconsin-disc.tab"
Number of attributes: 4
Binning range for continuous attributes: from 1 to 16 with interval 1
Missing values: included
Purging of duplicate instances: true
Prevalence weighting for ranking attributes: true
Prevalence weighting for nearest neighbor counts: true
Add instances to balance class prevalences: false
Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins
    2  Uniformity of Cell Size     D          86.07        10
    3  Uniformity of Cell Shape    D          84.26        10
    6  Bare Nuclei                 D          81.35        11
    5  Single Epithelial Cell Size D          79.34        10

Classifier History:
Date & Time (UTC)    Event   From file                   Original Instances  After purging
2023-03-12 12:42:09  make    datasets/breast-cancer-wisconsin-disc.tab        699            296
processing time: 0 hrs 0 min  0.095 sec

```

We can use this trained classifier as a clinical calculator, to classify a new sample of breast tissue (with values of 8, 9, 7, and 8 for the four attributes identified above) as either malignant or benign:

```sh
v run . query -a 4 -w -wr -p datasets/breast-cancer-wisconsin-disc.tab
```
```sh

Possible values for "Uniformity of Cell Size": ['1', '10', '2', '3', '4', '5', '6', '7', '8', '9']
Please enter one of these values for attribute "Uniformity of Cell Size": 8
Possible values for "Uniformity of Cell Shape": ['1', '10', '2', '3', '4', '5', '6', '7', '8', '9']
Please enter one of these values for attribute "Uniformity of Cell Shape": 9
Possible values for "Bare Nuclei": ['1', '10', '2', '3', '4', '5', '6', '7', '8', '9', '?']
Please enter one of these values for attribute "Bare Nuclei": 7
Possible values for "Single Epithelial Cell Size": ['1', '10', '2', '3', '4', '5', '6', '7', '8', '9']
Please enter one of these values for attribute "Single Epithelial Cell Size": 8
Your responses were:
Uniformity of Cell Size 8
Uniformity of Cell Shape 9
Bare Nuclei        7
Single Epithelial Cell Size 8
Do you want to proceed? (y/n) y
For the classes ['benign', 'malignant'] the prevalence-weighted nearest neighbor counts are [0, 1832], 
so the inferred class is 'malignant'
processing time: 0 hrs 0 min 40.541 sec

```

The classifier imputes the class of the new sample as malignant. This is based on finding 1832 "malignant" nearest neighbours, vs no "benign" nearest neighbours (weighted values; without weighting by class prevalence, the nearest
neighbour counts would be 4 for malignant and 0 for benign).

In the real world, important information may not be available. Suppose we have a breast tissue sample where we only have information on the uniformity of cell shape which has a value of 2, and single epithelial cell size with a value of 3:

```sh
v run . query -a 4 -w -wr -p datasets/breast-cancer-wisconsin-disc.tab
```
```sh
Possible values for "Uniformity of Cell Size": ['1', '10', '2', '3', '4', '5', '6', '7', '8', '9']
Please enter one of these values for attribute "Uniformity of Cell Size": 
Possible values for "Uniformity of Cell Shape": ['1', '10', '2', '3', '4', '5', '6', '7', '8', '9']
Please enter one of these values for attribute "Uniformity of Cell Shape": 2
Possible values for "Bare Nuclei": ['1', '10', '2', '3', '4', '5', '6', '7', '8', '9', '?']
Please enter one of these values for attribute "Bare Nuclei": 
Possible values for "Single Epithelial Cell Size": ['1', '10', '2', '3', '4', '5', '6', '7', '8', '9']
Please enter one of these values for attribute "Single Epithelial Cell Size": 3
Your responses were:
Uniformity of Cell Size 
Uniformity of Cell Shape 2
Bare Nuclei        
Single Epithelial Cell Size 3
Do you want to proceed? (y/n) y
For the classes ['benign', 'malignant'] the prevalence-weighted nearest neighbor counts are [241, 0], 
so the inferred class is 'benign'
processing time: 0 hrs 0 min 36.359 sec


```

This sample is classified as benign, with weighted nearest neighbours 241 for and none against this inferred classification.
