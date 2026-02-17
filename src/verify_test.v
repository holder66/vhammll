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

fn test_verify() ? {
	mut result := CrossVerifyResult{}
	mut cl := Classifier{}

	// test verify with a non-saved classifier
	assert verify(opts('-a 2 -b 2,3 -t datasets/test_verify.tab datasets/test.tab',
		cmd: 'verify'
	)).correct_count == 10
	println(r_b('Done with test.tab'))

	// now with a binary classifier with continuous values
	result = verify(opts('-p -wr -a 1 -b 5,5 -t datasets/leukemia34test.tab datasets/leukemia38train.tab',
		cmd: 'verify'
	))
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
	println(r_b('Done with leukemia38train.tab & leukemia34test.tab'))

	// test verify with a binary classifier without continuous values
	result = verify(opts('-wr -a 4 -b 2,4 -t datasets/bcw174test datasets/bcw350train',
		cmd: 'verify'
	))
	assert result.correct_count == 171
	assert result.wrong_count == 3
	println(r_b('Done with bcw350train for a non-saved classifier'))

	// now with a saved classifier
	cl = make_classifier(opts('-wr -a 4 -b 2,4 -o tempfolders/tempfolder_verify/classifierfile datasets/bcw350train',
		cmd: 'make'
	))
	assert result.BinaryMetrics == verify(opts('-wr -a 4 -b 2,4 -k tempfolders/tempfolder_verify/classifierfile -t datasets/bcw174test datasets/bcw350train',
		cmd: 'verify'
	)).BinaryMetrics
	println(r_b('Done with bcw350train using saved classifier'))

	result = verify(opts('-w -a 33 -b 2,16 -t datasets/soybean-large-test.tab datasets/soybean-large-train.tab',
		cmd: 'verify'
	))
	assert result.correct_count == 340
	assert result.wrong_count == 36
	println(r_b('Done with soybean-large-train.tab'))

	// now with a saved classifier
	cl = make_classifier(opts('-w -a 33 -b 2,16 -o tempfolders/tempfolder_verify/classifierfile datasets/soybean-large-train.tab',
		cmd: 'make'
	))
	assert result.Metrics == verify(opts('-w -a 33 -b 2,16 -k tempfolders/tempfolder_verify/classifierfile -t datasets/soybean-large-test.tab datasets/soybean-large-train.tab',
		cmd: 'verify'
	)).Metrics
	println(r_b('Done with soybean-large-train.tab using saved classifier'))

	if get_environment().arch_details[0] != '4 cpus' {
		result = verify(opts('-wr -a 50 -b 2,2 -t datasets/mnist_test.tab datasets/mnist_test.tab',
			cmd: 'verify'
		))
		assert result.correct_count >= 9982
		assert result.wrong_count <= 18
		println(r_b('Done with mnist_test.tab'))

		// now with a saved classifier
		cl = make_classifier(opts('-wr -a 50 -b 2,2 -o tempfolders/tempfolder_verify/classifierfile datasets/mnist_test.tab',
			cmd: 'make'
		))
		assert result.correct_count == verify(opts('-wr -a 50 -b 2,2 -k tempfolders/tempfolder_verify/classifierfile -t datasets/mnist_test.tab datasets/mnist_test.tab',
			cmd: 'verify'
		)).correct_count
		println(r_b('Done with mnist_test.tab using saved classifier'))
	}
}
