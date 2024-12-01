// save_settings_test.v

module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder_save_settings') {
		os.rmdir_all('tempfolder_save_settings')!
	}
	os.mkdir_all('tempfolder_save_settings')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder_save_settings')!
}

fn test_append() ? {
	mut opts := Options{}
	opts.datafile_path = 'datasets/breast-cancer-wisconsin-disc.tab'
	opts.number_of_attributes = [9]
	ds := load_file(opts.datafile_path)
	result := cross_validate(ds, opts)
	mut c_s := ClassifierSettings{
		Parameters:    result.Parameters
		BinaryMetrics: result.BinaryMetrics
		Metrics:       result.Metrics
		datafile_path: opts.datafile_path
	}
	append_json_file(c_s, 'tempfolder_save_settings/append_file.opts')
	saved := read_multiple_opts('tempfolder_save_settings/append_file.opts')!
	assert saved[0].correct_counts == c_s.correct_counts
	opts.number_of_attributes = [3]
	opts.weighting_flag = true
	result2 := cross_validate(ds, opts)
	mut c_s2 := ClassifierSettings{
		Parameters:    result2.Parameters
		BinaryMetrics: result2.BinaryMetrics
		Metrics:       result2.Metrics
		datafile_path: opts.datafile_path
	}
	append_json_file(c_s2, 'tempfolder_save_settings/append_file.opts')
	saved2 := read_multiple_opts('tempfolder_save_settings/append_file.opts')!
	assert saved2[0].correct_counts == c_s.correct_counts
	assert saved2[1].correct_counts == c_s2.correct_counts
	assert saved2[0].datafile_path == opts.datafile_path
}
