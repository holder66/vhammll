// make_classifier_test
module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_make_classifier') {
		os.rmdir_all('tempfolders/tempfolder_make_classifier')!
	}
	os.mkdir_all('tempfolders/tempfolder_make_classifier')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_make_classifier')!
}

fn test_max_ham_dist() {
	mut opts := Options{
		datafile_path: 'datasets/developer.tab'
		expanded_flag: true
	}
	mut cl := make_classifier(opts)
	assert max_ham_dist(cl.trained_attributes) == 3 + 12 + 10 + 10 + 12 + 7 + 5 + 5
	opts.number_of_attributes = [5]
	opts.bins = [3, 3]
	cl = make_classifier(opts)
	assert max_ham_dist(cl.trained_attributes) == 3 + 7 + 5 + 5 + 3
}

fn test_make_classifier() ? {
	mut opts := Options{
		datafile_path:        'datasets/developer.tab'
		bins:                 [2, 12]
		exclude_flag:         false
		command:              'make'
		number_of_attributes: [6]
		weighting_flag:       true
		weight_ranking_flag:  true
	}
	mut cl := Classifier{}
	cl = make_classifier(opts)
	assert cl.class_counts == {
		'm': 8
		'f': 3
		'X': 2
	}
	assert cl.lcm_class_counts == 24
	assert cl.attribute_ordering == ['height', 'negative', 'weight', 'number', 'age', 'lastname']
	assert cl.maximum_hamming_distance == 54
	opts.datafile_path = 'datasets/class_missing_developer.tab'
	cl = make_classifier(opts)
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
	cl = make_classifier(opts)

	opts.bins = [5, 5]
	opts.number_of_attributes = [1]
	opts.datafile_path = 'datasets/leukemia34test.tab'
	cl = make_classifier(opts)
	assert cl.maximum_hamming_distance == 5
	assert cl.class_counts == {
		'ALL': 20
		'AML': 14
	}
	assert cl.lcm_class_counts == 140
	assert cl.prepurge_class_values_len == 34
}

fn test_make_translation_table() {
	mut array := ['Montreal', 'Ottawa', 'Markham', 'Oakville', 'Oakville', 'Laval', 'Laval', 'Laval',
		'Laval', 'Laval', 'Laval', 'Laval', 'Laval']
	lo := LoadOptions{}
	assert make_translation_table(array, lo.missings) == {
		'Montreal': 1
		'Ottawa':   2
		'Markham':  3
		'Oakville': 4
		'Laval':    5
	}
	array = ['4', '5', '3', '?', '2', '4', '2', '4', '2', '4', '4', '3', '3']
	assert make_translation_table(array, lo.missings) == {
		'4': 1
		'5': 2
		'3': 3
		'?': 0
		'2': 4
	}
}

fn test_save_classifier() ? {
	mut cl := Classifier{}
	mut tcl := Classifier{}
	mut opts := Options{
		datafile_path:        'datasets/developer.tab'
		bins:                 [2, 12]
		exclude_flag:         false
		command:              'make'
		number_of_attributes: [6]
		weighting_flag:       true
		weight_ranking_flag:  true
		outputfile_path:      'tempfolders/tempfolder_make_classifier/classifierfile'
	}
	opts.classifierfile_path = opts.outputfile_path

	cl = make_classifier(opts)

	tcl = load_classifier_file(opts.classifierfile_path)!
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances
	opts.datafile_path = 'datasets/anneal.tab'
	cl = make_classifier(opts)

	tcl = load_classifier_file(opts.classifierfile_path)!
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances
	assert tcl.maximum_hamming_distance == 32
	opts.datafile_path = 'datasets/soybean-large-train.tab'
	cl = make_classifier(opts)

	tcl = load_classifier_file(opts.classifierfile_path)!
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances
	assert tcl.maximum_hamming_distance == 27

	if get_environment().arch_details[0] != '4 cpus' {
		opts.datafile_path = 'datasets/mnist_test.tab'
		cl = make_classifier(opts)

		tcl = load_classifier_file(opts.classifierfile_path)!
		assert tcl.trained_attributes == cl.trained_attributes
		assert tcl.instances == cl.instances
		assert tcl.maximum_hamming_distance == 72
	}
}
