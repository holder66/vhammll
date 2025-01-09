// save_settings_test.v

module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder_save_settings') {
		os.rmdir_all('tempfolder_save_settings')!
	}
	os.mkdir_all('tempfolder_save_settings')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder_save_settings')!
}

fn test_append_cross_verify_settings_to_file() {
	mut opts := Options{
		number_of_attributes: [2]
		bins:                 [2, 2]
		concurrency_flag:     true
		uniform_bins:         true
		datafile_path:        'datasets/iris.tab'
		settingsfile_path:    'tempfolder_save_settings/iris.opts'
		command:              'cross'
		append_settings_flag: true
	}
	ds := load_file(opts.datafile_path)
	// opts.show_flag = true
	cross_validate(ds, opts)
	assert os.is_file(opts.settingsfile_path.trim_space())
	assert os.file_size(opts.settingsfile_path.trim_space()) == 1171
	// display_file(opts.settingsfile_path)

	// add another classifier
	opts.bins = [3, 3]
	cross_validate(ds, opts)
	// display_file(opts.settingsfile_path)
	assert os.file_size(opts.settingsfile_path.trim_space()) == 2247
}

fn test_append_explore_settings_to_file() {
	mut opts := Options{
		number_of_attributes: [1, 4]
		bins:                 [2, 7]
		concurrency_flag:     true
		uniform_bins:         true
		datafile_path:        'datasets/iris.tab'
		settingsfile_path:    'tempfolder_save_settings/iris.opts'
		command:              'explore'
		append_settings_flag: true
	}
	mut ds := load_file(opts.datafile_path)
	// opts.show_flag = true
	explore(ds, opts)
	assert os.is_file(opts.settingsfile_path.trim_space())
	assert os.file_size(opts.settingsfile_path.trim_space()) == 9832

	// now add another explore
	opts.uniform_bins = false
	explore(ds, opts)
	assert os.file_size(opts.settingsfile_path.trim_space()) == 17422
}
