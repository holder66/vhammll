// json_test.v

module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder_json') {
		os.rmdir_all('tempfolder_json')!
	}
	os.mkdir_all('tempfolder_json')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder_json')!
}

fn test_load_classifier_file() ! {
	mut ds := Dataset{}
	mut cl := Classifier{}
	mut tcl := Classifier{}
	mut opts := Options{
		outputfile_path: 'tempfolder_json/classifierfile'
		command:         'make' // the make command is necessary to create a proper file
	}
	opts.bins = [2, 4]
	opts.number_of_attributes = [4]
	ds = load_file('datasets/developer.tab')
	cl = make_classifier(ds, opts)
	tcl = load_classifier_file('tempfolder_json/classifierfile')!
	assert cl.Parameters == tcl.Parameters
	assert cl.Class == tcl.Class
	assert cl.attribute_ordering == tcl.attribute_ordering
	assert cl.trained_attributes == tcl.trained_attributes
	assert cl.history[0].event == tcl.history[0].event
	// assert cl.history[0].event_date == tcl.history[0].event_date

	opts.bins = [3, 6]
	opts.number_of_attributes = [2]
	ds = load_file('datasets/iris.tab')
	cl = make_classifier(ds, opts)
	tcl = load_classifier_file('tempfolder_json/classifierfile')!
	assert cl.Parameters == tcl.Parameters
	assert cl.Class == tcl.Class
	assert cl.attribute_ordering == tcl.attribute_ordering
	assert cl.trained_attributes == tcl.trained_attributes
	assert cl.history[0].event == tcl.history[0].event
	// assert cl.history[0].event_date == tcl.history[0].event_date
}

fn test_load_instances_file() ! {
	mut ds := Dataset{}
	mut cl := Classifier{}
	mut vr := ValidateResult{}
	mut tvr := ValidateResult{}
	mut opts := Options{
		outputfile_path: 'tempfolder_json/validate_result.json'
	}
	opts.testfile_path = 'datasets/test_validate.tab'
	ds = load_file('datasets/test.tab')
	cl = make_classifier(ds, opts)
	vr = validate(cl, opts)!
	tvr = load_instances_file('tempfolder_json/validate_result.json')!
	assert vr.Class == tvr.Class
	assert vr.inferred_classes == tvr.inferred_classes
	assert vr.counts == tvr.counts

	opts.testfile_path = 'datasets/soybean-large-validate.tab'
	ds = load_file('datasets/soybean-large-train.tab')
	cl = make_classifier(ds, opts)
	vr = validate(cl, opts)!
	tvr = load_instances_file('tempfolder_json/validate_result.json')!
	assert vr.Class == tvr.Class
	assert vr.inferred_classes == tvr.inferred_classes
	assert vr.counts == tvr.counts
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
	append_json_file(c_s, 'tempfolder_json/append_file.opts')
	saved := read_multiple_opts('tempfolder_json/append_file.opts')!
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
	append_json_file(c_s2, 'tempfolder_json/append_file.opts')
	saved2 := read_multiple_opts('tempfolder_json/append_file.opts')!
	assert saved2[0].correct_counts == c_s.correct_counts
	assert saved2[1].correct_counts == c_s2.correct_counts
	assert saved2[0].datafile_path == opts.datafile_path
}
