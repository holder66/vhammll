// multi_cross_test.v

module vhammll

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolder_multi_cross') {
		os.rmdir_all('tempfolder_multi_cross')!
	}
	os.mkdir_all('tempfolder_multi_cross')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder_multi_cross')!
}

fn test_multiple_crossvalidate() ? {
	mut opts := Options{
		break_on_all_flag: true
		combined_radii_flag: false
		weighting_flag: false
		command: 'explore'
	}
	mut result := CrossVerifyResult{}

	opts.datafile_path = 'datasets/2_class_developer.tab'
	opts.settingsfile_path = 'tempfolder_multi_cross/2_class.opts'
	opts.append_settings_flag = true
	opts.weight_ranking_flag = true
	mut ds := load_file(opts.datafile_path)
	mut er := explore(ds, opts)
	opts.command = 'cross'
	opts.number_of_attributes = [3]
	opts.bins = [1, 3]
	result = cross_validate(ds, opts)
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.classifier_indices = [2]
	assert cross_validate(ds, opts).confusion_matrix_map == {
		'm': {
			'm': 8.0
			'f': 1.0
		}
		'f': {
			'm': 1.0
			'f': 3.0
		}
	}
	opts.classifier_indices = [3]
	assert cross_validate(ds, opts).confusion_matrix_map == result.confusion_matrix_map
	opts.classifier_indices = [2, 3]
	assert cross_validate(ds, opts).confusion_matrix_map == {
		'm': {
			'm': 8.0
			'f': 1.0
		}
		'f': {
			'm': 1.0
			'f': 3.0
		}
	}
}

fn test_multiple_crossvalidate_only_discrete_attributes() ? {
	mut opts := Options{
		datafile_path: 'datasets/breast-cancer-wisconsin-disc.tab'
		settingsfile_path: 'tempfolder_multi_cross/breast-cancer-wisconsin-disc.opts'
		append_settings_flag: true
		command: 'explore'
	}

	mut ds := load_file(opts.datafile_path)
	ft := [false, true]
	for pf in ft {
		opts.purge_flag = pf
		for wr in [false, true] {
			opts.weight_ranking_flag = wr
			for w in [false, true] {
				opts.weighting_flag = w
				er := explore(ds, opts)
			}
		}
	}
	display_file(opts.settingsfile_path, opts)
	opts.append_settings_flag = false
	opts.command = 'cross'
	opts.classifier_indices = [3, 4, 6, 14]
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.multiple_flag = true
	// for ci in [[3],[4],[6],[14],[3,4],[3,6],[4,6],[3,4,6],[3,4,6,14]] {
	for ci in [[3, 11, 4, 5, 6, 14]] {
		opts.classifier_indices = ci
		for ma in ft {
			opts.break_on_all_flag = ma
			for mc in ft {
				opts.combined_radii_flag = mc
				cross_validate(ds, opts)
			}
		}
	}
	opts.command = 'cross'
	ds = load_file(opts.datafile_path)
	opts.number_of_attributes = [7]
	mut result := cross_validate(ds, opts)
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.classifier_indices = [2]
	assert cross_validate(ds, opts).confusion_matrix_map == {
		'benign':    {
			'benign':    445.0
			'malignant': 13.0
		}
		'malignant': {
			'benign':    16.0
			'malignant': 225.0
		}
	}
	opts.classifier_indices = [3]
	assert cross_validate(ds, opts).confusion_matrix_map == {
		'benign':    {
			'benign':    447.0
			'malignant': 11.0
		}
		'malignant': {
			'benign':    24.0
			'malignant': 217.0
		}
	}
	opts.classifier_indices = [2, 3]
	assert cross_validate(ds, opts).confusion_matrix_map == {
		'benign':    {
			'benign':    446.0
			'malignant': 12.0
		}
		'malignant': {
			'benign':    22.0
			'malignant': 219.0
		}
	}
}
