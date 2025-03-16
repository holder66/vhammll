// multi_cross_test.v

module vhammll

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_multi_cross') {
		os.rmdir_all('tempfolders/tempfolder_multi_cross')!
	}
	os.mkdir_all('tempfolders/tempfolder_multi_cross')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_multi_cross')!
}

// fn test_multiple_crossvalidate() ? {
// 	mut opts := Options{
// 		// folds: 3
// 		break_on_all_flag:   false
// 		combined_radii_flag: false
// 		weighting_flag:      false
// 		// total_nn_counts_flag: true
// 		command:          'explore'
// 		concurrency_flag: false
// 	}
// 	mut result := CrossVerifyResult{}
// 	// create an .opts file with settings for multiple classifiers
// 	opts.datafile_path = 'datasets/developer.tab'
// 	opts.settingsfile_path = 'tempfolders/tempfolder_multi_cross/3_class.opts'
// 	opts.append_settings_flag = true
// 	opts.weight_ranking_flag = true
// 	mut ds := load_file(opts.datafile_path)
// 	// opts.expanded_flag = true
// 	mut er := explore(ds, opts)
// 	// opts.show_attributes_flag = true
// 	if !os.is_file('src/testdata/3_class.opts') {
// 		os.cp(opts.settingsfile_path, 'src/testdata/3_class.opts')!
// 	}
// 	// display_file(opts.settingsfile_path, opts)
// 	// display_file('src/testdata/3_class.opts', opts)
// 	// do an ordinary crossvalidation
// 	opts.command = 'cross'
// 	opts.expanded_flag = true
// 	opts.number_of_attributes = [1]
// 	opts.bins = [1, 3]
// 	result = cross_validate(ds, opts)
// 	// now do a multiple classifier crossvalidation
// 	opts.multiple_flag = true
// 	// opts.show_flag = true
// 	opts.multiple_classify_options_file_path = opts.settingsfile_path
// 	display_file(opts.multiple_classify_options_file_path)
// 	opts.classifiers = [7]
// 	// cross_validate(ds, opts)
// 	assert cross_validate(ds, opts).confusion_matrix_map == {
// 		'm': {
// 			'm': 8.0
// 			'f': 0.0
// 			'X': 0.0
// 		}
// 		'f': {
// 			'm': 0.0
// 			'f': 3.0
// 			'X': 0.0
// 		}
// 		'X': {
// 			'm': 0.0
// 			'f': 0.0
// 			'X': 2.0
// 		}
// 	}
// 	opts.classifiers = [3]
// 	assert cross_validate(ds, opts).correct_counts == [8,0,0]
// 	opts.classifiers = [2, 3]
// 	assert cross_validate(ds, opts).correct_counts == [8,1,0]
// }

@[assert_continues]
fn test_multiple_crossvalidate_mixed_attributes_developer() ? {
	mut opts := Options{
		datafile_path:        'datasets/2_class_developer.tab'
		settingsfile_path:    'tempfolders/tempfolder_multi_cross/2_class_big.opts'
		append_settings_flag: true
		command:              'explore'
		concurrency_flag:     true
		expanded_flag:        true
		verbose_flag:         false
		show_flag:            false
	}
	// opts.number_of_attributes = [11,13]
	// opts.bins = [1,10]
	mut ds := load_file(opts.datafile_path)
	ft := [false, true]
	for pf in ft {
		opts.uniform_bins = pf
		for wr in [false, true] {
			opts.weight_ranking_flag = wr
			for w in [false, true] {
				opts.weighting_flag = w
				dump('${pf} ${wr} ${w}')
				er := explore(ds, opts)
				// println('er in test_multiple_crossvalidate_mixed_attributes: $er')
			}
		}
	}
	// display_file(opts.settingsfile_path, opts)
	opts.append_settings_flag = false
	opts.command = 'cross'
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.multiple_flag = true
	// for ci in [[3],[4],[6],[14],[3,4],[3,6],[4,6],[3,4,6],[3,4,6,14]] {
	opts0 := Options{
		bins:                 [1, 7]
		number_of_attributes: [1]
	}
	opts3 := Options{
		bins:                 [1, 3]
		number_of_attributes: [3]
	}
	opts15 := Options{
		bins:                 [1, 3]
		number_of_attributes: [1]
		// weight_ranking_flag:  true
	}
	opts16 := Options{
		bins:                 [7, 7]
		number_of_attributes: [1]
	}
	opts03 := opts15
	opts031516 := Options{
		bins:                 [1, 7]
		number_of_attributes: [1]
	}
	result0 := cross_validate(ds, opts0)
	for ci in [[0], [3], [15], [16], [0, 3], [0, 3, 15, 16]] {
		opts.classifiers = ci
		for ma in ft {
			opts.break_on_all_flag = ma
			for mc in ft {
				opts.combined_radii_flag = mc
				for t in ft {
					opts.total_nn_counts_flag = t
					cross_validate(ds, opts)
					match ci {
						[0] {
							assert cross_validate(ds, opts).confusion_matrix_map == cross_validate(ds,
								opts0).confusion_matrix_map
						}
						[3] {
							// assert cross_validate(ds, opts).confusion_matrix_map == cross_validate(ds,
							// opts3).confusion_matrix_map
						}
						[15] {
							// assert cross_validate(ds, opts).confusion_matrix_map == cross_validate(ds,
							// opts15).confusion_matrix_map
						}
						[16] {
							// assert cross_validate(ds, opts).confusion_matrix_map == cross_validate(ds,
							// opts16).confusion_matrix_map
						}
						[0, 3] {
							// show_crossvalidation(cross_validate(ds, opts), opts)
							// match true {
							// 	!opts.combined_radii_flag && !opts.total_nn_counts_flag {
							// 		assert cross_validate(ds, opts).confusion_matrix_map == cross_validate(ds,
							// 			opts15).confusion_matrix_map
							// 	}
							// 	else {
							// 		assert cross_validate(ds, opts).confusion_matrix_map == cross_validate(ds,
							// 			opts0).confusion_matrix_map
							// 	}
							// }
						}
						else {}
					}
				}
			}
		}
	}
}

fn test_multiple_crossvalidate_only_discrete_attributes() ? {
	mut datafile :=  'datasets/breast-cancer-wisconsin-disc.tab'
	mut settingsfile := 'tempfolders/tempfolder_multi_cross/breast-cancer-wisconsin-disc.opts'
	mut resultfile := 'tempfolders/tempfolder_multi_cross/resultfile'

	mut arguments := CliOptions{
		args: ['cross', '-a', '9', '-w', '-ms', '${settingsfile}', '-e', '${datafile}']
	}
	cli(arguments)!
	arguments.args = ['cross', '-a', '2', '-w', '-ms', '${settingsfile}', '-e', '${datafile}']
	cli(arguments)!
	arguments.args = ['cross', '-a', '2', '-w', '-wr', '-bp', '-ms', '${settingsfile}', '-e',
		'${datafile}']
	cli(arguments)!
	arguments.args = ['cross', '-a', '6', '-w', '-bp', '-p', '-ms', '${settingsfile}', '-e',
		'${datafile}']
	cli(arguments)!
	opts := Options{
		datafile_path:                       datafile
		multiple_classify_options_file_path: settingsfile
		multiple_flag:                       true
		expanded_flag:                       true
		command:                             'cross'
	}
	mut result := cross_validate(load_file(datafile), opts)
	assert result.correct_counts == [442, 230]
}

// fn test_multiple_crossvalidate_mixed_attributes() ? {
// 	mut opts := Options{
// 		datafile_path:        'datasets/anneal.tab'
// 		settingsfile_path:    'tempfolders/tempfolder_multi_cross/anneal.opts'
// 		append_settings_flag: true
// 		command:              'explore'
// 		concurrency_flag:     true
// 		expanded_flag:        false
// 		verbose_flag:         false
// 		// show_flag:            true
// 	}
// 	opts.number_of_attributes = [11, 13]
// 	opts.bins = [1, 10]
// 	mut ds := load_file(opts.datafile_path)
// 	ft := [false, true]
// 	for pf in ft {
// 		opts.uniform_bins = pf
// 		for wr in [false, true] {
// 			opts.weight_ranking_flag = wr
// 			for w in [false, true] {
// 				opts.weighting_flag = w
// 				er := explore(ds, opts)
// 			}
// 		}
// 	}
// 	// opts.show_attributes_flag = true
// 	display_file(opts.settingsfile_path, opts)
// 	opts.append_settings_flag = false
// 	opts.command = 'cross'
// 	opts.classifiers = [3, 4, 6, 14]
// 	opts.multiple_classify_options_file_path = opts.settingsfile_path
// 	opts.multiple_flag = true
// 	// for ci in [[3],[4],[6],[14],[3,4],[3,6],[4,6],[3,4,6],[3,4,6,14]] {
// 	for ci in [[3, 11, 4, 5, 6, 14]] {
// 		opts.classifiers = ci
// 		for ma in ft {
// 			opts.break_on_all_flag = ma
// 			for mc in ft {
// 				opts.combined_radii_flag = mc
// 				// for t in ft {
// 				// 	opts.total_nn_counts_flag = t
// 				// }
// 				cross_validate(ds, opts)
// 			}
// 		}
// 	}
// 	opts.command = 'cross'
// 	ds = load_file(opts.datafile_path)
// 	opts.number_of_attributes = [7]
// 	mut result := cross_validate(ds, opts)
// 	opts.multiple_flag = true
// 	opts.multiple_classify_options_file_path = opts.settingsfile_path
// 	opts.classifiers = [2]
// 	assert cross_validate(ds, opts).confusion_matrix_map == {
// 		'3': {
// 			'3': 679.0
// 			'U': 2.0
// 			'1': 0.0
// 			'5': 0.0
// 			'2': 3.0
// 		}
// 		'U': {
// 			'3': 2.0
// 			'U': 38.0
// 			'1': 0.0
// 			'5': 0.0
// 			'2': 0.0
// 		}
// 		'1': {
// 			'3': 1.0
// 			'U': 0.0
// 			'1': 7.0
// 			'5': 0.0
// 			'2': 0.0
// 		}
// 		'5': {
// 			'3': 0.0
// 			'U': 0.0
// 			'1': 0.0
// 			'5': 67.0
// 			'2': 0.0
// 		}
// 		'2': {
// 			'3': 0.0
// 			'U': 0.0
// 			'1': 0.0
// 			'5': 0.0
// 			'2': 99.0
// 		}
// 	}
// 	opts.classifiers = [3]
// 	assert cross_validate(ds, opts).confusion_matrix_map == {
// 		'3': {
// 			'3': 679.0
// 			'U': 2.0
// 			'1': 0.0
// 			'5': 0.0
// 			'2': 3.0
// 		}
// 		'U': {
// 			'3': 2.0
// 			'U': 38.0
// 			'1': 0.0
// 			'5': 0.0
// 			'2': 0.0
// 		}
// 		'1': {
// 			'3': 1.0
// 			'U': 0.0
// 			'1': 7.0
// 			'5': 0.0
// 			'2': 0.0
// 		}
// 		'5': {
// 			'3': 1.0
// 			'U': 0.0
// 			'1': 0.0
// 			'5': 66.0
// 			'2': 0.0
// 		}
// 		'2': {
// 			'3': 0.0
// 			'U': 0.0
// 			'1': 0.0
// 			'5': 0.0
// 			'2': 99.0
// 		}
// 	}
// 	opts.classifiers = [2, 3]
// 	assert cross_validate(ds, opts).confusion_matrix_map == {
// 		'3': {
// 			'3': 679.0
// 			'U': 2.0
// 			'1': 0.0
// 			'5': 0.0
// 			'2': 3.0
// 		}
// 		'U': {
// 			'3': 2.0
// 			'U': 38.0
// 			'1': 0.0
// 			'5': 0.0
// 			'2': 0.0
// 		}
// 		'1': {
// 			'3': 1.0
// 			'U': 0.0
// 			'1': 7.0
// 			'5': 0.0
// 			'2': 0.0
// 		}
// 		'5': {
// 			'3': 0.0
// 			'U': 0.0
// 			'1': 0.0
// 			'5': 67.0
// 			'2': 0.0
// 		}
// 		'2': {
// 			'3': 0.0
// 			'U': 0.0
// 			'1': 0.0
// 			'5': 0.0
// 			'2': 99.0
// 		}
// 	}
// }
