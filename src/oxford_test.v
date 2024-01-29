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

fn test_oxford_crossvalidate() {
	mut disp := DisplaySettings{
		verbose_flag: true
		expanded_flag: true
	}
	mut opts := Options{
		command: 'cross'
		// concurrency_flag: true
		datafile_path: '/Users/henryolders/Oxford-train.tab'
		number_of_attributes: [8]
		bins: [1, 2]
		purge_flag: false
		weighting_flag: true
		weight_ranking_flag: true
		settingsfile_path: '/Users/henryolders/use_vhammll/oxford2024-1-27.opts'
	}
	mut result := CrossVerifyResult{}
	display_file(opts.settingsfile_path, opts)
	ds := load_file(opts.datafile_path)
	// result = cross_validate(ds, opts, disp)

	// try with the same settings but multiple classifiers

	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.classifier_indices = [1]
	// assert cross_validate(ds, opts, disp).confusion_matrix_map == result.confusion_matrix_map

	// with totalnn flag set

	opts.total_nn_counts_flag = true
	// assert cross_validate(ds, opts, disp).confusion_matrix_map == result.confusion_matrix_map

	opts.classifier_indices = [3, 6, 12]
	// result = cross_validate(ds, opts, disp)
	opts.break_on_all_flag = true
	result = cross_validate(ds, opts, disp)
}

// fn test_multiple_crossvalidate() ? {
// 	mut disp := DisplaySettings{
// 		verbose_flag: false
// 		expanded_flag: false
// 	}
// 	mut opts := Options{
// 		// folds: 3
// 		break_on_all_flag: true
// 		combined_radii_flag: false
// 		weighting_flag: false
// 		// total_nn_counts_flag: true
// 		command: 'explore'
// 		concurrency_flag: true
// 	}
// 	mut result := CrossVerifyResult{}
// 	// create an .opts file with settings for multiple classifiers
// 	opts.datafile_path = 'datasets/2_class_developer.tab'
// 	opts.settingsfile_path = 'tempfolder_oxford/2_class.opts'
// 	opts.append_settings_flag = true
// 	opts.weight_ranking_flag = true
// 	mut ds := load_file(opts.datafile_path)
// 	mut er := explore(ds, opts)
// 	// do an ordinary crossvalidation
// 	opts.command = 'cross'
// 	opts.number_of_attributes = [3]
// 	opts.bins = [1, 3]
// 	result = cross_validate(ds, opts)

// 	// now do a multiple classifier crossvalidation
// 	opts.multiple_flag = true
// 	opts.multiple_classify_options_file_path = opts.settingsfile_path
// 	opts.classifier_indices = [2]
// 	assert cross_validate(ds, opts, disp).confusion_matrix_map == {
// 		'm': {
// 			'm': 8.0
// 			'f': 1.0
// 		}
// 		'f': {
// 			'm': 1.0
// 			'f': 3.0
// 		}
// 	}
// 	opts.classifier_indices = [3]
// 	// assert cross_validate(ds, opts, disp).confusion_matrix_map == result.confusion_matrix_map
// 	opts.classifier_indices = [2, 3]
// 	assert cross_validate(ds, opts, disp).confusion_matrix_map == {
// 		'm': {
// 			'm': 8.0
// 			'f': 1.0
// 		}
// 		'f': {
// 			'm': 1.0
// 			'f': 3.0
// 		}
// 	}
// }

// fn test_multiple_crossvalidate_mixed_attributes() ? {
// 	mut opts := Options{
// 		datafile_path: 'datasets/2_class_developer.tab'
// 		settingsfile_path: 'tempfolder_oxford/2_class_big.opts'
// 		append_settings_flag: true
// 		command: 'explore'
// 		concurrency_flag: true
// 	}

// 	mut disp := DisplaySettings{
// 		expanded_flag: false
// 		verbose_flag: false
// 		show_flag: false
// 	}
// 	// opts.number_of_attributes = [11,13]
// 	// opts.bins = [1,10]
// 	mut ds := load_file(opts.datafile_path)
// 	ft := [false, true]
// 	for pf in ft {
// 		opts.uniform_bins = pf
// 		for wr in [false, true] {
// 			opts.weight_ranking_flag = wr
// 			for w in [false, true] {
// 				opts.weighting_flag = w
// 				er := explore(ds, opts, disp)
// 			}
// 		}
// 	}
// 	// display_file(opts.settingsfile_path, opts)
// 	opts.append_settings_flag = false
// 	opts.command = 'cross'
// 	opts.multiple_classify_options_file_path = opts.settingsfile_path
// 	opts.multiple_flag = true
// 	// for ci in [[3],[4],[6],[14],[3,4],[3,6],[4,6],[3,4,6],[3,4,6,14]] {
// 	opts0 := Options{
// 		bins: [1, 7]
// 		number_of_attributes: [1]
// 	}
// 	opts3 := Options{
// 		bins: [1, 3]
// 		number_of_attributes: [3]
// 	}
// 	opts15 := Options{
// 		bins: [1, 3]
// 		number_of_attributes: [1]
// 		weight_ranking_flag: true
// 	}
// 	opts16 := Options{
// 		bins: [7, 7]
// 		number_of_attributes: [1]
// 	}
// 	opts03 := opts15
// 	opts031516 := Options{
// 		bins: [1, 7]
// 		number_of_attributes: [1]
// 	}
// 	result0 := cross_validate(ds, opts0)
// 	for ci in [[0], [3], [15], [16], [0, 3], [0, 3, 15, 16]] {
// 		opts.classifier_indices = ci
// 		for ma in ft {
// 			opts.break_on_all_flag = ma
// 			for mc in ft {
// 				opts.combined_radii_flag = mc
// 				for t in ft {
// 					opts.total_nn_counts_flag = t

// 					match ci {
// 						[0] {
// 							assert cross_validate(ds, opts, disp).confusion_matrix_map == cross_validate(ds,
// 								opts0).confusion_matrix_map
// 						}
// 						[3] {
// 							assert cross_validate(ds, opts, disp).confusion_matrix_map == cross_validate(ds,
// 								opts3).confusion_matrix_map
// 						}
// 						[15] {
// 							assert cross_validate(ds, opts, disp).confusion_matrix_map == cross_validate(ds,
// 								opts15).confusion_matrix_map
// 						}
// 						[16] {
// 							assert cross_validate(ds, opts, disp).confusion_matrix_map == cross_validate(ds,
// 								opts16).confusion_matrix_map
// 						}
// 						[0, 3] {
// 							match true {
// 								!opts.combined_radii_flag && !opts.total_nn_counts_flag {
// 									assert cross_validate(ds, opts, disp).confusion_matrix_map == cross_validate(ds,
// 										opts15).confusion_matrix_map
// 								}
// 								else {
// 									assert cross_validate(ds, opts, disp).confusion_matrix_map == cross_validate(ds,
// 										opts0).confusion_matrix_map
// 								}
// 							}
// 						}
// 						else {}
// 					}
// 				}
// 			}
// 		}
// 	}
// }

// fn test_multiple_crossvalidate_only_discrete_attributes() ? {
// 	mut opts := Options{
// 		datafile_path: 'datasets/breast-cancer-wisconsin-disc.tab'
// 		settingsfile_path: 'tempfolder_oxford/breast-cancer-wisconsin-disc.opts'
// 		append_settings_flag: true
// 		command: 'explore'
// 		concurrency_flag: true
// 	}

// 	mut disp := DisplaySettings{
// 		expanded_flag: true
// 		verbose_flag: false
// 	}

// 	mut ds := load_file(opts.datafile_path)
// 	ft := [false, true]
// 	for pf in ft {
// 		opts.purge_flag = pf
// 		for wr in [false, true] {
// 			opts.weight_ranking_flag = wr
// 			for w in [false, true] {
// 				opts.weighting_flag = w
// 				er := explore(ds, opts, disp)
// 			}
// 		}
// 	}
// 	display_file(opts.settingsfile_path, opts)
// 	opts.append_settings_flag = false
// 	opts.command = 'cross'
// 	opts.classifier_indices = [3, 4, 6, 14]
// 	opts.multiple_classify_options_file_path = opts.settingsfile_path
// 	opts.multiple_flag = true
// 	// for ci in [[3],[4],[6],[14],[3,4],[3,6],[4,6],[3,4,6],[3,4,6,14]] {
// 	opts.classifier_indices = [6,14,3,11,23,31]

// 		for ma in ft {
// 			opts.break_on_all_flag = ma
// 			for mc in ft {
// 				opts.combined_radii_flag = mc
// 				for t in ft {
// 					opts.total_nn_counts_flag = t
// 				}
// 				cross_validate(ds, opts, disp)
// 			}
// 		}

// 	opts.command = 'cross'
// 	ds = load_file(opts.datafile_path)
// 	opts.number_of_attributes = [7]
// 	mut result := cross_validate(ds, opts, disp)
// 	opts.multiple_flag = true
// 	opts.multiple_classify_options_file_path = opts.settingsfile_path
// 	opts.classifier_indices = [2]
// 	assert cross_validate(ds, opts, disp).confusion_matrix_map == {
// 		'benign':    {
// 			'benign':    445.0
// 			'malignant': 13.0
// 		}
// 		'malignant': {
// 			'benign':    16.0
// 			'malignant': 225.0
// 		}
// 	}
// 	opts.classifier_indices = [3]
// 	assert cross_validate(ds, opts, disp).confusion_matrix_map == {
// 		'benign':    {
// 			'benign':    447.0
// 			'malignant': 11.0
// 		}
// 		'malignant': {
// 			'benign':    24.0
// 			'malignant': 217.0
// 		}
// 	}
// 	opts.classifier_indices = [2, 3]
// 	assert cross_validate(ds, opts, disp).confusion_matrix_map == {
// 		'benign':    {
// 			'benign':    446.0
// 			'malignant': 12.0
// 		}
// 		'malignant': {
// 			'benign':    22.0
// 			'malignant': 219.0
// 		}
// 	}
// }

// fn test_multiple_crossvalidate_mixed_attributes() ? {
// 	mut opts := Options{
// 		datafile_path: 'datasets/anneal.tab'
// 		settingsfile_path: 'tempfolder_oxford/anneal.opts'
// 		append_settings_flag: true
// 		command: 'explore'
// 		concurrency_flag: true
// 	}

// 	mut disp := DisplaySettings{
// 		expanded_flag: false
// 		verbose_flag: false
// 		show_flag: true
// 	}
// 	opts.number_of_attributes = [11,13]
// 	opts.bins = [1,10]
// 	mut ds := load_file(opts.datafile_path)
// 	ft := [false, true]
// 	for pf in ft {
// 		opts.uniform_bins = pf
// 		for wr in [false, true] {
// 			opts.weight_ranking_flag = wr
// 			for w in [false, true] {
// 				opts.weighting_flag = w
// 				er := explore(ds, opts, disp)
// 			}
// 		}
// 	}
// 	display_file(opts.settingsfile_path, opts)
// 	opts.append_settings_flag = false
// 	opts.command = 'cross'
// 	opts.classifier_indices = [3, 4, 6, 14]
// 	opts.multiple_classify_options_file_path = opts.settingsfile_path
// 	opts.multiple_flag = true
// 	// for ci in [[3],[4],[6],[14],[3,4],[3,6],[4,6],[3,4,6],[3,4,6,14]] {
// 	for ci in [[3, 11, 4, 5, 6, 14]] {
// 		opts.classifier_indices = ci
// 		for ma in ft {
// 			opts.break_on_all_flag = ma
// 			for mc in ft {
// 				opts.combined_radii_flag = mc
// 				for t in ft {
// 					opts.total_nn_counts_flag = t
// 				}
// 				cross_validate(ds, opts, disp)
// 			}
// 		}
// 	}
// 	opts.command = 'cross'
// 	ds = load_file(opts.datafile_path)
// 	opts.number_of_attributes = [7]
// 	mut result := cross_validate(ds, opts, disp)
// 	opts.multiple_flag = true
// 	opts.multiple_classify_options_file_path = opts.settingsfile_path
// 	opts.classifier_indices = [2]
// 	assert cross_validate(ds, opts, disp).confusion_matrix_map == {
// 		'benign':    {
// 			'benign':    445.0
// 			'malignant': 13.0
// 		}
// 		'malignant': {
// 			'benign':    16.0
// 			'malignant': 225.0
// 		}
// 	}
// 	opts.classifier_indices = [3]
// 	assert cross_validate(ds, opts, disp).confusion_matrix_map == {
// 		'benign':    {
// 			'benign':    447.0
// 			'malignant': 11.0
// 		}
// 		'malignant': {
// 			'benign':    24.0
// 			'malignant': 217.0
// 		}
// 	}
// 	opts.classifier_indices = [2, 3]
// 	assert cross_validate(ds, opts, disp).confusion_matrix_map == {
// 		'benign':    {
// 			'benign':    446.0
// 			'malignant': 12.0
// 		}
// 		'malignant': {
// 			'benign':    22.0
// 			'malignant': 219.0
// 		}
// 	}
// }
