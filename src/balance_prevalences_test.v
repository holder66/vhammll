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
	// balance_prevalences_threshold has no CLI flag, so we use manual Options
	mut o := Options{
		balance_prevalences_threshold: 0.25
	}
	mut ds := load_file('datasets/developer.tab', o.LoadOptions)
	assert evaluate_class_prevalence_imbalance(ds, o)
	o.balance_prevalences_threshold = 0.25
	assert evaluate_class_prevalence_imbalance(ds, o)
	o.balance_prevalences_threshold = 0.2
	assert !evaluate_class_prevalence_imbalance(ds, o)
	o.balance_prevalences_threshold = 0.0
	assert !evaluate_class_prevalence_imbalance(ds, o)
	o.balance_prevalences_threshold = 1.0
	assert evaluate_class_prevalence_imbalance(ds, o)
	ds = load_file('datasets/iris.tab', o.LoadOptions)
	o.balance_prevalences_threshold = Options{}.balance_prevalences_threshold
	assert !evaluate_class_prevalence_imbalance(ds, o)
	o.balance_prevalences_threshold = 0.2
	assert !evaluate_class_prevalence_imbalance(ds, o)
	o.balance_prevalences_threshold = 0.0
	assert !evaluate_class_prevalence_imbalance(ds, o)
	o.balance_prevalences_threshold = 1.0
	assert evaluate_class_prevalence_imbalance(ds, o)
	ds = load_file('datasets/UCI/ionosphere.arff', o.LoadOptions)
	o.balance_prevalences_threshold = 0.9
	assert evaluate_class_prevalence_imbalance(ds, o)
	o.balance_prevalences_threshold = 0.5
	assert !evaluate_class_prevalence_imbalance(ds, o)
	o.balance_prevalences_threshold = 0.0
	assert !evaluate_class_prevalence_imbalance(ds, o)
	o.balance_prevalences_threshold = 1.0
	assert evaluate_class_prevalence_imbalance(ds, o)
	o.balance_prevalences_threshold = 0.57
	assert evaluate_class_prevalence_imbalance(ds, o)
}

fn test_balance_prevalences() {
	mut ds := load_file('datasets/developer.tab')
	mut threshold := 0.8
	mut counts := ds.class_counts.clone()
	assert counts == {
		'm': 8
		'f': 3
		'X': 2
	}
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
	mut result := CrossVerifyResult{}

	// test verify with a non-saved classifier
	assert verify(opts('-bp -a 2 -b 2,3 -t datasets/test_verify.tab datasets/test.tab',
		cmd: 'verify'
	)).correct_count == 10
	println(r_b('Done with test.tab'))

	// now with a binary classifier with continuous values
	result = verify(opts('-bp -wr -a 1 -b 5,5 -t datasets/leukemia34test.tab datasets/leukemia38train.tab',
		cmd: 'verify'
	))
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
	cl := make_classifier(opts('-bp -wr -a 1 -b 5,5 -o tempfolders/tempfolder_balance_prevalences/classifierfile datasets/leukemia38train.tab',
		cmd: 'make'
	))
	assert result.BinaryMetrics == verify(opts('-bp -wr -a 1 -b 5,5 -k tempfolders/tempfolder_balance_prevalences/classifierfile -t datasets/leukemia34test.tab datasets/leukemia38train.tab',
		cmd: 'verify'
	)).BinaryMetrics
	println(r_b('Done with leukemia38train.tab & leukemia34test.tab using saved classifier'))
}

fn test_cross_validate() ? {
	mut result := CrossVerifyResult{}

	// balance_prevalences_threshold has no CLI flag, so we combine opts() with manual override
	mut o := opts('-bp -wr -a 7 -b 8,8 -f 10 -r 10 datasets/UCI/ionosphere.arff', cmd: 'cross')
	o.balance_prevalences_threshold = 0.9
	result = cross_validate(o)
	assert result.total_count == 1305
	assert result.correct_counts == [675, 630]
	println(r_b('\nDone with datasets/UCI/ionosphere.arff'))

	o = opts('-bp -wr -a 8 -b 9,9 datasets/UCI/diabetes.arff', cmd: 'cross')
	o.balance_prevalences_threshold = 0.9
	result = cross_validate(o)
	assert result.total_count == 1036
	assert result.correct_counts == [530, 370]
	println(r_b('\nDone with datasets/UCI/diabetes.arff'))

	result = cross_validate(opts('-bp -a 2 -b 3,3 datasets/iris.tab', cmd: 'cross'))
	assert result.class_counts == {
		'Iris-setosa':     50
		'Iris-versicolor': 50
		'Iris-virginica':  50
	}
	assert result.total_count == 150
	assert result.correct_counts == [50, 47, 50]
	println(r_b('\nDone with iris.tab'))

	result = cross_validate(opts('-bp -a 8 -b 3,3 datasets/breast-cancer-wisconsin-disc.tab',
		cmd: 'cross'
	))
	assert result.class_counts == {
		'benign':    458
		'malignant': 482
	}
	assert result.total_count == 940
	assert result.correct_counts == [445, 482]
	println(r_b('\nDone with breast-cancer-wisconsin-disc.tab'))
}

fn test_multiple_verify() {
	datafile := 'datasets/leukemia38train.tab'
	testfile := 'datasets/leukemia34test.tab'
	settingsfile := 'tempfolders/tempfolder_balance_prevalences/leuk.opts'
	mut result := CrossVerifyResult{}

	// check that the non-multiple verify works OK, and that the
	// settings file is getting appended
	result96 := verify(opts('-e -ea -p -wr -a 1 -b 5,5 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result96.correct_counts == [17, 14]
	result131 := verify(opts('-e -ea -wr -a 1 -b 5,5 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result131.correct_counts == [17, 13]
	result92 := verify(opts('-e -ea -w -p -a 3 -b 4,4 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result92.correct_counts == [20, 11]
	result140 := verify(opts('-e -ea -w -wr -a 7 -b 9,9 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result140.correct_counts == [20, 11]
	// verify that the settings file was correctly saved
	display_file(settingsfile, opts('-e -ea ${datafile}'))
	// test verify with multiple_classify_options_file_path
	// with classifier 2
	result2 := verify(opts('-e -ea -m ${settingsfile} -m# 2 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result2.confusion_matrix_map == result92.confusion_matrix_map
	result96_92 := verify(opts('-e -ea -mt -m ${settingsfile} -m# 0,2 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result96_92.correct_counts == [20, 12]
	result140_131_92 := verify(opts('-e -ea -mt -m ${settingsfile} -m# 1,2,3 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result140_131_92.correct_counts == [18, 12]
	result140_96_92 := verify(opts('-e -ea -m ${settingsfile} -m# 0,2,3 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result140_96_92.correct_counts == [20, 12]

	// now, do similarly with balance_prevalences_flag set
	// balance_prevalences_threshold has no CLI flag, so combine opts() with manual override
	mut o := opts('-bp -a 1 -b 1,5 -ms ${settingsfile} -t ${testfile} ${datafile}', cmd: 'verify')
	o.balance_prevalences_threshold = 0.9
	assert verify(o).correct_counts == [18, 13]

	o = opts('-bp -wr -a 1 -b 5,5 -ms ${settingsfile} -t ${testfile} ${datafile}', cmd: 'verify')
	o.balance_prevalences_threshold = 0.9
	assert verify(o).correct_counts == [17, 14]

	o = opts('-bp -a 2 -b 4,4 -ms ${settingsfile} -t ${testfile} ${datafile}', cmd: 'verify')
	o.balance_prevalences_threshold = 0.9
	assert verify(o).correct_counts == [20, 6]

	// now, multiple classifiers
	display_file(settingsfile, opts('-bp ${datafile}'))

	verify(opts('-bp -m ${settingsfile} -m# 5 -t ${testfile} ${datafile}', cmd: 'verify'))
	verify(opts('-bp -m ${settingsfile} -m# 4,5 -t ${testfile} ${datafile}', cmd: 'verify'))
	verify(opts('-bp -m ${settingsfile} -m# 4,5,6 -t ${testfile} ${datafile}', cmd: 'verify'))
	verify(opts('-bp -m ${settingsfile} -m# 0,4,5,6 -t ${testfile} ${datafile}', cmd: 'verify'))
}

fn test_multiple_verify_with_bcw() {
	datafile := 'datasets/bcw350train'
	testfile := 'datasets/bcw174test'

	explore(opts('-af -b 1,6 -t ${testfile} ${datafile}'))
}
