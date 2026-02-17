// verify_test.v
// this test file uses only two-class datasets
module vhammll

import os

fn testsuite_begin() ! {
	if os.is_dir('tempfolders/tempfolder_balance_prevalences') {
		os.rmdir_all('tempfolders/tempfolder_balance_prevalences')!
	}
	os.mkdir_all('tempfolders/tempfolder_balance_prevalences')!
}

// fn testsuite_end() ! {
// 	os.rmdir_all('tempfolders/tempfolder_balance_prevalences')!
// }

// fn test_evaluate_class_prevalence_imbalance() {
// 	mut opts := Options{
// 		balance_prevalences_threshold: 0.25
// 	}
// 	mut ds := load_file('datasets/developer.tab', opts.LoadOptions)
// 	assert evaluate_class_prevalence_imbalance(ds, opts)
// 	opts.balance_prevalences_threshold = 0.25
// 	assert evaluate_class_prevalence_imbalance(ds, opts)
// 	opts.balance_prevalences_threshold = 0.2
// 	assert !evaluate_class_prevalence_imbalance(ds, opts)
// 	opts.balance_prevalences_threshold = 0.0
// 	assert !evaluate_class_prevalence_imbalance(ds, opts)
// 	opts.balance_prevalences_threshold = 1.0
// 	assert evaluate_class_prevalence_imbalance(ds, opts)
// 	ds = load_file('datasets/iris.tab', opts.LoadOptions)
// 	opts.balance_prevalences_threshold = Options{}.balance_prevalences_threshold
// 	assert !evaluate_class_prevalence_imbalance(ds, opts)
// 	opts.balance_prevalences_threshold = 0.2
// 	assert !evaluate_class_prevalence_imbalance(ds, opts)
// 	opts.balance_prevalences_threshold = 0.0
// 	assert !evaluate_class_prevalence_imbalance(ds, opts)
// 	opts.balance_prevalences_threshold = 1.0
// 	assert evaluate_class_prevalence_imbalance(ds, opts)
// 	ds = load_file('datasets/UCI/ionosphere.arff', opts.LoadOptions)
// 	opts.balance_prevalences_threshold = 0.9
// 	assert evaluate_class_prevalence_imbalance(ds, opts)
// 	opts.balance_prevalences_threshold = 0.5
// 	assert !evaluate_class_prevalence_imbalance(ds, opts)
// 	opts.balance_prevalences_threshold = 0.0
// 	assert !evaluate_class_prevalence_imbalance(ds, opts)
// 	opts.balance_prevalences_threshold = 1.0
// 	assert evaluate_class_prevalence_imbalance(ds, opts)
// 	opts.balance_prevalences_threshold = 0.57
// 	assert evaluate_class_prevalence_imbalance(ds, opts)
// }

// fn test_balance_prevalences() {
// 	mut opts := Options{}
// 	mut ds := load_file('datasets/developer.tab')
// 	mut threshold := 0.8
// 	mut counts := ds.class_counts.clone()
// 	assert counts == {
// 		'm': 8
// 		'f': 3
// 		'X': 2
// 	}
// 	// dump(ds)
// 	mut ds_balanced := balance_prevalences(mut ds, threshold)
// 	assert ds.pre_balance_prevalences_class_counts == counts
// 	assert ds.class_counts == {
// 		'm': 8
// 		'f': 9
// 		'X': 10
// 	}
// 	threshold = 0.7
// 	ds = load_file('datasets/leukemia38train.tab')
// 	counts = ds.class_counts.clone()
// 	assert counts == {
// 		'ALL': 27
// 		'AML': 11
// 	}
// 	ds_balanced = balance_prevalences(mut ds, threshold)
// 	assert ds.pre_balance_prevalences_class_counts == counts
// 	assert ds_balanced.class_counts == {
// 		'ALL': 27
// 		'AML': 22
// 	}
// 	threshold = 0.9
// 	ds = load_file('datasets/leukemia38train.tab')
// 	ds_balanced = balance_prevalences(mut ds, threshold)
// 	assert ds.pre_balance_prevalences_class_counts == counts
// 	assert ds_balanced.class_counts == {
// 		'ALL': 54
// 		'AML': 55
// 	}
// 	ds = load_file('datasets/UCI/diabetes.arff')
// 	counts = ds.class_counts.clone()
// 	assert counts == {
// 		'tested_positive': 268
// 		'tested_negative': 500
// 	}
// 	ds_balanced = balance_prevalences(mut ds, threshold)
// 	assert ds.pre_balance_prevalences_class_counts == counts
// 	assert ds_balanced.class_counts == {
// 		'tested_positive': 536
// 		'tested_negative': 500
// 	}
// }

// fn test_verify() ? {
// 	mut opts := Options{
// 		balance_prevalences_flag: true
// 		// expanded_flag: true
// 	}

// 	mut result := CrossVerifyResult{}
// 	mut cl := Classifier{}
// 	mut saved_cl := Classifier{}

// 	// test verify with a non-saved classifier
// 	// opts.command = 'make'
// 	opts.datafile_path = 'datasets/test.tab'
// 	opts.testfile_path = 'datasets/test_verify.tab'
// 	opts.classifierfile_path = ''
// 	opts.bins = [2, 3]
// 	opts.number_of_attributes = [2]
// 	assert verify(opts).correct_count == 10
// 	// dump(verify(opts))
// 	println(r_b('Done with test.tab'))

// 	// now with a binary classifier with continuous values

// 	opts.datafile_path = 'datasets/leukemia38train.tab'
// 	opts.testfile_path = 'datasets/leukemia34test.tab'
// 	opts.number_of_attributes = [1]
// 	opts.bins = [5, 5]
// 	// opts.purge_flag = true
// 	opts.weight_ranking_flag = true
// 	result = verify(opts)
// 	assert result.confusion_matrix_map == {
// 		'ALL': {
// 			'ALL': 17.0
// 			'AML': 3.0
// 		}
// 		'AML': {
// 			'ALL': 0.0
// 			'AML': 14.0
// 		}
// 	}
// 	println(r_b('Done with leukemia38train.tab & leukemia34test.tab'))

// 	// now with a saved classifier
// 	opts.outputfile_path = 'tempfolders/tempfolder_balance_prevalences/classifierfile'
// 	cl = make_classifier(opts)
// 	opts.classifierfile_path = opts.outputfile_path
// 	opts.outputfile_path = ''
// 	assert result.BinaryMetrics == verify(opts).BinaryMetrics
// 	println(r_b('Done with leukemia38train.tab & leukemia34test.tab using saved classifier'))
// }

// fn test_cross_validate() ? {
// 	mut opts := Options{
// 		command:                  'cross'
// 		balance_prevalences_flag: true
// 		// expanded_flag:            true
// 	}
// 	mut result := CrossVerifyResult{}

// 	opts.datafile_path = 'datasets/UCI/ionosphere.arff'
// 	opts.number_of_attributes = [7]
// 	opts.bins = [8, 8]
// 	opts.folds = 10
// 	opts.repetitions = 10
// 	opts.weight_ranking_flag = true
// 	opts.balance_prevalences_threshold = 0.9

// 	result = cross_validate(opts)
// 	assert result.total_count == 1305
// 	assert result.correct_counts == [675, 630]
// 	println(r_b('\nDone with datasets/UCI/ionosphere.arff'))

// 	opts.datafile_path = 'datasets/UCI/diabetes.arff'
// 	opts.balance_prevalences_threshold = 0.9
// 	opts.number_of_attributes = [8]
// 	opts.bins = [9, 9]
// 	opts.folds = 0
// 	result = cross_validate(opts)
// 	assert result.total_count == 1036
// 	assert result.correct_counts == [530, 370]
// 	println(r_b('\nDone with datasets/UCI/diabetes.arff'))

// 	opts.datafile_path = 'datasets/iris.tab'
// 	opts.number_of_attributes = [2]
// 	opts.bins = [3, 3]
// 	opts.folds = 0
// 	result = cross_validate(opts)
// 	assert result.class_counts == {
// 		'Iris-setosa':     50
// 		'Iris-versicolor': 50
// 		'Iris-virginica':  50
// 	}
// 	assert result.total_count == 150
// 	assert result.correct_counts == [50, 47, 50]

// 	println(r_b('\nDone with iris.tab'))

// 	opts.datafile_path = 'datasets/breast-cancer-wisconsin-disc.tab'
// 	opts.number_of_attributes = [8]
// 	result = cross_validate(opts)
// 	assert result.class_counts == {
// 		'benign':    458
// 		'malignant': 482
// 	}
// 	assert result.total_count == 940
// 	assert result.correct_counts == [445, 482]
// 	println(r_b('\nDone with breast-cancer-wisconsin-disc.tab'))
// }

// fn test_multiple_verify() {
// 	mut opts := Options{
// 		concurrency_flag:     false
// 		break_on_all_flag:    false
// 		command:              'verify'
// 		verbose_flag:         false
// 		expanded_flag:        true
// 		show_attributes_flag: true
// 	}
// 	mut result := CrossVerifyResult{}
// 	opts.datafile_path = 'datasets/leukemia38train.tab'
// 	opts.testfile_path = 'datasets/leukemia34test.tab'
// 	opts.settingsfile_path = 'tempfolders/tempfolder_balance_prevalences/leuk.opts'
// 	opts.append_settings_flag = true
// 	opts.number_of_attributes = [1]
// 	opts.bins = [5, 5]
// 	opts.weight_ranking_flag = true
// 	opts.purge_flag = true

// 	// check that the non-multiple verify works OK, and that the
// 	// settings file is getting appended
// 	// opts.weight_ranking_flag = true
// 	result96 := verify(opts)
// 	assert result96.correct_counts == [17, 14]
// 	opts.weight_ranking_flag = true
// 	opts.purge_flag = false
// 	opts.balance_prevalences_flag = false
// 	result131 := verify(opts)
// 	assert result131.correct_counts == [17, 13]
// 	opts.number_of_attributes = [3]
// 	opts.bins = [4, 4]
// 	opts.weight_ranking_flag = false
// 	opts.purge_flag = true
// 	opts.weighting_flag = true
// 	result92 := verify(opts)
// 	assert result92.correct_counts == [20, 11]
// 	opts.number_of_attributes = [7]
// 	opts.bins = [9, 9]
// 	opts.weight_ranking_flag = true
// 	opts.weighting_flag = true
// 	opts.purge_flag = false
// 	result140 := verify(opts)
// 	assert result140.correct_counts == [20, 11]
// 	// verify that the settings file was correctly saved
// 	display_file(opts.settingsfile_path, opts)
// 	// test verify with multiple_classify_options_file_path
// 	opts.multiple_flag = true
// 	opts.multiple_classify_options_file_path = opts.settingsfile_path
// 	opts.append_settings_flag = false
// 	// with classifier 0
// 	opts.classifiers = [2]
// 	result2 := verify(opts)
// 	assert result2.confusion_matrix_map == result92.confusion_matrix_map
// 	opts.classifiers = [0, 2]
// 	opts.total_nn_counts_flag = true
// 	// opts.traverse_all_flags = true
// 	result96_92 := verify(opts)
// 	assert result96_92.correct_counts == [20, 12]
// 	opts.classifiers = [1, 2, 3]
// 	result140_131_92 := verify(opts)
// 	assert result140_131_92.correct_counts == [18, 12]
// 	opts.classifiers = [0, 2, 3]
// 	opts.total_nn_counts_flag = false
// 	result140_96_92 := verify(opts)
// 	assert result140_96_92.correct_counts == [20, 12]

// 	// now, do similarly with balance_prevalences_flag set
// 	opts.multiple_flag = false
// 	opts.multiple_classify_options_file_path = ''
// 	opts.append_settings_flag = true
// 	opts.balance_prevalences_flag = true
// 	opts.balance_prevalences_threshold = 0.9
// 	opts.number_of_attributes = [1]
// 	opts.bins = [1, 5]
// 	opts.weight_ranking_flag = false
// 	opts.weighting_flag = false

// 	assert verify(opts).correct_counts == [18, 13]

// 	opts.bins = [5, 5]
// 	opts.weight_ranking_flag = true
// 	assert verify(opts).correct_counts == [17, 14]

// 	opts.bins = [4, 4]
// 	opts.number_of_attributes = [2]
// 	opts.weight_ranking_flag = false
// 	assert verify(opts).correct_counts == [20, 6]

// 	// now, multiple classifiers
// 	opts.classifiers = []
// 	display_file(opts.settingsfile_path, opts)

// 	opts.multiple_flag = true
// 	opts.multiple_classify_options_file_path = opts.settingsfile_path
// 	opts.append_settings_flag = false

// 	opts.classifiers = [5]
// 	verify(opts)
// 	opts.classifiers = [4, 5]
// 	verify(opts)
// 	opts.classifiers = [4, 5, 6]
// 	verify(opts)
// 	opts.classifiers = [0, 4, 5, 6]
// 	verify(opts)
// }

fn test_multiple_verify_with_bcw() {
	datafile := 'datasets/bcw350train'
	testfile := 'datasets/bcw174test'

	explore(opts('-af -b 1,6 -t ${testfile} ${datafile}'))
}
