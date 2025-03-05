// save_settings_test.v

module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_save_settings') {
		os.rmdir_all('tempfolders/tempfolder_save_settings')!
	}
	os.mkdir_all('tempfolders/tempfolder_save_settings')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_save_settings')!
}

fn test_append_cross_verify_settings_to_file() {
	mut opts := Options{
		number_of_attributes: [2]
		bins:                 [2, 2]
		concurrency_flag:     true
		uniform_bins:         true
		datafile_path:        'datasets/iris.tab'
		settingsfile_path:    'tempfolders/tempfolder_save_settings/iris.opts'
		command:              'cross'
		append_settings_flag: true
	}
	ds := load_file(opts.datafile_path, opts.LoadOptions)
	// opts.show_flag = true
	cross_validate(ds, opts)
	assert os.is_file(opts.settingsfile_path.trim_space())
	assert os.file_size(opts.settingsfile_path.trim_space()) == 1190
	display_file(opts.settingsfile_path)

	// add another classifier
	opts.bins = [3, 3]
	cross_validate(ds, opts)
	display_file(opts.settingsfile_path)
	assert os.file_size(opts.settingsfile_path.trim_space()) == 2285
}

fn test_append_explore_cross_settings_to_file() {
	mut opts := Options{
		number_of_attributes: [1, 4]
		bins:                 [2, 7]
		concurrency_flag:     true
		uniform_bins:         true
		datafile_path:        'datasets/iris.tab'
		settingsfile_path:    'tempfolders/tempfolder_save_settings/iris.opts'
		command:              'explore'
		append_settings_flag: true
	}
	mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	// opts.show_flag = true
	explore(ds, opts)
	display_file(opts.settingsfile_path)
	assert os.is_file(opts.settingsfile_path.trim_space())
	assert os.file_size(opts.settingsfile_path.trim_space()) == 10003

	// now add another explore
	opts.uniform_bins = false
	explore(ds, opts)
	display_file(opts.settingsfile_path)
	assert os.file_size(opts.settingsfile_path.trim_space()) == 17726
}

fn test_append_explore_verify_settings_to_file() {
	mut opts := Options{
		datafile_path:        'datasets/bcw350train'
		testfile_path:        'datasets/bcw174test'
		settingsfile_path:    'tempfolders/tempfolder_save_settings/bcw.opts'
		command:              'explore'
		append_settings_flag: true
	}
	mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	opts.show_flag = true
	explore(ds, opts)
	display_file(opts.settingsfile_path)
	// assert os.is_file(opts.settingsfile_path.trim_space())
	// assert os.file_size(opts.settingsfile_path.trim_space()) == 9832

	// now add another explore
	opts.weight_ranking_flag = true
	explore(ds, opts)
	display_file(opts.settingsfile_path)
	// assert os.file_size(opts.settingsfile_path.trim_space()) == 17422
}
