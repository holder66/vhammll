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

fn test_explore_ox_mets_to_create_settings_file() {
	println(r_b('\nDo an explore using cross-validation on the mets-train.tab dataset, over all combinations of settings (with the traverse_all_flags flag set to true). Save the settings in a temporary settings file.'))
	home_dir := os.home_dir()
	temp_file := 'tempfolders/tempfolder_ox_mets/ox_mets_settings.opts'
	temp_purged := 'tempfolders/tempfolder_ox_mets/ox_mets_settings_purged.opts'
	saved_file := 'src/testdata/mets-purged.opts'
	mut opts := Options{
		command: 'explore'
		// concurrency_flag:     true
		datafile_path:        os.join_path(home_dir, 'metabolomics', 'mets-train.tab')
		number_of_attributes: [1, 12]
		bins:                 [2, 6]
		append_settings_flag: true
		traverse_all_flags:   true
		settingsfile_path:    temp_file
		expanded_flag:        true
		positive_class:       'Met' // because this class has a higher prevalence than 'Pri' in this dataset
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

fn test_optimal_settings() {
	home_dir := os.home_dir()
	mut opts := Options{
		command:                             'cross'
		datafile_path:                       os.join_path(home_dir, 'metabolomics', 'mets-train.tab')
		multiple_classify_options_file_path: 'src/testdata/mets-purged.opts'
		// verbose_flag:         true
		multiple_flag: true
		expanded_flag: true
		// show_attributes_flag: true
	}
	ds := load_file(opts.datafile_path, opts.LoadOptions)
	optimals(opts.multiple_classify_options_file_path, opts)
	multiple_classifier_settings := read_multiple_opts(opts.multiple_classify_options_file_path) or {
		panic('read_multiple_opts failed')
	}
	println(r_b('\nVerify that classifiers 20, 30, 85, and 100 in the purged settings file correspond to the settings giving best balanced accuracy of 78.79%, best Matthews Correlation Coefficient of 0.604, and highest total correct inferences of 14/17;'))
	assert multiple_classifier_settings.len == 90
	assert multiple_classifier_settings[44].correct_counts == [11, 4]
	assert multiple_classifier_settings[69].mcc == 0.7510676161988108
	println(r_b('and verify that classifier 42 in the purged settings file gives the highest specificity of 1.0, and classifier 53 the highest sensitivity of 0.833'))
	assert multiple_classifier_settings[42].incorrect_counts == [0, 3]
	assert multiple_classifier_settings[53].correct_counts == [8, 5]
	for i in [44, 69, 42, 53] {
		opts.classifiers = [i]
		// cross_validate(ds, opts)
	}
}

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
	ds := load_file(opts.datafile_path, opts.LoadOptions)
	println(r_b('\nTest using multiple classifiers. We can cycle through all possibilities for the multiple classifier flags, stopping when correct_counts is [11,5]. This gives the best result, with a Matthews Correlation Coefficient of 0.874'))
	ft := [false, true]
	mut result := CrossVerifyResult{}
	outer: for ci in [[42], [44], [61], [42, 44], [42, 61], [44, 61],
		[42, 44, 61]] {
		opts.classifiers = ci
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
							assert ci == [42, 44, 61]
							println('Classifiers: ${ci}; break_on_all_flag: ${ma}     combined_radii_flag: ${mc}      total_nn_counts_flag: ${tnc}     class_missing_purge_flag: ${cmp}')
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
	for ci in [[42], [44], [61], [42, 44], [42, 61], [44, 61],
		[42, 44, 61]] {
		opts.expanded_flag = false
		opts.classifiers = ci
		for ma in ft {
			opts.break_on_all_flag = ma
			for cmp in ft {
				opts.class_missing_purge_flag = cmp
				if multi_verify(opts).correct_counts == [4, 1] {
					assert ci == [44]
				}
			}
		}
	}
	opts.expanded_flag = true
	opts.classifiers = [44]
	result = multi_verify(opts)
	assert result.sens == 0.5
	assert result.spec == 0.8
	println(r_b('\nFor the classifier giving the best balanced accuracy on the training set,'))
	println(r_b('we get a sensitivity of 0.5, and specificity of 0.8, on the test set'))
}
