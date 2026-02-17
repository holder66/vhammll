// make_multi_classifiers_test.v

module vhammll

import os

fn testsuite_begin() ! {
	if os.is_dir('tempfolders/tempfolder_make_multi_classifiers') {
		os.rmdir_all('tempfolders/tempfolder_make_multi_classifiers')!
	}
	os.mkdir_all('tempfolders/tempfolder_make_multi_classifiers')!
}

fn testsuite_end() ! {
	os.rmdir_all('tempfolders/tempfolder_make_multi_classifiers')!
}

fn test_make_multi_classifiers() {
	mut opts := Options{
		concurrency_flag:     false
		break_on_all_flag:    true
		total_nn_counts_flag: true
		// expanded_flag: true
		command: 'verify'
	}
	// populate a settings file, doing individual verifications
	opts.datafile_path = 'datasets/leukemia38train.tab'
	opts.testfile_path = 'datasets/leukemia34test.tab'
	opts.settingsfile_path = 'tempfolders/tempfolder_make_multi_classifiers/leuk.opts'
	opts.append_settings_flag = true
	opts.number_of_attributes = [1]
	opts.bins = [5, 5]
	opts.purge_flag = true
	opts.weight_ranking_flag = true
	result0 := verify(opts)
	assert result0.confusion_matrix_map == {
		'ALL': {
			'ALL': 17.0
			'AML': 3.0
		}
		'AML': {
			'ALL': 0.0
			'AML': 14.0
		}
	}, 'test verify with 1 attribute and binning [5,5]'
	opts.purge_flag = false
	opts.weight_ranking_flag = false
	opts.number_of_attributes = [6]
	opts.bins = [1, 10]
	result1 := verify(opts)
	assert result1.confusion_matrix_map == {
		'ALL': {
			'ALL': 20.0
			'AML': 0.0
		}
		'AML': {
			'ALL': 5.0
			'AML': 9.0
		}
	}
	// test that the settings file was saved, and
	// is the right length
	assert os.is_file(opts.settingsfile_path)
	mut r := read_multiple_opts(opts.settingsfile_path)!
	assert r.len == 2

	opts.show_attributes_flag = true
	// display_file(opts.settingsfile_path, opts)
	// test verify with multiple_classify_options_file_path
	opts.multiple_flag = true
	opts.multiple_classify_options_file_path = opts.settingsfile_path
	opts.append_settings_flag = false
	mut settings := read_multiple_opts(opts.settingsfile_path)!
	mut cll := []Classifier{}
	mut ds := load_file(opts.datafile_path)
	cll = make_multi_classifiers(mut ds, settings, []int{})
	assert cll.len == 2
	// assert cll[0].attribute_ordering == ['APLP2']
	assert cll[0].trained_attributes.len > 0
	assert cll[0].attribute_ordering.len == 1
	assert cll[1].trained_attributes['CST3'].rank_value == 94.73684
	assert cll[1].attribute_ordering.len == 6
	// now try for just one classifier (index 1, which has 6 attributes)
	cll = make_multi_classifiers(mut ds, settings, [1])
	assert cll.len == 1
	assert cll[0].trained_attributes['CST3'].rank_value == 94.73684
	assert cll[0].attribute_ordering.len == 6
	// non-existent classifier_id should be skipped, returning empty
	cll = make_multi_classifiers(mut ds, settings, [99])
	assert cll.len == 0
}
