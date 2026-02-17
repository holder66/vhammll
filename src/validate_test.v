// validate_test.v
module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder3') {
		os.rmdir_all('tempfolder3')!
	}
	os.mkdir_all('tempfolder3')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder3')!
}

fn test_validate_save_result() ? {
	mut result := ValidateResult{}
	mut test_result := ValidateResult{}
	mut cl := Classifier{}
}

fn test_kaggle() ! {
	kagglefile := 'tempfolder3/kagglefile'
	datafile := 'datasets/test.tab'
	testfile := 'datasets/test_validate.tab'

	cl := make_classifier(opts('-c -a 2 -b 2,3 -ka ${kagglefile} -t ${testfile} ${datafile}',
		cmd: 'make'
	))
	result := validate(cl, opts('-c -a 2 -b 2,3 -ka ${kagglefile} -t ${testfile} ${datafile}',
		cmd: 'validate'
	))!
	assert result.inferred_classes == ['f', 'f', 'f', 'm', 'm', 'm', 'f', 'f', 'm', 'f']
	assert result.counts == [[1, 0], [1, 0], [1, 0], [0, 1], [0, 1],
		[0, 1], [1, 0], [1, 0], [0, 1], [3, 0]]
	content := os.read_lines(kagglefile) or { panic('failed to open ${kagglefile}') }
	assert content == ['id,gender', '10,f', '11,f', '12,f', '13,m', '14,m', '15,m', '16,f', '17,f',
		'18,m', '19,f']
	println('Done kaggle test')
}

// test_validate
fn test_validate() ? {
	mut result := ValidateResult{}
	mut cl := Classifier{}

	// test validate with a non-saved classifier
	cl = make_classifier(opts('-c -a 2 -b 2,3 -t datasets/test_validate.tab datasets/test.tab',
		cmd: 'make'
	))
	result = validate(cl, opts('-c -a 2 -b 2,3 -t datasets/test_validate.tab datasets/test.tab',
		cmd: 'validate'
	))!
	assert result.inferred_classes == ['f', 'f', 'f', 'm', 'm', 'm', 'f', 'f', 'm', 'f']
	assert result.counts == [[1, 0], [1, 0], [1, 0], [0, 1], [0, 1],
		[0, 1], [1, 0], [1, 0], [0, 1], [3, 0]]
	println('Done test.tab')

	cl = make_classifier(opts('-c -a 4 -b 2,4 -t datasets/bcw174validate datasets/bcw350train',
		cmd: 'make'
	))
	result = validate(cl, opts('-c -a 4 -b 2,4 -t datasets/bcw174validate datasets/bcw350train',
		cmd: 'validate'
	))!
	assert result.inferred_classes == ['benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'benign', 'benign',
		'malignant', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'benign',
		'benign', 'malignant', 'malignant', 'malignant', 'malignant', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant',
		'benign', 'benign', 'benign', 'malignant', 'benign', 'malignant', 'benign', 'malignant',
		'malignant', 'malignant', 'benign', 'malignant', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'malignant', 'benign',
		'benign', 'malignant', 'benign', 'malignant', 'malignant', 'malignant', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'malignant', 'benign', 'benign', 'malignant', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'malignant', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'malignant', 'malignant', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'malignant']
	assert result.counts == [[99, 0], [99, 0], [99, 0], [4, 0],
		[14, 0], [2, 7], [4, 0], [14, 0], [99, 0], [99, 0], [4, 0],
		[99, 0], [5, 0], [99, 0], [99, 0], [6, 0], [99, 0], [1, 0],
		[99, 0], [4, 0], [99, 0], [0, 16], [14, 0], [14, 0], [0, 1],
		[99, 0], [99, 0], [4, 0], [18, 12], [99, 0], [1, 0], [1, 0],
		[99, 0], [99, 0], [99, 0], [99, 0], [99, 0], [99, 0],
		[99, 0], [99, 0], [0, 4], [5, 0], [3, 0], [0, 1], [0, 1],
		[0, 6], [0, 3], [99, 0], [99, 0], [0, 5], [5, 0], [99, 0],
		[99, 0], [99, 0], [99, 0], [5, 0], [0, 4], [0, 2], [99, 0],
		[5, 0], [99, 0], [0, 1], [99, 0], [0, 1], [99, 0], [0, 2],
		[0, 1], [0, 1], [5, 0], [0, 4], [99, 0], [5, 0], [4, 0],
		[99, 0], [3, 1], [99, 0], [14, 0], [99, 0], [1, 2], [0, 1],
		[0, 1], [99, 0], [99, 0], [0, 4], [99, 0], [0, 1], [0, 2],
		[0, 1], [1, 0], [14, 0], [4, 0], [99, 0], [1, 0], [99, 0],
		[99, 0], [99, 0], [2, 0], [5, 0], [99, 0], [14, 0], [3, 0],
		[2, 0], [4, 0], [99, 0], [99, 0], [1, 0], [99, 0], [99, 0],
		[1, 10], [99, 0], [2, 0], [0, 8], [2, 0], [99, 0], [99, 0],
		[99, 0], [99, 0], [99, 0], [99, 0], [99, 0], [99, 0],
		[4, 0], [99, 0], [0, 9], [99, 0], [6, 0], [2, 0], [99, 0],
		[99, 0], [99, 0], [99, 0], [99, 0], [0, 1], [1, 5], [99, 0],
		[99, 0], [99, 0], [4, 0], [4, 0], [99, 0], [99, 0], [4, 0],
		[99, 0], [3, 8], [0, 2], [1, 0], [2, 0], [99, 0], [1, 0],
		[99, 0], [2, 0], [5, 0], [99, 0], [99, 0], [99, 0], [0, 2],
		[0, 16], [99, 0], [99, 0], [99, 0], [99, 0], [99, 0],
		[99, 0], [99, 0], [99, 0], [99, 0], [0, 1], [99, 0], [99, 0],
		[1, 0], [99, 0], [0, 2], [3, 8], [0, 1]]
	println('Done with bcw350train')

	// repeat with weighting
	cl = make_classifier(opts('-c -w -a 4 -b 2,4 -t datasets/bcw174validate datasets/bcw350train',
		cmd: 'make'
	))
	result = validate(cl, opts('-c -w -a 4 -b 2,4 -t datasets/bcw174validate datasets/bcw350train',
		cmd: 'validate'
	))!
	assert result.inferred_classes == ['benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'benign', 'benign',
		'malignant', 'benign', 'benign', 'benign', 'malignant', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'malignant', 'malignant', 'malignant', 'malignant', 'benign', 'benign',
		'malignant', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'malignant', 'benign', 'benign', 'benign', 'malignant', 'benign', 'malignant', 'benign',
		'malignant', 'malignant', 'malignant', 'benign', 'malignant', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'malignant',
		'benign', 'benign', 'malignant', 'benign', 'malignant', 'malignant', 'malignant', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'malignant', 'benign', 'benign', 'malignant', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'malignant', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'malignant', 'malignant', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'malignant']
	assert result.counts == [[15741, 0], [15741, 0], [15741, 0],
		[636, 0], [2226, 0], [318, 1337], [636, 0], [2226, 0],
		[15741, 0], [15741, 0], [636, 0], [15741, 0], [795, 0],
		[15741, 0], [15741, 0], [954, 0], [15741, 0], [159, 0],
		[15741, 0], [636, 0], [15741, 0], [0, 3056], [2226, 0],
		[2226, 0], [0, 191], [15741, 0], [15741, 0], [636, 0],
		[159, 191], [15741, 0], [159, 0], [159, 0], [15741, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [15741, 0], [0, 764], [795, 0], [477, 0],
		[0, 191], [0, 191], [0, 1146], [0, 573], [15741, 0], [15741, 0],
		[0, 955], [795, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [795, 0], [0, 764], [0, 382], [15741, 0],
		[795, 0], [15741, 0], [0, 191], [15741, 0], [0, 191],
		[15741, 0], [0, 382], [0, 191], [0, 191], [795, 0], [0, 764],
		[15741, 0], [795, 0], [636, 0], [15741, 0], [477, 191],
		[15741, 0], [2226, 0], [15741, 0], [159, 382], [0, 191],
		[0, 191], [15741, 0], [15741, 0], [0, 764], [15741, 0],
		[0, 191], [0, 382], [0, 191], [159, 0], [2226, 0], [636, 0],
		[15741, 0], [159, 0], [15741, 0], [15741, 0], [15741, 0],
		[318, 0], [795, 0], [15741, 0], [2226, 0], [477, 0], [318, 0],
		[636, 0], [15741, 0], [15741, 0], [159, 0], [15741, 0],
		[15741, 0], [159, 1910], [15741, 0], [318, 0], [0, 1528],
		[318, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [636, 0],
		[15741, 0], [0, 1719], [15741, 0], [954, 0], [318, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[0, 191], [159, 955], [15741, 0], [15741, 0], [15741, 0],
		[636, 0], [636, 0], [15741, 0], [15741, 0], [636, 0],
		[15741, 0], [477, 1528], [0, 382], [159, 0], [318, 0],
		[15741, 0], [159, 0], [15741, 0], [318, 0], [795, 0],
		[15741, 0], [15741, 0], [15741, 0], [0, 382], [0, 3056],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [0, 191],
		[15741, 0], [15741, 0], [159, 0], [15741, 0], [0, 382],
		[159, 191], [0, 191]]
	println('Done with bcw350train and weighting')

	// now with a saved classifier
	outputfile := 'tempfolder3/classifierfile'
	cl = make_classifier(opts('-c -w -a 4 -b 2,4 -o ${outputfile} -t datasets/bcw174validate datasets/bcw350train',
		cmd: 'make'
	))
	result = validate(load_classifier_file(outputfile)!, opts('-c -w -a 4 -b 2,4 -t datasets/bcw174validate datasets/bcw350train',
		cmd: 'validate'
	))!
	assert result.inferred_classes == ['benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'benign', 'benign',
		'malignant', 'benign', 'benign', 'benign', 'malignant', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'malignant', 'malignant', 'malignant', 'malignant', 'benign', 'benign',
		'malignant', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'malignant', 'benign', 'benign', 'benign', 'malignant', 'benign', 'malignant', 'benign',
		'malignant', 'malignant', 'malignant', 'benign', 'malignant', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'malignant',
		'benign', 'benign', 'malignant', 'benign', 'malignant', 'malignant', 'malignant', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'malignant', 'benign', 'benign', 'malignant', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'malignant', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'malignant', 'malignant', 'benign', 'benign', 'benign', 'benign', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'benign',
		'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'benign', 'malignant',
		'benign', 'benign', 'benign', 'benign', 'malignant', 'malignant', 'malignant']
	assert result.counts == [[15741, 0], [15741, 0], [15741, 0],
		[636, 0], [2226, 0], [318, 1337], [636, 0], [2226, 0],
		[15741, 0], [15741, 0], [636, 0], [15741, 0], [795, 0],
		[15741, 0], [15741, 0], [954, 0], [15741, 0], [159, 0],
		[15741, 0], [636, 0], [15741, 0], [0, 3056], [2226, 0],
		[2226, 0], [0, 191], [15741, 0], [15741, 0], [636, 0],
		[159, 191], [15741, 0], [159, 0], [159, 0], [15741, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [15741, 0], [0, 764], [795, 0], [477, 0],
		[0, 191], [0, 191], [0, 1146], [0, 573], [15741, 0], [15741, 0],
		[0, 955], [795, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [795, 0], [0, 764], [0, 382], [15741, 0],
		[795, 0], [15741, 0], [0, 191], [15741, 0], [0, 191],
		[15741, 0], [0, 382], [0, 191], [0, 191], [795, 0], [0, 764],
		[15741, 0], [795, 0], [636, 0], [15741, 0], [477, 191],
		[15741, 0], [2226, 0], [15741, 0], [159, 382], [0, 191],
		[0, 191], [15741, 0], [15741, 0], [0, 764], [15741, 0],
		[0, 191], [0, 382], [0, 191], [159, 0], [2226, 0], [636, 0],
		[15741, 0], [159, 0], [15741, 0], [15741, 0], [15741, 0],
		[318, 0], [795, 0], [15741, 0], [2226, 0], [477, 0], [318, 0],
		[636, 0], [15741, 0], [15741, 0], [159, 0], [15741, 0],
		[15741, 0], [159, 1910], [15741, 0], [318, 0], [0, 1528],
		[318, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [636, 0],
		[15741, 0], [0, 1719], [15741, 0], [954, 0], [318, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[0, 191], [159, 955], [15741, 0], [15741, 0], [15741, 0],
		[636, 0], [636, 0], [15741, 0], [15741, 0], [636, 0],
		[15741, 0], [477, 1528], [0, 382], [159, 0], [318, 0],
		[15741, 0], [159, 0], [15741, 0], [318, 0], [795, 0],
		[15741, 0], [15741, 0], [15741, 0], [0, 382], [0, 3056],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [15741, 0],
		[15741, 0], [15741, 0], [15741, 0], [15741, 0], [0, 191],
		[15741, 0], [15741, 0], [159, 0], [15741, 0], [0, 382],
		[159, 191], [0, 191]]
	println('Done with bcw350train saved classifier')

	cl = make_classifier(opts('-c -w -a 33 -b 2,16 -o ${outputfile} -t datasets/soybean-large-validate.tab datasets/soybean-large-train.tab',
		cmd: 'make'
	))
	result = validate(cl, opts('-c -w -a 33 -b 2,16 -t datasets/soybean-large-validate.tab datasets/soybean-large-train.tab',
		cmd: 'validate'
	))!
	assert result.counts[0] == [12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	s := result.inferred_classes[0..4]
	assert s == ['diaporthe-stem-canker', 'diaporthe-stem-canker', 'diaporthe-stem-canker',
		'diaporthe-stem-canker']
	tcl := load_classifier_file(outputfile)!
	test_result := validate(tcl, opts('-c -w -a 33 -b 2,16 -t datasets/soybean-large-validate.tab datasets/soybean-large-train.tab',
		cmd: 'validate'
	))!

	assert result.inferred_classes == test_result.inferred_classes
	assert result.counts == test_result.counts
}
