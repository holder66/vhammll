// ox_mets_test.v

module vhammll

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_ox_mets') {
		os.rmdir_all('tempfolders/tempfolder_ox_mets')!
	}
	os.mkdir_all('tempfolders/tempfolder_ox_mets')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_ox_mets')!
}

// fn test_explore_ox_mets_to_create_settings_file() {
// 	home_dir := os.home_dir()
// 	mut opts := Options{
// 		command: 'explore'
// 		// concurrency_flag:     true
// 		datafile_path:        os.join_path(home_dir, 'metabolomics', 'mets-train.tab')
// 		number_of_attributes: [1, 12]
// 		bins:                 [2, 16]
// 		append_settings_flag: true
// 		explore_all_flags: true
// 		settingsfile_path: 'tempfolders/tempfolder_ox_mets/ox_mets_settings.opts'
// 		expanded_flag:     true
// 	}
// 	ds := load_file(opts.datafile_path)
// 	explore(ds, opts)
// 	optimals(opts.settingsfile_path, opts)
// }

// fn test_optimal_settings() {
// 	home_dir := os.home_dir()
// 	mut opts := Options{
// 		command:                             'cross'
// 		datafile_path:                       os.join_path(home_dir, 'metabolomics', 'mets-train.tab')
// 		multiple_classify_options_file_path: 'src/testdata/mets-purged.opts'
// 		// verbose_flag:         true
// 		multiple_flag: true
// 		expanded_flag: true
// 		// show_attributes_flag: true
// 	}
// 	ds := load_file(opts.datafile_path)
// 	optimals(opts.multiple_classify_options_file_path, opts)
// 	multiple_classifier_settings := read_multiple_opts(opts.multiple_classify_options_file_path) or {
// 				panic('read_multiple_opts failed')
// 			}
// 	println(r_b('\nVerify that classifiers 44 and 69 in the purged settings file correspond to the settings giving best balanced accuracy of 83.33%, best Matthews Correlation Coefficient of 0.751, and highest total correct inferences of 15/17;'))
// 	assert multiple_classifier_settings.len == 90
// 	assert multiple_classifier_settings[44].correct_counts == [11,4]
// 	assert multiple_classifier_settings[69].mcc == 0.7510676161988108
// 	println(r_b('and verify that classifier 42 in the purged settings file gives the highest specificity of 1.0, and classifier 53 the highest sensitivity of 0.833'))
// 	assert multiple_classifier_settings[42].incorrect_counts == [0,3]
// 	assert multiple_classifier_settings[53].correct_counts == [8,5]
// 	for i in [44,69,42,53] {
// 		opts.classifier_indices = [i]
// 		// cross_validate(ds, opts)
// 	}
// }

fn test_multiple_crossvalidate_of_ox_mets() {
	home_dir := os.home_dir()
	mut opts := Options{
		command:                             'cross'
		datafile_path:                       os.join_path(home_dir, 'metabolomics', 'mets-train.tab')
		multiple_classify_options_file_path: 'src/testdata/mets-purged.opts'
		multiple_flag:                       true
		// expanded_flag: true
		// show_attributes_flag: true
	}
	ds := load_file(opts.datafile_path)
	println(r_b('\nTest using multiple classifiers. We can cycle through all possibilities for the multiple classifier flags, stopping when correct_counts is [11,5]. This gives the best result, with a Matthews Correlation Coefficient of 0.874'))
	ft := [false, true]
	mut result := CrossVerifyResult{}
	outer: for ci in [[42], [44], [61], [42,44],[42,61],[44,61],[42, 44, 61]] {
		opts.classifier_indices = ci
		for ma in ft {
			opts.break_on_all_flag = ma
			for mc in ft {
				opts.combined_radii_flag = mc
				for tnc in ft {
					opts.total_nn_counts_flag = tnc
					for cmp in ft {
						opts.class_missing_purge_flag = cmp
						opts.expanded_flag = false
						if cross_validate(ds, opts).correct_counts == [11, 5] {
							println('Classifiers: ${ci}; break_on_all_flag: $ma     combined_radii_flag: $mc      total_nn_counts_flag: $tnc     class_missing_purge_flag: $cmp')
							// break outer
						}
					}
				}
			}
		}
	}
}

fn test_ox_mets_multi_verify() {
	mut result := CrossVerifyResult{}
	println(r_b('\nWe can apply the classifier settings from previous to train classifiers on'))
	println(r_b('the entire mets-train dataset of 17 cases, and then classify the 7 cases in the'))
	println(r_b('independent mets-test dataset:'))
	home_dir := os.home_dir()
	ft := [false, true]
	mut opts := Options{
		command:                             'verify'
		datafile_path:                       os.join_path(home_dir, 'metabolomics', 'mets-train.tab')
		testfile_path:                       os.join_path(home_dir, 'metabolomics', 'mets-test.tab')
		multiple_classify_options_file_path: 'src/testdata/mets-purged.opts'
		multiple_flag:                       true
		// combined_radii_flag:                 false
		// break_on_all_flag: true
		// expanded_flag:                       true
		show_attributes_flag: true
	}
	for ci in [[42], [44], [61], [42,44],[42,61],[44,61],[42, 44, 61]] {
		opts.expanded_flag = false
		opts.classifier_indices = ci
		for ma in ft {
			opts.break_on_all_flag = ma
			for cmp in ft {
				opts.class_missing_purge_flag = cmp
				if multi_verify(opts).correct_counts == [4,1] {
				opts.expanded_flag = true
				result = multi_verify(opts)
			}
		}
		
		}
	}

	println(r_b('\nFor the classifier giving the best balanced accuracy on the training set,'))
	println(r_b('we get a sensitivity of 0.5, and specificity of 0.8, on the test set'))
}
