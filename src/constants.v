// constants.v

module vhammll

const vhammll_help = "

    Description:
    vhamml.v is a command line interface app to make use of the functionality
    of the holder66.vhamml Machine Learning library.
    help, -h, --help to display this usage information.
    For help with any of the commands below, enter the command followed by
      -h or --help, eg v run . make --help, or just enter the command,
      eg v run . explore
    Usage:
    Specify the file's path as the last command line argument, 
      eg, v run . analyze -s datasets/iris.tab
    
    Commands:
    analyze:   generates information about a dataset, for printing to the 
               console;
    append:    takes a classifier and extends it by adding labeled instances;
    cross:     performs a cross-validation on a dataset;
    display:   loads a previously saved result and displays it on the console.
               Applies to commands `analyze, append, cross, explore, make, 
               rank, validate, and verify` when those commands are run with
               -o --output and the path to a file.
    examples:  runs a file that displays brief information and a usage example 
               for running each command, prompts the user to continue, and then
               executes the example, displaying results on the console;
    explore:   carry out a series of cross-validation or verification 
               experiments over a range of parameter settings, in order to find 
               optimal values for classifier parameters;
    make:      create a classifier from a dataset;
    orange:    print an explanation of Orange file formats to the console;
    query:     using a classifier, create an instance using an interactive
               dialogue and then classify that instance;
    rank:      rank order the dataset's attributes in terms of their
               power in separating classes;
    validate:  as for verify, but using an unlabeled second dataset. Outputs 
               inferred classes for the second dataset;
    verify:    use a classifier and a second labeled dataset to verify how well
               the classifier performs in classifying the second dataset's 
               instances;
    
    Options:
    -a --attributes: can be one, two, or 3 integers; a single integer will
                     be used by make_classifier to produce a classifier with 
                     that number of attributes. More than one integer will be 
                     used by explore to provide a range and an interval;
    -b --bins:       can be one, two, or 3 integers; a single integer for one 
                     bin value to be used for all attributes; two integers for 
                     a range of bin values; a third integer specifies an 
                     interval for the range (note that the binning range is 
                     from the upper to the lower value);
    -bp, --balanced-prevalences: multiply the number of instances for classes
                     with low prevalence, to more closely balance prevalences;
    -c --concurrent: enable parallel processing to use multiple cores;
    -e --expanded:   show expanded results on the console;
    -f --folds:      default is leave-one-out;
    -g --graph:      generates plots that show in your default web browser;
    -h --help:        
    -k --classifier: followed by the path to a file for a saved Classifier;
    -ka --kaggle:    followed by the path to a file. Used with the 'validate' 
                     command, a csv file suitable for submission to a Kaggle 
                     competition is created;
    -m --multiple:   classify using more than one trained classifier, followed
                     by the path to a json file with parameters to generate
                     each classifier;
    -ma:             when multiple classifiers are used, stop classifying when 
                     matches have been found for all classifiers;
    -mc:             when multiple classifiers are used, combine the possible 
                     hamming distances for each classifier into a single list;
    -mt:             when multiple classifiers are used, add the nearest
                     neighbors from each classifier, weight by class
                     prevalences, and then infer from the totals;
    -m#:             followed by a list of which classifiers to apply in a 
                     multiple classification run (zero-indexed);
    -ms:             append the settings to a file (path follows flag) for use 
                     in multiple classification (with -m#). When used with
                     'explore', the settings for cases identified in the 
                     analytics are appended;
    -o --output:     followed by the path to a file in which a classifier, a
                     result, instances used for validation, or a query instance 
                     is to be stored;
    -p --purge:      remove instances which are duplicates after binning;
    -pmc --purge-missing-classes: removes instances for which the class value
                     is missing;
    -r --reps:       number of repetitions; if > 1, a random selection of
                     instances to be included in each fold will be applied;
    -s --show:       output results to the console;
    -t --test:       followed by the path to the datafile to be verified or
                     validated;
    -u --uniform:    specifies that the number of bins used will be the same
                     for all attributes for the explore command (note: to
                     obtain uniform binning with verify, validate, query, or
                     or cross-validate, specify the same value for binning,
                     eg -b 4,4))
    -v --verbose:    display additional information for debugging;
    -w --weight:     when classifying, weight the nearest neighbour counts by 
                     class prevalences;
    -wr:             when ranking attributes, weight contributions by 
                     class prevalences;
    -x --exclude:    do not take into account missing values when ranking 
                     attributes;
        
  "

const display_help = '
Description:
"display" regenerates the console display produced by other commands, from 
the file saved by those commands when run with the -o or --output flag followed
by the path to a file. It can also generate the plots produced by certain 
commands (rank, explore).
Display can be used to print out a multiple classifier settings file.

Usage:
first save a results file, eg 
v run . rank -o <path_to_results_file> <path_to_dataset_file>
Then: v run . display <path_to_results_file>

Options:
-e --expanded: show expanded results on the console 
-g --graph:    show plots on the default web browser
-ms:           save multiple classifier parameters to a file
'

const examples_help = '
Description:
"examples" displays information about running the various commands, shows
a typical command interface line illustrating the example, prompts the user
to continue by hitting the "return" key, and then executes the example 
and displays the result on the console. 

Usage:
To start the demonstration, enter "v run . examples go"

Options:
To stop before completing the demo, hit ctrl-C
'

const analyze_help = '
Description:
"analyze" displays on the console, tables containing information about a 
datafile\'s type, the attributes, and the class attribute. The tables are:
1. a list of attributes, their types, the unique values, and a count of
missing values;
2. a table with counts for each type of attribute;
3. a list of discrete attributes useful for training a classifier;
4. a list of continuous attributes useful for training a classifier;
5. a breakdown of the class attribute, showing counts for each class. 

Usage:
 v run . analyze <path_to_dataset_file>

Options:
-h --help: displays this message.
  '

const append_help = '
Description:
"append" extends a classifier by adding one or more labeled cases.
Instances to be added should be in a file specified at the end of the command 
line, to a classifier in a file specified by flag -k. The instances file can be
generated by the validate or query commands (using the -o option). information
about the extended classifier is displayed on the console.
Optionally, the extended classifier can be stored in a file specified by -o. 

Usage: v run . append -k <path_to_classifier_file> -o <path_to_instances_file> (this 
assumes that iris.cl and instancesfile have already been created)

Required:
-k --classifier: followed by the path to the classifier to be extended.

Options:
-o --output: followed by the path to a file in which the extended 
      classifier will be stored;
-e --expanded: print out the extended classifier struct on the console.
  '

const rank_help = '
Description:
  "rank" rank orders a dataset\'s attributes in terms of ability 
to distinguish between classes; it takes into account class prevalences.

Usage: v run . rank -x -g -wr <path_to_dataset_file>

Options: 
  -b --bins, eg, "3,6" specifies the lower and upper limits for the number 
      of slices or bins for continuous attributes;
  -x --exclude, exclude missing values from rank value calculations;
  -g --graph, produce a plot showing rank values vs number of bins for   
      continuous attributes.
  -wr, weight contribution to ranking by considering class prevalences.
    '

const make_help = '
Description:
"make" creates a classifier from the datafile given as the last argument.
Returns a classifier struct.

Usage: v run . make -s <path_to_dataset_file>

Options:
  -a --attributes: the number of attributes (picked from the list of 
      ranked attributes) to be used in training the classifier
  -b --bins: eg, "3,6" specifies the lower and upper limits for the number
      of slices or bins for continuous attributes;
  -e --expanded: display the classifier struct on the console.
  -o --output: followed by the path to a file in which the classifier will be stored;
  -p --purge: remove instances which are duplicates after binning;
  -wr: when ranking attributes, weight contributions by class prevalences;
  -x --exclude: exclude missing values from rank value calculations.
    '

const query_help = '
Description:
"query" takes a classifier created by make(), and interactively asks the user
to input (at the console) values for each attribute included in the classifier.
After the last entry, it classifies the new instance and returns its inferred
class.
Optionally, the new instance can be saved in an instances file specified by -o.
This instances file can be used by "append" to extend the classifier.

Usage: v run . query -k <path_to_classifier_file>

Options:
In addition to the options below, the options for the "make" command are also
applicable.
  -k --classifier, followed by the path to a classifier file.
  -o --output, followed by the path for saving the instance file.
  -v --verbose, show additional information for each query, and additional 
    statistics for the classification.
  -w --weight, weight the number of nearest neighbor counts by class prevalences;
  -wr, when ranking attributes, weight contributions by class prevalences.
    '

const orange_help = "
Description:
How to format files as per Orange.

Usage: v run . orange

Options: none


NEWER ORANGE FORMAT:
A single-line header consisting of attribute names prefixed by an optional
'<flags>#'' string, i.e. flags followed by a hash ('#') sign. The flags can 
be a consistent combination of:

c for class attribute (also known as a target variable or dependent variable),
i for attribute to be ignored,
m for meta attributes (not used in learning),
C for attributes that are continuous (numeric),
D for attributes that are discrete (categorical),
T for attributes that represent date and/or time in one of the ISO 8601 formats,
S for string attributes.

    if there are no prefixes for an attribute (ie just the attribute name)
    then the attribute will be treated as discrete, unless the actual values
    are numbers, in which case it will be treated as continuous.
  
OLDER ORANGE FORMAT:
the information about variable type, etc is contained in two lines:
  in the second line:
  d or discrete or a list of values: denotes a discrete attribute
  c or continuous: denotes a continuous attribute
  string denotes a string variable, which we ignore
  basket: these are continuous-valued meta attributes; ignore
  it may also contain a string of values separated by spaces. Use these
  as the values for a discrete attribute.
the third line contains optional flags:
  i or ignore
  c or class: there can only be one class attribute. If none is found,
   use the last attribute as the class attribute.
  m or meta: meta attribute, eg weighting information; ignore
  -dc followed by a value: indicates how a don't care is represented.
    "

const verify_help = '
Description:
"verify" takes two datasets; it creates a classifier from the dataset file
given by the last item in the command line, and uses that classifier to
classify the instances in the second dataset, given by the -t --test option. 
The parameters for which attributes to use, the list of permissible attribute 
values for discrete attributes, and the binning information for continuous 
attributes is copied from the classification dataset. Each instance in the 
verification dataset is classified, and the inferred classes are compared to 
the labeled classes to provide accuracy and other statistics.

Usage: v run . verify -c -e -t datasets/bcw174test datasets/bcw350train

Required:
-t --test: path to a test file to be verified.
Options:
In addition to the options below, the options for "make" apply to 
both the classification and the verification datafile.
-c --concurrent, permit parallel processing to use multiple cores;
-e --expanded, expanded results on the console;
-k --classifier, followed by the path to a file for a saved Classifier;
    can be used instead of the training dataset;
-w --weight, weight the number of nearest neighbor counts
    by class prevalences when classifying;
-wr, when ranking attributes, weight contributions by class prevalences.
    '

const validate_help = '
Description:
"validate" classifies the instances in a validation dataset (specified by 
-t, --test) using a classifier generated from the dataset specified by the 
final command line argument (or optionally a classifier file specified by 
-k --classifier). Note that a validation dataset does not contain class 
information. The parameters regarding which attributes to use, the list of 
permissible attribute values for discrete attributes, and the binning 
information for continuous attributes is copied from the classification 
dataset. Each instance in the validation dataset is classified, and the 
inferred classes are displayed on the console.

IMPORTANT: The validation dataset should still have an identified
class attribute; however, the values should be empty.

Usage: v run . validate -o ~/instancesfile -t datasets/bcw174validate <path_to_dataset_file> 

Required:
  -t --test: followed by the file path for the datafile to be used 
  for validation;

Options:
  In addition to the options below, the options for "make" apply to 
  both the classification and the validation datafile.
  -c --concurrent: permit parallel processing to use multiple cores (TODO);
  -e --expanded: display the ValidateResult struct on the console;
  -k --classifier: followed by the path to a file for a saved Classifier;
  -ka --kaggle:    followed by the path to a file for submission to a Kaggle
  competition;
  -w --weight: weight the number of nearest neighbor counts
  by class prevalences when classifying;
  -wr: when ranking attributes, weight contributions by class prevalences.
  '

const cross_help = '
Description:
"cross": When verifying the accuracy of a ML tool, it is common practice
to train the tool on a subset of the instances in a datafile, and then 
test that trained tool on the instances excluded from the subset. 
Two schemes are: leave one out, where a single instance is kept aside 
for testing; and n-fold partitioning, where n is often chosen to be 10. 
The training and testing is repeated for every possible fold.
For example, suppose the total dataset has 700 instances. That would 
give 70 instances for each fold, in the case of 10-fold partitioning. 
Thus, 70 instances would be kept aside and the tool trained on the 
remaining 630 instances, and this process would be repeated 10 times
to ensure that testing is done on all the instances.
Picking the instances to be kept aside can be done sequentially or 
randomly. If random, more repetitions are necessary to obtain some
degree of statistical validity.
An important consideration is that when training on a subset of instances, 
the dataset characteristics used in the training NOT be those of the 
whole dataset. For example, the maximum and minimum values for continuous 
attributes need to be recalculated for the subset, and the map of unique
values for discrete attributes may be different also for the subset 
compared to the whole dataset. 

Usage: v run . cross -c <path_to_dataset_file>

Options:
  -a --attributes: the number of attributes (picked from the list of 
      ranked attributes) to be used in training the classifier
  -b --bins: eg, "3,6" specifies the lower and upper limits for the 
      number of slices or bins for continuous attributes;
  -c --concurrent: permit parallel processing to use multiple cores;
  -e --expanded: expanded results on the console;
  -f --folds: number of cross-validation folds (default is leave-one-out);
  -p --purge: remove instances which are duplicates after binning;
  -r --reps: number of repetitions; if > 1, a random selection of 
      instances to be included in each fold will be applied;
  -w --weight: weight the number of nearest neighbor counts by 
      class prevalences;
  -wr: when ranking attributes, weight contributions by class prevalences;
  -x --exclude: exclude missing values from rank value calculations;

'

const explore_help = '
Description:
"explore" runs a series of cross-validations (or of verifies, if a
second file is given) over a range of parameter 
settings, used when seeking optimal values for parameters. A parameter 
range can be specified with up to 3 integers, with the first two for 
lower and upper ends of the range, and the 3rd integer (optional) for
the interval. For example, --bins 2,12,3 would indicate to do 
cross-validations for bins settings of 2, 5, 8, and 11. Note that a 
single integer specifies the upper end of a range starting at 1.

Usage: v run . explore <options> <path_to_dataset_file> 

Options:
  -a --attributes: a range for the number of attributes (picked from the list
      of ranked attributes) to be used in training the classifier;
  -b --bins: a range for the number of bins for continuous attributes;
  -c --concurrent: permit parallel processing to use multiple cores;
  -e --expanded: show expanded results on the console;
  -f --folds: number of cross-validation folds (default is leave-one-out);
  -g --graph: generates plots of accuracy vs number of attributes used; for 
      binary classifiers (ie only 2 classes) also generates AUC plots;
  -o --output: followed by the path to a file in which the ExploreResult
        struct will be saved;
  -p --purge: remove instances which are duplicates after binning;
  -r --reps: number of repetitions; if > 1, a random selection of 
      instances to be included in each fold will be applied;
  -s --show: show output on the console;
  -t --test: followed by the path to a second file, used for verifications;
  -u --uniform: specifies that the number of bins used will be the same
      for all attributes on a given cross-validation or verification;
  -w --weight: weight the number of nearest neighbor counts by 
      class prevalences;
  -wr: when ranking attributes, weight contributions by class prevalences;
  -x --exclude: exclude missing values from rank value calculations;
'
