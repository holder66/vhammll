# Classification of Cancer using Metabolomics
Using the Command Line Interface (CLI)

## Install V and set up to use the CLI
Follow the instructions in the README. The following assumes you've named your directory or folder "vhamml".

## Compile the app
In your terminal, navigate to directory/folder `vhamml` containing the `main.v` file
(see the README)
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
For the explore, use an attribute number range from 1 to 10, and a binning range also from 1 to 10. There are several flags, and the explore should be done over every combination of those flags. 
```sh
./vhamml explore -e -a 1,10 -b 1,10 ~/metabolomics/train.tab;
./vhamml explore -e -a 1,10 -b 1,10 -u ~/metabolomics/train.tab
```
