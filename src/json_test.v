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
	outputfile := 'tempfolders/tempfolder_json/classifierfile'
	mut cl := Classifier{}
	mut tcl := Classifier{}

	cl = make_classifier(opts('-a 4 -b 2,4 -o ${outputfile} datasets/developer.tab', cmd: 'make'))
	tcl = load_classifier_file(outputfile)!
	assert cl.Parameters == tcl.Parameters
	assert cl.Class == tcl.Class
	assert cl.attribute_ordering == tcl.attribute_ordering
	assert cl.trained_attributes == tcl.trained_attributes
	assert cl.history_events[0].event == tcl.history_events[0].event

	cl = make_classifier(opts('-a 2 -b 3,6 -o ${outputfile} datasets/iris.tab', cmd: 'make'))
	tcl = load_classifier_file(outputfile)!
	assert cl.Parameters == tcl.Parameters
	assert cl.Class == tcl.Class
	assert cl.attribute_ordering == tcl.attribute_ordering
	assert cl.trained_attributes == tcl.trained_attributes
	assert cl.history_events[0].event == tcl.history_events[0].event
	assert cl.history_events[0].event_date == tcl.history_events[0].event_date
}

fn test_load_instances_file() ! {
	outputfile := 'tempfolders/tempfolder_json/validate_result.json'
	mut cl := Classifier{}
	mut vr := ValidateResult{}
	mut tvr := ValidateResult{}

	cl = make_classifier(opts('-o ${outputfile} -t datasets/test_validate.tab datasets/test.tab',
		cmd: 'make'
	))
	vr = validate(cl, opts('-o ${outputfile} -t datasets/test_validate.tab datasets/test.tab',
		cmd: 'validate'
	))!
	tvr = load_instances_file(outputfile)!
	assert vr.Class == tvr.Class
	assert vr.inferred_classes == tvr.inferred_classes
	assert vr.counts == tvr.counts

	cl = make_classifier(opts('-o ${outputfile} -t datasets/soybean-large-validate.tab datasets/soybean-large-train.tab',
		cmd: 'make'
	))
	vr = validate(cl, opts('-o ${outputfile} -t datasets/soybean-large-validate.tab datasets/soybean-large-train.tab',
		cmd: 'validate'
	))!
	tvr = load_instances_file(outputfile)!
	assert vr.Class == tvr.Class
	assert vr.inferred_classes == tvr.inferred_classes
	assert vr.counts == tvr.counts
}

fn test_append() ? {
	datafile := 'datasets/breast-cancer-wisconsin-disc.tab'

	result := cross_validate(opts('-a 9 ${datafile}', cmd: 'cross'))
	mut c_s := ClassifierSettings{
		Parameters:    result.Parameters
		BinaryMetrics: result.BinaryMetrics
		Metrics:       result.Metrics
		datafile_path: datafile
	}
	append_json_file(c_s, 'tempfolders/tempfolder_json/append_file.opts')
	saved := read_multiple_opts('tempfolders/tempfolder_json/append_file.opts')!
	assert saved[0].correct_counts == c_s.correct_counts

	result2 := cross_validate(opts('-w -a 3 ${datafile}', cmd: 'cross'))
	mut c_s2 := ClassifierSettings{
		Parameters:    result2.Parameters
		BinaryMetrics: result2.BinaryMetrics
		Metrics:       result2.Metrics
		datafile_path: datafile
	}
	append_json_file(c_s2, 'tempfolders/tempfolder_json/append_file.opts')
	saved2 := read_multiple_opts('tempfolders/tempfolder_json/append_file.opts')!
	assert saved2[0].correct_counts == c_s.correct_counts
	assert saved2[1].correct_counts == c_s2.correct_counts
	assert saved2[0].datafile_path == datafile
}
