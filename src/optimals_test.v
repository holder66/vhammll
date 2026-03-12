module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_optimals') {
		os.rmdir_all('tempfolders/tempfolder_optimals')!
	}
	os.mkdir_all('tempfolders/tempfolder_optimals')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_optimals')!
}

fn test_limit_to_unique_attribute_number() {
	savedsettings := 'src/testdata/anneal.opts'
	if !os.is_file(savedsettings) {
		explore(opts('-a 2,10 -b 2,10 -ms ${savedsettings} datasets/anneal.tab', cmd: 'explore'))
	}
	settings := read_multiple_opts(savedsettings) or { panic('read_multiple_opts failed') }
	assert limit_to_unique_attribute_number(settings, [3, 4, 5], true) == [3, 4, 5]
	assert limit_to_unique_attribute_number(settings, [3, 4, 5], false) == [3, 4]
	assert limit_to_unique_attribute_number(settings, [1, 2, 3], false) == [1, 2, 3]
	assert limit_to_unique_attribute_number(settings, [2, 6, 7, 8], false) == [2, 6, 8]
	assert limit_to_unique_attribute_number(settings[..1], [3], false) == []
	assert limit_to_unique_attribute_number(settings[3..4], [3], false) == [3]
}

fn test_max_auc_combinations() {
	leukbp_settings := 'src/testdata/leukbp.opts'
	if !os.is_file(leukbp_settings) {
		explore(opts('-bp -a 1,2 -b 2,5 -af -ms ${leukbp_settings} -t datasets/leukemia34test.tab datasets/leukemia38train.tab',
			cmd: 'explore'))
	}
	// display_file('src/testdata/leukbp.opts', expanded_flag: true)
	settings := read_multiple_opts(leukbp_settings)!
	classifier_ids := settings.map(it.classifier_id)
	limits := CombinationSizeLimits{
		generate_combinations_flag: true
		min:                        2
		max:                        3
	}
	mut r := max_auc_combinations(settings, classifier_ids, limits)
	assert classifier_ids.len == 28
	// C(28,2) + C(28,3) = 378 + 3276 = 3654
	assert r.len == 3654
	assert array_max(r.map(it.auc)) == 0.9660714285714286
	// all AUC values must lie within [0.0, 1.0]
	assert r.all(it.auc >= 0.0 && it.auc <= 1.0)
	// every result's classifier_ids must have length within [min, max]
	assert r.all(it.classifier_ids.len >= limits.min && it.classifier_ids.len <= limits.max)
	// pairs only: C(28,2) = 378
	limits_pairs := CombinationSizeLimits{
		generate_combinations_flag: true
		min:                        2
		max:                        2
	}
	r_pairs := max_auc_combinations(settings, classifier_ids, limits_pairs)
	assert r_pairs.len == 378
	// triples only: C(28,3) = 3276
	limits_triples := CombinationSizeLimits{
		generate_combinations_flag: true
		min:                        3
		max:                        3
	}
	r_triples := max_auc_combinations(settings, classifier_ids, limits_triples)
	assert r_triples.len == 3276
	// pairs + triples must equal the combined total
	assert r_pairs.len + r_triples.len == r.len
	// max clamping: max > available count is silently clamped to classifier count;
	// C(28,27) + C(28,28) = 28 + 1 = 29
	limits_clamped := CombinationSizeLimits{
		generate_combinations_flag: true
		min:                        27
		max:                        100
	}
	r_clamped := max_auc_combinations(settings, classifier_ids, limits_clamped)
	assert r_clamped.len == 29
	// small subset (first 5 IDs): C(5,2) + C(5,3) = 10 + 10 = 20
	small_ids := classifier_ids[..5]
	r_small := max_auc_combinations(settings, small_ids, limits)
	assert r_small.len == 20
}

fn test_purge_duplicate_settings() {
	// empty array returns empty array
	assert purge_duplicate_settings([]ClassifierSettings{}) == []ClassifierSettings{}
	// generate a settings file for further testing
	datafile := 'datasets/2_class_developer.tab'
	settingsfile := 'tempfolders/tempfolder_optimals/2_class_developer.opts'
	explore(opts('-af -a 2 -b 2,7 -ms ${settingsfile} ${datafile}', cmd: 'explore'))
	assert os.is_file(settingsfile)
	all_settings := read_multiple_opts(settingsfile)!
	assert all_settings.len == 140
	// a single setting returns the same setting
	assert purge_duplicate_settings([all_settings[0]]) == [all_settings[0]]
	// three identical settings returns one setting
	mut test_settings := []ClassifierSettings{}
	for i in 0 .. 2 {
		test_settings << all_settings[139]
	}
	assert purge_duplicate_settings(test_settings) == [all_settings[139]]
}

fn test_optimals_with_max_auc_combinations() {
	options := opts('optimals -p -l 3,4 src/testdata/leukbp.opts')
	// dump(options)
}

fn test_optimals_with_purge() {
	// create a settings file by doing an explore on bcwtrain and test
	datafile := 'datasets/bcw350train'
	testfile := 'datasets/bcw174test'
	settingsfile := 'tempfolders/tempfolder_optimals/bcw.opts'
	savedsettings := 'src/testdata/bcw.opts'

	explore(opts('-af -ms ${settingsfile} -t ${testfile} ${datafile}', cmd: 'explore'))
	if !os.is_file(savedsettings) {
		os.cp(settingsfile, savedsettings)!
	}
	println(r_b('\nDump the optimals result struct:'))
	result_a := optimals(settingsfile)
	dump(optimals(settingsfile))
	assert result_a.best_balanced_accuracies_classifiers == [
		[1],
		[2, 9],
		[16],
		[0, 3, 14],
		[21],
		[23, 24],
		[27],
	]
	assert result_a.receiver_operating_characteristic_settings == [27, 23, 0, 1, 2]
	assert result_a.mcc_max_classifiers == [0, 3, 14]

	println(r_b('\nDump the optimals result struct after purging'))
	result_b := optimals(settingsfile, opts('-p'))
	dump(result_b)
	assert result_b.settings_length - result_b.settings_purged == 224 - 160
	assert result_b.correct_inferences_total_max_classifiers_all == [0, 3, 7, 14, 28, 31, 35, 42,
		56, 59, 63, 70, 84, 87, 91, 98, 112, 119, 126, 133]
	println(r_b('\nDump the optimals struct result after purging and with auc combinations from 2 through 4:'))
	result_c := optimals(settingsfile, opts('-p -cl 2,4'))
	dump(result_c)
	assert result_c.multi_classifier_combinations_for_auc.len == 91
	assert result_c.multi_classifier_combinations_for_auc[7].auc == 0.9982585139318886
	assert result_c.multi_classifier_combinations_for_auc.last().classifier_ids == [0, 14]
	println(r_b('\nPrint out the abbreviated and the expanded optimals results after purging:'))
	mut result_d := optimals(settingsfile, opts('-p -cl 2,4 -s'))
	assert result_c == result_d
	println(r_b('\nDo a a verify on all the combinations taken 3 at a time:'))
	mut result_e := optimals(settingsfile, opts('-p -cl 3,3'))
	for classifier_ids in result_e.multi_classifier_combinations_for_auc.map(it.classifier_ids) {
		list := classifier_ids.map('${it}').join(',')
		verify(opts('-af -m# ${list} -m ${settingsfile} -t ${testfile} ${datafile}'))
	}
	println(r_b('\nWith classifiers 0, 1, and 2, we can achieve a balanced accuracy of 99.26%!:'))
	verify(opts('-e -ea -m# 0,1,2 -ma -mc -m ${settingsfile} -t ${testfile} ${datafile}'))

	optimals(settingsfile, opts('-p -e'))
	assert result_c.settings_length == 140
	assert result_c.settings_purged == 76
	assert result_c.best_balanced_accuracies[6] == 94.73684210526316
	assert result_c.best_balanced_accuracies_classifiers_all[2] == [16, 44, 72, 100]
	println(r_b('\nGet all the combinations of lengths 4 and 5:'))
	result_d = optimals(settingsfile, opts('-g -s -p -cl 4,5'))
	result_f := verify(opts('-m# 0,1,2,3,16 -ma -mc -m ${settingsfile} -t ${testfile} ${datafile}'))
	assert result_f.correct_counts == [133, 38]
}
