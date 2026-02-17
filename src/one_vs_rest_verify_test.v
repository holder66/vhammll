// one_vs_rest_verify_test.v

// test_multiple_classifier_settings

module vhammll

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_one_vs_rest_verify') {
		os.rmdir_all('tempfolders/tempfolder_one_vs_rest_verify')!
	}
	os.mkdir_all('tempfolders/tempfolder_one_vs_rest_verify')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_one_vs_rest_verify')!
}

// test_one_vs_rest_verify
fn test_one_vs_rest_verify() ? {
	settingsfile := 'tempfolders/tempfolder_one_vs_rest_verify/onevsrest.opts'
	mut result := CrossVerifyResult{}

	result0 := one_vs_rest_verify(opts('-e -a 0 -b 5,5 -ms ${settingsfile} -t datasets/onevsrest_test.tab datasets/onevsrest_train.tab',
		cmd: 'verify'
	))

	result1 := one_vs_rest_verify(opts('-e -wr -a 25 -b 1,16 -ms ${settingsfile} -t datasets/soybean-large-test.tab datasets/soybean-large-train.tab',
		cmd: 'verify'
	))

	// opts.testfile_path = 'datasets/mnist_test.tab'
	// opts.number_of_attributes = [313]
	// opts.bins = [2, 2]
	// opts.weight_ranking_flag = true
	// opts.weighting_flag = true
	// result2 := one_vs_rest_verify(opts)
	// assert result0.confusion_matrix_map == {
	// 	'ALL': {
	// 		'ALL': 17.0
	// 		'AML': 3.0
	// 	}
	// 	'AML': {
	// 		'ALL': 0.0
	// 		'AML': 14.0
	// 	}
	// }
	// opts.purge_flag = false
	// opts.weight_ranking_flag = false
	// opts.number_of_attributes = [6]
	// opts.bins = [1, 10]
	// result1 := verify(opts)
	// assert result1.confusion_matrix_map == {
	// 	'ALL': {
	// 		'ALL': 20.0
	// 		'AML': 0.0
	// 	}
	// 	'AML': {
	// 		'ALL': 5.0
	// 		'AML': 9.0
	// 	}
	// }
	// // verify that the settings file was correctly saved, and
	// // is the right length
	// assert os.file_size(opts.settingsfile_path) >= 929

	// // test verify with multiple_classify_options_file_path
	// opts.multiple_flag = true
	// opts.multiple_classify_options_file_path = opts.settingsfile_path
	// opts.settingsfile_path = ''
	// // with classifier 0
	// opts.classifiers = [0]
	// result = multi_verify(opts)
	// assert result.confusion_matrix_map == result0.confusion_matrix_map
	// // classifier 0 with total_nn_counts_flag true
	// opts.total_nn_counts_flag = true
	// result = multi_verify(opts)
	// assert result.confusion_matrix_map == result0.confusion_matrix_map
	// // with classifier 1
	// opts.total_nn_counts_flag = false
	// opts.classifiers = [1]
	// result = multi_verify(opts)
	// assert result.confusion_matrix_map == result1.confusion_matrix_map
	// opts.total_nn_counts_flag = true
	// opts.classifiers = [1]
	// result = multi_verify(opts)
	// assert result.confusion_matrix_map == result1.confusion_matrix_map
	// // with both classifiers
	// opts.classifiers = []
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
	// // with both classifiers, and break_on_all_flag false
	// opts.break_on_all_flag = false
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
	// // with both classifiers, break_on_all_flag false, combined_radii_flag true
	// opts.break_on_all_flag = false
	// opts.combined_radii_flag = true
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
	// // with both classifiers, break_on_all_flag true, combined_radii_flag true
	// opts.break_on_all_flag = true
	// opts.combined_radii_flag = true
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
	// // with both classifiers, break_on_all_flag true, combined_radii_flag true, total_nn_counts_flag true
	// opts.classifiers = []
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
