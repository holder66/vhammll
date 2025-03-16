// heart-statlog_test.v

module vhammll

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_heart_statlog') {
		os.rmdir_all('tempfolders/tempfolder_heart_statlog')!
	}
	os.mkdir_all('tempfolders/tempfolder_heart_statlog')!
}

// fn testsuite_end() ? {
// 	os.rmdir_all('tempfolders/tempfolder_heart_statlog')!
// }

fn test_heart_statlog() ? {
	mut datafile := os.join_path(os.home_dir(), '.vmodules/holder66/vhammll', 'datasets/UCI/heart-statlog.arff')
	mut settingsfile := os.join_path(os.home_dir(), '.vmodules/holder66/vhammll', 'tempfolders/tempfolder_heart_statlog/heart-statlog.opts')
	mut resultfile := os.join_path(os.home_dir(), '.vmodules/holder66/vhammll', 'tempfolders/tempfolder_heart_statlog/resultfile')

	mut arguments := CliOptions{
		args: ['explore', '-b', '2,8', '-af', '-c', '-ms', '${settingsfile}', '-e', '${datafile}']
	}
	cli(arguments)!
	arguments.args = ['optimals', '-p', '-e', '${settingsfile}']
	cli(arguments)!
	// arguments.args = ['cross', '-a', '2', '-w','-wr','-bp', '-ms', '${settingsfile}', '-e', '${datafile}']
	// cli(arguments)!
	// arguments.args = ['cross', '-a', '6', '-w','-bp','-p', '-ms', '${settingsfile}', '-e', '${datafile}']
	// cli(arguments)!
	// opts := Options{
	// 	datafile_path: datafile
	// 	multiple_classify_options_file_path: settingsfile
	// 	multiple_flag: true
	// 	expanded_flag: true
	// 	command: 'cross'
	// }
	// mut result := cross_validate(load_file(datafile), opts)
	// assert result.correct_counts == [442,230]
}
