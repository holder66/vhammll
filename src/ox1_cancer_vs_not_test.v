// oxford_test.v

module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_oxford') {
		os.rmdir_all('tempfolders/tempfolder_oxford')!
	}
	os.mkdir_all('tempfolders/tempfolder_oxford')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_oxford')!
}

fn test_note_re_datafile_locations() {
	println(r_b("\nThis test file assumes that the Oxford dataset train and test files are in\na folder named 'metabolomics', and that this folder is itself in the user's home directory."))
	println(r_b("\nIt is also assumed that the two files have been prepared according to the \ninstructions in the documentation file 'metabolomics_cancer_oxford.md'."))
}

// fn test_summary_roc_plot() {
// 	home_dir := os.home_dir()
// 	// run optimals as the result includes plotting data
// 	optimals_result := optimals(os.join_path(home_dir, 'metabolomics', 'ox1trainb2-6a2-15.opts'))
// 	mut files := optimals_result.RocFiles
// 	files.datafile = files.datafile.replace(home_dir, '~')
// 	files.settingsfile = files.settingsfile.replace(home_dir, '~')
// 	files.testfile = '~/metabolomics/ox1_test.tab'
// 	rocdata2 := RocData{
// 		pairs:          [[0.941, 0.720], [1.000, 0.600], [0.882, 0.737],
// 			[0.824, 0.743], [0.647, 0.966], [0.706, 0.966], [0.706, 0.971],
// 			[0.765, 0.937], [0.588, 0.846]]
// 		classifiers:    ['118, 113, 5', '118, 113, 120', '118, 113, 120', '120, 113, 118',
// 			'70, 5, 120, 14, 113, 118', '70, 118, 113, 135, 14', '70, 118, 113, 135, 14',
// 			'70, 5, 120, 14, 113, 118', '70, 118, 113, 135, 14']
// 		classifier_ids: [[118, 113, 5], [118, 113, 120], [118, 113, 120],
// 			[120, 113, 118], [70, 5, 120, 14, 113, 118], [70, 118, 113, 135, 14],
// 			[70, 118, 113, 135, 14], [70, 5, 120, 14, 113, 118],
// 			[70, 118, 113, 135, 14]]
// 		trace_text:     'Multi-classifier<br>cross-validations'
// 	}
// 	rocdata3 := RocData{
// 		pairs:          [[0.857, 0.671], [0.857, 0.612], [0.857, 0.682],
// 			[0.286, 0.824], [0.714, 0.824], [0.286, 0.800], [0.857, 0.706]]
// 		classifiers:    ['5, 113, 118', '120, 113, 118', '120, 113, 118', '70, 5, 120, 14, 113, 118',
// 			'70, 118, 113, 135, 14', '70, 5, 120, 14, 113, 118', '120, 113, 118']
// 		classifier_ids: [[5, 113, 118], [120, 113, 118], [120, 113, 118],
// 			[70, 5, 120, 14, 113, 118], [70, 118, 113, 135, 14],
// 			[70, 5, 120, 14, 113, 118], [120, 113, 118]]
// 		trace_text:     'Verifications on file<br>${files.testfile}'
// 	}

// 	plot_mult_roc([optimals_result.RocData, rocdata2, rocdata3], files)
// }

// fn test_oxford_crossvalidate_to_create_settings_file() {
// 	println(r_b('\nStart by creating a settings file for the four sets of classifier settings,'))
// 	println(r_b('by doing four cross-validations with the append_settings_flag set:'))
// 	// home_dir := os.home_dir()
// 	datafile := os.join_path(os.home_dir(), 'metabolomics', 'ox1_train.tab')
// 	settingsfile := 'tempfolders/tempfolder_oxford/ox1-cancer.opts'
// 	result0 := cross_validate(opts('-e -a 9 -b 2,2 -p -wr -ms ${settingsfile} ${datafile}',
// 		cmd: 'cross'
// 	))

// 	result1 := cross_validate(opts('-e -a 7 -b 2,2 -wr -w -p -ms ${settingsfile} ${datafile}',
// 		cmd: 'cross'
// 	))
// 	// assert result1.correct_counts == []
// 	result2 := cross_validate(opts('-e -a 4 -b 2,2 -bp -ms ${settingsfile} ${datafile}',
// 		cmd: 'cross'
// 	))
// 	result3 := cross_validate(opts('-e -a 7 -b 2,2 -bp -ms ${settingsfile} ${datafile}',
// 		cmd: 'cross'
// 	))
// 	result4 := cross_validate(opts('-e -a 8 -b 2,2 -wr -w -ms ${settingsfile} ${datafile}',
// 		cmd: 'cross'
// 	))
// }

// 	opts.number_of_attributes = [1]
// 	opts.bins = [3, 3]
// 	opts.weight_ranking_flag = true
// 	opts.purge_flag = false
// 	result1 := cross_validate(opts)
// 	assert result1.confusion_matrix_map == {
// 		'Non': {
// 			'Non': 120.0
// 			'Can': 53.0
// 		}
// 		'Can': {
// 			'Non': 4.0
// 			'Can': 13.0
// 		}
// 	}
// 	opts.number_of_attributes = [3]
// 	opts.weight_ranking_flag = false
// 	opts.balance_prevalences_flag = false
// 	result2 := cross_validate(opts)
// 	assert result2.confusion_matrix_map == {
// 		'Non': {
// 			'Non': 52.0
// 			'Can': 123.0
// 		}
// 		'Can': {
// 			'Non': 2.0
// 			'Can': 15.0
// 		}
// 	}
// 	opts.number_of_attributes = [9]
// 	opts.bins = [1, 4]
// 	result3 := cross_validate(opts)
// 	assert result3.confusion_matrix_map == {
// 		'Non': {
// 			'Non': 152.0
// 			'Can': 23.0
// 		}
// 		'Can': {
// 			'Non': 4.0
// 			'Can': 13.0
// 		}
// 	}
// }

fn test_oxford_settings_file() {
	println(r_b('\nConfirm that a settings file was successfully created by displaying it, along with'))
	println(r_b('the attributes on which each of the four classifiers was trained:'))
	savedsettings := 'src/testdata/ox1trainb2-6a2-15expanded.opts'
	settingsfile := 'tempfolders/tempfolder_oxford/oxford_settings.opts'
	if os.is_file(settingsfile) {
		optimals(settingsfile, opts('-p -s'))
	} else {
		println(r_b('\nWhen a settings file was not created, display the saved settings file instead:'))
		optimals(savedsettings, opts('-p -s -cl 2,6'))
	}
}

fn test_oxford_multi_crossvalidate() {
	println(r_b('\nConfirm that the saved settings file can be successfully used in a multiple classifier paradigm.'))

	datafile := os.join_path(os.home_dir(), 'metabolomics', 'ox1_train.tab')
	savedsettings := 'src/testdata/ox1trainb2-6a2-15expanded.opts'

	// use a single classifier in a multi-classifier cross-validation
	println(r_b('\nFirst, test that when using only one classifier in a multiple classifier paradigm, we get the same\nas in single classifier paradigm.'))
	println(r_b('\nFor classifier 21:'))
	cross_validate(opts('-e -m# 21 -m ${savedsettings} ${datafile}', cmd: 'cross')).correct_counts
		
	println(r_b('\nAnd for classifiers 7, 21, 119, 189:'))
	cross_validate(opts('-e -af -m# 7,21,119,189 -m ${savedsettings} ${datafile}', cmd: 'cross'))
	// cross_validate(opts)
	// assert cross_validate(opts).confusion_matrix_map == {
	// 	'Non': {
	// 		'Non': 152.0
	// 		'Can': 23.0
	// 	}
	// 	'Can': {
	// 		'Non': 4.0
	// 		'Can': 13.0
	// 	}
	// }
	println(r_b('\nNext, test using all four classifiers. We expect a balanced accuracy of 86.32%'))
	// with all 4 classifiers, we get the highest balanced accuracy of 86.32%:
	// opts.classifiers = []
	// // cross_validate(opts)
	// assert cross_validate(opts).confusion_matrix_map == {
	// 	'Non': {
	// 		'Non': 158.0
	// 		'Can': 17.0
	// 	}
	// 	'Can': {
	// 		'Non': 3.0
	// 		'Can': 14.0
	// 	}
	// }
	println(r_b('\nUsing only the first 3 classifiers, we should get maximum sensitivity of 0.882'))
	// with the first 3 classifiers we get the highest sensitivity of 0.882:
	// opts.classifiers = [0, 1, 2]
	// cross_validate(opts)
	// assert cross_validate(opts).confusion_matrix_map == {
	// 	'Non': {
	// 		'Non': 124.0
	// 		'Can': 51.0
	// 	}
	// 	'Can': {
	// 		'Non': 2.0
	// 		'Can': 15.0
	// 	}
	// }
	println(r_b('\nAdding the combined radius flag -mc maintains sensitivity but increases specificity to 0.754'))
	// adding the combined radius flag -mc maintains sensitivity but increases specificity to 0.754:
	// opts.combined_radii_flag = true
	// cross_validate(opts)
	// assert cross_validate(opts).confusion_matrix_map == {
	// 	'Non': {
	// 		'Non': 132.0
	// 		'Can': 43.0
	// 	}
	// 	'Can': {
	// 		'Non': 2.0
	// 		'Can': 15.0
	// 	}
	// }
}

// fn test_oxford_multi_verify() {
// 	println(r_b('\nWe can apply the 4 classifier settings from previous to train classifiers on'))
// 	println(r_b('the entire training dataset of 192 cases, and then classify the 92 cases in the'))
// 	println(r_b('independent test dataset "test.tab":'))
// 	home_dir := os.home_dir()
// 	mut opts := Options{
// 		command:                             'verify'
// 		datafile_path:                       os.join_path(home_dir, 'metabolomics', 'ox1_train.tab')
// 		testfile_path:                       os.join_path(home_dir, 'metabolomics', 'ox1_test.tab')
// 		multiple_classify_options_file_path: 'tempfolders/tempfolder_oxford/oxford_settings.opts'
// 		// verbose_flag:         true
// 		multiple_flag:        true
// 		classifiers:          []
// 		combined_radii_flag:  false
// 		expanded_flag:        true
// 		show_attributes_flag: false
// 	}

// 	mut result := multi_verify(opts)
// 	println(r_b('\nWhen using just the first 3 classifiers (with which we achieved maximum sensitivity,'))
// 	println(r_b('we get a sensitivity of 0.714 on the test set:'))
// 	opts.classifiers = [0, 1, 2]
// 	result = multi_verify(opts)
// 	assert result.confusion_matrix_map == {
// 		'Non': {
// 			'Non': 60.0
// 			'Can': 25.0
// 		}
// 		'Can': {
// 			'Non': 2.0
// 			'Can': 5.0
// 		}
// 	}
// 	assert result.sens == 0.7142857142857143
// 	assert result.spec == 0.7058823529411765

// 	println(r_b('\nAnd when we add the combined_radii_flag we maintain the sensitivity,'))
// 	println(r_b('but we get a tiny improvement on specificity, to 0.718:'))
// 	opts.combined_radii_flag = true
// 	result = multi_verify(opts)
// 	assert result.confusion_matrix_map == {
// 		'Non': {
// 			'Non': 61.0
// 			'Can': 24.0
// 		}
// 		'Can': {
// 			'Non': 2.0
// 			'Can': 5.0
// 		}
// 	}
// 	assert result.sens == 0.7142857142857143
// 	assert result.spec == 0.7176470588235294
// }
