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

fn testsuite_end() ! {
	os.rmdir_all('tempfolders/tempfolder_balance_prevalences')!
}

fn test_evaluate_class_prevalence_imbalance() {
	mut opts := Options{
		balance_prevalences_threshold: 0.25
	}
	mut ds := load_file('datasets/developer.tab', opts.LoadOptions)
	assert evaluate_class_prevalence_imbalance(ds, opts)
	opts.balance_prevalences_threshold = 0.25
	assert evaluate_class_prevalence_imbalance(ds, opts)
	opts.balance_prevalences_threshold = 0.2
	assert !evaluate_class_prevalence_imbalance(ds, opts)
	opts.balance_prevalences_threshold = 0.0
	assert !evaluate_class_prevalence_imbalance(ds, opts)
	opts.balance_prevalences_threshold = 1.0
	assert evaluate_class_prevalence_imbalance(ds, opts)
	ds = load_file('datasets/iris.tab', opts.LoadOptions)
	opts.balance_prevalences_threshold = Options{}.balance_prevalences_threshold
	assert !evaluate_class_prevalence_imbalance(ds, opts)
	opts.balance_prevalences_threshold = 0.2
	assert !evaluate_class_prevalence_imbalance(ds, opts)
	opts.balance_prevalences_threshold = 0.0
	assert !evaluate_class_prevalence_imbalance(ds, opts)
	opts.balance_prevalences_threshold = 1.0
	assert evaluate_class_prevalence_imbalance(ds, opts)
	ds = load_file('datasets/UCI/ionosphere.arff', opts.LoadOptions)
	opts.balance_prevalences_threshold = 0.9
	assert evaluate_class_prevalence_imbalance(ds, opts)
	opts.balance_prevalences_threshold = 0.5
	assert !evaluate_class_prevalence_imbalance(ds, opts)
	opts.balance_prevalences_threshold = 0.0
	assert !evaluate_class_prevalence_imbalance(ds, opts)
	opts.balance_prevalences_threshold = 1.0
	assert evaluate_class_prevalence_imbalance(ds, opts)
	opts.balance_prevalences_threshold = 0.57
	assert evaluate_class_prevalence_imbalance(ds, opts)
}

fn test_balance_prevalences() {
	mut opts := Options{}
	mut ds := load_file('datasets/developer.tab')
	mut threshold := 0.8
	mut counts := ds.class_counts.clone()
	assert counts == {
		'm': 8
		'f': 3
		'X': 2
	}
	// dump(ds)
	mut ds_balanced := balance_prevalences(mut ds, threshold)
	assert ds.pre_balance_prevalences_class_counts == counts
	assert ds.class_counts == {
		'm': 8
		'f': 9
		'X': 10
	}
	threshold = 0.7
	ds = load_file('datasets/leukemia38train.tab')
	counts = ds.class_counts.clone()
	assert counts == {
		'ALL': 27
		'AML': 11
	}
	ds_balanced = balance_prevalences(mut ds, threshold)
	assert ds.pre_balance_prevalences_class_counts == counts
	assert ds_balanced.class_counts == {
		'ALL': 27
		'AML': 22
	}
	threshold = 0.9
	ds = load_file('datasets/leukemia38train.tab')
	ds_balanced = balance_prevalences(mut ds, threshold)
	assert ds.pre_balance_prevalences_class_counts == counts
	assert ds_balanced.class_counts == {
		'ALL': 54
		'AML': 55
	}
	ds = load_file('datasets/UCI/diabetes.arff')
	counts = ds.class_counts.clone()
	assert counts == {
		'tested_positive': 268
		'tested_negative': 500
	}
	ds_balanced = balance_prevalences(mut ds, threshold)
	assert ds.pre_balance_prevalences_class_counts == counts
	assert ds_balanced.class_counts == {
		'tested_positive': 536
		'tested_negative': 500
	}
}

fn test_verify() ? {
	mut opts := Options{
		concurrency_flag: false
		// expanded_flag: true
	}

	mut result := CrossVerifyResult{}
	mut cl := Classifier{}
	mut saved_cl := Classifier{}
	opts.balance_prevalences_flag = true

	// test verify with a non-saved classifier
	opts.command = 'make'
	opts.datafile_path = 'datasets/test.tab'
	opts.testfile_path = 'datasets/test_verify.tab'
	opts.classifierfile_path = ''
	opts.bins = [2, 3]
	opts.number_of_attributes = [2]
	assert verify(opts).correct_count == 10
	// dump(verify(opts))
	println(r_b('Done with test.tab'))

	// now with a binary classifier with continuous values

	opts.datafile_path = 'datasets/leukemia38train.tab'
	opts.testfile_path = 'datasets/leukemia34test.tab'
	opts.number_of_attributes = [1]
	opts.bins = [5, 5]
	// opts.purge_flag = true
	opts.weight_ranking_flag = true
	result = verify(opts)
	assert result.confusion_matrix_map == {
		'ALL': {
			'ALL': 17.0
			'AML': 3.0
		}
		'AML': {
			'ALL': 0.0
			'AML': 14.0
		}
	}
	println(r_b('Done with leukemia38train.tab & leukemia34test.tab'))

	// now with a saved classifier
	opts.outputfile_path = 'tempfolders/tempfolder_balance_prevalences/classifierfile'
	cl = make_classifier(opts)
	opts.classifierfile_path = opts.outputfile_path
	opts.outputfile_path = ''
	assert result.BinaryMetrics == verify(opts).BinaryMetrics
	println(r_b('Done with leukemia38train.tab & leukemia34test.tab using saved classifier'))
}

fn test_cross_validate() ? {
	mut opts := Options{
		command:                  'cross'
		exclude_flag:             false
		verbose_flag:             false
		balance_prevalences_flag: true
		// expanded_flag:            true
	}
	mut result := CrossVerifyResult{}

	opts.datafile_path = 'datasets/UCI/ionosphere.arff'
	opts.number_of_attributes = [22]
	opts.bins = [2, 15]
	opts.folds = 10
	opts.repetitions = 5
	opts.random_pick = false
	opts.concurrency_flag = false
	opts.balance_prevalences_threshold = 0.85

	result = cross_validate(opts)
	assert result.class_counts == {
		'g': 225
		'b': 252
	}
	assert result.total_count == 477
	assert result.correct_counts == [214, 252]
	println(r_b('\nDone with datasets/UCI/ionosphere.arff'))

	opts.datafile_path = 'datasets/UCI/diabetes.arff'
	opts.balance_prevalences_threshold = 0.9
	opts.number_of_attributes = [3]
	opts.bins = [1, 3]
	opts.folds = 0
	result = cross_validate(opts)
	assert result.total_count == 1036
	assert result.correct_counts == [394, 348]
	println(r_b('\nDone with datasets/UCI/diabetes.arff'))

	opts.datafile_path = 'datasets/iris.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 0
	result = cross_validate(opts)
	assert result.class_counts == {
		'Iris-setosa':     50
		'Iris-versicolor': 50
		'Iris-virginica':  50
	}
	assert result.total_count == 150
	assert result.correct_counts == [50, 47, 50]

	println(r_b('\nDone with iris.tab'))

	opts.datafile_path = 'datasets/breast-cancer-wisconsin-disc.tab'
	opts.number_of_attributes = [9]
	result = cross_validate(opts)
	assert result.class_counts == {
		'benign':    458
		'malignant': 482
	}
	assert result.total_count == 940
	assert result.correct_counts == [445, 482]
	println(r_b('\nDone with breast-cancer-wisconsin-disc.tab'))
}
