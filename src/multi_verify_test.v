// multiple_verify_test.v

// test_multiple_classifier_settings

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
		break_on_all_flag:    true
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
	opts.weight_ranking_flag = true
	// check that the non-multiple verify works OK, and that the
	// settings file is getting appended
	mut ds := load_file(opts.datafile_path)
	result0 := verify(opts)
	assert result0.confusion_matrix_map == {
		'ALL': {
			'ALL': 17.0
			'AML': 3.0
		}
		'AML': {
			'ALL': 0.0
			'AML': 14.0
		}
	}
	opts.purge_flag = false
	opts.weight_ranking_flag = false
	opts.number_of_attributes = [6]
	opts.bins = [1, 10]
	result1 := verify(opts)
	assert result1.confusion_matrix_map == {
		'ALL': {
			'ALL': 20.0
			'AML': 0.0
		}
		'AML': {
			'ALL': 5.0
			'AML': 9.0
		}
	}
	// verify that the settings file was correctly saved, and
	// is the right length
	assert os.file_size(opts.settingsfile_path) >= 929
	// test verify with multiple_classify_options_file_path
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.settingsfile_path = ''
	// with classifier 0
	opts.classifier_indices = [0]
	result = multi_verify(opts)
	assert result.confusion_matrix_map == result0.confusion_matrix_map
	// classifier 0 with total_nn_counts_flag true
	opts.total_nn_counts_flag = true
	result = multi_verify(opts)
	assert result.confusion_matrix_map == result0.confusion_matrix_map
	// with classifier 1
	opts.total_nn_counts_flag = false
	opts.classifier_indices = [1]
	result = multi_verify(opts)
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	opts.total_nn_counts_flag = true
	opts.classifier_indices = [1]
	result = multi_verify(opts)
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	// with both classifiers
	opts.classifier_indices = []
	result = multi_verify(opts)
	assert result.confusion_matrix_map == {
		'ALL': {
			'ALL': 20.0
			'AML': 0.0
		}
		'AML': {
			'ALL': 4.0
			'AML': 10.0
		}
	}
	// with both classifiers, and break_on_all_flag false
	opts.break_on_all_flag = false
	result = multi_verify(opts)
	assert result.confusion_matrix_map == {
		'ALL': {
			'ALL': 18.0
			'AML': 2.0
		}
		'AML': {
			'ALL': 0.0
			'AML': 14.0
		}
	}
	// with both classifiers, break_on_all_flag false, combined_radii_flag true
	opts.break_on_all_flag = false
	opts.combined_radii_flag = true
	result = multi_verify(opts)
	assert result.confusion_matrix_map == {
		'ALL': {
			'ALL': 18.0
			'AML': 2.0
		}
		'AML': {
			'ALL': 0.0
			'AML': 14.0
		}
	}
	// with both classifiers, break_on_all_flag true, combined_radii_flag true
	opts.break_on_all_flag = true
	opts.combined_radii_flag = true
	result = multi_verify(opts)
	assert result.confusion_matrix_map == {
		'ALL': {
			'ALL': 20.0
			'AML': 0.0
		}
		'AML': {
			'ALL': 4.0
			'AML': 10.0
		}
	}
	// with both classifiers, break_on_all_flag true, combined_radii_flag true, total_nn_counts_flag true
	opts.classifier_indices = []
	opts.break_on_all_flag = false
	opts.combined_radii_flag = false
	opts.total_nn_counts_flag = true
	result = multi_verify(opts)
	assert result.confusion_matrix_map == {
		'ALL': {
			'ALL': 18.0
			'AML': 2.0
		}
		'AML': {
			'ALL': 0.0
			'AML': 14.0
		}
	}
}

fn test_multiple_verify_with_multiple_classes() ? {
	mut opts := Options{
		concurrency_flag:  false
		break_on_all_flag: true
		command:           'verify'
	}
	mut disp := DisplaySettings{
		verbose_flag:  false
		expanded_flag: false
	}
	mut result := CrossVerifyResult{}

	opts.datafile_path = 'datasets/onevsrest_train.tab'
	opts.testfile_path = 'datasets/onevsrest_test.tab'
	opts.settingsfile_path = 'tempfolders/tempfolder_multiple_verify/onevsrest.opts'
	opts.append_settings_flag = true
	opts.number_of_attributes = [1]
	opts.bins = [5, 5]
	opts.purge_flag = true
	opts.weight_ranking_flag = true
	// check that the non-multiple verify works OK, and that the
	// settings file is getting appended
	mut ds := load_file(opts.datafile_path)
	result0 := verify(opts)
	assert result0.confusion_matrix_map == {
		'f': {
			'f': 1.0
			'm': 0.0
			'X': 0.0
		}
		'm': {
			'f': 0.0
			'm': 4.0
			'X': 0.0
		}
		'X': {
			'f': 0.0
			'm': 0.0
			'X': 1.0
		}
	}
	opts.purge_flag = false
	opts.weight_ranking_flag = false
	opts.number_of_attributes = [6]
	opts.bins = [1, 10]
	result1 := verify(opts)
	assert result1.confusion_matrix_map == {
		'f': {
			'f': 0.0
			'm': 1.0
			'X': 0.0
		}
		'm': {
			'f': 1.0
			'm': 3.0
			'X': 0.0
		}
		'X': {
			'f': 1.0
			'm': 0.0
			'X': 0.0
		}
	}
	// verify that the settings file was correctly saved, and
	// is the right length
	// display_file(opts.settingsfile_path, opts)
	assert os.file_size(opts.settingsfile_path) >= 929
	// test verify with multiple_classify_options_file_path
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.settingsfile_path = ''
	// with classifier 0
	opts.classifier_indices = [0]
	result = multi_verify(opts)
	assert result.confusion_matrix_map == result0.confusion_matrix_map
	// classifier 0 with total_nn_counts_flag true
	// opts.total_nn_counts_flag = true
	// result = multi_verify(opts)
	// assert result.confusion_matrix_map == result0.confusion_matrix_map
	// with classifier 1
	opts.total_nn_counts_flag = false
	opts.classifier_indices = [1]
	result = multi_verify(opts)
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	// opts.total_nn_counts_flag = true
	// opts.classifier_indices = [1]
	// result = multi_verify(opts)
	// assert result.confusion_matrix_map == result1.confusion_matrix_map
	// with both classifiers
	opts.classifier_indices = []
	result = multi_verify(opts)
	assert result.confusion_matrix_map == {
		'f': {
			'f': 1.0
			'm': 0.0
			'X': 0.0
		}
		'm': {
			'f': 0.0
			'm': 4.0
			'X': 0.0
		}
		'X': {
			'f': 0.0
			'm': 0.0
			'X': 1.0
		}
	}
	// with both classifiers, and break_on_all_flag false
	opts.break_on_all_flag = false
	result = multi_verify(opts)
	assert result.confusion_matrix_map == {
		'f': {
			'f': 1.0
			'm': 0.0
			'X': 0.0
		}
		'm': {
			'f': 0.0
			'm': 4.0
			'X': 0.0
		}
		'X': {
			'f': 0.0
			'm': 0.0
			'X': 1.0
		}
	}
	// with both classifiers, break_on_all_flag false, combined_radii_flag true
	opts.break_on_all_flag = false
	opts.combined_radii_flag = true
	result = multi_verify(opts)
	assert result.confusion_matrix_map == {
		'f': {
			'f': 1.0
			'm': 0.0
			'X': 0.0
		}
		'm': {
			'f': 0.0
			'm': 4.0
			'X': 0.0
		}
		'X': {
			'f': 0.0
			'm': 0.0
			'X': 1.0
		}
	}
	// with both classifiers, break_on_all_flag true, combined_radii_flag true
	opts.break_on_all_flag = true
	opts.combined_radii_flag = true
	result = multi_verify(opts)
	assert result.confusion_matrix_map == {
		'f': {
			'f': 1.0
			'm': 0.0
			'X': 0.0
		}
		'm': {
			'f': 0.0
			'm': 4.0
			'X': 0.0
		}
		'X': {
			'f': 0.0
			'm': 0.0
			'X': 1.0
		}
	}
	// with both classifiers, break_on_all_flag true, combined_radii_flag true, total_nn_counts_flag true
	// opts.classifier_indices = []
	// opts.break_on_all_flag = false
	// opts.combined_radii_flag = false
	// opts.total_nn_counts_flag = true
	// result = multi_verify(opts)
	// assert result.confusion_matrix_map == {
	// 	'ALL': {
	// 		'ALL': 18.0
	// 		'AML': 2.0
	// 	}
	// 	'AML': {
	// 		'ALL': 0.0
	// 		'AML': 14.0
	// 	}
	// }
}
