// examples.v
module vhammll

import os
import readline { read_line }

const examples_help = '
Description:
"examples" displays information about running the various commands, shows
a typical command interface line illustrating the example, prompts the user
to continue by hitting the "return" key, and then executes the example
and displays the result on the console.

Usage:
To start the demonstration, enter "v run main.v examples go"

Options:
To stop before completing the demo, hit ctrl-C
'

// run_example
fn run_example(before string, after string, cmd string) ! {
	println(before)
	println('eg, ~$ ' + c_r(cmd))
	line := read_line('Press "return" to execute ("s" to skip)...')!
	// test if an 's' was entered
	if !line.contains_u8(115) {
		println(os.execute_or_panic(cmd).output)
	}
	println('\n${after}\n\n')
}

// examples
fn examples() ! {
	mut before := ''
	mut after := ''
	mut cmd := ''

	// help
	before = 'To get help for individual commands, use this pattern: v run . analyze --help , or v run . analyze -h , or simply v run . analyze'
	cmd = 'v run . analyze --help'
	run_example(before, after, cmd)!

	// analyze
	before = 'Analyzing a dataset displays tables describing the dataset.'
	cmd = 'v run . analyze ~/.vmodules/holder66/vhammll/datasets/anneal.tab'
	run_example(before, after, cmd)!

	// rank
	before = 'The rank command is for discovering which attributes are the most useful: \nv run . rank --show --graph ~/.vmodules/holder66/vhammll/datasets/anneal.tab , or '
	cmd = 'v run . rank -s ~/.vmodules/holder66/vhammll/datasets/anneal.tab'
	after = 'Please note that the -g or --graph flag resulted in a plot being displayed in your web browser.'
	run_example(before, after, cmd)!

	before = 'To specify a range for the number of bins for continuous attributes (if unspecified, the default range is 2 through 16 inclusive):
v run . rank --show --bins 3,6 ~/.vmodules/holder66/vhammll/datasets/iris.tab , or '
	after = ''
	cmd = 'v run . rank -s -b 3,6 ~/.vmodules/holder66/vhammll/datasets/iris.tab'
	run_example(before, after, cmd)!

	before = 'To calculate rank values using the same number of bins for all attributes:'
	cmd = 'v run . rank -s -b 3,3 ~/.vmodules/holder66/vhammll/datasets/iris.tab'
	run_example(before, after, cmd)!

	// cross
	before = "The classifier provides two mechanisms to test classification:
cross-validation or verification (which requires a separate test dataset).
Let's look at cross-validation first:"
	cmd = 'v run . cross ~/.vmodules/holder66/vhammll/datasets/iris.tab'
	run_example(before, after, cmd)!

	before = 'One can specify the number of attributes to be used, as well as a range over which binning will take place. Also, the -e or --expanded flag gives additional information including a confusion matrix:'
	cmd = 'v run . cross -a 2 -b 6 -e ~/.vmodules/holder66/vhammll/datasets/iris.tab'
	after = "Note that the accuracy of 98% is  higher than the highest published result for this dataset that I'm aware of!"
	run_example(before, after, cmd)!

	before = 'For datasets with only 2 classes, measures of accuracy including sensitivity, balanced accuracy, and F1 score are provided. The class with fewer cases is taken to be the "positive" class:'
	cmd = 'v run . cross -c -e ~/.vmodules/holder66/vhammll/datasets/breast-cancer-wisconsin-disc.tab'
	after = ''
	run_example(before, after, cmd)!

	before = 'When the classes are unbalanced, using the -w or --weighting flag results in computing nearest neighbor counts by taking into account class prevalences:'
	cmd = 'v run . cross -c -e -w ~/.vmodules/holder66/vhammll/datasets/breast-cancer-wisconsin-disc.tab'
	run_example(before, after, cmd)!

	// verify
	before = 'The second classification mechanism uses one dataset for training a classifier, and a second test dataset (specified with the -t option) with different labeled instances or cases for verification:'
	cmd = 'v run . verify -c -a 1 -b 4 -u -w -e -t ~/.vmodules/holder66/vhammll/datasets/leukemia34test.tab ~/.vmodules/holder66/vhammll/datasets/leukemia38train.tab'
	run_example(before, after, cmd)!

	before = 'And here is the use of verify with a multi-class dataset: 19 classes, 35 discrete attributes'
	cmd = 'v run . verify -c -a 13 -e -t ~/.vmodules/holder66/vhammll/datasets/soybean-large-test.tab ~/.vmodules/holder66/vhammll/datasets/soybean-large-train.tab'
	run_example(before, after, cmd)!

	before = 'Most classifier algorithms do not handle missing values well. However, missing values often add useful information that can improve classification accuracy. VHamMLL
	 by default includes missing values, but they can be excluded by using the -x or --exclude flag:'
	cmd = 'v run . cross -c -e -w -a 2 -x ~/.vmodules/holder66/vhammll/datasets/developer.tab'
	run_example(before, after, cmd)!

	before = 'Contrast with the accuracy when missing values are taken into account:'
	cmd = 'v run . cross -c -e -w -a 2 ~/.vmodules/holder66/vhammll/datasets/developer.tab'
	run_example(before, after, cmd)!

	before = 'When working with large ~/.vmodules/holder66/vhammll/datasets, doing a leave-one-out cross-validation can be time-consuming. For example, the mnist test dataset has 10,000 cases, so doing a leave-one-out cross-validation requires training 10,000 classifiers. Save time by doing fewer folds, eg 10-fold (-f 10). Repeat the exercise 5 times (-r 5); results are averaged over the 5 repetitions, since random selection of instances for folding means that results will be different for one repetition to another. (Warning: executing this command can take several minutes!)'
	cmd = 'v run . cross -s -e -f 10 -r 5 -a 310 -b 2,2 -c ~/.vmodules/holder66/vhammll/datasets/mnist_test.tab'
	run_example(before, after, cmd)!

	before = 'The explore command allows us to run a series of cross-validations or verifications on a dataset while varying the number of attributes and the number of bins used for continuous attributes. This allows us to find which parameter values give good classification accuracy for our use case. For datasets with continuous attributes, specify the binning range (eg, from 3 through 30 bins, stepping by 3):'
	cmd = 'v run . explore -s  -c -w --bins 3,30,3 ~/.vmodules/holder66/vhammll/datasets/iris.tab'
	run_example(before, after, cmd)!

	before = 'To use the same number of bins for each attribute, add the -u or --uniform flag:'
	cmd = 'v run . explore -s  -c -w -b 3,30,3 -u ~/.vmodules/holder66/vhammll/datasets/iris.tab'
	run_example(before, after, cmd)!

	before = 'A consequence of binning of continous attributes is that more instances are duplicates of other instances. In general, deleting these duplicate instances when building a classifier (by specifying the -p or --purge flag) has minimal effects on classification accuracy. In some cases, accuracy may improve! In any case, by deleting duplicate instances, the final classifier will have a tinier memory footprint and classification will take less processing time:'
	cmd = 'v run . explore -s  -c -w -b 3,30,3 -u -p ~/.vmodules/holder66/vhammll/datasets/iris.tab'
	run_example(before, after, cmd)!

	before = 'When there are only two classes, the -e flag give additional accuracy measures, and the -g flag generates Receiver Operating Characteristic plots:'
	cmd = 'v run . explore -e  -c -w ~/.vmodules/holder66/vhammll/datasets/breast-cancer-wisconsin-disc.tab
'
	run_example(before, after, cmd)!

	before = 'To specify how the number of attributes should be varied (eg, from 2 through 8 attributes, inclusive, stepping by 2):'
	cmd = 'v run . explore -e  -c -w --attributes 2,8,2 ~/.vmodules/holder66/vhammll/datasets/breast-cancer-wisconsin-disc.tab'
	run_example(before, after, cmd)!

	before = 'Explore also works in verification mode; simply specify a test dataset with the -t or --test flag:'
	cmd = 'v run . explore   -c -u -w -t ~/.vmodules/holder66/vhammll/datasets/vowel-test.tab ~/.vmodules/holder66/vhammll/datasets/vowel-train.tab'
	run_example(before, after, cmd)!

	// multiple classifiers and optimals
	before = 'VHamMLL can combine several classifiers trained with different settings to improve accuracy. The -ms flag saves each classifier\'s settings to a file as explore runs. Here we save settings for the breast-cancer-wisconsin dataset:'
	cmd = 'v run . explore -s -c -w -ms ~/bcw.opts ~/.vmodules/holder66/vhammll/datasets/bcw350train'
	after = 'Each row in the output corresponds to one classifier. Its settings have been appended to ~/bcw.opts.'
	run_example(before, after, cmd)!

	before = 'The optimals command searches all pairs, triples, etc. of classifiers in a settings file and reports which combinations give the best balanced accuracy, highest Matthews Correlation Coefficient (MCC), and highest correct-inference count per class:'
	cmd = 'v run . optimals -e ~/bcw.opts'
	after = 'Note the classifier IDs listed for each category — you can pass those IDs to -m# in a subsequent cross or verify run.'
	run_example(before, after, cmd)!

	before = 'Settings files can accumulate duplicate entries (same parameters, different IDs). The -p flag purges duplicates, and -o saves the cleaned file for later use:'
	cmd = 'v run . optimals -p -o ~/bcw-purged.opts ~/bcw.opts'
	after = 'The purged file ~/bcw-purged.opts contains only unique classifier settings and can be used in place of the original.'
	run_example(before, after, cmd)!

	before = 'To cross-validate using all classifiers in the settings file together (combining their votes):'
	cmd = 'v run . cross -s -m ~/bcw-purged.opts ~/.vmodules/holder66/vhammll/datasets/bcw350train'
	after = ''
	run_example(before, after, cmd)!

	before = 'Use -af (all-flags) to automatically run all strategy combinations and compare them side by side (3 strategies × 2 -ma settings = 6 rows):'
	cmd = 'v run . cross -s -m ~/bcw-purged.opts -af ~/.vmodules/holder66/vhammll/datasets/bcw350train'
	after = 'Pick the strategy that gives the best result and then use it with -mc or -mt in a final cross or verify run.'
	run_example(before, after, cmd)!

	// make
	before = 'Once you have settled on parameter values that will be optimal for your use case, you can generate a classifier and save it to a file, which you specify with the -o or --output option:'
	cmd = 'v run . make --output ~/bcw.cl -a 4 ~/.vmodules/holder66/vhammll/datasets/bcw350train'
	run_example(before, after, cmd)!

	before = 'The saved classifier, accessed with the -k or --classifier option, can be used to verify a separate dataset (the -t or --test option is required to specify the dataset to be verified):'
	cmd = 'v run . verify -k ~/bcw.cl -t ~/.vmodules/holder66/vhammll/datasets/bcw174test'
	run_example(before, after, cmd)!

	before = 'A classifier, generated as needed or a saved file, can be used to classify unlabeled instances in a dataset file. This process uses the validate command, and the test dataset specified with the -t or --test option should include the class attribute, but with empty strings for its values.'
	cmd = 'v run . validate --classifier ~/bcw.cl --test ~/.vmodules/holder66/vhammll/datasets/bcw174validate'
	after = 'The output of validate gives the inferred class for each instance, and the nearest neighbor counts for that instance to each of the possible classes. When the counts are very different between classes, one can be confident in the inferred classification. For example, look at the second-last instance in the output of the above command, [3, 8], a ratio of 8 to 3, or 2.67, in favor of "malignant".'
	run_example(before, after, cmd)!

	before = 'If the classifier was generated with the -w or --weighting flag set, then that flag can also be used with validate, in order to weight the nearest neighbor counts by class prevalences. Saving...'
	after = ''
	cmd = 'v run . make --output ~/bcw.cl -a 4 -w ~/.vmodules/holder66/vhammll/datasets/bcw350train'
	run_example(before, after, cmd)!

	before = 'And now validating...'
	cmd = 'v run . validate -w --classifier ~/bcw.cl --test ~/.vmodules/holder66/vhammll/datasets/bcw174validate'
	after = 'The resultant count values are artificially high, but the ratios are important; with weighting, the second-last instance gives [159, 191], which still classifies to malignant, but the ratio of 1.2 to 1 inspires much less confidence than 8 to 3 without weighting.'
	run_example(before, after, cmd)!

	// before = 'The "query" command is another way to use a trained classifier, either generated on the spot or as a saved file. This command starts an interactive session at the console for the user to enter values for attributes:'
	// cmd = 'v run . query -a 4 -w -s  ~/.vmodules/holder66/vhammll/datasets/bcw350train'
	// after = ''
	// run_example(before, after, cmd)!

	before = 'It is possible to save the results of a query or a validate to a file specified with the -o or --output option. This saved file can be used to extend a saved classifier by appending the now labeled instances onto it. First, save a classifier:'
	cmd = 'v run . make -a 33 -o ~/soybean.cl ~/.vmodules/holder66/vhammll/datasets/soybean-large-train.tab'
	after = ''
	run_example(before, after, cmd)!

	before = 'Do a validation using the saved classifier:'
	cmd = 'v run . validate -k ~/soybean.cl -o ~/soybean.val -t ~/.vmodules/holder66/vhammll/datasets/soybean-large-validate.tab'
	after = ''
	run_example(before, after, cmd)!

	before = 'Then append the saved validation file to the saved classifier:'
	cmd = 'v run . append -o ~/soybean.ext.cl -k ~/soybean.cl ~/soybean.val'
	after = ''
	run_example(before, after, cmd)!

	before = "Let's test the extended classifier with a test file:"
	cmd = 'v run . verify -k ~/soybean.ext.cl -t ~/.vmodules/holder66/vhammll/datasets/soybean-large-test.tab'
	after = "That's it! Now try it on your own datasets!"
	run_example(before, after, cmd)!
}
