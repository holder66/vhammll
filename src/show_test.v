// show_test.v
module vhammll

import os

fn testsuite_begin() ! {
	if os.is_dir('tempfolder_show') {
		os.rmdir_all('tempfolder_show')!
	}
	os.mkdir_all('tempfolder_show')!
}

fn testsuite_end() ! {
	os.rmdir_all('tempfolder_show')!
}

// test_show_analyze has no asserts; the console output needs
// to be verified visually.

fn test_show_analyze() {
	println('test_show_analyze should print out dataset analyses for developer.tab and for iris.tab')
	mut opts := Options{
		show_flag: false
	}
	mut ar := AnalyzeResult{}
	mut ds := Dataset{}

	ar = analyze_dataset(load_file('datasets/developer.tab'), opts)
	show_analyze(ar)

	ar = analyze_dataset(load_file('datasets/iris.tab'), opts)
	show_analyze(ar)

	// with purging of instances whose class values are missing
	ar = analyze_dataset(load_file('datasets/class_missing_developer.tab', class_missing_purge_flag: true), opts)
	show_analyze(ar)

	ar = analyze_dataset(load_file('datasets/class_missing_iris.tab', class_missing_purge_flag: true), opts)
	show_analyze(ar)
}

fn test_show_append() ? {
	println('test_show_append should print out a test.tab classifier, with 6 instances, followed by a test.tab classifier with 16 instances, and then a test.tab classifier with 26 instances and 3 history events. Then 3 classifiers based on soybean-large-train.tab.')
	mut opts := Options{
		verbose_flag: false
		show_flag: true
		concurrency_flag: false
		weighting_flag: true
	}

	mut cl := Classifier{}
	mut tcl := Classifier{}
	mut val_results := ValidateResult{}
	// create the classifier file and save it
	opts.command = 'make'
	opts.outputfile_path = 'tempfolder_show/classifierfile'
	mut ds := load_file('datasets/test.tab')
	cl = make_classifier(mut ds, opts)
	// do a validation and save the result
	opts.outputfile_path = 'tempfolder_show/instancesfile'
	opts.testfile_path = 'datasets/test_validate.tab'
	val_results = validate(cl, opts)!
	// now do the append, first from val_results, and
	// saving the extended classifier
	opts.outputfile_path = 'tempfolder_show/classifierfile'
	opts.command = 'append'
	tcl = append_instances(cl, val_results, opts)

	// now do it again but from the saved validate result,
	// appending to the previously extended classifier
	tcl = append_instances(load_classifier_file('tempfolder_show/classifierfile')!, load_instances_file('tempfolder_show/instancesfile')!,
		opts)

	// repeat with soybean
	opts.command = 'make'
	opts.outputfile_path = 'tempfolder_show/classifierfile'
	ds = load_file('datasets/soybean-large-train.tab')
	cl = make_classifier(mut ds, opts)
	// do a validation and save the result
	opts.outputfile_path = 'tempfolder_show/instancesfile'
	opts.testfile_path = 'datasets/soybean-large-validate.tab'
	val_results = validate(cl, opts)!
	// now do the append, first from val_results, and
	// saving the extended classifier
	opts.outputfile_path = 'tempfolder_show/classifierfile'
	opts.command = 'append'
	tcl = append_instances(cl, val_results, opts)

	// now do it again but from the saved validate result,
	// appending to the previously extended classifier
	tcl = append_instances(load_classifier_file('tempfolder_show/classifierfile')!, load_instances_file('tempfolder_show/instancesfile')!,
		opts)
}

fn test_show_classifier() {
	println('test_show_classifier prints out classifiers for iris.tab and for developer.tab')
	mut opts := Options{
		show_flag: true
		command: 'make'
		bins: [3, 10]
		number_of_attributes: [2]
	}
	mut ds := load_file('datasets/iris.tab')
	mut cl := make_classifier(mut ds, opts)
	ds = load_file('datasets/anneal.tab')
	cl = make_classifier(mut ds, opts)

	// now with purging of instances with missing class values

	ds = load_file('datasets/class_missing_iris.tab', class_missing_purge_flag: true)
	cl = make_classifier(mut ds, opts)

	// repeat with developer.tab, which is newer_orange format
	ds = load_file('datasets/developer.tab')
	cl = make_classifier(mut ds, opts)
	ds = load_file('datasets/class_missing_developer.tab', class_missing_purge_flag: true)
	cl = make_classifier(mut ds, opts)
}

fn test_show_crossvalidation() ? {
	println('test_show_crossvalidation prints out cross-validation results for developer.tab, breast-cancer-wisconsin-disc.tab, and iris.tab')
	mut cvr := CrossVerifyResult{}
	mut opts := Options{
		show_flag: true
		concurrency_flag: true
		command: 'cross'
	}
	println('\n\ndeveloper.tab')
	cvr = cross_validate(load_file('datasets/developer.tab'), opts)
	println('\ndeveloper.tab with expanded results')
	opts.expanded_flag = true
	cvr = cross_validate(load_file('datasets/developer.tab'), opts)

	println('\n\nbreast-cancer-wisconsin-disc.tab')
	opts.expanded_flag = false
	opts.number_of_attributes = [4]
	cvr = cross_validate(load_file('datasets/breast-cancer-wisconsin-disc.tab'), opts)
	println('\nbreast-cancer-wisconsin-disc.tab with expanded results')
	opts.expanded_flag = true
	cvr = cross_validate(load_file('datasets/breast-cancer-wisconsin-disc.tab'), opts)

	println('\n\niris.tab')
	opts.expanded_flag = false
	opts.bins = [3, 6]
	opts.number_of_attributes = [2]
	cvr = cross_validate(load_file('datasets/iris.tab'), opts)
	println('\niris.tab with expanded results')
	opts.expanded_flag = true
	cvr = cross_validate(load_file('datasets/iris.tab'), opts)
	// now with purging for missing classes
	cvr = cross_validate(load_file('datasets/class_missing_iris.tab', class_missing_purge_flag: true), opts)
}

fn test_show_explore_cross() ? {
	println('\n\n test_show_explore_cross prints out explore results for cross-validation of developer.tab')
	mut results := ExploreResult{}
	mut opts := Options{
		verbose_flag: false
		number_of_attributes: [2, 4]
		bins: [2, 5]
		show_flag: true
		expanded_flag: false
		weighting_flag: true
		exclude_flag: true
		concurrency_flag: true
		uniform_bins: true
		folds: 10
		repetitions: 50
		random_pick: true
		datafile_path: 'datasets/developer.tab'
		command: 'explore'
	}
	results = explore(load_file(opts.datafile_path), opts)

	// repeat for class missing purge
	opts.datafile_path = 'datasets/class_missing_developer.tab'
	results = explore(load_file(opts.datafile_path, class_missing_purge_flag: true), opts)
}

fn test_show_explore_verify() ? {
	println('\n\ntest_show_explore_verify prints out explore results for verification of bcw350train with bcw174test')
	mut results := ExploreResult{}
	mut opts := Options{
		verbose_flag: false
		number_of_attributes: [2, 6]
		show_flag: true
		expanded_flag: false
		weighting_flag: false
		exclude_flag: true
		concurrency_flag: true
		command: 'explore'
		datafile_path: 'datasets/bcw350train'
		testfile_path: 'datasets/bcw174test'
	}
	results = explore(load_file(opts.datafile_path), opts)
	opts.weighting_flag = true
	opts.expanded_flag = true
	opts.number_of_attributes = [0]
	results = explore(load_file(opts.datafile_path), opts)
}

fn test_show_rank_attributes() {
	println('\n\ntest_show_rank_attributes prints out attribute rankings for developer.tab, iris.tab, and anneal.tab (without and with missing values)')
	mut opts := Options{
		exclude_flag: true
		show_flag: true
		command: 'rank'
	}
	mut ds := Dataset{}
	mut rr := RankingResult{}
	ds = load_file('datasets/developer.tab')
	rr = rank_attributes(ds, opts)

	opts.bins = [3, 3]
	ds = load_file('datasets/iris.tab')
	rr = rank_attributes(ds, opts)
	// repeat for class missing purge
	rr = rank_attributes(load_file('datasets/class_missing_iris.tab', class_missing_purge_flag:true), opts)

	ds = load_file('datasets/anneal.tab')
	rr = rank_attributes(ds, opts)

	opts.exclude_flag = false
	rr = rank_attributes(ds, opts)
}

fn test_show_validate() ? {
	println('\n\ntest_show_validate prints out results for validation of bcw350train with bcw174validate')
	mut opts := Options{
		verbose_flag: false
		show_flag: true
		concurrency_flag: true
		command: 'validate'
	}
	mut result := ValidateResult{}
	mut ds := Dataset{}
	mut cl := Classifier{}

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174validate'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [4]
	opts.weighting_flag = false
	ds = load_file(opts.datafile_path)
	cl = make_classifier(mut ds, opts)
	result = validate(cl, opts)!
}

fn test_show_verify() ? {
	println('\n\ntest_show_verify prints out results for verification of bcw350train with bcw174test, and of soybean-large-train.tab with soybean-large-test.tab')
	mut opts := Options{
		verbose_flag: false
		show_flag: true
		concurrency_flag: true
		command: 'verify'
	}
	mut result := CrossVerifyResult{}
	mut ds := Dataset{}
	mut cl := Classifier{}

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [4]
	opts.weighting_flag = false
	// ds = load_file(opts.datafile_path)
	// cl = make_classifier(mut ds, opts)
	result = verify(opts)
	// println('result one in show_test: $result')
	opts.weighting_flag = true
	opts.expanded_flag = true
	// cl = make_classifier(mut ds, opts)
	result = verify(opts)

	// println('result two in show_test: $result')
}

fn test_show_multiple_classifiers_options() ? {
	println('\n\ntest_show_multiple_classifiers_options prints out a table showing the classifier settings for the chosen classifiers in a multiple classifier cross-validation or verification')
	mut opts := Options{
		verbose_flag: false
		show_flag: false
		datafile_path: 'datasets/UCI/leukemia38train'
		testfile_path: 'datasets/UCI/leukemia34test'
		settingsfile_path: 'tempfolder_show/leuk.opts'
	}
	mut result := CrossVerifyResult{}
	mut ds := Dataset{}
	mut cl := Classifier{}
}
