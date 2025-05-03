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

// fn test_settings_for_roc() {
// 	roc_settingsfile := 'src/testdata/roc_settings.opts'
// 	datafile :=         'datasets/bcw350train'
// 	testfile :=       'datasets/bcw174test'
// 	explore(opts('-e -af -b 1,6 -u -roc $roc_settingsfile -t $testfile $datafile', cmd: 'explore'))
// 	display_file(roc_settingsfile)
// }

fn test_explore_traverse_all_flags() {
	mut datafile := 'datasets/iris.tab'
	mut settingsfile := 'tempfolders/tempfolder_explore/iris.opts'
	mut purgedfile := 'tempfolders/tempfolder_explore/iris_purged.opts'
	mut result := ExploreResult{}
	result = explore(opts('-a 2,4 -b 2,3 -u -af -ms ${settingsfile} ${datafile}', cmd: 'explore'))
	// display_file(settingsfile, expanded_flag: true)
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	assert r.len == 144
	assert r[1].correct_counts == [50, 47, 50]
	optimals(settingsfile, opts('-p -o ${purgedfile} -cl 2,4'))
	// display_file(purgedfile, show_flag: true)
	r = read_multiple_opts(purgedfile)!
	dump(r.len)
	assert r.len == 64
	assert r.filter(it.classifier_id == 11)[0].incorrect_counts == [0, 3, 1]
}

fn test_explore_cross() ? {
	mut result := ExploreResult{}
	mut metrics := Metrics{}
	mut datafile := 'datasets/iris.tab'
	result = explore(opts('-b 2,7 -u ${datafile}', cmd: 'explore'))
	assert result.array_of_results[0].correct_count == 99
	assert result.array_of_results[0].incorrects_count == 51
	assert result.array_of_results[0].wrong_count == 51
	assert result.array_of_results[0].total_count == 150
	metrics = get_metrics(result.array_of_results[0])
	assert metrics.balanced_accuracy == 66.0
	result = explore(opts('-b 10,12 ${datafile}', cmd: 'explore'))
	assert result.array_of_results.last().correct_count == 143
	assert result.array_of_results.last().incorrects_count == 7
	assert result.array_of_results.last().wrong_count == 7
	assert result.array_of_results.last().total_count == 150
	metrics = get_metrics(result.array_of_results.last())
	assert metrics.balanced_accuracy == 95.33333333333333
	println('Done with iris.tab')

	datafile = 'datasets/anneal.tab'
	result = explore(opts('-f 10 -a 27,29 -b 20,22 -w -u ${datafile}', cmd: 'explore'))
	metrics = get_metrics(result.array_of_results[1])
	assert metrics.balanced_accuracy == 96.28256246677299
	result = explore(opts('-f 10 -a 27,29 -b 20,22 -w ${datafile}', cmd: 'explore'))
	metrics = get_metrics(result.array_of_results[1])
	assert metrics.balanced_accuracy == 95.40510366826156
	result = explore(opts('-f 5 -5 50 -a 27,29 -b 20,22 -w ${datafile}', cmd: 'explore'))
	metrics = get_metrics(result.array_of_results[1])
	assert metrics.balanced_accuracy == 94.28814460393407
	println('Done with anneal.tab')
}

fn test_explore_verify() ? {
	datafile := 'datasets/bcw350train'
	testfile := 'datasets/bcw174test'
	settingsfile := 'tempfolders/tempfolder_explore/bcw.opts'
	mut result := explore(opts('-w -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'explore'
	))
	// display_file(settingsfile, expanded_flag: true)
	assert result.array_of_results[7].correct_count == 170
	assert result.array_of_results[7].wrong_count == 4
	println('done with explore_verify of bcw')
}
