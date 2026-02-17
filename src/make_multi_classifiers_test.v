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
	datafile := 'datasets/leukemia38train.tab'
	testfile := 'datasets/leukemia34test.tab'
	settingsfile := 'tempfolders/tempfolder_make_multi_classifiers/leuk.opts'

	// populate a settings file, doing individual verifications
	result0 := verify(opts('-e -ma -mt -p -wr -a 1 -b 5,5 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
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
	result1 := verify(opts('-e -ma -mt -a 6 -b 1,10 -ms ${settingsfile} -t ${testfile} ${datafile}',
		cmd: 'verify'
	))
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
	// test that the settings file was saved, and is the right length
	assert os.is_file(settingsfile)
	mut r := read_multiple_opts(settingsfile)!
	assert r.len == 2

	// test make_multi_classifiers
	mut settings := read_multiple_opts(settingsfile)!
	mut ds := load_file(datafile)
	mut cll := make_multi_classifiers(mut ds, settings, []int{})
	assert cll.len == 2
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
