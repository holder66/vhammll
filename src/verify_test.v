// verify_test.v
module vhammll

import os

fn testsuite_begin() ! {
	if os.is_dir('tempfolders/tempfolder_verify') {
		os.rmdir_all('tempfolders/tempfolder_verify')!
	}
	os.mkdir_all('tempfolders/tempfolder_verify')!
}

fn testsuite_end() ! {
	os.rmdir_all('tempfolders/tempfolder_verify')!
}

// test_verify
// fn test_verify() ? {
// 	mut opts := Options{
// 		concurrency_flag: false
// 	}

// 	mut result := CrossVerifyResult{}
// 	mut cl := Classifier{}
// 	mut saved_cl := Classifier{}

// 	// test verify with a non-saved classifier
// 	opts.command = 'make'
// 	opts.datafile_path = 'datasets/test.tab'
// 	opts.testfile_path = 'datasets/test_verify.tab'
// 	opts.classifierfile_path = ''
// 	opts.bins = [2, 3]
// 	opts.number_of_attributes = [2]
// 	assert verify(opts).correct_count == 10
// 	// dump(verify(opts))
// 	println('Done with test.tab')

// 	// now with a binary classifier with continuous values

// 	opts.datafile_path = 'datasets/leukemia38train.tab'
// 	opts.testfile_path = 'datasets/leukemia34test.tab'
// 	opts.number_of_attributes = [1]
// 	opts.bins = [5, 5]
// 	opts.purge_flag = true
// 	opts.weight_ranking_flag = true
// 	result = verify(opts)
// 	assert result.confusion_matrix_map == {
// 		'ALL': {
// 			'ALL': 17.0
// 			'AML': 3.0
// 		}
// 		'AML': {
// 			'ALL': 0.0
// 			'AML': 14.0
// 		}
// 	}
// 	println('Done with leukemia38train.tab & leukemia34test.tab')
// 	// test verify with a binary classifier without continuous values

// 	opts.datafile_path = 'datasets/bcw350train'
// 	opts.testfile_path = 'datasets/bcw174test'
// 	opts.classifierfile_path = ''
// 	opts.number_of_attributes = [4]
// 	opts.bins = [2, 4]
// 	opts.purge_flag = false
// 	result = verify(opts)
// 	assert result.correct_count == 171
// 	assert result.wrong_count == 3

// 	println('Done with bcw350train for a non-saved classifier')

// 	// now with a saved classifier
// 	opts.outputfile_path = 'tempfolders/tempfolder_verify/classifierfile'
// 	cl = make_classifier(opts)
// 	opts.classifierfile_path = opts.outputfile_path
// 	opts.outputfile_path = ''
// 	assert result.BinaryMetrics == verify(opts).BinaryMetrics

// 	println('Done with bcw350train using saved classifier')

// 	opts.datafile_path = 'datasets/soybean-large-train.tab'
// 	opts.testfile_path = 'datasets/soybean-large-test.tab'
// 	opts.classifierfile_path = ''
// 	opts.number_of_attributes = [33]
// 	opts.bins = [2, 16]
// 	opts.weighting_flag = true
// 	opts.weight_ranking_flag = false
// 	result = verify(opts)

// 	assert result.correct_count == 340
// 	assert result.wrong_count == 36

// 	println('Done with soybean-large-train.tab')

// 	// now with a saved classifier
// 	opts.outputfile_path = 'tempfolders/tempfolder_verify/classifierfile'
// 	cl = make_classifier(opts)
// 	opts.classifierfile_path = opts.outputfile_path
// 	opts.outputfile_path = ''
// 	assert result.Metrics == verify(opts).Metrics

// 	println('Done with soybean-large-train.tab using saved classifier')

// 	if get_environment().arch_details[0] != '4 cpus' {
// 		opts.datafile_path = 'datasets/mnist_test.tab'
// 		opts.testfile_path = 'datasets/mnist_test.tab'
// 		opts.classifierfile_path = ''
// 		opts.outputfile_path = ''
// 		opts.number_of_attributes = [50]
// 		opts.bins = [2, 2]
// 		opts.weight_ranking_flag = true
// 		opts.weighting_flag = false
// 		result = verify(opts)
// 		assert result.correct_count >= 9982
// 		assert result.wrong_count <= 18

// 		println('Done with mnist_test.tab')

// 		// now with a saved classifier
// 		opts.outputfile_path = 'tempfolders/tempfolder_verify/classifierfile'
// 		cl = make_classifier(opts)
// 		opts.classifierfile_path = opts.outputfile_path
// 		opts.outputfile_path = ''
// 		assert result.correct_count == verify(opts).correct_count
// 		println('Done with mnist_test.tab using saved classifier')
// 	}

// 	if get_environment().arch_details[0] != '4 cpus' {
// 		opts.datafile_path = '../../mnist_train.tab'
// 		opts.testfile_path = 'datasets/mnist_test.tab'
// 		opts.classifierfile_path = ''
// 		opts.outputfile_path = ''
// 		opts.number_of_attributes = [288]
// 		opts.bins = [2, 2]
// 		// opts.concurrency_flag = true
// 		opts.weight_ranking_flag = false
// 		opts.weighting_flag = false
// 		result = verify(opts)
// 		assert result.correct_count == 9597
// 		// assert result.correct_counts == [851, 972, 921, 1128, 943, 985, 970, 941, 982, 878]
// 		// assert result.incorrect_counts == [41, 8, 61, 7, 66, 47, 40, 17, 46, 96]

// 		// opts.weight_ranking_flag = true
// 		// opts.weighting_flag = true
// 		// result = verify(opts)
// 		// assert result.correct_count == 9567
// 		// assert result.correct_counts == [849, 972, 924, 1128, 943, 984, 969, 940, 982, 876]
// 		// assert result.incorrect_counts == [43, 8, 58, 7, 66, 48, 41, 18, 46, 98]
// 	}
// }

fn test_mnist_train() {
	datafile := os.join_path(os.home_dir(), 'mnist_train.tab')
	testfile := 'datasets/mnist_test.tab'
	result := verify(opts('-e -a 288 -b 2,2 -t ${testfile} ${datafile}', cmd: 'verify'))
}
