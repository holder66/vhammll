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
	// first, with a dataset with balanced prevalences
	mut datafile := 'datasets/iris.tab'
	mut settingsfile := 'tempfolders/tempfolder_explore/iris.opts'
	mut purgedfile := 'tempfolders/tempfolder_explore/iris_purged.opts'
	mut result := ExploreResult{}
	result = explore(opts('-a 2,4 -b 2,3 -af -ms ${settingsfile} ${datafile}', cmd: 'explore'))
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
	// now with the balance_prevalences flag set
	settingsfile = 'tempfolders/tempfolder_explore/iris_bp.opts'
	result = explore(opts('-e -bp -a 2,4 -b 2,3 -af -ms ${settingsfile} ${datafile}', cmd: 'explore'))
	// display_file(settingsfile, expanded_flag: true)
	assert !os.is_file(settingsfile)

	// repeat for a dataset with unbalanced prevalences
	datafile = 'datasets/leukemia38train.tab'
	mut testfile := 'datasets/leukemia34test.tab'
	settingsfile = 'tempfolders/tempfolder_explore/leuk.opts'
	purgedfile = 'tempfolders/tempfolder_explore/leuk_purged.opts'
	result = explore(opts('-a 1,2 -b 2,5 -af -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'explore'
	))
	assert os.is_file(settingsfile)
	r = read_multiple_opts(settingsfile)!
	assert r.len == 140
	assert r[139].correct_counts == [20, 6]
	optimals(settingsfile, opts('-p -o ${purgedfile}'))
	assert os.is_file(purgedfile)
	r = read_multiple_opts(purgedfile)!
	assert r.len == 64
	assert r[3].classifier_id == 7
	assert r[3].correct_counts == [18, 13]
	// display_file(purgedfile, expanded_flag: true)
	// limit the -af to -bp
	settingsfile = 'tempfolders/tempfolder_explore/leuk_bp.opts'
	purgedfile = 'tempfolders/tempfolder_explore/leuk_bp_purged'
	result = explore(opts('-bp -a 1,2 -b 2,5 -af -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'explore'
	))
	assert os.is_file(settingsfile)
	r = read_multiple_opts(settingsfile)!
	assert r.len == 28
	optimals(settingsfile, opts('-p -o ${purgedfile}'))
	assert os.is_file(purgedfile)
	r = read_multiple_opts(purgedfile)!
	assert r.len == 16
	assert r[13].classifier_id == 22
	assert r[13].incorrect_counts == [3, 0]
	// display_file(purgedfile, expanded_flag: true)
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
