// ox1_low_binning_test.v

module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_ox1_low_binning') {
		os.rmdir_all('tempfolders/tempfolder_ox1_low_binning')!
	}
	os.mkdir_all('tempfolders/tempfolder_ox1_low_binning')!
}

// fn testsuite_end() ? {
// 	os.rmdir_all('tempfolders/tempfolder_ox1_low_binning')!
// }

fn test_heart_statlog() ? {
	mut datafile := os.join_path(os.home_dir(), 'metabolomics/ox1_train.tab')
	mut settingsfile := os.join_path(os.home_dir(), '.vmodules/holder66/vhammll', 'tempfolders/tempfolder_ox1_low_binning/ox1_low_binning.opts')
	mut resultfile := os.join_path(os.home_dir(), '.vmodules/holder66/vhammll', 'tempfolders/tempfolder_ox1_low_binning/resultfile')
	mut saved_settings := os.join_path(os.home_dir(), '.vmodules/holder66/vhammll', 'src/testdata/ox1_low_binning.opts')

	mut arguments := CliOptions{
		args: ['cross', '-b', '2,2', '-a', '9', '-p', '-wr', '-ms', '${settingsfile}', '-e',
			'${datafile}']
	}
	if !os.is_file(saved_settings) {
		cli(arguments)!
		arguments.args = ['cross', '-b', '2,2', '-a', '7', '-p', '-wr', '-w', '-ms',
			'${settingsfile}', '-e', '${datafile}']
		cli(arguments)!
		arguments.args = ['cross', '-b', '2,2', '-a', '4', '-bp', '-ms', '${settingsfile}', '-e',
			'${datafile}']
		cli(arguments)!
		arguments.args = ['cross', '-b', '2,2', '-a', '7', '-bp', '-ms', '${settingsfile}', '-e',
			'${datafile}']
		cli(arguments)!
		arguments.args = ['cross', '-b', '2,2', '-a', '8', '-wr', '-w', '-ms', '${settingsfile}',
			'-e', '${datafile}']
		cli(arguments)!
	}
	arguments.args = ['display', '-e', '${saved_settings}']
	cli(arguments)!
	for mc in ['0,0,4', '0,1,1,4'] {
		arguments.args = ['cross', '-m#', '${mc}', '-m', '${saved_settings}', '-af', '${datafile}']
		cli(arguments)!
	}
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
