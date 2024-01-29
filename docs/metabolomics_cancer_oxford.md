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
						_ := vhammll.explore(ds, opts, expanded_flag: true)
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
This would take a couple of days to run, depending on the speed of your computer. Since we already know what the settings should be to achieve good results with classification, it will be faster to build the settings file with the multiple classifier settings use the "cross" command:
```sh
.vhamml cross -e -ms ~/metabolomics/metabolomics.opts -a 4 -b 8,8 -w -bp -p ~/metabolomics/train.tab;
.vhamml cross -e -ms ~/metabolomics/metabolomics.opts -a 1 -b 3,3 -wr -w -bp ~/metabolomics/train.tab;
.vhamml cross -e -ms ~/metabolomics/metabolomics.opts -a 3 -b 3,3 -w ~/metabolomics/train.tab;
.vhamml cross -e -ms ~/metabolomics/metabolomics.opts -a 9 -b 1,4 -w ~/metabolomics/train.tab
```