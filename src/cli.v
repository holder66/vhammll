// cli.v
module vhammll

import os
import os.cmdline as oscmdline
import time
import math
// import runtime

@[params]
pub struct CliOptions {
	LoadOptions
pub mut:
	args []string
	astr string
}

// cli() is the command line interface app for the holder66.vhamml ML library.
// ```sh
// Usage: v run main.v [command] [flags and options] <path_to_file>
// Datafiles should be either tab-delimited, or have extension .csv or .arff
// Commands: analyze | append | cross | display | examples | explore
// | make | optimals | orange | partition | query | rank | validate | verify
// To get help with individual commands, type `v run main.v [command] -h`
//
// Flags and options (note that most are specific to commands):
// -a --attributes, followed by one, two, or 3 integers: Parameters.number_of_attributes
// -aa --all-attributes: for each category of optimals, retain all settings (the
//    default is to retain only settings with unique attribute numbers in each category);
// -af --all-flags: Options.traverse_all_flags
// -b --bins, followed by one, two, or 3 integers: Binning
//    A single value will be used for all attributes; two integers for a range of bin
//    values; a third integer specifies an interval for the range (note that
//    the binning range is from the upper to the lower value);
//    note: when doing an explore, the first integer specifies the lower
//    limit for the number of bins, and the second gives the upper value
//    for the explore range. Example: explore -b 3,6 would first use 3 - 3,
//    then 3 - 4, then 3 - 5, and finally 3 - 6 for the binning ranges.
//    If the uniform flag is true, then a single integer specifies
//    the number of bins for all continuous attributes; two integers for a
//    range of uniform bin values for the explore command; a third integer
//    for the interval to be used over the explore range;
// -bp, --balanced-prevalences: Parameters.balance_prevalences_flag
// -c --concurrent, permit parallel processing to use multiple cores: Options.concurrency_flag
// -cl --combination-limits: sets minimum and maximum lengths for combinations
//    of multiple classifiers: Options.DisplaySettings.CombinationSizeLimits;
//    entering values for limits also sets the generate_combinations_flag so
//    that classifier combinations will be generated.
// -e --expanded, expanded results on the console: DisplaySettings.expanded_flag
// -ea display information re trained attributes on the console, for
//    classification operations; DisplaySettings.show_attributes_flag
// -exr --explore-rank, followed by eg "2,7", will repeat the ranking
//    exercise over the binning range from 2 through 7 ⇒ Options.explore_rank
// -f --folds, followed by an integer specifying the number of folds in
//    cross-validation. The default is leave-one-out: Parameters.folds
// -g --graph, displays a plot: DisplaySettings.graph_flag
// -h --help: DisplaySettings.help_flag
// -k --classifier, followed by the path to a file for a saved Classifier: Options.classifierfile_path
// -ka --kaggle, followed by the path to a file. Used with the "validate" command,
// 	  a csv file suitable for submission to a Kaggle competition is created
//		Options.kagglefile_path
// -l --limit-output, followed by an integer which specifies how many
//  	attributes should be included in the console listing: DisplaySettings.limit_output
// -m --multiple, classify using more than one trained classifier, followed by
//    the path to a json file with parameters to generate each classifier:
//    Options.multiple_classify_options_file_path
// -ma when multiple classifiers are used, stop classifying when matches
//    have been found for all classifiers;
// -mc when multiple classifiers are used, combine the possible hamming
//    distances for each classifier into a single list;
// -mr for multiclass datasets, perform classification using a classifier for
//    each class, based on cases for that class set against all the other cases;
// -mt when multiple classifiers are used, add the nearest neighbors from
//    each classifier, weight by class prevalences, and then infer
//    from the totals;
// -m# followed by a list of which classifiers to apply in a multiple classi-
//	  fication run; also used to specify which classifiers to
//    append to a settings file. These values are classifier IDs, not array indices.
// -ms append the settings to a file (path follows flag) for use in multiple
//    classification (with -m#). When used with 'explore', the settings for
//    cases identified in the analytics are appended;
// -o --output, followed by the path to a file in which a classifier, a
//    result, instances used for validation, or a query instance will be
//    stored;
// -of --overfitting, when ranking attributes, the console output and graph will
//    include information allowing for an assessment of overfitting likelihood.
// -p --purge, removes instances which after binning are duplicates;
// -pos, followed by the name of the class to be considered the Positive class;
// -p#, number of partitions and their relative size (integer multiples of the smallest partition);
// -ps, list of file paths for saving each partition in its own file;
// -pmc --purge-missing-classes, removes instances for which the class value
//  is missing;
// -r --reps, number of repetitions; if > 1, a random selection of
// 	instances to be included in each fold will be applied;
// -rand, when partitioning datafiles, picks cases randomly (instead of sequentially);
// -roc, generate sensitivity vs 1-specificity values for generating a Receiver
//    Operating Characteristic (ROC) curve; if followed by a file path, save the
//    corresponding classifier settings to that file
// -s --show, output results to the console;
// -t --test, followed by the path to the datafile to be verified or validated;
// -u --uniform, specifies if uniform binning is to be used for the explore
//    command (note: to obtain uniform binning with verify, validate, query, or
//    or cross-validate, specify the same value for binning, eg -b 4,4)
// -v --verbose
// -w --weight, when classifying, weight the nearest neighbour counts by class prevalences;
// -wr when ranking attributes, weight contributions by class prevalences;
// -x --exclude, do not take into account missing values when ranking attributes;
// ```
pub fn cli(cli_options CliOptions) ! {
	sw := time.new_stopwatch()
	// get the command line string and use it to create an Options struct
	// println('nr_cpus: $runtime.nr_cpus() nr_jobs: $runtime.nr_jobs()')
	mut opts := get_options(match true {
		cli_options.astr != '' { cli_options.astr.split(' ') }
		cli_options.args != [] { cli_options.args }
		else { os.args[1..] }
	})
	if opts.command == '' && os.args.len > 1 {
		opts.command = os.args[1]
	}
	// opts.missings = cli_options.missings
	// opts.integer_range_for_discrete = cli_options.integer_range_for_discrete
	// opts.class_missing_purge_flag = cli_options.class_missing_purge_flag
	if opts.help_flag {
		println(show_help(opts))
	} else {
		opts.show_flag = true
		command := opts.command
		match command {
			'analyze' { analyze(opts) }
			'append' { do_append(opts)! }
			'cross' { cross(opts) }
			'display' { do_display(opts) }
			'examples' { examples()! }
			'explore' { explore(opts) }
			'make' { make(opts) }
			'optimals' { do_optimals(opts) }
			'orange' { orange() }
			'partition' { do_partition(opts)! }
			'query' { do_query(opts)! }
			'rank' { rank(opts) }
			'validate' { do_validate(opts)! }
			'verify' { verify(opts) }
			else { println('unrecognized command') }
		}
	}
	mut duration := sw.elapsed()
	// println('duration: $duration')
	println('processing time: ${int(duration.hours())} hrs ${int(math.fmod(duration.minutes(),
		60))} min ${math.fmod(duration.seconds(), 60):6.3f} sec')
}

@[params]
pub struct Cmd {
pub mut:
	cmd string
}

// opts takes a string of command line arguments and returns an Options struct
// corresponding to the command line arguments.
pub fn opts(s string, c Cmd) Options {
	mut result := get_options(s.split(' '))
	result.command = c.cmd
	return result
}

// get_options fills an Options struct with values from the command line
fn get_options(args []string) Options {
	mut opts := Options{
		args: args
	}

	if (flag(args, ['-h', '--help', 'help']) && args.len == 2) || args.len <= 1 {
		opts.help_flag = true
	}
	opts.non_options = oscmdline.only_non_options(args)
	if opts.non_options.len > 0 {
		opts.datafile_path = opts.non_options.last()
	}
	opts.traverse_all_flags = flag(args, ['-af', '--all-flags'])
	opts.concurrency_flag = flag(args, ['-c', '--concurrent'])
	opts.exclude_flag = flag(args, ['-x', '--exclude'])
	opts.graph_flag = flag(args, ['-g', '--graph'])
	opts.verbose_flag = flag(args, ['-v', '--verbose'])
	opts.weighting_flag = flag(args, ['-w', '--weight'])
	opts.weight_ranking_flag = flag(args, ['-wr'])
	opts.uniform_bins = flag(args, ['-u', '--uniform'])
	opts.show_flag = flag(args, ['-s', '--show'])
	opts.expanded_flag = flag(args, ['-e', '--expanded'])
	opts.show_attributes_flag = flag(args, ['-ea'])
	opts.multiple_flag = flag(args, ['-m', '--multiple'])
	opts.break_on_all_flag = flag(args, ['-ma'])
	if flag(args, ['-mt']) {
		opts.multi_strategy = 'totalnn'
	} else if flag(args, ['-mc']) {
		opts.multi_strategy = 'combined'
	}
	opts.one_vs_rest_flag = flag(args, ['-mr'])
	opts.append_settings_flag = flag(args, ['-ms'])
	opts.overfitting_flag = flag(args, ['-of', '--overfitting'])
	opts.purge_flag = flag(args, ['-p', '--purge'])
	opts.class_missing_purge_flag = flag(args, ['-pmc', '--purge-missing-classes'])
	opts.balance_prevalences_flag = flag(args, ['-bp', '--balanced-prevalences'])
	opts.random_pick = flag(args, ['-rand'])
	opts.generate_roc_flag = flag(args, ['-roc'])
	opts.all_attributes_flag = flag(args, ['-aa', '--all_attributes'])

	if option(args, ['-a', '--attributes']) != '' {
		opts.number_of_attributes = parse_range(option(args, ['-a', '--attributes']))
	}
	if option(args, ['-cl', '--combination-limits']) != '' {
		limits := parse_range(option(args, ['-cl', '--combination-limits']))
		opts.DisplaySettings.CombinationSizeLimits = CombinationSizeLimits{
			generate_combinations_flag: true
			min:                        limits.first()
			max:                        limits.last()
		}
	}
	if option(args, ['-f', '--folds']) != '' {
		opts.folds = option(args, ['-f', '--folds']).int()
	}

	if option(args, ['-l', '--limit-output']) != '' {
		opts.limit_output = option(args, ['-l', '--limit-output']).int()
	}

	if option(args, ['-r', '--reps']) != '' {
		opts.repetitions = option(args, ['-r', '--reps']).int()
	}
	if option(args, ['-pos', '--positive-class']) != '' {
		opts.positive_class = option(args, ['-pos', '--positive-class'])
	}
	if option(args, ['-b', '--bins']) != '' {
		opts.bins = parse_range(option(args, ['-b', '--bins']))
	}
	if option(args, ['-exr', '--explore-rank']) != '' {
		opts.explore_rank = parse_range(option(args, ['-exr', '--explore-rank']))
	}
	if option(args, ['-m#']) != '' {
		opts.classifiers = parse_range(option(args, ['-m#']))
	}
	if option(args, ['-p#']) != '' {
		opts.partition_sizes = parse_range(option(args, ['-p#']))
	}
	if option(args, ['-ps']) != '' {
		opts.partitionfiles_paths = parse_paths(option(args, ['-ps']))
	}
	opts.testfile_path = option(args, ['-t', '--test'])
	opts.outputfile_path = option(args, ['-o', '--output'])
	opts.classifierfile_path = option(args, ['-k', '--classifier'])
	opts.multiple_classify_options_file_path = option(args, ['-m', '--multiple'])
	opts.settingsfile_path = option(args, ['-ms'])
	opts.kagglefile_path = option(args, ['-ka', '--kaggle'])
	opts.roc_settingsfile_path = option(args, ['-roc'])
	return opts
}

// show_help
fn show_help(opts Options) string {
	return match opts.command {
		'rank' { rank_help }
		'query' { query_help }
		'analyze' { analyze_help }
		'append' { append_help }
		'make' { make_help }
		'optimals' { optimals_help }
		'orange' { orange_help }
		'verify' { verify_help }
		'cross' { cross_help }
		'explore' { explore_help }
		'validate' { validate_help }
		'display' { display_help }
		'examples' { examples_help }
		'partition' { partition_help }
		else { vhammll_help }
	}
}

// option returns the parameter following any of a list of options
fn option(args []string, what []string) string {
	mut found := false
	mut result := ''
	for arg in args {
		if found {
			result = arg
			break
		} else if arg in what {
			found = true
		}
	}
	return result
}

// flag returns true if a specific flag is found, false otherwise
fn flag(args []string, what []string) bool {
	for arg in args {
		if arg in what {
			return true
		}
	}
	return false
}

// analyze prints out to the console
fn analyze(opts Options) {
	analyze_dataset(opts)
}

// do_append appends instances in a file, to a classifier in a file specified
// by flag -k, and (optionally) stores the extended classifier in a file
// specified by -o. It displays the extended classifier on the console.
fn do_append(opts Options) ! {
	ext_cl := append_instances(load_classifier_file(opts.classifierfile_path)!, load_instances_file(opts.datafile_path)!,
		opts)
	if opts.expanded_flag {
		println(ext_cl)
	}
}

// do_display displays information about the contents of a file
// for classifiers, datasets, or results of operations
fn do_display(opts Options) {
	display_file(opts.datafile_path, opts)
}

fn get_classifier(opts Options) !Classifier {
	if opts.classifierfile_path == '' {
		return make_classifier(opts)
	}
	return load_classifier_file(opts.classifierfile_path)!
}

// query
fn do_query(opts Options) ! {
	cl := get_classifier(opts)!
	qr := query(cl, opts)
	if opts.expanded_flag {
		println(qr)
	}
}

// verify
// fn do_verify(opts Options) ! {
// 	match true {
// 		opts.multiple_flag { multi_verify(opts) }
// 		opts.one_vs_rest_flag { one_vs_rest_verify(opts) }
// 		else { verify(opts) }
// 	}
// }

// validate
fn do_validate(opts Options) ! {
	cl := get_classifier(opts)!
	var := validate(cl, opts)!
	if opts.expanded_flag {
		println(var)
	}
}

// cross
fn cross(opts Options) {
	mut new_opts := opts
	new_opts.random_pick = if opts.repetitions > 1 { true } else { false }
	new_opts.command = 'cross'
	cross_validate(new_opts)
}

// do_explore
// fn do_explore(opts Options) {
// 	explore(opts)
// }

fn do_optimals(opts Options) {
	optimals(opts.datafile_path, opts)
}

// orange
fn orange() {
}

// rank generates an array of attributes sorted according to their
// capacity to separate the classes, and displays it on the console.
// Optionally (-e flag) it prints out the RankingResult struct.
// Optionally (-o flag) it saves the RankingResult struct to a file.
fn rank(opts Options) {
	mut ra := RankingResult{}
	if opts.one_vs_rest_flag {
		ra = rank_one_vs_rest(opts)
	} else {
		ra = rank_attributes(opts)
	}
	if opts.verbose_flag {
		println(ra)
	}
}

// make generates a Classifier, and displays it on the console.
// Optionally (-e flag) it prints out the classifier struct.
// Optionally (-o flag) it saves the classifier file.
fn make(opts Options) {
	// mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	cl := make_classifier(opts)
	if opts.expanded_flag {
		println(cl)
	}
}

fn do_partition(opts Options) ! {
	partition_file(opts.partition_sizes, opts.datafile_path, opts.partitionfiles_paths,
		opts.random_pick)!
}
