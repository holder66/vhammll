// json_test.v

module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_json') {
		os.rmdir_all('tempfolders/tempfolder_json')!
	}
	os.mkdir_all('tempfolders/tempfolder_json')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_json')!
}

fn test_load_classifier_file() ! {
	mut ds := Dataset{}
	mut cl := Classifier{}
	mut tcl := Classifier{}
	mut opts := Options{
		datafile_path:   'datasets/developer.tab'
		outputfile_path: 'tempfolders/tempfolder_json/classifierfile'
		command:         'make' // the make command is necessary to create a proper file
	}
	opts.bins = [2, 4]
	opts.number_of_attributes = [4]
	cl = make_classifier(opts)
	tcl = load_classifier_file('tempfolders/tempfolder_json/classifierfile')!
	assert cl.Parameters == tcl.Parameters
	assert cl.Class == tcl.Class
	assert cl.attribute_ordering == tcl.attribute_ordering
	assert cl.trained_attributes == tcl.trained_attributes
	// dump(cl.History)
	// dump(tcl.History)
	assert cl.history_events[0].event == tcl.history_events[0].event

	opts.bins = [3, 6]
	opts.number_of_attributes = [2]
	ds = load_file('datasets/iris.tab')
	cl = make_classifier(opts)
	tcl = load_classifier_file('tempfolders/tempfolder_json/classifierfile')!
	assert cl.Parameters == tcl.Parameters
	assert cl.Class == tcl.Class
	assert cl.attribute_ordering == tcl.attribute_ordering
	assert cl.trained_attributes == tcl.trained_attributes
	assert cl.history_events[0].event == tcl.history_events[0].event
	assert cl.history_events[0].event_date == tcl.history_events[0].event_date
}

fn test_load_instances_file() ! {
	mut ds := Dataset{}
	mut cl := Classifier{}
	mut vr := ValidateResult{}
	mut tvr := ValidateResult{}
	mut opts := Options{
		outputfile_path: 'tempfolders/tempfolder_json/validate_result.json'
		datafile_path:   'datasets/test.tab'
		testfile_path:   'datasets/test_validate.tab'
	}
	cl = make_classifier(opts)
	vr = validate(cl, opts)!
	tvr = load_instances_file('tempfolders/tempfolder_json/validate_result.json')!
	// dump(vr)
	// dump(tvr)
	assert vr.Class == tvr.Class
	assert vr.inferred_classes == tvr.inferred_classes
	assert vr.counts == tvr.counts

	opts.testfile_path = 'datasets/soybean-large-validate.tab'
	ds = load_file('datasets/soybean-large-train.tab')
	cl = make_classifier(opts)
	vr = validate(cl, opts)!
	tvr = load_instances_file('tempfolders/tempfolder_json/validate_result.json')!
	assert vr.Class == tvr.Class
	assert vr.inferred_classes == tvr.inferred_classes
	assert vr.counts == tvr.counts
}

fn test_append() ? {
	mut opts := Options{}
	opts.datafile_path = 'datasets/breast-cancer-wisconsin-disc.tab'
	opts.number_of_attributes = [9]
	ds := load_file(opts.datafile_path)
	result := cross_validate(opts)
	mut c_s := ClassifierSettings{
		Parameters:    result.Parameters
		BinaryMetrics: result.BinaryMetrics
		Metrics:       result.Metrics
		datafile_path: opts.datafile_path
	}
	append_json_file(c_s, 'tempfolders/tempfolder_json/append_file.opts')
	saved := read_multiple_opts('tempfolders/tempfolder_json/append_file.opts')!
	assert saved[0].correct_counts == c_s.correct_counts
	opts.number_of_attributes = [3]
	opts.weighting_flag = true
	result2 := cross_validate(opts)
	mut c_s2 := ClassifierSettings{
		Parameters:    result2.Parameters
		BinaryMetrics: result2.BinaryMetrics
		Metrics:       result2.Metrics
		datafile_path: opts.datafile_path
	}
	append_json_file(c_s2, 'tempfolders/tempfolder_json/append_file.opts')
	saved2 := read_multiple_opts('tempfolders/tempfolder_json/append_file.opts')!
	assert saved2[0].correct_counts == c_s.correct_counts
	assert saved2[1].correct_counts == c_s2.correct_counts
	assert saved2[0].datafile_path == opts.datafile_path
}
