// totalnn_test.v

// test_multiple_classifier_settings using the totalnn algorithm

module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_totalnn') {
		os.rmdir_all('tempfolders/tempfolder_totalnn')!
	}
	os.mkdir_all('tempfolders/tempfolder_totalnn')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_totalnn')!
}

fn test_multiple_classifier_crossvalidate_totalnn_2_classes() {
	datafile := 'datasets/2_class_developer.tab'
	settingsfile := 'tempfolders/tempfolder_totalnn/2_class.opts'
	mut result := CrossVerifyResult{}

	er := explore(opts('-e -wr -ms ${settingsfile} ${datafile}', cmd: 'explore'))
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	assert r.len == 7
	display_file(settingsfile, opts('-e ${datafile}'))
	// repeat display with show attributes
	display_file(settingsfile, opts('-e -ea ${datafile}'))

	// show optimals without and with purging
	optimals(settingsfile, opts('${datafile}'))
	optimals(settingsfile, opts('-p ${datafile}'))

	result = cross_validate(opts('-m ${settingsfile} -m# 0,2 ${datafile}', cmd: 'cross'))
	// assert result.correct_counts == [8, 3]
	result = cross_validate(opts('-mt -m ${settingsfile} -m# 1 ${datafile}', cmd: 'cross'))
	// assert result.correct_counts == [8, 3], 'for classifier #1'
	assert cross_validate(opts('-mt -m ${settingsfile} -m# 2 ${datafile}', cmd: 'cross')).correct_counts == [
		9,
		3,
	], 'for classifier #2'
	result = cross_validate(opts('-s -mt -m ${settingsfile} -m# 2,3 ${datafile}', cmd: 'cross'))
	assert result.correct_counts == [9, 3], 'for classifiers 2 & 3'
}

fn test_multiple_classifier_crossvalidate_totalnn_multiple_classes() {
	datafile := 'datasets/developer.tab'
	settingsfile := 'tempfolders/tempfolder_totalnn/developer.opts'
	mut result := CrossVerifyResult{}

	er := explore(opts('-e -wr -ms ${settingsfile} ${datafile}', cmd: 'explore'))
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	assert r.len == 9
	display_file(settingsfile, opts('-e ${datafile}'))
	// repeat display with show attributes
	display_file(settingsfile, opts('-e -ea ${datafile}'))

	// show optimals without and with purging
	optimals(settingsfile, opts('${datafile}'))
	optimals(settingsfile, opts('-p ${datafile}'))

	result = cross_validate(opts('-m ${settingsfile} -m# 0,2 ${datafile}', cmd: 'cross'))
	assert result.correct_counts == [8, 3, 2]
	result = cross_validate(opts('-mt -m ${settingsfile} -m# 0,2 ${datafile}', cmd: 'cross'))
	assert result.correct_counts == [8, 3, 2]
	assert cross_validate(opts('-mt -m ${settingsfile} -m# 2 ${datafile}', cmd: 'cross')).correct_counts == [
		8,
		3,
		2,
	], 'for classifier #2'
	result = cross_validate(opts('-s -mt -m ${settingsfile} -m# 2,3 ${datafile}', cmd: 'cross'))
	// assert result.correct_counts == [8, 0, 0], 'for classifiers 2 & 3'
}

fn test_multiple_classifier_verify_totalnn_continuous_attributes() ? {
	datafile := 'datasets/leukemia38train.tab'
	testfile := 'datasets/leukemia34test.tab'
	settingsfile := 'tempfolders/tempfolder_totalnn/leuk.opts'
	mut result := CrossVerifyResult{}

	result0 := verify(opts('-e -p -wr -a 1 -b 5,5 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result0.correct_counts == [17, 14], 'verify with 1 attribute and binning [5,5]'
	result1 := verify(opts('-e -a 6 -b 1,10 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result1.correct_counts == [20, 9], 'verify with 6 attributes and binning [1,10]'
	// verify that the settings file was saved, and is the right length
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	assert r.len == 2
	display_file(settingsfile, opts('-ea ${datafile}'))
	// with classifier 0 only
	result = verify(opts('-s -e -m ${settingsfile} -m# 0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.confusion_matrix_map == result0.confusion_matrix_map
	// with classifier 1
	result = verify(opts('-s -e -m ${settingsfile} -m# 1 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	// repeat with total_nn flag set
	result = verify(opts('-s -e -mt -m ${settingsfile} -m# 1 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	// with both classifiers, traverse all flags to find best
	result = verify(opts('-af -m ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	// best balanced accuracy with [18, 14] 95.00  ma false mc true mt false []
	result = verify(opts('-e -mc -m ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	dump(result.correct_counts)
	// assert result.correct_counts == [18, 14], 'with both classifiers mc'
	// this deteriorates when add totalnn-counts
	result = verify(opts('-e -mc -mt -m ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	dump(result.correct_counts)
	assert result.correct_counts == [18, 13], 'with both classifiers mc mt'
}

fn test_multiple_classifier_verify_totalnn_discrete_attributes() ? {
	datafile := 'datasets/bcw350train'
	testfile := 'datasets/bcw174test'
	settingsfile := 'tempfolders/tempfolder_totalnn/bcw.opts'
	mut result := CrossVerifyResult{}

	result0 := verify(opts('-e -ma -a 3 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result0.correct_counts == [133, 37], 'verify with 3 attributes'
	result1 := verify(opts('-e -ma -a 4 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result1.correct_counts == [135, 36], 'verify with 4 attributes'
	// verify that the settings file was saved, and is the right length
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	assert r.len == 2
	display_file(settingsfile, opts('-ea ${datafile}'))
	// with classifier 0 only
	result = verify(opts('-s -e -ma -m ${settingsfile} -m# 0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.confusion_matrix_map == result0.confusion_matrix_map
	// with classifier 1
	result = verify(opts('-s -e -ma -m ${settingsfile} -m# 1 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	// with both classifiers
	result = verify(opts('-s -e -ma -m ${settingsfile} -m# 1,0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.correct_counts == [135, 37], 'with both classifiers'
	// with totalnn flag set, performance deteriorates
	result = verify(opts('-s -e -ma -mt -m ${settingsfile} -m# 1,0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.correct_counts == [133, 36]
	// without break_on_all
	result = verify(opts('-s -e -mt -m ${settingsfile} -m# 1,0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.correct_counts == [133, 37]
}

fn test_multiple_classifier_verify_totalnn_multiple_classes() ? {
	datafile := 'datasets/develop_train.tab'
	testfile := 'datasets/develop_test.tab'
	settingsfile := 'tempfolders/tempfolder_totalnn/develop.opts'
	mut result := CrossVerifyResult{}

	result0 := verify(opts('-e -s -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result0.correct_counts == [1, 0, 1], 'verify with 13 attributes'
	result1 := verify(opts('-e -s -w -a 4 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result1.correct_counts == [0, 0, 1], 'verify with 4 attributes'
	// verify that the settings file was saved, and is the right length
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	assert r.len == 2
	display_file(settingsfile, opts('-ea ${datafile}'))
	// with classifier 0 only
	result = verify(opts('-s -ma -m ${settingsfile} -m# 0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.confusion_matrix_map == result0.confusion_matrix_map
	// with classifier 1
	result = verify(opts('-s -ma -m ${settingsfile} -m# 1 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	// with both classifiers
	result = verify(opts('-s -ma -m ${settingsfile} -m# 1,0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.correct_counts == [0, 0, 1], 'with both classifiers'
	// with totalnn flag set, performance improves
	result = verify(opts('-s -ma -mt -m ${settingsfile} -m# 1,0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.correct_counts == [1, 0, 1]
}

fn test_multiple_classifier_verify_totalnn_discrete_attributes_multiple_classes() ? {
	datafile := 'datasets/soybean-large-train.tab'
	testfile := 'datasets/soybean-large-test.tab'
	settingsfile := 'tempfolders/tempfolder_totalnn/soybean.opts'
	mut result := CrossVerifyResult{}

	result0 := verify(opts('-s -a 13 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result0.correct_counts == [10, 10, 10, 48, 20, 9, 9, 47, 10, 8, 10, 24, 6, 49, 39, 9,
		8, 15, 4], 'verify with 13 attributes'
	result1 := verify(opts('-s -w -a 32 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result1.correct_counts == [10, 10, 10, 48, 24, 10, 10, 39, 10, 9, 10, 24, 9, 41, 40,
		9, 8, 15, 4], 'verify with 32 attributes'
	// verify that the settings file was saved, and is the right length
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	assert r.len == 2
	display_file(settingsfile, opts('-ea ${datafile}'))
	// with classifier 0 only
	result = verify(opts('-s -m ${settingsfile} -m# 0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.confusion_matrix_map == result0.confusion_matrix_map
	// with classifier 1
	result = verify(opts('-s -m ${settingsfile} -m# 1 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	// with both classifiers
	result = verify(opts('-s -m ${settingsfile} -m# 1,0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.correct_counts == [10, 10, 10, 48, 24, 10, 10, 42, 10, 9, 10, 24, 9, 48, 41,
		9, 8, 15, 4], 'with both classifiers'
	// with totalnn flag set, performance deteriorates
	result = verify(opts('-s -mt -m ${settingsfile} -m# 1,0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.correct_counts == [10, 10, 10, 48, 20, 9, 9, 47, 10, 8, 10, 24, 6, 49, 39, 9,
		8, 15, 4]
	// repeat with break_on_all
	result = verify(opts('-s -ma -m ${settingsfile} -m# 1,0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.correct_counts == [10, 10, 10, 48, 24, 10, 10, 42, 10, 9, 10, 24, 9, 48, 41,
		9, 8, 15, 4], 'with both classifiers'
	// with totalnn flag set, performance deteriorates
	result = verify(opts('-s -ma -mt -m ${settingsfile} -m# 1,0 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.correct_counts == [10, 10, 10, 48, 20, 9, 5, 39, 8, 6, 10, 23, 1, 50, 38, 9,
		8, 15, 4]
}
