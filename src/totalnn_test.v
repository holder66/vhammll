// totalnn_test.v

// test_multiple_classifier_settings using the totalnn algorithm

module vhammll

import os
// import vtl

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
	mut opts := Options{
		// break_on_all_flag:    true
		combined_radii_flag: false
		weighting_flag:      false
		show_flag:           false
		command:             'explore'
		expanded_flag:       true
	}
	mut result := CrossVerifyResult{}

	opts.datafile_path = 'datasets/2_class_developer.tab'
	opts.settingsfile_path = 'tempfolders/tempfolder_totalnn/2_class.opts'
	opts.append_settings_flag = true
	opts.weight_ranking_flag = true
	mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	mut er := explore(opts)
	assert os.file_size(opts.settingsfile_path) == 5892, 'Settings file too small'
	display_file(opts.settingsfile_path, opts)
	// repeat display with show attributes
	opts.show_attributes_flag = true
	display_file(opts.settingsfile_path, opts)

	// show optimals without and with purging
	optimals(opts.settingsfile_path, opts)
	opts.purge_flag = true
	optimals(opts.settingsfile_path, opts)
	opts.multiple_flag = true
	opts.append_settings_flag = false
	opts.show_attributes_flag = false
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.classifiers = [0, 2]
	opts.command = 'cross'
	result = cross_validate(opts)
	assert result.correct_counts == [8, 3]
	opts.total_nn_counts_flag = true
	opts.classifiers = [1]
	// opts.break_on_all_flag = true
	result = cross_validate(opts)
	assert result.correct_counts == [8, 3], 'for classifier #1'
	opts.classifiers = [2]
	cross_validate(ds, opts)
	assert cross_validate(opts).correct_counts == [9, 2], 'for classifier #2'
	opts.classifiers = [2, 3]
	opts.command = 'cross'
	opts.show_flag = true
	// opts.expanded_flag = true
	result_mult := cross_validate(opts)
	assert cross_validate(opts).correct_counts == [8, 3], 'for classifiers 2 & 3'
}

fn test_multiple_classifier_crossvalidate_totalnn_multiple_classes() {
	mut opts := Options{
		// break_on_all_flag:    true
		combined_radii_flag: false
		weighting_flag:      false
		show_flag:           false
		// total_nn_counts_flag: true
		command:       'explore'
		expanded_flag: true
	}
	mut result := CrossVerifyResult{}

	opts.datafile_path = 'datasets/developer.tab'
	opts.settingsfile_path = 'tempfolders/tempfolder_totalnn/developer.opts'
	opts.append_settings_flag = true
	opts.weight_ranking_flag = true
	mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	mut er := explore(opts)
	assert os.file_size(opts.settingsfile_path) == 7026, 'Settings file too small'
	display_file(opts.settingsfile_path, opts)
	// repeat display with show attributes
	opts.show_attributes_flag = true
	display_file(opts.settingsfile_path, opts)

	// show optimals without and with purging
	optimals(opts.settingsfile_path, opts)
	opts.purge_flag = true
	optimals(opts.settingsfile_path, opts)
	opts.multiple_flag = true
	opts.append_settings_flag = false
	opts.show_attributes_flag = false
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.classifiers = [0, 2]
	opts.command = 'cross'
	// opts.verbose_flag = true
	result = cross_validate(opts)
	assert result.correct_counts == [8, 3, 2]
	opts.total_nn_counts_flag = true
	// opts.break_on_all_flag = true
	result = cross_validate(opts)
	assert result.correct_counts == [8, 3, 2]
	opts.classifiers = [2]
	cross_validate(ds, opts)
	assert cross_validate(opts).correct_counts == [8, 3, 2], 'for classifier #2'
	opts.classifiers = [2, 3]
	opts.command = 'cross'
	opts.show_flag = true
	// opts.expanded_flag = true
	result_mult := cross_validate(opts)
	assert cross_validate(opts).correct_counts == [8, 0, 0], 'for classifiers 2 & 3'
}

fn test_multiple_classifier_verify_totalnn_continuous_attributes() ? {
	mut opts := Options{
		concurrency_flag: false
		// total_nn_counts_flag: true
		command:       'verify'
		expanded_flag: true
	}
	mut result := CrossVerifyResult{}
	opts.datafile_path = 'datasets/leukemia38train.tab'
	opts.testfile_path = 'datasets/leukemia34test.tab'
	opts.settingsfile_path = 'tempfolders/tempfolder_totalnn/leuk.opts'
	opts.append_settings_flag = true
	opts.number_of_attributes = [1]
	opts.bins = [5, 5]
	opts.purge_flag = true
	opts.weight_ranking_flag = true
	mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	result0 := verify(opts)
	assert result0.correct_counts == [17, 14], 'verify with 1 attribute and binning [5,5]'
	opts.bins = [2, 2]
	opts.purge_flag = false
	opts.weight_ranking_flag = false
	opts.number_of_attributes = [6]
	opts.bins = [1, 10]
	result1 := verify(opts)
	assert result1.correct_counts == [20, 9], 'verify with 6 attributes and binning [2,2]'
	// verify that the settings file was saved, and
	// is the right length

	assert os.file_size(opts.settingsfile_path) == 2337
	opts.show_attributes_flag = true
	display_file(opts.settingsfile_path, opts)
	// test verify with multiple_classify_options_file_path
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.append_settings_flag = false
	opts.show_flag = true
	opts.expanded_flag = true
	opts.show_attributes_flag = false
	// with classifier 0 only
	opts.classifiers = [0]
	result = verify(opts)
	assert result.confusion_matrix_map == result0.confusion_matrix_map
	// with classifier 1
	opts.classifiers = [1]
	result = verify(opts)
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	// repeat with total_nn flag set
	opts.total_nn_counts_flag = true
	result = verify(opts)
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	// with both classifiers
	opts.classifiers = []
	opts.total_nn_counts_flag = false
	opts.traverse_all_flags = true
	opts.expanded_flag = false
	opts.show_flag = false
	result = verify(opts)
	// get best balanced accuracy with [18, 14] 95.00  ma false mc true mt false []
	opts.traverse_all_flags = false
	opts.break_on_all_flag = false
	opts.total_nn_counts_flag = false
	opts.combined_radii_flag = true
	opts.expanded_flag = true
	result = verify(opts)
	assert result.correct_counts == [18, 14], 'with both classifiers'
	// this deteriorates when add totalnn-counts
	opts.total_nn_counts_flag = true
	result = verify(opts)
	assert result.correct_counts == [18, 13]
}

fn test_multiple_classifier_verify_totalnn_discrete_attributes() ? {
	mut opts := Options{
		concurrency_flag:  false
		break_on_all_flag: true
		command:           'verify'
		expanded_flag:     true
	}
	mut result := CrossVerifyResult{}
	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'
	opts.settingsfile_path = 'tempfolders/tempfolder_totalnn/bcw.opts'
	opts.append_settings_flag = true
	opts.number_of_attributes = [3]
	// mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	result0 := verify(opts)
	assert result0.correct_counts == [133, 37], 'verify with 3 attributes'
	opts.number_of_attributes = [4]
	result1 := verify(opts)
	assert result1.correct_counts == [135, 36], 'verify with 4 attributes'
	// verify that the settings file was saved, and
	// is the right length

	assert os.file_size(opts.settingsfile_path) == 2538
	opts.show_attributes_flag = true
	display_file(opts.settingsfile_path, opts)
	// test verify with multiple_classify_options_file_path
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.append_settings_flag = false
	opts.show_attributes_flag = false
	// with classifier 0 only
	opts.classifiers = [0]
	result = verify(opts)
	assert result.confusion_matrix_map == result0.confusion_matrix_map
	// with classifier 1
	opts.classifiers = [1]
	result = verify(opts)
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	result = verify(opts)
	// with both classifiers
	opts.classifiers = [1, 0]
	result = verify(opts)
	assert result.correct_counts == [135, 37], 'with both classifiers'
	// with totalnn flag set, performance deteriorates
	opts.total_nn_counts_flag = true
	result = verify(opts)
	assert result.correct_counts == [133, 36]
	opts.break_on_all_flag = false
	result = verify(opts)
	assert result.correct_counts == [133, 37]
}

fn test_multiple_classifier_verify_totalnn_multiple_classes() ? {
	mut opts := Options{
		concurrency_flag: false
		command:          'verify'
		expanded_flag:    true
		show_flag:        true
	}
	mut result := CrossVerifyResult{}
	opts.datafile_path = 'datasets/develop_train.tab'
	opts.testfile_path = 'datasets/develop_test.tab'
	opts.settingsfile_path = 'tempfolders/tempfolder_totalnn/develop.opts'
	opts.append_settings_flag = true
	// mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	result0 := verify(opts)
	assert result0.correct_counts == [1, 0, 1], 'verify with 13 attributes'
	opts.number_of_attributes = [4]
	opts.weighting_flag = true
	result1 := verify(opts)
	assert result1.correct_counts == [0, 0, 1], 'verify with 4 attributes'
	// verify that the settings file was saved, and
	// is the right length

	assert os.file_size(opts.settingsfile_path) == 2169
	opts.show_attributes_flag = true
	display_file(opts.settingsfile_path, opts)
	// test verify with multiple_classify_options_file_path
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.append_settings_flag = false
	opts.show_flag = true
	// opts.expanded_flag = true
	opts.show_attributes_flag = false
	// with classifier 0 only
	opts.classifiers = [0]
	result = verify(opts)
	assert result.confusion_matrix_map == result0.confusion_matrix_map
	// with classifier 1
	opts.classifiers = [1]
	result = verify(opts)
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	// with both classifiers
	opts.classifiers = [1, 0]
	opts.break_on_all_flag = true
	result = verify(opts)
	assert result.correct_counts == [0, 0, 1], 'with both classifiers'
	// with totalnn flag set, performance improves
	opts.total_nn_counts_flag = true

	result = verify(opts)
	assert result.correct_counts == [1, 0, 1]
}

fn test_multiple_classifier_verify_totalnn_discrete_attributes_multiple_classes() ? {
	mut opts := Options{
		concurrency_flag: false
		command:          'verify'
		expanded_flag:    false
		show_flag:        true
	}
	mut result := CrossVerifyResult{}
	opts.datafile_path = 'datasets/soybean-large-train.tab'
	opts.testfile_path = 'datasets/soybean-large-test.tab'
	opts.settingsfile_path = 'tempfolders/tempfolder_totalnn/soybean.opts'
	opts.append_settings_flag = true
	opts.number_of_attributes = [13]
	// mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	result0 := verify(opts)
	assert result0.correct_counts == [10, 10, 10, 48, 20, 9, 9, 47, 10, 8, 10, 24, 6, 49, 39, 9,
		8, 15, 4], 'verify with 13 attributes'
	opts.number_of_attributes = [32]
	opts.weighting_flag = true
	result1 := verify(opts)
	assert result1.correct_counts == [10, 10, 10, 48, 24, 10, 10, 39, 10, 9, 10, 24, 9, 41, 40,
		9, 8, 15, 4], 'verify with 4 attributes'
	// verify that the settings file was saved, and
	// is the right length

	assert os.file_size(opts.settingsfile_path) == 3215
	opts.show_attributes_flag = true
	display_file(opts.settingsfile_path, opts)
	// test verify with multiple_classify_options_file_path
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.append_settings_flag = false
	opts.show_flag = true
	// opts.expanded_flag = true
	opts.show_attributes_flag = false
	// with classifier 0 only
	opts.classifiers = [0]
	result = verify(opts)
	assert result.confusion_matrix_map == result0.confusion_matrix_map
	// with classifier 1
	opts.classifiers = [1]
	result = verify(opts)
	assert result.confusion_matrix_map == result1.confusion_matrix_map
	// with both classifiers
	opts.classifiers = [1, 0]
	result = verify(opts)
	assert result.correct_counts == [10, 10, 10, 48, 24, 10, 10, 42, 10, 9, 10, 24, 9, 48, 41,
		9, 8, 15, 4], 'with both classifiers'
	// with totalnn flag set, performance deteriorates
	opts.total_nn_counts_flag = true
	result = verify(opts)
	assert result.correct_counts == [10, 10, 10, 48, 20, 9, 9, 47, 10, 8, 10, 24, 6, 49, 39, 9,
		8, 15, 4]
	// repeat with break_on_all
	opts.break_on_all_flag = true
	opts.total_nn_counts_flag = false
	result = verify(opts)
	assert result.correct_counts == [10, 10, 10, 48, 24, 10, 10, 42, 10, 9, 10, 24, 9, 48, 41,
		9, 8, 15, 4], 'with both classifiers'
	// with totalnn flag set, performance deteriorates
	opts.total_nn_counts_flag = true
	result = verify(opts)
	assert result.correct_counts == [10, 10, 10, 48, 20, 9, 5, 39, 8, 6, 10, 23, 1, 50, 38, 9,
		8, 15, 4]
}
