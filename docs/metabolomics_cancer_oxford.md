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

## Exploring the `train.tab` data
We will leave aside the `test.tab` file, as it is to be used as an independent test set after the classifier has been optimized.
For the explore, use an attribute number range from 1 to 10, and a binning range also from 1 to 10. There are several flags, and the explore should be done over every combination of those flags (but read ahead to avoid these time-consuming steps):
```sh
./vhamml explore -e -a 1,10 -b 1,10 ~/metabolomics/train.tab;
./vhamml explore -e -a 1,10 -b 1,10 -u ~/metabolomics/train.tab;
./vhamml explore -e -a 1,10 -b 1,10 -wr ~/metabolomics/train.tab;
./vhamml explore -e -a 1,10 -b 1,10 -wr -u ~/metabolomics/train.tab;
./vhamml explore -e -a 1,10 -b 1,10 -w ~/metabolomics/train.tab;
./vhamml explore -e -a 1,10 -b 1,10 -w -u ~/metabolomics/train.tab;
./vhamml explore -e -a 1,10 -b 1,10 -w -wr ~/metabolomics/train.tab;
./vhamml explore -e -a 1,10 -b 1,10 -w -wr -u ~/metabolomics/train.tab;
```
and so on cycling through all the combinations of -u, -wr, -w, -p, and -bp.

Or, one can automate the process. In the `vhamml` directory, start a new file, "explore.v", with content
```v
module main

import holder66.vhammll
import os

fn main() {
	home_dir := os.home_dir()
	mut opts := vhammll.Options{
		datafile_path: os.join_path(home_dir, 'metabolomics', 'train.tab')
		settingsfile_path: os.join_path(home_dir, 'metabolomics', 'metabolomics.opts')
		command: 'explore'
		number_of_attributes: [1,10]
		bins: [2,10]
		append_settings_flag: true
	}
	ds := vhammll.load_file(opts.datafile_path)
	ft := [false, true]
	for ub in ft {
		opts.uniform_bins = ub
		for wr in ft {
			opts.weight_ranking_flag = wr
			for w in ft {
				opts.weighting_flag = w
				for p in ft {
					opts.purge_flag = p
					for bp in ft {
						opts.balance_prevalences_flag = bp
						_ := vhammll.explore(ds, opts)
					}
				}
			}
		}
	}
}
```
and run it from the command line:
```sh
v -prod run explore.v
```
This would take a couple of days to run, depending on the speed of your computer. Since we already know what the settings should be to achieve good results with classification, it will be faster to build the settings file using the "cross" command with parameters obtained by prior experimentation (remember to delete any pre-existing metabolomics.opts file first):
```sh
./vhamml cross -e -ms ~/metabolomics/metabolomics.opts -a 4 -b 8,8 -w -bp -p ~/metabolomics/train.tab;
./vhamml cross -e -ms ~/metabolomics/metabolomics.opts -a 1 -b 3,3 -wr -w -bp ~/metabolomics/train.tab;
./vhamml cross -e -ms ~/metabolomics/metabolomics.opts -a 3 -b 3,3 -w ~/metabolomics/train.tab;
./vhamml cross -e -ms ~/metabolomics/metabolomics.opts -a 9 -b 1,4 -w ~/metabolomics/train.tab
```
Verify that the newly generated settings file contains the settings for all 4 classifiers, and in the correct order:
```sh
./vhamml display ~/metabolomics/metabolomics.opts
```
Which should give:
```sh
./vhamml display ~/metabolomics/metabolomics.opts 
Multiple Classifier Options file: /Users/henryolders/metabolomics/metabolomics.opts
break_on_all_flag: false     combined_radii_flag: false      total_nn_counts_flag: false     class_missing_purge_flag: false
Multiple Classifier Parameters:
              Classifier:   0            1            2            3            
    Number of attributes:   4            1            3            9            
                 Binning:   8, 8, 1      3, 3, 1      3, 3, 1      1, 4, 1      
  Exclude missing values:   false        false        false        false        
 Ranking using weighting:   false        true         false        false        
  Weighting of NN counts:   true         true         true         true         
     Balance prevalences:   true         true         false        false        
   Purge duplicate cases:   true         false        false        false        
             True counts:   13     146   13     120   15     52    13     152   
            False counts:   4      29    4      55    2      123   4      23    
            Raw accuracy:   82.81 %      69.27 %      34.90 %      85.94 %      
       Balanced accuracy:   79.95 %      72.52 %      58.97 %      81.66 %      
Maximum Hamming Distance:   32           3            9            34           
```
Use all four classifiers in a multiple-classifier cross-validation of train.tab:
```sh
./vhamml cross -e -m ~/metabolomics/metabolomics.opts ~/metabolomics/train.tab
```
This gives the highest balanced accuracy of 86.32%.
To obtain the highest sensitivity, use only the first 3 classifiers. Add the combined_radii_flag, -mc, to give a higher specificity without a loss of sensitivity:
```sh
./vhamml cross -e -m ~/metabolomics/metabolomics.opts -m# 0,1,2 -mc ~/metabolomics/train.tab
```
Feel free to experiment. You may be able to improve on these settings, either by using different classifier settings, or different flags for the cross-validation.

If these are the best settings we can find for optimizing classification using the training data only, let's try them when applied to the entire training set (192 cases, instead of the 191 cases for each leave-one-out cross-validation) and then to classify the 92 cases in the independent test set `test.tab`:

```sh
./vhamml verify -e -m ~/metabolomics/metabolomics.opts -t ~/metabolomics/test.tab ~/metabolomics/train.tab
```
This gives a good specificity of 0.847, but a poor sensitivity of only 0.571.
Using the first three classifiers only, and again setting the combined_radii-flag:
```sh
./vhamml verify -e -m ~/metabolomics/metabolomics.opts -t ~/metabolomics/test.tab -m# 0,1,2 -mc ~/metabolomics/train.tab
```
We now get:
```sh

Verification of "/Users/henryolders/metabolomics/test.tab" using multiple classifiers from "/Users/henryolders/metabolomics/train.tab"
Classifier parameters are in file "/Users/henryolders/metabolomics/metabolomics.opts"
break_on_all_flag: false     combined_radii_flag: true      total_nn_counts_flag: false     class_missing_purge_flag: false
Multiple Classifier Parameters:
              Classifier:   0            1            2            
    Number of attributes:   4            1            3            
                 Binning:   8, 8, 1      3, 3, 1      3, 3, 1      
  Exclude missing values:   false        false        false        
 Ranking using weighting:   false        true         false        
  Weighting of NN counts:   true         true         true         
     Balance prevalences:   true         true         false        
   Purge duplicate cases:   true         false        false        
             True counts:   13     146   13     120   15     52    
            False counts:   4      29    4      55    2      123   
            Raw accuracy:   82.81 %      69.27 %      34.90 %      
       Balanced accuracy:   79.95 %      72.52 %      58.97 %      
Maximum Hamming Distance:   32           3            9            
Results:
    Class                   Instances    True Positives    Precision    Recall    F1 Score
    Non                            85      61 ( 71.76%)        0.968     0.718       0.824
    Can                             7       5 ( 71.43%)        0.172     0.714       0.278
        Totals                     92      66 (accuracy: raw: 71.74% balanced: 71.60%)
             Macro Averages:                                   0.570     0.716       0.551
          Weighted Averages:                                   0.908     0.717       0.783
A correct classification to "Can" is a True Positive (TP);
A correct classification to "Non" is a True Negative (TN).
   TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced
    5     2    61    24   0.714  0.718  0.172  0.968     0.278         71.74%    71.60%
Confusion Matrix:
Predicted Classes (columns)          Non        Can
      Actual Classes (rows)
                        Non           61         24
                        Can            2          5
processing time: 0 hrs 0 min  0.664 sec
```