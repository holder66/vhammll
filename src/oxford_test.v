// oxford_test.v

// multi_cross_test.v

module vhammll

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolder_oxford') {
		os.rmdir_all('tempfolder_oxford')!
	}
	os.mkdir_all('tempfolder_oxford')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder_oxford')!
}

// fn test_oxford_crossvalidate_to_create_settings_file() {
// 	home_dir := os.home_dir()
// 	mut opts := Options{
// 		command:                  'cross'
// 		concurrency_flag:         true
// 		datafile_path:            os.join_path(home_dir, 'metabolomics', 'train.tab')
// 		number_of_attributes:     [4]
// 		bins:                     [8, 8]
// 		purge_flag:               true
// 		weighting_flag:           true
// 		weight_ranking_flag:      false
// 		balance_prevalences_flag: true
// 		append_settings_flag:     true

// 		settingsfile_path: 'tempfolder_oxford/oxford_settings.opts'
// 		// verbose_flag:         true
// 		expanded_flag: true
// 	}
// 	ds := load_file(opts.datafile_path)
// 	mut result0 := cross_validate(ds, opts)
// 	// dump(result0.confusion_matrix_map)
// 	assert result0.confusion_matrix_map == {
// 		'Non': {
// 			'Non': 146.0
// 			'Can': 29.0
// 		}
// 		'Can': {
// 			'Non': 4.0
// 			'Can': 13.0
// 		}
// 	}
// 	display_file(opts.settingsfile_path, opts)
// 	opts.number_of_attributes = [1]
// 	opts.bins = [3, 3]
// 	opts.weight_ranking_flag = true
// 	opts.purge_flag = false
// 	result1 := cross_validate(ds, opts)
// 	assert result1.confusion_matrix_map == {
// 		'Non': {
// 			'Non': 120.0
// 			'Can': 53.0
// 		}
// 		'Can': {
// 			'Non': 4.0
// 			'Can': 13.0
// 		}
// 	}
// 	display_file(opts.settingsfile_path, opts)
// 	opts.number_of_attributes = [3]
// 	opts.weight_ranking_flag = false
// 	opts.balance_prevalences_flag = false
// 	result2 := cross_validate(ds, opts)
// 	assert result2.confusion_matrix_map == {
// 		'Non': {
// 			'Non': 52.0
// 			'Can': 123.0
// 		}
// 		'Can': {
// 			'Non': 2.0
// 			'Can': 15.0
// 		}
// 	}
// 	display_file(opts.settingsfile_path, opts)
// 	opts.number_of_attributes = [9]
// 	opts.bins = [1, 4]
// 	result3 := cross_validate(ds, opts)
// 	assert result3.confusion_matrix_map == {
// 		'Non': {
// 			'Non': 152.0
// 			'Can': 23.0
// 		}
// 		'Can': {
// 			'Non': 4.0
// 			'Can': 13.0
// 		}
// 	}
// 	opts.show_attributes_flag = true
// 	display_file(opts.settingsfile_path, opts)
// }

// fn test_oxford_settings_file() {
// 	home_dir := os.home_dir()
// 	opts := Options{
// 		expanded_flag:        true
// 		show_attributes_flag: true
// 	}
// 	display_file(os.join_path(home_dir, 'metabolomics', 'metabolomics.opts'), opts)
// }

fn test_oxford_multi_crossvalidate() {
	home_dir := os.home_dir()
	mut opts := Options{
		command:                             'cross'
		datafile_path:                       os.join_path(home_dir, 'metabolomics', 'train.tab')
		multiple_classify_options_file_path: os.join_path(home_dir, 'metabolomics', 'metabolomics.opts')
		// verbose_flag:         true
		multiple_flag:        true
		expanded_flag:        true
		show_attributes_flag: true
	}
	ds := load_file(opts.datafile_path)
	// use a single classifier in a multi-classifier cross-validation
	opts.classifier_indices = [1]
	assert cross_validate(ds, opts).confusion_matrix_map == {
		'Non': {
			'Non': 158.0
			'Can': 17.0
		}
		'Can': {
			'Non': 3.0
			'Can': 14.0
		}
	}

	// with all 4 classifiers, we get the highest balanced accuracy of 86.32%:
	opts.classifier_indices = []

	assert cross_validate(ds, opts).confusion_matrix_map == {
		'Non': {
			'Non': 158.0
			'Can': 17.0
		}
		'Can': {
			'Non': 3.0
			'Can': 14.0
		}
	}

	// with the first 3 classifiers we get the highest sensitivity of 0.882:
	opts.classifier_indices = [0, 1, 2]
	assert cross_validate(ds, opts).confusion_matrix_map == {
		'Non': {
			'Non': 124.0
			'Can': 51.0
		}
		'Can': {
			'Non': 2.0
			'Can': 15.0
		}
	}
	// adding the combined radius flag -mc maintains sensitivity but increases specificity to 0.754:
	opts.combined_radii_flag = true
	assert cross_validate(ds, opts).confusion_matrix_map == {
		'Non': {
			'Non': 132.0
			'Can': 43.0
		}
		'Can': {
			'Non': 2.0
			'Can': 15.0
		}
	}
}

// fn test_oxford_multi_verify() {
// 	home_dir := os.home_dir()
// 	mut opts := Options{
// 		command:                             'verify'
// 		datafile_path:                       os.join_path(home_dir, 'metabolomics', 'train.tab')
// 		testfile_path:                       os.join_path(home_dir, 'metabolomics', 'test.tab')
// 		multiple_classify_options_file_path: os.join_path(home_dir, 'metabolomics', 'metabolomics.opts')
// 		// verbose_flag:         true
// 		multiple_flag:        true
// 		classifier_indices:   [0, 1, 2]
// 		combined_radii_flag:  true
// 		expanded_flag:        true
// 		show_attributes_flag: true
// 	}
// 	result := multi_verify(opts)
// 	assert result.confusion_matrix_map == {
// 		'Non': {
// 			'Non': 61.0
// 			'Can': 24.0
// 		}
// 		'Can': {
// 			'Non': 2.0
// 			'Can': 5.0
// 		}
// 	}
// 	assert result.sens == 0.7142857142857143
// 	assert result.spec == 0.7176470588235294
// }
