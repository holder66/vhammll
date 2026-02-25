# Examples of Command Line usage

## Compile the app
In your terminal, navigate to the directory/folder containing the `main.v` file
(see the [README](https://github.com/holder66/vhammll/blob/master/README.md))
```sh
% cd <directory containing your main.v file>
% v -prod main.v
```

Now you can run the app with command line entries starting with `% ./main`, 
as in `% ./main analyze ~/.vmodules/holder66/vhammll/datasets/anneal.tab`.
Sometimes, it may be more convenient and quicker to start with `% v run main.v`, as in
`% v run main.v verify -c -t ~/.vmodules/holder66/vhammll/datasets/bcw174test ~/.vmodules/holder66/vhammll/datasets/bcw350train`.

## Getting help
`% v run main.v --help` or
`% v run main.v -h` or simply, 
`% v run main.v`

For individual commands, use this pattern:

`% v run main.v analyze --help` or

`% v run main.v analyze -h` or 

`% v run main.v analyze`

## Analyzing a dataset
`% ./main analyze ~/.vmodules/holder66/vhammll/datasets/anneal.tab`

## Discovering which attributes are most useful
`% ./main rank --show --graph ~/.vmodules/holder66/vhammll/datasets/anneal.tab` or

`% ./main rank -s -g ~/.vmodules/holder66/vhammll/datasets/anneal.tab`

To specify a range for the number of bins for continuous attributes (if unspecified, the default range is 2 through 16 inclusive):

`% ./main rank --show --bins 3,6 ~/.vmodules/holder66/vhammll/datasets/iris.tab` or 

`% ./main rank -s -b 3,6 ~/.vmodules/holder66/vhammll/datasets/iris.tab`

To calculate rank values using the same number of bins for all attributes:

`% ./main rank -s -b 3,3 ~/.vmodules/holder66/vhammll/datasets/iris.tab`

To exclude missing values from the rank value calculations:

`% ./main rank --exclude --show --graph ~/.vmodules/holder66/vhammll/datasets/anneal.tab` or 

`% ./main rank -s -g -e ~/.vmodules/holder66/vhammll/datasets/anneal.tab`

## Working with large datasets
Doing a leave-one-out cross-validation on a large dataset can be time-consuming. Save time by doing fewer folds, eg 10-fold (`-f 10`). Repeat the exercise 5 times (`-r 5`); results are averaged over the 5 repetitions, since random selection of instances for folding means that results will be different for one repetition to another:

`% ./main analyze ~/.vmodules/holder66/vhammll/datasets/mnist_test.tab`

`% ./main cross -s -e -f 10 -r 5 -a 310 -b 2,2 -c ~/.vmodules/holder66/vhammll/datasets/mnist_test.tab`

## To explore how varying parameters affect classification accuracy
`% ./main explore --expand --graph --concurrent --weight ~/.vmodules/holder66/vhammll/datasets/breast-cancer-wisconsin-disc.tab` or

`% ./main explore -e -g -c -w ~/.vmodules/holder66/vhammll/datasets/breast-cancer-wisconsin-disc.tab`

To specify how the number of attributes should be varied (eg, from 2 through 8 attributes, inclusive, stepping by 2):

`% ./main explore -e -g -c -w --attributes 2,8,2 ~/.vmodules/holder66/vhammll/datasets/breast-cancer-wisconsin-disc.tab`

For datasets with continuous attributes, specify the binning range (eg, from 3 through 30 bins, stepping by 3):

`% ./main explore -s -g -c -w --bins 3,30,3 ~/.vmodules/holder66/vhammll/datasets/iris.tab`

To use the same number of bins for each attribute, add the -u or --uniform flag:

`% ./main explore -s -g -c -w -b 3,30,3 -u ~/.vmodules/holder66/vhammll/datasets/iris.tab`
