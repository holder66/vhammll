// load_file_test.v
module vhammll

import os

fn testsuite_begin() ! {
	if os.is_dir('tempfolder1') {
		os.rmdir_all('tempfolder1')!
	}
	os.mkdir_all('tempfolder1')!
}

fn testsuite_end() ! {
	os.rmdir_all('tempfolder1')!
}

fn test_file_type() {
	assert file_type('datasets/developer.tab') == 'orange_newer'
	assert file_type('datasets/iris.tab') == 'orange_older'
	assert file_type('datasets/ESL.arff') == 'arff'
	home_dir := os.home_dir()
	// if os.exists(home_dir + '/UKDA') {
	// 	assert file_type(home_dir + '/UKDA/UKDA-8156-tab/tab/mcs6_cm_accelerometer_derived.tab') == 'UKDA'
	// } else {
	// 	println('UKDA files not found; skipping tests on UKDA datasets')
	// }
}

/*
The existing attribute type codes are, for orange-newer:
Attribute names in the column header can be preceded with a label followed by a hash. Use c for class and m for meta attribute, i to ignore a column, w for weights column, and C, D, T, S for continuous, discrete, time, and string attribute types. Examples: C#mph, mS#name, i#dummy.
If no prefix, treat numbers as continuous, otherwise discrete
*/

fn test_infer_type_from_data() {
	lo := LoadOptions{}
	assert infer_type_from_data([], lo) == 'i' // ignore if no data
	assert infer_type_from_data(['1', '2', '3'], lo) == 'D' // all integers,
	assert infer_type_from_data(['3', '3', '3'], lo) == 'i'
	assert infer_type_from_data(['', '', '', '?'], lo) == 'i'
	assert infer_type_from_data(['', '?', '1', '2', '3'], lo) == 'D'
	assert infer_type_from_data(['', '?', '1', '2', '3', '10'], lo) == 'D'
	assert infer_type_from_data(['', '?', '1', '2', '3', '10', '-8', '-1'], lo) == 'C'
	assert infer_type_from_data(['', '?', '1', '2', '3', '22'], lo) == 'C'
	assert infer_type_from_data(['i', '', 'w', 'cD', 'C', 'm', '', 'T', 'S', ''], lo) == 'D'
	assert infer_type_from_data(['3.14', '2'], lo) == 'C'
	assert infer_type_from_data(['?', '', '3.14', '2'], lo) == 'C'
	assert infer_type_from_data(['?', '', '4800', '3.14', '2'], lo) == 'C'
}

fn test_load_file() {
	mut ds := Dataset{}
	ds = load_file('datasets/developer.tab')
	assert ds.Class == Class{
		class_name:                 'gender'
		class_index:                3
		classes:                    ['m', 'f', 'X']
		class_values:               ['m', 'm', 'm', 'f', 'f', 'm', 'X', 'f', 'm', 'm', 'm', 'X',
			'm']
		missing_class_values:       []
		class_counts:               {
			'm': 8
			'f': 3
			'X': 2
		}
		lcm_class_counts:           0
		prepurge_class_values_len:  13
		postpurge_class_counts:     {}
		postpurge_lcm_class_counts: 0
	}

	assert ds.attribute_names == ['firstname', 'lastname', 'age', 'gender', 'height', 'weight',
		'SEC', 'city', 'number', 'negative']
	assert ds.attribute_types == ['i', 'D', 'C', 'c', 'C', 'C', 'D', 'D', 'C', 'C']
	// println(ds.useful_continuous_attributes)
	assert is_nan(ds.useful_continuous_attributes[4][5])
	assert is_nan(ds.useful_continuous_attributes[9][9])
	assert ds.useful_discrete_attributes[6] == ['4', '5', '3', '?', '2', '4', '2', '4', '2', '4',
		'4', '3', '3']
}

fn test_load_file_with_purging() ! {
	// first, no purging
	mut ds := Dataset{}
	mut datafile := 'datasets/class_missing_developer.tab'
	ds = load_file(datafile)
	assert ds.Class == Class{
		class_name:                 'gender'
		class_index:                3
		classes:                    ['m', '', 'f', 'X', '?']
		class_values:               ['m', 'm', 'm', '', 'f', 'f', 'm', 'X', '?', 'f', 'm', 'm',
			'm', 'X', 'm']
		missing_class_values:       []
		class_counts:               {
			'm': 8
			'':  1
			'f': 3
			'X': 2
			'?': 1
		}
		lcm_class_counts:           0
		prepurge_class_values_len:  15
		postpurge_class_counts:     {}
		postpurge_lcm_class_counts: 0
	}

	// repeat with purging of instances where the class value is missing
	ds = load_file(datafile, class_missing_purge_flag: true)
	assert ds.Class == Class{
		class_name:                 'gender'
		class_index:                3
		classes:                    ['m', 'f', 'X']
		class_values:               ['m', 'm', 'm', 'f', 'f', 'm', 'X', 'f', 'm', 'm', 'm', 'X',
			'm']
		missing_class_values:       []
		class_counts:               {
			'm': 8
			'f': 3
			'X': 2
		}
		lcm_class_counts:           0
		prepurge_class_values_len:  15
		postpurge_class_counts:     {}
		postpurge_lcm_class_counts: 0
	}
}

fn test_load_classifier_file() ! {
	mut ds := Dataset{}
	mut cl := Classifier{}
	mut tcl := Classifier{}
	mut opts := Options{
		outputfile_path: 'tempfolder1/classifierfile'
		command:         'make' // the make command is necessary to create a proper file
	}
	opts.bins = [2, 4]
	opts.number_of_attributes = [4]
	ds = load_file('datasets/developer.tab')
	cl = make_classifier(ds, opts)
	tcl = load_classifier_file('tempfolder1/classifierfile')!
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
	tcl = load_classifier_file('tempfolder1/classifierfile')!
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
		outputfile_path: 'tempfolder1/validate_result.json'
	}
	opts.testfile_path = 'datasets/test_validate.tab'
	ds = load_file('datasets/test.tab')
	cl = make_classifier(ds, opts)
	vr = validate(cl, opts)!
	tvr = load_instances_file('tempfolder1/validate_result.json')!
	assert vr.Class == tvr.Class
	assert vr.inferred_classes == tvr.inferred_classes
	assert vr.counts == tvr.counts

	opts.testfile_path = 'datasets/soybean-large-validate.tab'
	ds = load_file('datasets/soybean-large-train.tab')
	cl = make_classifier(ds, opts)
	// println('cl: $cl')
	vr = validate(cl, opts)!
	tvr = load_instances_file('tempfolder1/validate_result.json')!
	assert vr.Class == tvr.Class
	assert vr.inferred_classes == tvr.inferred_classes
	assert vr.counts == tvr.counts
}
