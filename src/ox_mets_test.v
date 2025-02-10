// ox_mets_test.v

module vhammll

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolder_ox_mets') {
		os.rmdir_all('tempfolder_ox_mets')!
	}
	os.mkdir_all('tempfolder_ox_mets')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder_ox_mets')!
}

fn test_explore_ox_mets_to_create_settings_file() {
	home_dir := os.home_dir()
	mut opts := Options{
		command:              'explore'
		// concurrency_flag:     true
		datafile_path:        os.join_path(home_dir, 'metabolomics', 'mets-train.tab')
		number_of_attributes: [1, 6]
		bins:                 [2, 15]
		append_settings_flag: true

		settingsfile_path: 'tempfolder_ox_mets/ox_mets_settings.opts'
		expanded_flag: true
	}
	ds := load_file(opts.datafile_path)
	ft := [false, true]
	for pf in ft {
		opts.purge_flag = pf
		for ub in ft {
			opts.uniform_bins = ub
			for wr in [false, true] {
				opts.weight_ranking_flag = wr
				for w in [false, true] {
					opts.weighting_flag = w
					explore(ds, opts)
				}
			}
		}
	}
	optimals(opts.settingsfile_path, opts)
}


fn test_multiple_crossvalidate_of_ox_mets() {
	home_dir := os.home_dir()
	mut opts := Options{
		command:                             'cross'
		datafile_path:                       os.join_path(home_dir, 'metabolomics', 'mets-train.tab')
		multiple_classify_options_file_path: '/Users/henryolders/use_vhammll/vhammll/src/testdata/ox_mets_settings.opts'
		// verbose_flag:         true
		multiple_flag: true
		expanded_flag: true
		// show_attributes_flag: true
	}
	ds := load_file(opts.datafile_path)
	// use a single classifier in a multi-classifier cross-validation
	println(r_b('\nTest using multiple classifiers. We can cycle through all possibilities for the multiple classifier flags:'))
	ft := [false, true]

	for ci in [[65,27,67]] {
		opts.classifier_indices = ci
	for ma in ft {
		opts.break_on_all_flag = ma
		for mc in ft {
			opts.combined_radii_flag = mc
			for tnc in ft {
				opts.total_nn_counts_flag = tnc
				for cmp in ft {
					dump(opts.classifier_indices)
					result := cross_validate(ds, opts)
					// assert cross_validate(ds, opts).mcc == 0.5367394391967351
					// assert cross_validate(ds, opts).confusion_matrix_map in [
					// 	{
					// 		'Met': {
					// 			'Met': 8.0
					// 			'Pri': 3.0
					// 		}
					// 		'Pri': {
					// 			'Met': 1.0
					// 			'Pri': 5.0
					// 		}
					// 	},
					// 	{
					// 		'Met': {
					// 			'Met': 8.0
					// 			'Pri': 2.0
					// 		}
					// 		'Pri': {
					// 			'Met': 1.0
					// 			'Pri': 5.0
					// 		}
					// 	},
					// ]
				}
			}
		}
	}
}
	with classifiers 5,8,46, we get MCC 0.633 with all flags false; also with 8,20
	println(r_b('\nIndependently of what flags are used, we always get an MCC of 0.537.'))
	println(r_b('\nWith classifiers 5,8,46 or classifiers 8,20 we get and MCC of 0.633 when all flags are false.'))
	opts.break_on_all_flag = false
	opts.combined_radii_flag = false
	opts.total_nn_counts_flag = false
	opts.class_missing_purge_flag = false
	opts.classifier_indices = [5,8,46]
	assert cross_validate(ds, opts).mcc == 0.6326266278117372
	opts.classifier_indices = [8,20]
	assert cross_validate(ds, opts).mcc == 0.6326266278117372
}

fn test_ox_mets_multi_verify() {
	println(r_b('\nWe can apply the classifier settings from previous to train classifiers on'))
	println(r_b('the entire mets-train dataset of 17 cases, and then classify the 7 cases in the'))
	println(r_b('independent mets-test dataset:'))
	home_dir := os.home_dir()
	mut opts := Options{
		command:                             'verify'
		datafile_path:                       os.join_path(home_dir, 'metabolomics', 'mets-train.tab')
		testfile_path:                       os.join_path(home_dir, 'metabolomics', 'mets-test.tab')
		multiple_classify_options_file_path: '/Users/henryolders/use_vhammll/vhammll/src/testdata/ox_mets_settings.opts'
		multiple_flag:                       true
		classifier_indices:                  [5]
		combined_radii_flag:                 false
		expanded_flag:                       true
		show_attributes_flag:                false
	}

	mut result := multi_verify(opts)
	println(r_b('\nWhen using just the first 3 classifiers (with which we achieved maximum sensitivity,'))
	println(r_b('we get a sensitivity of 0.714 on the test set:'))
	opts.classifier_indices = [8]
	result = multi_verify(opts)
	assert result.confusion_matrix_map == {
		'Met': {
			'Met': 2.0
			'Pri': 3.0
		}
		'Pri': {
			'Met': 1.0
			'Pri': 1.0
		}
	}
	opts.classifier_indices = [20]
	multi_verify(opts)
	opts.classifier_indices = [46]
	multi_verify(opts)
	opts.classifier_indices = [8, 20]
	multi_verify(opts)
	opts.classifier_indices = [5, 8, 46]
	multi_verify(opts)
}
