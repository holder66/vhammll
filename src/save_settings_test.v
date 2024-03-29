// save_settings_test.v

module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder5') {
		os.rmdir_all('tempfolder5')!
	}
	os.mkdir_all('tempfolder5')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder5')!
}

fn test_append() ? {
	mut opts := Options{}
	opts.datafile_path = 'datasets/breast-cancer-wisconsin-disc.tab'
	opts.number_of_attributes = [9]
	ds := load_file(opts.datafile_path)
	result := cross_validate(ds, opts)
	mut c_s := ClassifierSettings{
		Parameters: result.Parameters
		BinaryMetrics: result.BinaryMetrics
		Metrics: result.Metrics
	}
	append_json_file(c_s, 'tempfolder5/append_file.opts')
	saved := read_multiple_opts('tempfolder5/append_file.opts')!
	assert saved.multiple_classifier_settings[0] == c_s
	opts.number_of_attributes = [3]
	opts.weighting_flag = true
	result2 := cross_validate(ds, opts)
	mut c_s2 := ClassifierSettings{
		Parameters: result2.Parameters
		BinaryMetrics: result2.BinaryMetrics
		Metrics: result2.Metrics
	}
	append_json_file(c_s2, 'tempfolder5/append_file.opts')
	saved2 := read_multiple_opts('tempfolder5/append_file.opts')!
	assert saved2.multiple_classifier_settings[0] == c_s
	assert saved2.multiple_classifier_settings[1] == c_s2
}
