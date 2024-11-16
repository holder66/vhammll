// verify_test.v
module vhammll

import os

fn testsuite_begin() ! {
	if os.is_dir('tempfolder_verify') {
		os.rmdir_all('tempfolder_verify')!
	}
	os.mkdir_all('tempfolder_verify')!
}

fn testsuite_end() ! {
	os.rmdir_all('tempfolder_verify')!
}

// test_verify
fn test_verify() ? {
	mut opts := Options{
		concurrency_flag: true
	}

	mut result := CrossVerifyResult{}
	mut ds := Dataset{}
	mut cl := Classifier{}
	mut saved_cl := Classifier{}

	// test verify with a non-saved classifier
	opts.command = 'make'
	opts.datafile_path = 'datasets/test.tab'
	opts.testfile_path = 'datasets/test_verify.tab'
	opts.classifierfile_path = ''
	opts.bins = [2, 3]
	opts.number_of_attributes = [2]
	assert verify(opts).correct_count == 10

	println('Done with test.tab')

	// now with a binary classifier with continuous values

	opts.datafile_path = 'datasets/leukemia38train.tab'
	opts.testfile_path = 'datasets/leukemia34test.tab'
	opts.number_of_attributes = [1]
	opts.bins = [5, 5]
	opts.purge_flag = true
	opts.weight_ranking_flag = true
	result = verify(opts)
	assert result.confusion_matrix_map == {
		'ALL': {
			'ALL': 17.0
			'AML': 3.0
		}
		'AML': {
			'ALL': 0.0
			'AML': 14.0
		}
	}

	// test verify with a binary classifier without continuous values

	opts.datafile_path = 'datasets/bcw350train'
	opts.testfile_path = 'datasets/bcw174test'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [4]
	opts.bins = [2, 4]
	opts.purge_flag = false
	result = verify(opts)
	assert result.correct_count == 171
	assert result.wrong_count == 3

	println('Done with bcw350train')

	// now with a saved classifier
	opts.outputfile_path = 'tempfolder_verify/classifierfile'
	cl = make_classifier(load_file(opts.datafile_path), opts)
	opts.classifierfile_path = opts.outputfile_path
	opts.outputfile_path = ''
	assert result.BinaryMetrics == verify(opts).BinaryMetrics

	println('Done with bcw350train using saved classifier')

	opts.datafile_path = 'datasets/soybean-large-train.tab'
	opts.testfile_path = 'datasets/soybean-large-test.tab'
	opts.classifierfile_path = ''
	opts.number_of_attributes = [33]
	opts.bins = [2, 16]
	opts.weighting_flag = true
	opts.weight_ranking_flag = false
	result = verify(opts)

	assert result.correct_count == 340
	assert result.wrong_count == 36

	println('Done with soybean-large-train.tab')

	// now with a saved classifier
	opts.outputfile_path = 'tempfolder_verify/classifierfile'
	cl = make_classifier(load_file(opts.datafile_path), opts)
	opts.classifierfile_path = opts.outputfile_path
	opts.outputfile_path = ''
	assert result.Metrics == verify(opts).Metrics

	println('Done with soybean-large-train.tab using saved classifier')

	if get_environment().arch_details[0] != '4 cpus' {
		opts.datafile_path = 'datasets/mnist_test.tab'
		opts.testfile_path = 'datasets/mnist_test.tab'
		opts.classifierfile_path = ''
		opts.outputfile_path = ''
		opts.number_of_attributes = [50]
		opts.bins = [2, 2]
		opts.weight_ranking_flag = true
		opts.weighting_flag = false
		result = verify(opts)
		assert result.correct_count >= 9982
		assert result.wrong_count <= 18

		println('Done with mnist_test.tab')

		// now with a saved classifier
		opts.outputfile_path = 'tempfolder_verify/classifierfile'
		cl = make_classifier(load_file(opts.datafile_path), opts)
		opts.classifierfile_path = opts.outputfile_path
		opts.outputfile_path = ''
		assert result.correct_count == verify(opts).correct_count
		println('Done with mnist_test.tab using saved classifier')
	}

	if get_environment().arch_details[0] != '4 cpus' {
		opts.datafile_path = '../../mnist_train.tab'
		opts.testfile_path = 'datasets/mnist_test.tab'
		opts.classifierfile_path = ''
		opts.outputfile_path = ''
		opts.number_of_attributes = [313]
		opts.bins = [2, 2]
		opts.concurrency_flag = true
		opts.weight_ranking_flag = false
		opts.weighting_flag = false
		result = verify(opts)
		assert result.correct_count == 9571
		assert result.wrong_count == 429

		// note: as of 2024-1-17, we cannot use weight_ranking or weighting, as we cannot
		// calculate the lcm within the confines of i64

		// opts.weighting_flag = true
		// result = verify(opts)
		// assert result.correct_count == 9279
		// assert result.wrong_count == 721
	}
}
