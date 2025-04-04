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
	mut opts := Options{
		concurrency_flag:     false
		break_on_all_flag:    false
		command:              'verify'
		verbose_flag:         false
		expanded_flag:        true
		show_attributes_flag: true
	}
	mut result := CrossVerifyResult{}

	opts.datafile_path = 'datasets/leukemia38train.tab'
	opts.testfile_path = 'datasets/leukemia34test.tab'
	opts.settingsfile_path = 'tempfolders/tempfolder_multiple_verify/leuk.opts'
	opts.append_settings_flag = true
	opts.number_of_attributes = [1]
	opts.bins = [5, 5]
	opts.purge_flag = true
	opts.balance_prevalences_flag = true
	// check that the non-multiple verify works OK, and that the
	// settings file is getting appended
	// opts.weight_ranking_flag = true
	result96 := verify(opts)
	assert result96.correct_counts == [17, 14]
	opts.weight_ranking_flag = true
	opts.balance_prevalences_flag = false
	result131 := verify(opts)
	assert result131.correct_counts == [17, 14]
	opts.number_of_attributes = [3]
	opts.bins = [4, 4]
	opts.weight_ranking_flag = false
	opts.weighting_flag = true
	result92 := verify(opts)
	assert result92.correct_counts == [20, 11]
	opts.number_of_attributes = [7]
	opts.bins = [9, 9]
	opts.weight_ranking_flag = true
	opts.weighting_flag = true
	opts.purge_flag = false
	result140 := verify(opts)
	assert result140.correct_counts == [20, 11]
	// verify that the settings file was correctly saved
	display_file(opts.settingsfile_path, opts)
	// test verify with multiple_classify_options_file_path
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.append_settings_flag = false
	// with classifier 0
	opts.classifiers = [2]
	result2 := verify(opts)
	assert result2.confusion_matrix_map == result92.confusion_matrix_map
	opts.classifiers = [0, 2]
	opts.total_nn_counts_flag = true
	// opts.traverse_all_flags = true
	result96_92 := verify(opts)
	assert result96_92.correct_counts == [18,12]
	opts.classifiers = [1, 2, 3]
	result140_131_92 := verify(opts)
	assert result140_131_92.correct_counts == [20, 12]
	opts.classifiers = [0, 2, 3]
	opts.total_nn_counts_flag = false
	result140_96_92 := verify(opts)
	assert result140_96_92.correct_counts == [20, 11]
}

fn test_multiple_verify_with_multiple_classes() ? {
	mut opts := Options{
		concurrency_flag:  false
		break_on_all_flag: true
		command:           'verify'
		verbose_flag:      false
		expanded_flag:     true
	}
	mut result := CrossVerifyResult{}

	opts.datafile_path = 'datasets/develop_train.tab'
	opts.testfile_path = 'datasets/develop_test.tab'
	opts.settingsfile_path = 'tempfolders/tempfolder_multiple_verify/develop.opts'
	opts.append_settings_flag = true
	opts.number_of_attributes = [2]
	opts.bins = [1, 10]
	opts.balance_prevalences_flag = true
	opts.purge_flag = true
	// check that the non-multiple verify works OK, and that the
	// settings file is getting appended
	mut ds := load_file(opts.datafile_path)
	result0 := verify(opts)
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
	opts.weight_ranking_flag = true
	opts.number_of_attributes = [1]
	opts.bins = [5, 5]
	result1 := verify(opts)
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
	// verify that the settings file was correctly saved, and
	// is the right length
	// display_file(opts.settingsfile_path, opts)
	dump(os.file_size(opts.settingsfile_path))
	mut size := os.file_size(opts.settingsfile_path)
	assert size == 2214
	// test verify with multiple_classify_options_file_path
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.settingsfile_path = ''
	// with both classifiers, over all flag settings
	opts.expanded_flag = false
	opts.classifiers = []
	opts.traverse_all_flags = true
	result = verify(opts)
	assert result.correct_inferences == {
		'm': 4
		'f': 0
		'X': 0
	}
}
