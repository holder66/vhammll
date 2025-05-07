// multi_cross_test.v

module vhammll

import os
// import vtl

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_multi_cross') {
		os.rmdir_all('tempfolders/tempfolder_multi_cross')!
	}
	os.mkdir_all('tempfolders/tempfolder_multi_cross')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_multi_cross')!
}

fn test_multiple_crossvalidate() ? {
	mut result := CrossVerifyResult{}
	datafile := 'datasets/developer.tab'
	savedsettings := 'src/testdata/3_class.opts'
	if !os.is_file(savedsettings) {
		explore(opts('-wr -ms ${savedsettings} ${datafile}', cmd: 'explore'))
	}
	result = cross_validate(opts('-a 1 -b 1,3 ${datafile}', cmd: 'cross'))
	assert result.correct_counts == [8, 3, 2]
	result = cross_validate(opts('-m ${savedsettings} -m# 6 ${datafile}'))
	assert result.correct_counts == [7, 0, 0]
	result = cross_validate(opts('-m ${savedsettings} -m# 3 ${datafile}'))
	assert result.correct_counts == [8, 0, 0]
	result = cross_validate(opts('-af -m ${savedsettings} -m# 0,1,2 ${datafile}'))
	assert result.correct_counts == [8, 3, 2]
}

fn test_multiple_crossvalidate_mixed_attributes_developer() ? {
	datafile := 'datasets/2_class_developer.tab'
	settingsfile := 'tempfolders/tempfolder_multi_cross/2_class_big.opts'
	er := explore(opts('-af -b 2,7 -ms ${settingsfile} ${datafile}', cmd: 'explore'))
	opt_res := optimals(settingsfile, opts('-s -p -cl 3,4'))
	assert opt_res.RocData.classifiers == ['6', '0', '43', '22']
	assert opt_res.mcc_max_classifiers == [22, 23, 24, 78, 79, 134, 135, 136, 190, 191, 192]
	result := cross_validate(opts('-m# 22,23,9 -m ${settingsfile} -af ${datafile}'))
	assert result.correct_counts == [9,2]
}

fn test_multiple_crossvalidate_only_discrete_attributes() ? {
	// expanded_flag := '-e'
	expanded_flag := ''
	mut datafile := 'datasets/breast-cancer-wisconsin-disc.tab'
	mut settingsfile := 'tempfolders/tempfolder_multi_cross/breast-cancer-wisconsin-disc.opts'
	mut resultfile := 'tempfolders/tempfolder_multi_cross/resultfile'
	cross_validate(opts('-a 9 -w -ms ${settingsfile} ${expanded_flag} ${datafile}', cmd: 'cross'))
	cross_validate(opts('-a 2 -w -ms ${settingsfile} ${expanded_flag} ${datafile}', cmd: 'cross'))
	cross_validate(opts('-a 2 -w -wr -ms ${settingsfile} ${expanded_flag} ${datafile}', cmd: 'cross'))
	cross_validate(opts('-a 6 -w -bp -p -ms ${settingsfile} ${expanded_flag} ${datafile}',
		cmd: 'cross'
	))
	assert cross_validate(opts('-m ${settingsfile} ${expanded_flag} ${datafile}')).correct_counts == [
		442,
		230,
	]
}

fn test_multiple_crossvalidate_mixed_attributes() ? {
	datafile := 'datasets/UCI/heart-statlog.arff'
	settingsfile := 'tempfolders/tempfolder_multi_cross/heart-statlog.opts'
	savedsettings := 'src/testdata/heart-statlog.opts'
	mut result := optimals(savedsettings, opts('-p -cl 2,2'))
	assert result.multi_classifier_combinations_for_auc.first().auc == 0.8500000000000001
	// assert result.multi_classifier_combinations_for_auc.first().classifier_ids == [40, 120]
	mut res := cross_validate(opts('-m ${savedsettings} -m# 80 ${datafile}'))
	assert res.correct_counts == [96, 135]
	for combo in result.multi_classifier_combinations_for_auc.filter(it.auc == 0.8484166666666667).map(it.classifier_ids) {
		str_combo := combo.map('${it}').join(',')
		res = cross_validate(opts('-m ${savedsettings} -m# ${str_combo} -ma -mc -mt ${datafile}'))
		assert res.correct_counts == [97, 129]
	}
}

fn test_multiple_crossvalidate_multi_classes() {
	datafile := 'datasets/anneal.tab'
	savedsettings := 'src/testdata/anneal.opts'
	if !os.is_file(savedsettings) {
		explore_result := explore(opts('-a 2,10 -b 2,10 -ms ${savedsettings} ${datafile}',
			cmd: 'explore'
		))
	}
	optimals(savedsettings, opts('-p'))
	mut result := cross_validate(opts('-m# 0 -m ${savedsettings} ${datafile}'))
	assert result.correct_counts == [675, 38, 7, 67, 97]
	result = cross_validate(opts('-m# 0,4,7 -mc -m ${savedsettings} ${datafile}'))
	assert result.correct_counts == [661, 40, 2, 67, 97]
}
