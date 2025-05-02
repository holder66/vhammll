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

// fn testsuite_end() ? {
// 	os.rmdir_all('tempfolders/tempfolder_explore')!
// }

// fn test_settings_for_roc() {
// 	roc_settingsfile := 'src/testdata/roc_settings.opts'
// 	datafile :=         'datasets/bcw350train'
// 	testfile :=       'datasets/bcw174test'
// 	explore(opts('-e -af -b 1,6 -u -roc $roc_settingsfile -t $testfile $datafile', cmd: 'explore'))
// 	display_file(roc_settingsfile)
// }

// fn test_explore_traverse_all_flags() {
// 	mut datafile := 'datasets/iris.tab'
// 	mut settingsfile := 'tempfolders/tempfolder_explore/iris.opts'
// 	mut purgedfile := 'tempfolders/tempfolder_explore/iris_purged.opts'
// 	savedfile := 'src/testdata/iris_purged.opts'

// 	mut result := ExploreResult{}
// 	result = explore(opts('-a 2,4 -b 2,3 -u -af -ms ${settingsfile} ${datafile}', cmd: 'explore'))
// 	assert os.is_file(settingsfile)
// 	mut r := read_multiple_opts(settingsfile)!
// 	assert r.len == 112
// 	assert r[1].correct_counts == [50, 47, 50]
// 	optimals(settingsfile, opts('-p -o ${purgedfile} -cl 2,4'))
// 	r = read_multiple_opts(purgedfile)!
// 	assert r.len == 32
// 	assert r.filter(it.classifier_id == 11)[0].incorrect_counts == [50, 0, 50]
// }

// fn test_explore_cross() ? {
// 	mut result := ExploreResult{}
// 	mut metrics := Metrics{}
// 	mut opts := Options{
// 		number_of_attributes: [1, 4]
// 		bins:                 [2, 7]
// 		// concurrency_flag:     true
// 		uniform_bins:  true
// 		datafile_path: 'datasets/iris.tab'
// 	}
// 	result = explore(opts)
// 	assert result.array_of_results[0].correct_count == 99
// 	assert result.array_of_results[0].incorrects_count == 51
// 	assert result.array_of_results[0].wrong_count == 51
// 	assert result.array_of_results[0].total_count == 150
// 	metrics = get_metrics(result.array_of_results[0])
// 	assert metrics.balanced_accuracy >= 0.66

// 	opts.uniform_bins = false
// 	opts.bins = [10, 12]
// 	result = explore(opts)
// 	assert result.array_of_results.last().correct_count == 143
// 	assert result.array_of_results.last().incorrects_count == 7
// 	assert result.array_of_results.last().wrong_count == 7
// 	assert result.array_of_results.last().total_count == 150
// 	metrics = get_metrics(result.array_of_results.last())
// 	assert metrics.balanced_accuracy >= 0.94
// 	println('Done with iris.tab')

// 	opts.folds = 10
// 	opts.number_of_attributes = [27, 29]
// 	opts.bins = [20, 22]
// 	opts.weighting_flag = true
// 	opts.datafile_path = 'datasets/anneal.tab'
// 	opts.uniform_bins = true
// 	result = explore(opts)
// 	metrics = get_metrics(result.array_of_results[1])
// 	assert metrics.balanced_accuracy >= 0.96

// 	opts.uniform_bins = false
// 	result = explore(opts)
// 	metrics = get_metrics(result.array_of_results[1])
// 	assert metrics.balanced_accuracy >= 0.955

// 	opts.folds = 5
// 	opts.repetitions = 50
// 	result = explore(opts)
// 	metrics = get_metrics(result.array_of_results[1])
// 	assert metrics.balanced_accuracy >= 0.945
// 	println('Done with anneal.tab')
// }

fn test_explore_verify() ? {
	datafile := 'datasets/bcw350train'
	testfile := 'datasets/bcw174test'
	settingsfile := 'tempfolders/tempfolder_explore/bcw.opts'
	mut result := explore(opts('-e -w -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'explore'
	))
	// dump(result)
	display_file(settingsfile)
	assert result.array_of_results[7].correct_count == 170
	assert result.array_of_results[7].wrong_count == 4
	println('done with explore_verify of bcw')
}
