// optimals_test.v

module vhammll

import os

fn test_optimals_with_purge() {
	mut opts := Options{
		show_flag:         true
		settingsfile_path: 'src/testdata/leuk.opts'
	}
	println(r_b('\nPrint out the abbreviated optimals results:'))
	result_a := optimals(opts.settingsfile_path, opts)
	assert result_a.balanced_accuracy_max_classifiers == [125, 126, 127, 140, 141, 142, 145, 146,
		147, 150, 151, 152, 155, 156, 157]
	assert result_a.receiver_operating_characteristic_settings == [93, 118, 96, 10, 85, 125]
	println(r_b('\nPrint out the abbreviated and the expanded optimals results:'))
	opts.expanded_flag = true
	result_b := optimals(opts.settingsfile_path, opts)
	println(r_b('\nPurge duplicate settings, and then print out the abbreviated and the expanded optimals results:'))
	opts.purge_flag = true
	result_c := optimals(opts.settingsfile_path, opts)
	assert result_c.balanced_accuracy_max_classifiers == [68, 77, 80, 83, 86]
	assert result_c.receiver_operating_characteristic_settings == [45, 62, 48, 4, 39, 68]
	println(r_b('\nSave the purged file, then load it and display:'))
	opts.show_flag = false
	opts.expanded_flag = false
	opts.outputfile_path = 'src/testdata/ox_mets_settings_purged.opts'
	// delete the existing purged settings file
	if os.exists(opts.outputfile_path) {
		os.rm(opts.outputfile_path)!
	}
	result_d := optimals(opts.settingsfile_path, opts)
	assert result_d.balanced_accuracy_max_classifiers == [68, 77, 80, 83, 86]
	assert result_d.receiver_operating_characteristic_settings == [45, 62, 48, 4, 39, 68]

	opts.settingsfile_path = opts.outputfile_path
	opts.outputfile_path = ''
	opts.purge_flag = false
	opts.show_flag = true
	opts.expanded_flag = true
	result_e := optimals(opts.settingsfile_path, opts)
	assert result_e == result_d
	// ensure that further purging makes no difference
	opts.purge_flag = true
	// assert result_e == optimals(opts.settingsfile_path, opts)
}

fn test_optimals_for_leuk_opts() {
	mut opts := Options{
		expanded_flag:     true
		settingsfile_path: 'src/testdata/leuk.opts'
	}
	result := optimals(opts.settingsfile_path, opts)
	opts.purge_flag = true
	result_purged := optimals(opts.settingsfile_path, opts)
}
