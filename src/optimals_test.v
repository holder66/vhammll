// optimals_test.v

module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_optimals') {
		os.rmdir_all('tempfolders/tempfolder_optimals')!
	}
	os.mkdir_all('tempfolders/tempfolder_optimals')!
}

// fn testsuite_end() ? {
// 	os.rmdir_all('tempfolders/tempfolder_optimals')!
// }

fn test_max_auc_combinations() {
	settings := read_multiple_opts('src/testdata/ox1trainb2-6a2-15newbp.opts')!
	mut r := max_auc_combinations(settings, [[1, 2]], min: 2)
	// dump(r)
}

fn test_optimals_with_max_auc_combinations() {
	options := opts('optimals -p -l 3,4 src/testdata/ox1trainb2-6a2-15newbp.opts')
	// dump(options)
}

fn test_optimals_with_purge() {
	// create a settings file by doing an explore on bcwtrain and test
		datafile :=        'datasets/bcw350train'
		testfile :=       'datasets/bcw174test'
		settingsfile :=    'tempfolders/tempfolder_optimals/bcw.opts'
		savedsettings := 'testdata/bcw.opts'

	explore(opts('-af -ms $settingsfile -t $testfile $datafile', cmd: 'explore'))
	println(r_b('\nPrint out the abbreviated optimals results:'))
	result_a := optimals(settingsfile)
	// assert result_a.best_balanced_accuracies_classifiers == [1, 8, 15, 22, 57, 64, 71, 78, 113, 120, 127, 134, 169, 176, 183, 190]
	assert result_a.receiver_operating_characteristic_settings == [48, 44, 0, 1, 2]
	assert result_a.mcc_max_classifiers == [0, 3, 4, 6, 7, 10, 11, 13, 14, 18, 20, 21, 25, 27, 28, 31, 32, 34, 35, 38, 39, 41, 56, 59, 60, 62, 63, 66, 67, 69, 70, 74, 76, 77, 81, 83, 84, 87, 88, 90, 91, 94, 95, 97, 112, 115, 116, 118, 119, 122, 123, 125, 126, 130, 132, 133, 137, 139, 140, 143, 144, 146, 147, 150, 151, 153, 168, 171, 172, 174, 175, 178, 179, 181, 182, 186, 188, 189, 193, 195, 196, 199, 200, 202, 203, 206, 207, 209]

	println(r_b('\nPrint out the expanded optimals results:'))
	result_b := optimals(settingsfile, opts('-e'))
	println(r_b('\nPurge duplicate settings, and then print out the abbreviated and the expanded optimals results:'))
	result_c := optimals(settingsfile, opts('-p'))
	optimals(settingsfile, opts('-p -e'))
	assert result_c.settings_length == 224
	assert result_c.purged_settings_count == 60
	assert result_c.best_balanced_accuracies[6] == 94.73684210526316
	assert result_c.best_balanced_accuracies_classifiers[2] == [30, 86, 142, 198]
	println(r_b('\nGet all the combinations of lengths 4 and 5:'))
	result_d := optimals(settingsfile, opts('-s -p -cl 4,5'))
	result_e := verify(opts('-e -m# 0,1,2,3,16 -ma -mc -m $settingsfile -t $testfile $datafile'))
	assert result_e.correct_counts == [133,38]
}
