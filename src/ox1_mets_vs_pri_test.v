// ox_mets_test.v

module vhammll

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_ox1_mets') {
		os.rmdir_all('tempfolders/tempfolder_ox1_mets')!
	}
	os.mkdir_all('tempfolders/tempfolder_ox1_mets')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_ox1_mets')!
}

// fn test_binning_for_overfitting() {
// 	println(r_b('\nTo limit the possibility of overfitting, look for the binning number that gives the first peak in rank values:'))
// 	datafile := '${os.home_dir()}/metabolomics/ox1_mets-train.tab'
// 	rank_attributes(opts('-g -e -l 5 -b 2,7 $datafile', cmd: 'rank'))
// 	println(r_b('\nThe graph (when visible) shows that limiting binning to 4 will likely limit overfitting.'))
// }

// fn test_explore_ox_mets_to_create_settings_file() {
// 	println(r_b('\nDo an explore using cross-validation on the ox1_mets-train.tab dataset, over all combinations of settings (with the traverse_all_flags flag set to true). Save the settings in a temporary settings file.'))
// 	datafile := os.join_path(os.home_dir(), 'metabolomics', 'ox1_mets-train.tab')
// 	settingsfile := 'tempfolders/tempfolder_ox1_mets/ox1metstrainb2-4a2-25_expanded.opts'
// 	savedsettings := 'src/testdata/ox1metstrainb2-4a2-25_expanded.opts'
// 	explore(opts('-e -af -pos Met -ms $settingsfile -b 2,4 -a 2,25 $datafile', cmd: 'explore'))
// 	println(r_b('\nShow the optimal settings after purging for duplicate settings'))
// 	optimals(settingsfile, opts('-p -s'))
// 	println(r_b('\nIf the saved settings file ${savedsettings} does not exist, copy the temporary file to that path.'))
// 	if !os.is_file(savedsettings) {
// 		os.cp(settingsfile, savedsettings)!
// 	}
// }

// fn test_optimal_settings() {
// 	// do_optimals(opts('-g -e -b 2,7 -pos Met src/testdata/ox1metstrainb2-4a2-25purged.opts'))
// }

// 	home_dir := os.home_dir()
// 	mut opts := Options{
// 		command:                             'cross'
// 		datafile_path:                       os.join_path(home_dir, 'metabolomics', 'ox1_mets-train.tab')
// 		multiple_classify_options_file_path: 'src/testdata/ox1metstrainb2-4a2-25purged.opts'
// 		// verbose_flag:         true
// 		positive_class: 'Met'
// 		multiple_flag:  true
// 		expanded_flag:  true
// 		// show_attributes_flag: true
// 	}
// 	ds := load_file(opts.datafile_path, opts.LoadOptions)
// 	result := optimals(opts.multiple_classify_options_file_path, opts)
// 	multiple_classifier_settings := read_multiple_opts(opts.multiple_classify_options_file_path) or {
// 		panic('read_multiple_opts failed')
// 	}
// 	println(r_b('\nVerify that classifiers 20, 30, 85, and 100 correspond to the settings giving best balanced accuracy of 78.79%, best Matthews Correlation Coefficient of 0.604, and highest total correct inferences of 14/17;'))
// 	assert multiple_classifier_settings.filter(it.classifier_id == 100)[0].mcc == 0.6038596398555418
// 	assert result.best_balanced_accuracies == 78.7878787878788
// 	assert result.best_balanced_accuracies_classifiers_all == [20, 30, 85, 100]
// 	println(r_b('and verify that classifier 0 gives the highest sensitivity of 0.909, and classifier 24 the highest specificity of 0.833'))
// 	assert multiple_classifier_settings.filter(it.classifier_id == 0)[0].incorrect_counts == [
// 		1,
// 		3,
// 	]
// 	assert multiple_classifier_settings.filter(it.classifier_id == 24)[0].correct_counts == [
// 		8,
// 		5,
// 	]
// }

fn test_multiple_crossvalidate_of_ox_mets() {
	// result := cross_validate(opts('-e -pos Met -m src/testdata/ox1metstrainb2-4a2-25purged.opts -m# 0,20,40 ${os.home_dir()}/metabolomics/ox1_mets-train.tab'))
	// assert result.correct_counts == [11,6]
	// mut opts := Options{
	// 	command:                             'cross'
	// 	datafile_path:                       os.join_path(home_dir, 'metabolomics', 'ox1_mets-train.tab')
	// 	multiple_classify_options_file_path: 'src/testdata/ox1metstrainb2-4a2-25purged.opts'
	// 	positive_class:                      'Met'
	// 	multiple_flag:                       true
	// 	traverse_all_flags:                  true
	// 	// expanded_flag: true
	// 	// show_attributes_flag: true
	// }
	// ds := load_file(opts.datafile_path, opts.LoadOptions)
	// println(r_b('\nTest using multiple classifiers. We can cycle through all possibilities for the multiple classifier flags. Classifiers 30 and 24 together give the highest specificity of 0.909, with a Matthews Correlation Coefficient of 0.742, while classifiers 20, 6, and 34 together give the highest sensitivity of 1.0, with MCC of 0.783'))
	// for cl_list in [[30, 24], [20, 6, 34]] {
	// 	opts.classifiers = cl_list
	// 	mut result := cross_validate(opts)
	// }
	// opts.traverse_all_flags = false
	// opts.expanded_flag = true
	// opts.classifiers = [30, 24]
	// opts.break_on_all_flag = true
	// opts.combined_radii_flag = false
	// opts.total_nn_counts_flag = true
	// assert cross_validate(opts).correct_counts == [10, 5]
}

fn test_ox_mets_multi_verify() {
	mut result := CrossVerifyResult{}
	datafile := '${os.home_dir()}/metabolomics/ox1_mets-train.tab'
	testfile := '${os.home_dir()}/metabolomics/ox1_mets-test.tab'
	savedsettings := 'src/testdata/ox1met_expanded.opts'
	optimals(savedsettings, opts('-s -p'))
	// result = verify(opts('-e -pos Met -a 4 -b 1,4 -t ${os.home_dir()}/metabolomics/ox1_mets-test.tab ${os.home_dir()}/metabolomics/ox1_mets-train.tab'))
	// result = verify(opts(' -pos Met -m src/testdata/ox1met_expanded.opts -m# 150,134,154 -af -t ${os.home_dir()}/metabolomics/ox1_mets-test.tab ${os.home_dir()}/metabolomics/ox1_mets-train.tab'))
	// println(result.mcc)
	// 	mut result := CrossVerifyResult{}
	// 	println(r_b('\nWe can apply the classifier settings from previous to train classifiers on'))
	// 	println(r_b('the entire mets-train dataset of 17 cases, and then classify the 7 cases in the'))
	// 	println(r_b('independent mets-test dataset:'))
	// 	home_dir := os.home_dir()
	// 	ft := [false, true]
	// 	mut opts := Options{
	// 		command:                             'verify'
	// 		datafile_path:                       os.join_path(home_dir, 'metabolomics', 'ox1_mets-train.tab')
	// 		testfile_path:                       os.join_path(home_dir, 'metabolomics', 'ox1_mets-test.tab')
	// 		multiple_classify_options_file_path: 'src/testdata/ox1metstrainb2-4a2-25purged.opts'
	// 		positive_class:                      'Met'
	// 		multiple_flag:                       true
	// 		show_attributes_flag:                true
	// 		expanded_flag:                       true
	// 		classifiers:                         [30, 24]
	// 		break_on_all_flag:                   true
	// 		combined_radii_flag:                 false
	// 		total_nn_counts_flag:                true
	// 	}

	// 	result = verify(opts)
	// 	assert result.sens == 0.4
	// 	assert result.spec == 0.5
	// 	println(r_b('\nFor the classifier giving the best balanced accuracy on the training set,'))
	// 	println(r_b('we get a sensitivity of 0.4, and specificity of 0.4, on the test set'))
}

// fn test_ox1_mets_reverse_test_and_train_datafiles() {
// 	println(r_b('\nDo an explore using cross-validation on the ox1_mets-test.tab dataset, over all combinations of settings (with the traverse_all_flags flag set to true). Save the settings in a temporary settings file.'))
// 	home_dir := os.home_dir()
// 	temp_file := 'tempfolders/tempfolder_ox1_mets/ox1metstestb2-6a2-25.opts'
// 	temp_purged := 'tempfolders/tempfolder_ox1_mets/ox1metstestb2-6a2-25purged.opts'
// 	saved_file := 'src/testdata/ox1metstestb2-6a2-25purged.opts'
// 	mut opts := Options{
// 		command:              'explore'
// 		datafile_path:        os.join_path(home_dir, 'metabolomics', 'ox1_mets-test.tab')
// 		number_of_attributes: [2, 25]
// 		bins:                 [2, 6]
// 		append_settings_flag: true
// 		traverse_all_flags:   true
// 		settingsfile_path:    temp_file
// 		expanded_flag:        true
// 		positive_class:       'Met' // because this class has a higher prevalence than 'Pri' in this dataset
// 	}
// 	ds := load_file(opts.datafile_path, opts.LoadOptions)
// 	// explore(ds, opts)

// 	// println(r_b('\nShow the optimal settings (after purging for duplicate settings), and save the purged settings to a temporary file:'))
// 	// opts.purge_flag = true
// 	// opts.outputfile_path = temp_purged
// 	// optimals(opts.settingsfile_path, opts)
// 	// println(r_b('\nVerify that the temporary purged settings file is identical to settings file ${saved_file}. If the latter file does not exist, copy the temporary file to that path.'))
// 	// if os.is_file(saved_file) {
// 	// 	saved := os.read_file(saved_file)!
// 	// 	temp := os.read_file(temp_purged)!
// 	// 	assert saved == temp
// 	// } else {
// 	// 	os.cp(temp_purged, saved_file)!
// 	// }

// 	opts.expanded_flag = false
// 	opts.multiple_classify_options_file_path = saved_file
// 	result := optimals(opts.multiple_classify_options_file_path, opts)
// 	multiple_classifier_settings := read_multiple_opts(opts.multiple_classify_options_file_path) or {
// 		panic('read_multiple_opts failed')
// 	}
// 	println(r_b('\nVerify that classifiers 0, 5, 10, etc correspond to the settings giving best balanced accuracy of 100%, best Matthews Correlation Coefficient of 1.0, and highest total correct inferences of 7/7;'))
// 	assert multiple_classifier_settings.filter(it.classifier_id == 10)[0].mcc == 1.0
// 	assert result.best_balanced_accuracies == 100.0
// 	assert result.best_balanced_accuracies_classifiers_all == [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50,
// 		55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120, 125, 130, 135, 140, 145, 150,
// 		155]

// 	opts.command = 'cross'
// 	opts.expanded_flag = true
// 	opts.multiple_flag = true
// 	opts.traverse_all_flags = false
// 	opts.classifiers = [0]
// 	assert cross_validate(opts).correct_counts == [5, 2]

// 	println(r_b('\nSince we get 100% accuracy with single classifiers, there is little point in attempting to find which combinations of multiple classifiers give good classification performance. Instead, we will go directly to using both single and multiple classifier verifications of the test set (which in this situation is actually the ox1_mets-train.tab file)'))

// 	opts.command = 'verify'
// 	opts.testfile_path = os.join_path(home_dir, 'metabolomics', 'ox1_mets-train.tab')
// 	opts.show_attributes_flag = true
// 	assert verify(opts).correct_counts == [10, 2]
// 	opts.classifiers = [0, 3, 5, 80]
// 	assert verify(opts).correct_counts == [11, 2]
// 	opts.total_nn_counts_flag = true
// 	assert verify(opts).correct_counts == [9, 3]

// 	println(r_b('\nUnfortunately, these results are in a sense "cheating" as the separate validation dataset was not held back and kept independent.'))
// }
