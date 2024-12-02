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