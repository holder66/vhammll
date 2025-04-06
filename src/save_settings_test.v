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

fn test_append_cross_validate_settings_to_file() {
	datafile := 'datasets/iris.tab'
	settingsfile := 'tempfolders/tempfolder_save_settings/iris1.opts'
	cross_validate(opts(' -a 2 -b 2,2 -ms ${settingsfile} ${datafile}'))
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	// // add another classifier
	cross_validate(opts('-a 2 -b 3,3 -ms ${settingsfile} ${datafile}'))
	r = read_multiple_opts(settingsfile)!
	assert r.len == 2
	assert r.map(it.classifier_id) == [0, 1]
	assert r[0].correct_counts == [50, 18, 50]
	assert r[1].incorrect_counts == [0, 3, 0]
}

fn test_append_verify_settings_to_file() {
	datafile := 'datasets/bcw350train'
	testfile := 'datasets/bcw174test'
	settingsfile := 'tempfolders/tempfolder_save_settings/bcw1.opts'
	verify(opts('-ms ${settingsfile} -t ${testfile} ${datafile}'))
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	assert r.len == 1
	verify(opts('-a 5 -ms ${settingsfile} -t ${testfile} ${datafile}'))
	r = read_multiple_opts(settingsfile)!
	assert r.len == 2
	assert r[1].correct_counts == [135, 36]
}

fn test_append_explore_cross_settings_to_file() {
	datafile := 'datasets/iris.tab'
	settingsfile := 'tempfolders/tempfolder_save_settings/iris2.opts'
	explore(opts('-a 1,4 -b 2,7 -u -ms ${settingsfile} ${datafile}', cmd: 'explore'))
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	assert r.len == 7
	// now add another explore
	explore(opts('-a 1,4 -b 2,7 -ms ${settingsfile} ${datafile}', cmd: 'explore'))
	r = read_multiple_opts(settingsfile)!
	assert r.len == 14
}

fn test_append_explore_verify_settings_to_file() {
	datafile := 'datasets/bcw350train'
	testfile := 'datasets/bcw174test'
	settingsfile := 'tempfolders/tempfolder_save_settings/bcw.opts'
	explore(opts('-a 1,4 -ms ${settingsfile} -t ${testfile} ${datafile}', cmd: 'explore'))
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	assert r.len == 5
	// now add another explore
	explore(opts('-w -a 2,4 -ms ${settingsfile} -t ${testfile} ${datafile}', cmd: 'explore'))
	r = read_multiple_opts(settingsfile)!
	assert r.len == 10
}
