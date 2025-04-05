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

fn test_multiple_crossvalidate() ? {
	mut opts := Options{
		// folds: 3
		break_on_all_flag:   false
		combined_radii_flag: false
		weighting_flag:      false
		// total_nn_counts_flag: true
		command:          'explore'
		concurrency_flag: false
	}
	mut result := CrossVerifyResult{}
	// create an .opts file with settings for multiple classifiers
	opts.datafile_path = 'datasets/developer.tab'
	opts.settingsfile_path = 'tempfolders/tempfolder_multi_cross/3_class.opts'
	opts.append_settings_flag = true
	opts.weight_ranking_flag = true
	// opts.expanded_flag = true
	mut er := explore(opts)
	// opts.show_attributes_flag = true
	if !os.is_file('src/testdata/3_class.opts') {
		os.cp(opts.settingsfile_path, 'src/testdata/3_class.opts')!
	}
	// display_file(opts.settingsfile_path, opts)
	// display_file('src/testdata/3_class.opts', opts)
	// do an ordinary crossvalidation
	opts.command = 'cross'
	// opts.expanded_flag = true
	opts.number_of_attributes = [1]
	opts.bins = [1, 3]
	result = cross_validate(opts)
	// now do a multiple classifier crossvalidation
	opts.multiple_flag = true
	// opts.show_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	display_file(opts.multiple_classify_options_file_path)
	opts.classifiers = [7]
	// cross_validate(opts)
	assert cross_validate(opts).confusion_matrix_map == {
		'm': {
			'm': 8.0
			'f': 0.0
			'X': 0.0
		}
		'f': {
			'm': 0.0
			'f': 3.0
			'X': 0.0
		}
		'X': {
			'm': 0.0
			'f': 0.0
			'X': 2.0
		}
	}
	opts.classifiers = [3]
	assert cross_validate(opts).correct_counts == [8, 0, 0]
	opts.traverse_all_flags = true
	opts.expanded_flag = false
	opts.classifiers = [0, 1, 2]
	assert cross_validate(opts).correct_counts == [8, 3, 2]
}

fn test_multiple_crossvalidate_mixed_attributes_developer() ? {
	mut opts := Options{
		datafile_path:        'datasets/2_class_developer.tab'
		settingsfile_path:    'tempfolders/tempfolder_multi_cross/2_class_big.opts'
		append_settings_flag: true
		command:              'explore'
		// concurrency_flag:     true
		// expanded_flag:        true
		verbose_flag:       false
		show_flag:          false
		traverse_all_flags: true
		bins:               [2, 7]
	}
	er := explore(opts)
	opt_res := optimals(opts.settingsfile_path, purge_flag: true)
	assert opt_res.RocData.classifiers == ['4', '0', '31', '38']
	assert opt_res.mcc_max_classifiers == [38, 68, 78, 118, 148, 158]
	opts.append_settings_flag = false
	opts.command = 'cross'
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.multiple_flag = true
	opts.classifiers = [31, 38]
	result := cross_validate(opts)
	assert result.correct_counts == [8, 3]
}

fn test_multiple_crossvalidate_only_discrete_attributes() ? {
	// expanded_flag := '-e'
	expanded_flag := ''
	mut datafile := 'datasets/breast-cancer-wisconsin-disc.tab'
	mut settingsfile := 'tempfolders/tempfolder_multi_cross/breast-cancer-wisconsin-disc.opts'
	mut resultfile := 'tempfolders/tempfolder_multi_cross/resultfile'
	cli(args: 'cross -a 9 -w -ms ${settingsfile} ${expanded_flag} ${datafile}'.split(' '))!
	cli(args: 'cross -a 2 -w -ms ${settingsfile} ${expanded_flag} ${datafile}'.split(' '))!
	cli(args: 'cross -a 2 -w -wr -ms ${settingsfile} ${expanded_flag} ${datafile}'.split(' '))!
	cli(args: 'cross -a 6 -w -bp -p -ms ${settingsfile} ${expanded_flag} ${datafile}'.split(' '))!
	// cli(args: 'cross -m# 0,1,2,3 -m ${settingsfile} ${expanded_flag} ${datafile}'.split(' '))!
	assert cross_validate(
		multiple_flag:                       true
		multiple_classify_options_file_path: settingsfile
		classifiers:                         [
			0,
			1,
			2,
			3,
		]
		datafile_path:                       datafile
	).correct_counts == [442, 230]
}

fn test_multiple_crossvalidate_mixed_attributes() ? {
	mut opts := Options{
		datafile_path:        'datasets/anneal.tab'
		settingsfile_path:    'tempfolders/tempfolder_multi_cross/anneal.opts'
		append_settings_flag: true
		command:              'explore'
		concurrency_flag:     true
		expanded_flag:        false
		verbose_flag:         false
		// show_flag:            true
	}
	opts.number_of_attributes = [11, 13]
	opts.bins = [1, 10]
	mut ds := load_file(opts.datafile_path)
	ft := [false, true]
	for pf in ft {
		opts.uniform_bins = pf
		for wr in [false, true] {
			opts.weight_ranking_flag = wr
			for w in [false, true] {
				opts.weighting_flag = w
				er := explore(opts)
			}
		}
	}
	// opts.show_attributes_flag = true
	display_file(opts.settingsfile_path, opts)
	opts.append_settings_flag = false
	opts.command = 'cross'
	opts.classifiers = [3, 4, 6, 14]
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.multiple_flag = true
	// for ci in [[3],[4],[6],[14],[3,4],[3,6],[4,6],[3,4,6],[3,4,6,14]] {
	for ci in [[3, 11, 4, 5, 6, 14]] {
		opts.classifiers = ci
		for ma in ft {
			opts.break_on_all_flag = ma
			for mc in ft {
				opts.combined_radii_flag = mc
				// for t in ft {
				// 	opts.total_nn_counts_flag = t
				// }
				cross_validate(opts)
			}
		}
	}
	opts.command = 'cross'
	ds = load_file(opts.datafile_path)
	opts.number_of_attributes = [7]
	mut result := cross_validate(opts)
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.classifiers = [2]
	assert cross_validate(opts).confusion_matrix_map == {
		'3': {
			'3': 679.0
			'U': 2.0
			'1': 0.0
			'5': 0.0
			'2': 3.0
		}
		'U': {
			'3': 2.0
			'U': 38.0
			'1': 0.0
			'5': 0.0
			'2': 0.0
		}
		'1': {
			'3': 1.0
			'U': 0.0
			'1': 7.0
			'5': 0.0
			'2': 0.0
		}
		'5': {
			'3': 0.0
			'U': 0.0
			'1': 0.0
			'5': 67.0
			'2': 0.0
		}
		'2': {
			'3': 0.0
			'U': 0.0
			'1': 0.0
			'5': 0.0
			'2': 99.0
		}
	}
	opts.classifiers = [3]
	assert cross_validate(opts).confusion_matrix_map == {
		'3': {
			'3': 679.0
			'U': 2.0
			'1': 0.0
			'5': 0.0
			'2': 3.0
		}
		'U': {
			'3': 2.0
			'U': 38.0
			'1': 0.0
			'5': 0.0
			'2': 0.0
		}
		'1': {
			'3': 1.0
			'U': 0.0
			'1': 7.0
			'5': 0.0
			'2': 0.0
		}
		'5': {
			'3': 1.0
			'U': 0.0
			'1': 0.0
			'5': 66.0
			'2': 0.0
		}
		'2': {
			'3': 0.0
			'U': 0.0
			'1': 0.0
			'5': 0.0
			'2': 99.0
		}
	}
	opts.classifiers = [2, 3]
	assert cross_validate(opts).confusion_matrix_map == {
		'3': {
			'3': 679.0
			'U': 2.0
			'1': 0.0
			'5': 0.0
			'2': 3.0
		}
		'U': {
			'3': 2.0
			'U': 38.0
			'1': 0.0
			'5': 0.0
			'2': 0.0
		}
		'1': {
			'3': 1.0
			'U': 0.0
			'1': 7.0
			'5': 0.0
			'2': 0.0
		}
		'5': {
			'3': 0.0
			'U': 0.0
			'1': 0.0
			'5': 67.0
			'2': 0.0
		}
		'2': {
			'3': 0.0
			'U': 0.0
			'1': 0.0
			'5': 0.0
			'2': 99.0
		}
	}
}
