// ox2_cancers_only_test.v

module vhammll

import os
// import arrays
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_ox2_cancers_only') {
		os.rmdir_all('tempfolders/tempfolder_ox2_cancers_only')!
	}
	os.mkdir_all('tempfolders/tempfolder_ox2_cancers_only')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_ox2_cancers_only')!
}

fn test_explore_ox_mets_to_create_settings_file() {
	println(r_b('\nDo an explore using cross-validation on the ~/mets/ox2_mets_train.tsv dataset, over all combinations of settings (with the traverse_all_flags flag set to true). Save the settings in a temporary settings file.'))
	home_dir := os.home_dir()
	temp_file := 'tempfolders/tempfolder_ox2_cancers_only/ox2.opts'
	temp_purged := 'tempfolders/tempfolder_ox2_cancers_only/ox2-purged.opts'
	saved_file := 'src/testdata/ox2-purged.opts'
	mut opts := Options{
		command: 'explore'
		// concurrency_flag:     true
		datafile_path:        os.join_path(home_dir, 'mets', 'ox2_mets_train.tsv')
		number_of_attributes: [1, 10]
		bins:                 [2, 14]
		append_settings_flag: true
		traverse_all_flags:   true
		settingsfile_path:    temp_file
		expanded_flag:        true
		generate_roc_flag:    true
		positive_class:       'Mets'
	}
	ds := load_file(opts.datafile_path, opts.LoadOptions)
	explore(ds, opts)
	println(r_b('\nShow the optimal settings (after purging for duplicate settings), and save the purges settings to a temporary file:'))
	opts.purge_flag = true
	opts.outputfile_path = temp_purged
	optimals(opts.settingsfile_path, opts)
	println(r_b('\nVerify that the temporary purged settings file is identical to settings file ${saved_file}. If the latter file does not exist, copy the temporary file to that path.'))
	if os.is_file(saved_file) {
		saved := os.read_file(saved_file)!
		temp := os.read_file(temp_purged)!
		// assert saved == temp
	} else {
		os.cp(temp_purged, saved_file)!
	}
}

// fn test_optimal_settings() {
// 	home_dir := os.home_dir()
// 	mut opts := Options{
// 		command:                             'cross'
// 		datafile_path:                       os.join_path(home_dir, 'mets', 'all_mets_v_other_odds.tsv')
// 		multiple_classify_options_file_path: 'src/testdata/ox2-purged.opts'
// 		// verbose_flag:         true
// 		multiple_flag: true
// 		expanded_flag: true
// 		// show_attributes_flag: true
// 	}
// 	ds := load_file(opts.datafile_path)
// 	optimals(opts.multiple_classify_options_file_path, opts)
// 	multiple_classifier_settings := read_multiple_opts(opts.multiple_classify_options_file_path) or {
// 		panic('read_multiple_opts failed')
// 	}
// 	println(r_b('\nVerify that classifiers 53 and 89 in the purged settings file correspond to the settings giving best balanced accuracy of 82.94%.'))
// 	assert multiple_classifier_settings.len == 98
// 	assert multiple_classifier_settings[53].correct_counts == [137,10]
// 	assert multiple_classifier_settings[89].bal_acc == 82.94205794205794
// 	println(r_b('\nVerify that classifier 61 in the purged settings file correspond to the settings giving best Matthews Correlation Coefficient of 0.605, and highest total correct inferences of 159/167;'))
// 	assert multiple_classifier_settings[61].correct_counts == [154, 5]
// 	assert multiple_classifier_settings[61].incorrect_counts == [0,8]
// 	assert multiple_classifier_settings[61].mcc == 0.6046668771221878

// 	println(r_b('and verify that classifier 61 in the purged settings file gives the highest specificity of 1.0, and classifier 73 the highest sensitivity of 1.0'))
// 	assert multiple_classifier_settings[61].spec == 1.0
// 	assert multiple_classifier_settings[73].sens == 1.0
// 	for i in [53,89,61,73] {
// 		opts.classifiers = [i]
// 		cross_validate(ds, opts)
// 	}
// }

// fn test_multiple_crossvalidate_of_ox2() {
// 	home_dir := os.home_dir()
// 	saved_file := 'src/testdata/ox2-purged.opts'
// 	mut opts := Options{
// 		command:                             'cross'
// 		datafile_path:                       os.join_path(home_dir, 'mets', 'all_mets_v_other_odds.tsv')
// 		multiple_classify_options_file_path: saved_file
// 		multiple_flag:                       true
// 	}
// 	ds := load_file(opts.datafile_path)
// 	println(r_b('\nTest using multiple classifiers. We can cycle through all possibilities for the multiple classifier flags.'))
// 	ft := [false, true]
// 	mut result := CrossVerifyResult{}
// 	// outer: for ci in [[61,73,97],[6,61,73,97],[53,61,73,97]] {
// 	// 	opts.classifiers = ci
// 	// 	for ma in ft {
// 	// 		opts.break_on_all_flag = ma
// 	// 		for mc in ft {
// 	// 			opts.combined_radii_flag = mc
// 	// 			for tnc in ft {
// 	// 				opts.total_nn_counts_flag = tnc
// 	// 				for cmp in ft {
// 	// 					opts.class_missing_purge_flag = cmp
// 	// 					opts.expanded_flag = false
// 	// 					// if cross_validate(ds, opts).correct_counts == [11, 5] {
// 	// 					// 	assert ci == [42, 44, 61]
// 	// 					dump(cross_validate(ds, opts).correct_counts)
// 	// 						println('Classifiers: ${ci}; break_on_all_flag: ${ma}     combined_radii_flag: ${mc}      total_nn_counts_flag: ${tnc}     class_missing_purge_flag: ${cmp}')
// 	// 						// break outer
// 	// 					// }
// 	// 				}
// 	// 			}
// 	// 		}
// 	// 	}
// 	// }
// 	println(r_b('\nA manual inspection of the results of the previous exercise shows that there are 6 sets of settings producing an optimum "area under the ROC curve"'))
// 	outer2: for ci in [[19,61,73],[6,61,73,97],[53,61,73],[53,61,73,97],[61,73]] {
// 		opts.classifiers = ci
// 			opts.break_on_all_flag = false
// 				opts.combined_radii_flag = true
// 					opts.total_nn_counts_flag = false

// 						opts.class_missing_purge_flag = false
// 						opts.expanded_flag = false
// 						result = cross_validate(ds, opts)
// 						println('${result.sens:-4.3f}   ${(1.0 - result.spec):-4.3f} ')

// 	}
// }

// fn test_ox2_multi_verify() {
// 	mut result := CrossVerifyResult{}
// 	println(r_b('\nWe can apply the classifier settings from previous to train classifiers on'))
// 	println(r_b('the entire all_mets_v_other_odds.tsv dataset of  cases, and then classify the  cases in the'))
// 	println(r_b('independent all_mets_v_other_evens.tsv dataset:'))
// 	home_dir := os.home_dir()

// 	ft := [false, true]
// 	mut opts := Options{
// 		command:                             'verify'
// 		datafile_path:                       os.join_path(home_dir, 'mets', 'all_mets_v_other_odds.tsv')
// 		testfile_path:                       os.join_path(home_dir, 'mets', 'all_mets_v_other_evens.tsv')
// 		multiple_classify_options_file_path: 'src/testdata/ox2-purged.opts'
// 		multiple_flag:                       true
// 		// combined_radii_flag:                 false
// 		// break_on_all_flag: true
// 		// expanded_flag:                       true
// 		show_attributes_flag: true
// 	}
// 	for ci in [[19, 61, 73], [6, 61, 73, 97], [53, 61, 73], [53, 61, 73, 97],
// 		[61, 73]] {
// 		// opts.expanded_flag = true
// 		opts.classifiers = ci
// 		opts.break_on_all_flag = true
// 		result = multi_verify(opts)
// 		println('${result.sens:-4.3f}   ${(1.0 - result.spec):-4.3f} ')
// 	}
// 	// opts.expanded_flag = true
// 	// opts.classifiers = [44]
// 	// result = multi_verify(opts)
// 	// assert result.sens == 0.5
// 	// assert result.spec == 0.8
// 	// println(r_b('\nFor the classifier giving the best balanced accuracy on the training set,'))
// 	// println(r_b('we get a sensitivity of 0.5, and specificity of 0.8, on the test set'))
// }
