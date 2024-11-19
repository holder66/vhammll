// show_attributes_test.v

module vhammll

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolder_show_attr') {
		os.rmdir_all('tempfolder_show_attr')!
	}
	os.mkdir_all('tempfolder_show_attr')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder_show_attr')!
}

fn test_show_attributes_in_make_classifier() {
	mut opts := Options{
		datafile_path: 'datasets/developer.tab'
		// show_flag:     true
		show_attributes_flag: true
		command:              'make'
	}
	make_classifier(load_file(opts.datafile_path), opts)
}

fn test_show_attributes_in_verify() {
	mut opts := Options{
		datafile_path:        'datasets/mobile_price_classification_train.csv'
		testfile_path:        'datasets/mobile_price_classification_test.csv'
		show_flag:            true
		expanded_flag:        true
		show_attributes_flag: true
		command:              'verify'
	}
	verify(opts)
}

fn test_show_attributes_in_multiple_classifier_verify() {}

fn test_multiple_classifier_verify_totalnn() ? {
	mut opts := Options{
		concurrency_flag:     false
		break_on_all_flag:    true
		total_nn_counts_flag: true
		command:              'verify'
	}
	// populate a settings file, doing individual verifications
	mut result := CrossVerifyResult{}
	opts.datafile_path = 'datasets/leukemia38train.tab'
	opts.testfile_path = 'datasets/leukemia34test.tab'
	opts.settingsfile_path = 'tempfolder_show_attr/leuk.opts'
	opts.append_settings_flag = true
	opts.number_of_attributes = [1]
	opts.bins = [5, 5]
	opts.purge_flag = true
	opts.weight_ranking_flag = true
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
	}, 'verify with 1 attribute and binning [5,5]'
	opts.bins = [2, 2]
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
	// verify that the settings file was saved, and
	// is the right length
	assert os.file_size(opts.settingsfile_path) >= 929
	opts.show_attributes_flag = true
	display_file(opts.settingsfile_path, opts)
	// test verify with multiple_classify_options_file_path
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.append_settings_flag = false
	opts.show_flag = true
	// opts.expanded_flag = true
	opts.show_attributes_flag = true
	// result = multi_verify(opts)
	// with both classifiers
	// assert result.confusion_matrix_map == {
	// 	'ALL': {
	// 		'ALL': 20.0
	// 		'AML': 0.0
	// 	}
	// 	'AML': {
	// 		'ALL': 4.0
	// 		'AML': 10.0
	// 	}
	// }, 'with both classifiers'
	// with classifier 0 only
	opts.classifier_indices = [0]
	// result = multi_verify(opts)
	// assert result.confusion_matrix_map == result0.confusion_matrix_map
	// with classifier 1
	opts.classifier_indices = [1]
	// result = multi_verify(opts)
	// assert result.confusion_matrix_map == result1.confusion_matrix_map
}
