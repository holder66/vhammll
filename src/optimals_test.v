// optimals_test.v

module vhammll

import vsl.iter

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

fn test_generate_combinations() {
	assert iter.combinations([0.0,1,2,3,4,5], 3) == [][]f64{}
}

fn test_max_auc_combinations() {
	settings := read_multiple_opts('src/testdata/oxford_settings.opts')!
	mut r := max_auc_combinations(settings)
	dump(r)
}

// fn test_optimals_with_purge() {
// 	// create a settings file by doing an explore on bcwtrain and test
// 	mut opts := Options{
// 		datafile_path:        'datasets/bcw350train'
// 		testfile_path:        'datasets/bcw174test'
// 		settingsfile_path:    'tempfolders/tempfolder_optimals/bcw.opts'
// 		command:              'explore'
// 		traverse_all_flags:   true
// 		append_settings_flag: true
// 	}
// 	mut ds := load_file(opts.datafile_path, opts.LoadOptions)

// 	explore(opts)
// 	// display_file(opts.settingsfile_path)
// 	opts.show_flag = true
// 	println(r_b('\nPrint out the abbreviated optimals results:'))
// 	result_a := optimals(opts.settingsfile_path, opts)
// 	assert result_a.balanced_accuracy_max_classifiers == [1, 6, 11, 16, 41, 46, 51, 56, 81, 86,
// 		91, 96, 121, 126, 131, 136]
// 	assert result_a.receiver_operating_characteristic_settings == [34, 0, 1, 3]
// 	assert result_a.mcc_max_classifiers == [0, 2, 4, 5, 7, 9, 10, 12, 14, 15, 17, 19, 20, 22, 24,
// 		25, 27, 29, 40, 42, 44, 45, 47, 49, 50, 52, 54, 55, 57, 59, 60, 62, 64, 65, 67, 69, 80,
// 		82, 84, 85, 87, 89, 90, 92, 94, 95, 97, 99, 100, 102, 104, 105, 107, 109, 120, 122, 124,
// 		125, 127, 129, 130, 132, 134, 135, 137, 139, 140, 142, 144, 145, 147, 149]

// 	println(r_b('\nPrint out the abbreviated and the expanded optimals results:'))
// 	opts.expanded_flag = true
// 	result_b := optimals(opts.settingsfile_path, opts)
// 	println(r_b('\nPurge duplicate settings, and then print out the abbreviated and the expanded optimals results:'))
// 	opts.purge_flag = true
// 	result_c := optimals(opts.settingsfile_path, opts)
// 	assert result_c.mcc_max_classifiers == [0, 10, 20, 40, 50, 60, 80, 90, 100, 120, 130, 140]
// 	assert result_c.receiver_operating_characteristic_settings == [34, 0, 1, 3]
// 	println(r_b('\nSave the purged file, then load it and display:'))
// 	opts.show_flag = false
// 	opts.expanded_flag = false
// 	opts.outputfile_path = 'tempfolders/tempfolder_optimals/bcw_purged.opts'

// 	result_d := optimals(opts.settingsfile_path, opts)
// 	assert result_d == result_c

// 	opts.settingsfile_path = opts.outputfile_path
// 	opts.outputfile_path = ''
// 	opts.purge_flag = false
// 	opts.show_flag = true
// 	opts.expanded_flag = true
// 	result_e := optimals(opts.settingsfile_path, opts)
// 	assert result_e.RocData == result_d.RocData
// 	// ensure that further purging makes no difference
// 	opts.purge_flag = true
// 	assert result_e == optimals(opts.settingsfile_path, opts)
// }
