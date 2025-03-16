// explore_test.v
module vhammll

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_explore') {
		os.rmdir_all('tempfolders/tempfolder_explore')!
	}
	os.mkdir_all('tempfolders/tempfolder_explore')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_explore')!
}

fn test_settings_for_roc() {
	mut opts := Options{
		traverse_all_flags:    true
		generate_roc_flag:     true
		roc_settingsfile_path: 'src/testdata/roc_settings.opts'
		datafile_path:         'datasets/bcw350train'
		testfile_path:         'datasets/bcw174test'
		bins:                  [1, 6]
		uniform_bins:          true
		// number_of_attributes: [1,4]
		// show_flag: true
		// expanded_flag: true
	}
	mut ds := load_file(opts.datafile_path)
	explore(ds, opts)
	display_file(opts.roc_settingsfile_path)
}

fn test_explore_traverse_all_flags() {
	mut result := ExploreResult{}
	mut metrics := Metrics{}
	mut opts := Options{
		number_of_attributes: [2, 4]
		bins:                 [2, 3]
		traverse_all_flags:   true
		// expanded_flag: true
		show_flag:        true
		concurrency_flag: true
		uniform_bins:     true
		// generate_roc_flag:    true
		append_settings_flag: true
		command:              'explore'
		datafile_path:        'datasets/iris.tab'
		settingsfile_path:    'tempfolders/tempfolder_explore/iris.opts'
	}
	saved_file := 'src/testdata/iris_purged.opts'
	mut ds := load_file(opts.datafile_path)
	result = explore(ds, opts)
	assert os.is_file(opts.settingsfile_path)
	assert int(os.file_size(opts.settingsfile_path)) in [253572, 252452]
	opts.purge_flag = true
	opts.expanded_flag = true
	opts.outputfile_path = 'tempfolders/tempfolder_explore/iris_purged.opts'
	optimals(opts.settingsfile_path, opts)
	dump(os.home_dir())
	if !os.is_file(saved_file) {
		os.cp(opts.outputfile_path, saved_file)!
	}
	assert os.file_size(opts.outputfile_path) == 75883
}

fn test_explore_cross() ? {
	mut result := ExploreResult{}
	mut metrics := Metrics{}
	mut opts := Options{
		number_of_attributes: [1, 4]
		bins:                 [2, 7]
		concurrency_flag:     true
		uniform_bins:         true
		datafile_path:        'datasets/iris.tab'
	}
	mut ds := load_file(opts.datafile_path)
	result = explore(ds, opts)
	assert result.array_of_results[0].correct_count == 99
	assert result.array_of_results[0].incorrects_count == 51
	assert result.array_of_results[0].wrong_count == 51
	assert result.array_of_results[0].total_count == 150
	metrics = get_metrics(result.array_of_results[0])
	assert metrics.balanced_accuracy >= 0.66

	opts.uniform_bins = false
	opts.bins = [10, 12]
	result = explore(ds, opts)
	assert result.array_of_results.last().correct_count == 140
	assert result.array_of_results.last().incorrects_count == 10
	assert result.array_of_results.last().wrong_count == 10
	assert result.array_of_results.last().total_count == 150
	metrics = get_metrics(result.array_of_results.last())
	assert metrics.balanced_accuracy >= 0.94
	println('Done with iris.tab')

	opts.folds = 10
	opts.number_of_attributes = [27, 29]
	opts.bins = [20, 22]
	opts.weighting_flag = true
	opts.datafile_path = 'datasets/anneal.tab'
	opts.uniform_bins = true
	ds = load_file(opts.datafile_path)
	result = explore(ds, opts)
	metrics = get_metrics(result.array_of_results[1])
	assert metrics.balanced_accuracy >= 0.96

	opts.uniform_bins = false
	result = explore(ds, opts)
	metrics = get_metrics(result.array_of_results[1])
	assert metrics.balanced_accuracy >= 0.955

	opts.folds = 5
	opts.repetitions = 50
	result = explore(ds, opts)
	metrics = get_metrics(result.array_of_results[1])
	assert metrics.balanced_accuracy >= 0.945
	println('Done with anneal.tab')
}

fn test_explore_verify() ? {
	mut opts := Options{
		command:          'explore'
		concurrency_flag: true
		weighting_flag:   true
		testfile_path:    'datasets/bcw174test'
		datafile_path:    'datasets/bcw350train'
	}
	mut ds := load_file(opts.datafile_path)
	mut result := explore(ds, opts)
	assert result.array_of_results[7].correct_count == 170
	assert result.array_of_results[7].wrong_count == 4
	println('done with explore_verify of bcw')
}
