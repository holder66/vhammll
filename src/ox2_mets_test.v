// ox2_test.v

module vhammll

import os
// import arrays
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_ox2_mets') {
		os.rmdir_all('tempfolders/tempfolder_ox2_mets')!
	}
	os.mkdir_all('tempfolders/tempfolder_ox2_mets')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_ox2_mets')!
}

fn test_explore_ox_mets_to_create_settings_file() {
	println(r_b('\nDo an explore using cross-validation on the all_mets_v_other_odd.tsv dataset, over all combinations of settings (with the traverse_all_flags flag set to true). Save the settings in a temporary settings file.'))
	home_dir := os.home_dir()
	temp_file := 'tempfolders/tempfolder_ox2_mets/ox2_mets_train.opts'
	temp_purged := 'tempfolders/tempfolder_ox2_mets/ox2_mets_train-purged.opts'
	saved_file := 'src/testdata/ox2_mets_train-purged.opts'
	mut opts := Options{
		command: 'explore'
		// concurrency_flag:     true
		datafile_path:        os.join_path(home_dir, 'mets', 'ox2_mets_train.tsv')
		number_of_attributes: [1, 8]
		bins:                 [2, 6]
		append_settings_flag: true
		traverse_all_flags:   true
		settingsfile_path:    temp_file
		expanded_flag:        true
		positive_class:       'Mets'
	}
	ds := load_file(opts.datafile_path, opts.LoadOptions)
	explore(ds, opts)
	println(r_b('\nShow the optimal settings (after purging for duplicate settings), and save the purges settings to a temporary file:'))
	opts.purge_flag = true
	opts.outputfile_path = temp_purged
	optimals(opts.settingsfile_path, opts)
	println(r_b('\nVerify that the temporary purged settings file is identical to settings file ${saved_file}. If the latter file does not exist, copy the temporary file to that path.'))
	if !os.is_file(saved_file) {
		os.cp(temp_purged, saved_file)!
		saved := os.read_file(saved_file)!
		temp := os.read_file(temp_purged)!
		assert saved == temp
	}
}

fn test_optimal_settings() {
	home_dir := os.home_dir()
	mut opts := Options{
		command:                             'cross'
		datafile_path:                       os.join_path(home_dir, 'mets', 'ox2_mets_train.tsv')
		multiple_classify_options_file_path: 'src/testdata/ox2_mets_train-purged.opts'
		// verbose_flag:         true
		multiple_flag:      true
		expanded_flag:      true
		positive_class:     'Mets'
		traverse_all_flags: true
		// show_attributes_flag: true
	}
	ds := load_file(opts.datafile_path, opts.LoadOptions)
	optimals(opts.multiple_classify_options_file_path, opts)
	multiple_classifier_settings := read_multiple_opts(opts.multiple_classify_options_file_path) or {
		panic('read_multiple_opts failed')
	}
	println(r_b('\nTest that classifiers 13 and 15 in the purged settings file correspond to the settings giving best balanced accuracy of 84.38%.'))
	assert multiple_classifier_settings.len == 63
	assert multiple_classifier_settings[13].correct_counts == [15, 9]
	assert multiple_classifier_settings[15].bal_acc == 84.375
	println(r_b('\nTest that classifier 48 in the purged settings file correspond to the setting giving second best Matthews Correlation Coefficient of 0.641, and total correct inferences of 23/28;'))
	assert multiple_classifier_settings[48].correct_counts == [13, 10]
	assert multiple_classifier_settings[48].mcc == 0.6408461287109104

	// opts.expanded_flag = false
	println(r_b('\nTest that a multiple classifier cross-validation using classifiers 48 and 16 gives correct counts of 14 out of 16 and 10 out of 12'))
	opts.traverse_all_flags = false
	for i in [[48, 16]] {
		opts.classifiers = i
		assert cross_validate(ds, opts).correct_counts == [14, 10]
	}
}

fn test_ox2_multi_verify() {
	println(r_b('\nWe can apply the classifier settings from previous to train classifiers on'))
	println(r_b('the entire ox2_mets_train.tsv dataset of 28 cases, and then classify the 14 cases in the'))
	println(r_b('independent ox2_mets_validation.tsv dataset:'))
	home_dir := os.home_dir()
	mut opts := Options{
		command:                             'verify'
		datafile_path:                       os.join_path(home_dir, 'mets', 'ox2_mets_train.tsv')
		testfile_path:                       os.join_path(home_dir, 'mets', 'ox2_mets_validation.tsv')
		multiple_classify_options_file_path: 'src/testdata/ox2_mets_train-purged.opts'
		multiple_flag:                       true
		positive_class:                      'Mets'
		// traverse_all_flags: true
		expanded_flag:        true
		show_attributes_flag: true
	}
	println(r_b('\nTest that for classifiers 13 and 15 used individually, we get correct counts\n of 6 out of 8 cases for mets, and 1 out of 4 cases for no mets. For classifier 48, \nit is 8 and 1 correct, and for multiple classification with classifiers 48 and 16, \nit is 7 and 2 cases correctly identified.'))
	test_values := [[6, 1], [6, 1], [8, 1], [7, 2]]
	for i, ci in [[13], [15], [48], [48, 16]] {
		opts.classifiers = ci
		assert verify(opts).correct_counts == test_values[i]
	}
}
