// save_settings_test.v

module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder_save_settings') {
		os.rmdir_all('tempfolder_save_settings')!
	}
	os.mkdir_all('tempfolder_save_settings')!
}

// fn testsuite_end() ? {
// 	os.rmdir_all('tempfolder_save_settings')!
// }

fn test_append_explore_settings_to_file() {
	mut result := ExploreResult{}
	mut metrics := Metrics{}
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
	opts.show_flag = true

	result = explore(ds, opts)
}
