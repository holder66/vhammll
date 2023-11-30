// make_classifier_test
module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder2') {
		os.rmdir_all('tempfolder2')!
	}
	os.mkdir_all('tempfolder2')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder2')!
}

// test_make_classifier
fn test_make_classifier() ? {
	mut opts := Options{
		bins: [2, 12]
		exclude_flag: false
		verbose_flag: false
		command: 'make'
		number_of_attributes: [6]
		show_flag: false
		weighting_flag: true
		weight_ranking_flag: true
	}
	mut ds := load_file('datasets/developer.tab')
	mut cl := Classifier{}
	cl = make_classifier(mut ds, opts)
	assert cl.class_counts == {
		'm': 8
		'f': 3
		'X': 2
	}
	assert cl.lcm_class_counts == 24
	assert cl.attribute_ordering == ['height', 'negative', 'weight', 'number', 'age', 'lastname']
	assert cl.maximum_hamming_distance == 54

	ds = load_file('datasets/class_missing_developer.tab')
	cl = make_classifier(mut ds, opts)
	assert cl.class_counts == {
		'm': 8
		'':  1
		'f': 3
		'X': 2
		'?': 1
	}
	assert cl.lcm_class_counts == 24
	assert cl.attribute_ordering == ['negative', 'height', 'number', 'weight', 'age', 'lastname']
	assert cl.maximum_hamming_distance == 59

	opts.class_missing_purge_flag = true
	// println(ds.data)
	cl = make_classifier(mut ds, opts)

	opts.bins = [5, 5]
	opts.number_of_attributes = [1]
	ds = load_file('datasets/leukemia34test.tab')
	cl = make_classifier(mut ds, opts)
	assert cl.maximum_hamming_distance == 5
	assert cl.Class == Class{
		class_name: 'gene'
		classes: ['ALL', 'AML']
		class_values: ['ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL',
			'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'AML', 'AML', 'AML',
			'AML', 'AML', 'AML', 'AML', 'AML', 'AML', 'AML', 'AML', 'AML', 'AML', 'AML']
		class_counts: {
			'ALL': 20
			'AML': 14
		}
		lcm_class_counts: 140
	}
}

fn test_make_translation_table() {
	mut array := ['Montreal', 'Ottawa', 'Markham', 'Oakville', 'Oakville', 'Laval', 'Laval', 'Laval',
		'Laval', 'Laval', 'Laval', 'Laval', 'Laval']
	dv := DefaultValues{}
	assert make_translation_table(array, dv.missings) == {
		'Montreal': 1
		'Ottawa':   2
		'Markham':  3
		'Oakville': 4
		'Laval':    5
	}
	array = ['4', '5', '3', '?', '2', '4', '2', '4', '2', '4', '4', '3', '3']
	assert make_translation_table(array, dv.missings) == {
		'4': 1
		'5': 2
		'3': 3
		'?': 0
		'2': 4
	}
}

// test_save_classifier
fn test_save_classifier() ? {
	mut ds := Dataset{}
	mut cl := Classifier{}
	mut tcl := Classifier{}
	mut opts := Options{
		bins: [2, 12]
		exclude_flag: false
		verbose_flag: false
		command: 'make'
		number_of_attributes: [6]
		show_flag: false
		weighting_flag: true
		weight_ranking_flag: true
		outputfile_path: 'tempfolder2/classifierfile'
	}
	opts.classifierfile_path = opts.outputfile_path

	ds = load_file('datasets/developer.tab')
	cl = make_classifier(mut ds, opts)

	tcl = load_classifier_file(opts.classifierfile_path)!
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances

	ds = load_file('datasets/anneal.tab')
	cl = make_classifier(mut ds, opts)

	tcl = load_classifier_file(opts.classifierfile_path)!
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances
	assert tcl.maximum_hamming_distance == 32

	ds = load_file('datasets/soybean-large-train.tab')
	cl = make_classifier(mut ds, opts)

	tcl = load_classifier_file(opts.classifierfile_path)!
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances
	assert tcl.maximum_hamming_distance == 27

	if get_environment().arch_details[0] != '4 cpus' {
		path := 'datasets/mnist_test.tab'
		ds = load_file(path)
		cl = make_classifier(mut ds, opts)

		tcl = load_classifier_file(opts.classifierfile_path)!
		assert tcl.trained_attributes == cl.trained_attributes
		assert tcl.instances == cl.instances
		assert tcl.maximum_hamming_distance == 72
	}
}
