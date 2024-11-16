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
	println(rgb('test_show_analyze should print out dataset analyses for developer.tab and for iris.tab'))
	mut opts := Options{}
	mut ar := AnalyzeResult{}
	mut ds := Dataset{}

	ar = analyze_dataset(load_file('datasets/developer.tab'), opts)
	show_analyze(ar)

	ar = analyze_dataset(load_file('datasets/iris.tab'), opts)
	show_analyze(ar)

	// with purging of instances whose class values are missing
	ar = analyze_dataset(load_file('datasets/class_missing_developer.tab',
		class_missing_purge_flag: true
	), opts)
	show_analyze(ar)

	ar = analyze_dataset(load_file('datasets/class_missing_iris.tab', class_missing_purge_flag: true),
		opts)
	show_analyze(ar)
}

fn test_show_append() ? {
	println(rgb('test_show_append should print out a test.tab classifier, with 6 instances, followed by a test.tab classifier with 16 instances, and then a test.tab classifier with 26 instances and 3 history events. Then 3 classifiers based on soybean-large-train.tab.'))
	mut opts := Options{
		concurrency_flag: false
		weighting_flag:   true
	}

	mut cl := Classifier{}
	mut tcl := Classifier{}
	mut val_results := ValidateResult{}
	// create the classifier file and save it
	opts.command = 'make'
	opts.outputfile_path = 'tempfolder_show/classifierfile'
	mut ds := load_file('datasets/test.tab')
	cl = make_classifier(ds, opts)
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
	cl = make_classifier(ds, opts)
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
	println(rgb('test_show_classifier prints out classifiers for iris.tab and for developer.tab'))
	mut opts := Options{
		command:              'make'
		bins:                 [3, 10]
		number_of_attributes: [2]
	}
	mut ds := load_file('datasets/iris.tab')
	mut cl := make_classifier(ds, opts)
	ds = load_file('datasets/anneal.tab')
	opts.show_flag = true
	cl = make_classifier(ds, opts)

	// now with purging of instances with missing class values

	ds = load_file('datasets/class_missing_iris.tab', class_missing_purge_flag: true)
	opts.show_flag = true
	cl = make_classifier(ds, opts)

	// repeat with developer.tab, which is newer_orange format
	ds = load_file('datasets/developer.tab')
	opts.show_flag = true
	cl = make_classifier(ds, opts)
	ds = load_file('datasets/class_missing_developer.tab', class_missing_purge_flag: true)
	cl = make_classifier(ds, opts)
}

fn test_show_crossvalidation() ? {
	println(rgb('test_show_crossvalidation prints out cross-validation results for developer.tab, breast-cancer-wisconsin-disc.tab, and iris.tab'))
	mut cvr := CrossVerifyResult{}
	mut opts := Options{
		concurrency_flag: true
		command:          'cross'
		show_flag:        true
	}
	println('\n\ndeveloper.tab')
	cvr = cross_validate(load_file('datasets/developer.tab'), opts)
	println('\ndeveloper.tab with expanded results')
	cvr = cross_validate(load_file('datasets/developer.tab'), opts)

	println('\n\nbreast-cancer-wisconsin-disc.tab')
	opts.number_of_attributes = [4]
	cvr = cross_validate(load_file('datasets/breast-cancer-wisconsin-disc.tab'), opts)
	println('\nbreast-cancer-wisconsin-disc.tab with expanded results')
	opts.expanded_flag = true
	cvr = cross_validate(load_file('datasets/breast-cancer-wisconsin-disc.tab'), opts)

	println('\n\niris.tab')
	opts.bins = [3, 6]
	opts.number_of_attributes = [2]
	cvr = cross_validate(load_file('datasets/iris.tab'), opts)
	println('\niris.tab with expanded results')
	cvr = cross_validate(load_file('datasets/iris.tab'), opts)
	// now with purging for missing classes
	cvr = cross_validate(load_file('datasets/class_missing_iris.tab', class_missing_purge_flag: true),
		opts)
}

fn test_show_explore_cross() ? {
	println(rgb('\n\n test_show_explore_cross prints out explore results for cross-validation of developer.tab'))
	mut results := ExploreResult{}
	mut opts := Options{
		number_of_attributes: [2, 4]
		bins:                 [2, 5]
		weighting_flag:       true
		exclude_flag:         true
		concurrency_flag:     true
		uniform_bins:         true
		folds:                10
		repetitions:          50
		random_pick:          true
		datafile_path:        'datasets/developer.tab'
		command:              'explore'
	}
	mut ds := load_file(opts.datafile_path)
	opts.show_flag = true
	results = explore(ds, opts)

	// repeat for class missing purge
	opts.datafile_path = 'datasets/class_missing_developer.tab'
	ds = load_file(opts.datafile_path, class_missing_purge_flag: true)
	opts.show_flag = true
	results = explore(ds, opts)
}

fn test_show_explore_verify() ? {
	println(rgb('\n\ntest_show_explore_verify prints out explore results for verification of bcw350train with bcw174test'))
	mut results := ExploreResult{}
	mut opts := Options{
		number_of_attributes: [2, 6]
		weighting_flag:       false
		exclude_flag:         true
		concurrency_flag:     true
		command:              'explore'
		datafile_path:        'datasets/bcw350train'
		testfile_path:        'datasets/bcw174test'
	}
	mut ds := load_file(opts.datafile_path)
	opts.show_flag = true
	results = explore(ds, opts)
	opts.weighting_flag = true
	opts.number_of_attributes = [0]
	results = explore(ds, opts)
}

fn test_show_rank_attributes() {
	println(rgb('\n\ntest_show_rank_attributes prints out attribute rankings for developer.tab, iris.tab, and anneal.tab (without and with missing values)'))
	mut opts := Options{
		exclude_flag: true
		command:      'rank'
	}
	mut ds := Dataset{}
	mut rr := RankingResult{}
	ds = load_file('datasets/developer.tab')
	opts.show_flag = true
	rr = rank_attributes(ds, opts)

	opts.bins = [3, 3]
	ds = load_file('datasets/iris.tab')
	rr = rank_attributes(ds, opts)
	// repeat for class missing purge
	rr = rank_attributes(load_file('datasets/class_missing_iris.tab', class_missing_purge_flag: true),
		opts)

	ds = load_file('datasets/anneal.tab')
	rr = rank_attributes(ds, opts)

	opts.exclude_flag = false
	rr = rank_attributes(ds, opts)
}

fn test_show_validate() ? {
	println(rgb('\n\ntest_show_validate prints out results for validation of bcw350train with bcw174validate'))
	mut opts := Options{
		concurrency_flag: true
		command:          'validate'
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
	opts.show_flag = true
	cl = make_classifier(ds, opts)
	result = validate(cl, opts)!
}

fn test_show_verify() ? {
	println(rgb('\n\ntest_show_verify prints out results for verification of bcw350train with bcw174test, and of soybean-large-train.tab with soybean-large-test.tab'))
	mut opts := Options{
		concurrency_flag: true
		command:          'verify'
	}
	mut result := CrossVerifyResult{}
	mut ds := Dataset{}
	mut cl := Classifier{}

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [4]
	opts.weighting_flag = false
	ds = load_file(opts.datafile_path)
	opts.show_flag = true
	result = verify(opts)
	opts.weighting_flag = true
	result = verify(opts)
}

fn test_show_multiple_classifier_settings_options() ? {
	println(rgb('\n\ntest_show_multiple_classifier_settings_options prints out a table showing the classifier settings for the chosen classifiers in a multiple classifier cross-validation or verification'))
	mut opts := Options{
		datafile_path:     'datasets/UCI/leukemia38train'
		testfile_path:     'datasets/UCI/leukemia34test'
		settingsfile_path: 'tempfolder_show/leuk.opts'
	}
	mut result := CrossVerifyResult{}
	mut ds := Dataset{}
	mut cl := Classifier{}
}
