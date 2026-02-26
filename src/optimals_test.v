// optimals_test.v

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

fn test_max_auc_combinations() {
	settings := read_multiple_opts('src/testdata/leukbp.opts')!
	dump(settings)
	mut r := max_auc_combinations(settings, [[1, 2]], min: 2)
	dump(r)
}

fn test_optimals_with_max_auc_combinations() {
	options := opts('optimals -p -l 3,4 src/testdata/leukbp.opts')
	dump(options)
}

fn test_limit_to_unique_attribute_number() {
	savedsettings := 'src/testdata/anneal.opts'
	settings := read_multiple_opts(savedsettings) or { panic('read_multiple_opts failed') }
	assert limit_to_unique_attribute_number(settings, [3, 4, 5]) == [3, 4]
	assert limit_to_unique_attribute_number(settings, [1, 2, 3]) == [1]
	assert limit_to_unique_attribute_number(settings, [2, 6, 7, 8]) == [2, 6, 7]
	assert limit_to_unique_attribute_number(settings[..1], [3]) == []
	assert limit_to_unique_attribute_number(settings[3..4], [3]) == [3]
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
	result_f := verify(opts('-e -m# 0,1,2,3,16 -ma -mc -m ${settingsfile} -t ${testfile} ${datafile}'))
	assert result_f.correct_counts == [133, 38]
}
