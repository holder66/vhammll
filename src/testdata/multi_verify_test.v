// multiple_verify_test.v

// test_multiple_classifier_settings

// as of 2025-3-9, this test fails with the totalnn_flag set

module vhammll

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_multiple_verify') {
		os.rmdir_all('tempfolders/tempfolder_multiple_verify')!
	}
	os.mkdir_all('tempfolders/tempfolder_multiple_verify')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_multiple_verify')!
}

fn test_multiple_verify() ? {
	datafile := 'datasets/leukemia38train.tab'
	testfile := 'datasets/leukemia34test.tab'
	settingsfile := 'tempfolders/tempfolder_multiple_verify/leuk.opts'
	mut result := CrossVerifyResult{}

	// check that the non-multiple verify works OK, and that the
	// settings file is getting appended
	result96 := verify(opts('-e -ea -p -a 1 -b 5,5 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result96.correct_counts == [17, 14]
	result131 := verify(opts('-e -ea -wr -a 1 -b 5,5 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result131.correct_counts == [17, 14]
	result92 := verify(opts('-e -ea -w -a 3 -b 4,4 -ms ${settingsfile} -t ${testfile} ${datafile}',
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
	assert result96_92.correct_counts == [18, 12]
	result140_131_92 := verify(opts('-e -ea -mt -m ${settingsfile} -m# 1,2,3 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result140_131_92.correct_counts == [20, 12]
	result140_96_92 := verify(opts('-e -ea -m ${settingsfile} -m# 0,2,3 -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result140_96_92.correct_counts == [20, 11]
}

fn test_multiple_verify_with_multiple_classes() ? {
	datafile := 'datasets/develop_train.tab'
	testfile := 'datasets/develop_test.tab'
	settingsfile := 'tempfolders/tempfolder_multiple_verify/develop.opts'
	mut result := CrossVerifyResult{}

	// check that the non-multiple verify works OK, and that the
	// settings file is getting appended
	result0 := verify(opts('-ma -bp -p -a 2 -b 1,10 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result0.confusion_matrix_map == {
		'm': {
			'm': 4.0
			'X': 0.0
			'f': 0.0
		}
		'X': {
			'm': 0.0
			'X': 1.0
			'f': 0.0
		}
		'f': {
			'm': 1.0
			'X': 0.0
			'f': 0.0
		}
	}
	result1 := verify(opts('-ma -bp -p -wr -a 1 -b 5,5 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result1.confusion_matrix_map == {
		'm': {
			'm': 4.0
			'X': 0.0
			'f': 0.0
		}
		'X': {
			'm': 0.0
			'X': 1.0
			'f': 0.0
		}
		'f': {
			'm': 1.0
			'X': 0.0
			'f': 0.0
		}
	}
	// verify that the settings file was correctly saved, and is the right length
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	assert r.len == 2
	// test verify with multiple_classify_options_file_path
	// with both classifiers, over all flag settings
	result = verify(opts('-af -m ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
	assert result.correct_inferences == {
		'm': 4
		'f': 0
		'X': 0
	}
}
