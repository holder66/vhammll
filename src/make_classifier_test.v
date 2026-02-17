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
	mut cl := make_classifier(opts('-e datasets/developer.tab', cmd: 'make'))
	assert max_ham_dist(cl.trained_attributes) == 3 + 12 + 10 + 10 + 12 + 7 + 5 + 5
	cl = make_classifier(opts('-e -a 5 -b 3,3 datasets/developer.tab', cmd: 'make'))
	assert max_ham_dist(cl.trained_attributes) == 3 + 7 + 5 + 5 + 3
}

fn test_make_classifier() ? {
	mut cl := make_classifier(opts('-w -wr -a 6 -b 2,12 datasets/developer.tab', cmd: 'make'))
	assert cl.class_counts == {
		'm': 8
		'f': 3
		'X': 2
	}
	assert cl.lcm_class_counts == 24
	assert cl.attribute_ordering == ['height', 'negative', 'weight', 'number', 'age', 'lastname']
	assert cl.maximum_hamming_distance == 54
	cl = make_classifier(opts('-w -wr -a 6 -b 2,12 datasets/class_missing_developer.tab',
		cmd: 'make'
	))
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

	cl = make_classifier(opts('-pmc -w -wr -a 6 -b 2,12 datasets/class_missing_developer.tab',
		cmd: 'make'
	))

	cl = make_classifier(opts('-w -wr -a 1 -b 5,5 datasets/leukemia34test.tab', cmd: 'make'))
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
	outputfile := 'tempfolders/tempfolder_make_classifier/classifierfile'
	mut cl := Classifier{}
	mut tcl := Classifier{}

	cl = make_classifier(opts('-w -wr -a 6 -b 2,12 -o ${outputfile} datasets/developer.tab',
		cmd: 'make'
	))
	tcl = load_classifier_file(outputfile)!
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances

	cl = make_classifier(opts('-w -wr -a 6 -b 2,12 -o ${outputfile} datasets/anneal.tab',
		cmd: 'make'
	))
	tcl = load_classifier_file(outputfile)!
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances
	assert tcl.maximum_hamming_distance == 32

	cl = make_classifier(opts('-w -wr -a 6 -b 2,12 -o ${outputfile} datasets/soybean-large-train.tab',
		cmd: 'make'
	))
	tcl = load_classifier_file(outputfile)!
	assert tcl.trained_attributes == cl.trained_attributes
	assert tcl.instances == cl.instances
	assert tcl.maximum_hamming_distance == 27

	if get_environment().arch_details[0] != '4 cpus' {
		cl = make_classifier(opts('-w -wr -a 6 -b 2,12 -o ${outputfile} datasets/mnist_test.tab',
			cmd: 'make'
		))
		tcl = load_classifier_file(outputfile)!
		assert tcl.trained_attributes == cl.trained_attributes
		assert tcl.instances == cl.instances
		assert tcl.maximum_hamming_distance == 72
	}
}
