// append_test.v
module vhammll

import os

fn testsuite_begin() ! {
	if os.is_dir('tempfolders/tempfolder_append') {
		os.rmdir_all('tempfolders/tempfolder_append')!
	}
	os.mkdir_all('tempfolders/tempfolder_append')!
}

fn testsuite_end() ! {
	os.rmdir_all('tempfolders/tempfolder_append')!
}

fn test_append() ! {
	mut opts := Options{
		command:          'append'
		concurrency_flag: false
		weighting_flag:   true
		// show_flag: true
		// verbose_flag: true
	}

	mut cl := Classifier{}
	mut tcl := Classifier{}
	mut ds := Dataset{}
	mut val_results := ValidateResult{}
	// create the classifier file and save it
	opts.outputfile_path = 'tempfolders/tempfolder_append/classifierfile'
	opts.datafile_path = 'datasets/test.tab'
	cl = make_classifier(opts)
	// do a validation and save the result
	opts.outputfile_path = 'tempfolders/tempfolder_append/instancesfile'
	opts.testfile_path = 'datasets/test_validate.tab'
	val_results = validate(cl, opts)!
	// now do the append, first from val_results, and
	// saving the extended classifier
	opts.outputfile_path = 'tempfolders/tempfolder_append/extclassifierfile'
	tcl = append_instances(cl, val_results, opts)
	// dump(tcl.history.len)
	assert tcl.class_counts == {
		'f': 9
		'm': 7
	}
	// repeat the append, this time with the saved files
	mut scl := load_classifier_file('tempfolders/tempfolder_append/extclassifierfile')!
	// dump(scl.history_events)
	stcl := append_instances(scl, load_instances_file('tempfolders/tempfolder_append/instancesfile')!,
		opts)
	// dump(stcl.history.len)
	assert stcl.instances.len == 26
	assert stcl.history_events.len == 3

	// test if the appended classifier works as a classifier
	opts.testfile_path = 'datasets/test_verify.tab'
	opts.classifierfile_path = 'tempfolders/tempfolder_append/extclassifierfile'
	// cl = load_classifier_file(opts.classifierfile_path)!
	mut result := verify(opts)
	assert result.correct_count == 10
	assert result.wrong_count == 0

	// test with the soybean files
	// create the classifier file and save it
	opts.outputfile_path = 'tempfolders/tempfolder_append/classifierfile'
	opts.datafile_path = 'datasets/soybean-large-train.tab'
	cl = make_classifier(opts)
	// do a validation and save the result
	opts.outputfile_path = 'tempfolders/tempfolder_append/instancesfile'
	opts.testfile_path = 'datasets/soybean-large-validate.tab'
	val_results = validate(cl, opts)!
	// now do the append

	opts.outputfile_path = 'tempfolders/tempfolder_append/extended_classifierfile'
	tcl = append_instances(cl, val_results, opts)
	assert tcl.class_counts == {
		'diaporthe-stem-canker':       20
		'charcoal-rot':                20
		'rhizoctonia-root-rot':        20
		'phytophthora-rot':            88
		'brown-stem-rot':              44
		'powdery-mildew':              20
		'downy-mildew':                19
		'brown-spot':                  85
		'bacterial-blight':            19
		'bacterial-pustule':           19
		'purple-seed-stain':           21
		'anthracnose':                 44
		'phyllosticta-leaf-spot':      23
		'alternarialeaf-spot':         93
		'frog-eye-leaf-spot':          95
		'diaporthe-pod-&-stem-blight': 15
		'cyst-nematode':               14
		'2-4-d-injury':                16
		'herbicide-injury':            8
	}

	// test if the appended classifier works as a classifier
	opts.testfile_path = 'datasets/soybean-large-test.tab'
	opts.classifierfile_path = 'tempfolders/tempfolder_append/extended_classifierfile'
	// cl = load_classifier_file(opts.classifierfile_path)!
	result = verify(opts)
	assert result.correct_count == 333
	assert result.wrong_count == 43
}
