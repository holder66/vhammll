// display_test.v

module vhammll

import os

fn testsuite_begin() ! {
	if os.is_dir('tempfolder_display') {
		os.rmdir_all('tempfolder_display')!
	}
	os.mkdir_all('tempfolder_display')!
}

fn testsuite_end() ! {
	os.rmdir_all('tempfolder_display')!
}

fn test_display_multiple_options() ? {
	datafile_path := 'datasets/bcw350train'
	mut opts := Options{
		show_flag: true
	}
	mut settings1 := ClassifierSettings{
		Parameters:    Parameters{
			binning:              Binning{
				lower:    1
				upper:    2
				interval: 1
			}
			number_of_attributes: [1]
			weighting_flag:       true
		}
		datafile_path: datafile_path
	}
	mut settings2 := ClassifierSettings{
		Parameters:    Parameters{
			binning:              Binning{
				lower:    1
				upper:    2
				interval: 1
			}
			number_of_attributes: [6]
			weighting_flag:       true
		}
		datafile_path: datafile_path
	}
	append_json_file[ClassifierSettings](settings1, 'tempfolder_display/bcw.opts')
	assert os.file_size('tempfolder_display/bcw.opts') >= 416
	display_file('tempfolder_display/bcw.opts', opts)
	append_json_file[ClassifierSettings](settings2, 'tempfolder_display/bcw.opts')
	assert os.file_size('tempfolder_display/bcw.opts') >= 832
	display_file('tempfolder_display/bcw.opts', opts)
	// repeat with displaying trained attributes
	opts.show_attributes_flag = true
	display_file('tempfolder_display/bcw.opts', opts)
}

fn test_display_saved_classifier() ? {
	// make a classifier, show it, then save it, then display the saved classifier file
	mut opts := Options{
		command:              'make'
		bins:                 [3, 10]
		number_of_attributes: [8]
		show_flag:            true
	}
	opts.outputfile_path = 'tempfolder_display/classifierfile'
	mut ds := load_file('datasets/developer.tab')
	mut cl := make_classifier(ds, opts)
	display_file(opts.outputfile_path, opts)
}

fn test_display_saved_analyze_result() ? {
	// analyze a dataset file and show the result; save the result, then display the saved file
	mut opts := Options{
		command:         'analyze'
		outputfile_path: 'tempfolder_display/analyze_result'
		show_flag:       true
	}
	_ = analyze_dataset(load_file('datasets/UCI/anneal.arff'), opts)
	display_file(opts.outputfile_path, opts)
}

fn test_display_saved_ranking_result() ? {
	// rank a dataset file and show the result; save the result, then display the saved file
	mut opts := Options{
		command:         'rank'
		outputfile_path: 'tempfolder_display/rank_result'
		show_flag:       true
	}
	_ = rank_attributes(load_file('datasets/UCI/anneal.arff'), opts)
	display_file(opts.outputfile_path, opts)
}

fn test_display_saved_validate_result() ? {
	// validate a dataset file and show the result; save the result, then display the saved file
	mut opts := Options{
		command:   'validate'
		show_flag: true
	}
	opts.datafile_path = 'datasets/bcw350train'
	mut ds := load_file(opts.datafile_path)
	cl := make_classifier(ds, opts)
	opts.outputfile_path = 'tempfolder_display/validate_result'
	opts.testfile_path = 'datasets/bcw174validate'
	_ = validate(cl, opts)!
	display_file(opts.outputfile_path, opts)
}

fn test_display_saved_verify_result() ? {
	// verify a dataset file and show the result, with and without the expanded and
	// show_attributes flags; save the result, then display the saved result, again with
	// and without those flags
	mut opts := Options{
		datafile_path:        'datasets/bcw350train'
		testfile_path:        'datasets/bcw174test'
		outputfile_path:      'tempfolder_display/verify_result'
		command:              'verify'
		number_of_attributes: [5]
		concurrency_flag:     true
		show_flag:            true
	}
	mut ds := load_file(opts.datafile_path)

	cl := make_classifier(ds, opts)
	// println(verify(opts))
	verify(opts)
	opts.expanded_flag = true
	verify(opts)
	opts.show_attributes_flag = true
	verify(opts)
	opts.expanded_flag = false
	opts.show_attributes_flag = false
	display_file(opts.outputfile_path, opts)
	// repeat with expanded flag set
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)
	// repeat with show_attributes flag set
	opts.show_attributes_flag = true
	display_file(opts.outputfile_path, opts)
	// finally, show_attributes but without expanded result
	opts.expanded_flag = false
	display_file(opts.outputfile_path, opts)
}

fn test_display_cross_result() ? {
	// cross-validate a dataset file and display the result; save the result, then display
	// the saved result file
	mut opts := Options{
		command:              'cross'
		number_of_attributes: [4]
		bins:                 [12]
		folds:                5
		repetitions:          0
		random_pick:          false
		concurrency_flag:     true
		show_flag:            true
	}
	ds := load_file('datasets/UCI/segment.arff')
	opts.outputfile_path = 'tempfolder_display/cross_result'
	cross_validate(ds, opts)
	opts.expanded_flag = true
	cross_validate(ds, opts)
	opts.expanded_flag = false
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)
	opts.folds = 10
	opts.repetitions = 10
	opts.random_pick = true
	cross_validate(ds, opts)
	display_file(opts.outputfile_path, opts)
	println('Done for test_display_cross_result')
}

fn test_display_explore_result_cross() ? {
	mut opts := Options{
		command:              'explore'
		datafile_path:        'datasets/UCI/iris.arff'
		bins:                 [2, 3]
		number_of_attributes: [2, 3]
		concurrency_flag:     true
		outputfile_path:      'tempfolder_display/explore_result'
		show_flag:            true
	}
	mut ds := load_file(opts.datafile_path)
	explore(ds, opts)
	opts.expanded_flag = true
	explore(ds, opts)
	opts.expanded_flag = false
	display_file(opts.outputfile_path, opts)
	// repeat with expanded flag set
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)

	// repeat with purge flag set
	opts.purge_flag = true
	opts.expanded_flag = false
	explore(ds, opts)
	opts.expanded_flag = true
	explore(ds, opts)
	opts.expanded_flag = false
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	display_file(opts.outputfile_path, opts)

	// repeat for a binary class dataset
	opts.number_of_attributes = [0]
	opts.datafile_path = 'datasets/bcw174test'
	opts.purge_flag = false
	opts.expanded_flag = false
	opts.graph_flag = true
	ds = load_file(opts.datafile_path)
	explore(ds, opts)
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	explore(ds, opts)
	display_file(opts.outputfile_path, opts)

	// repeat with purge flag set
	opts.purge_flag = true
	ds = load_file(opts.datafile_path)
	opts.expanded_flag = false
	explore(ds, opts)
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	explore(ds, opts)
	display_file(opts.outputfile_path, opts)
}

fn test_display_explore_result_verify() ? {
	mut opts := Options{
		command:              'explore'
		datafile_path:        'datasets/soybean-large-train.tab'
		testfile_path:        'datasets/soybean-large-test.tab'
		bins:                 [2, 6]
		number_of_attributes: [12, 15]
		concurrency_flag:     true
		outputfile_path:      'tempfolder_display/explore_result'
		show_flag:            true
	}
	mut ds := load_file(opts.datafile_path)
	explore(ds, opts)
	display_file(opts.outputfile_path, opts)
	opts.expanded_flag = true
	explore(ds, opts)
	display_file(opts.outputfile_path, opts)

	// repeat with purge flag set
	opts.purge_flag = true
	explore(ds, opts)
	display_file(opts.outputfile_path, opts)

	// explore(ds, opts)
	// display_file(opts.outputfile_path, opts)
	// display_file(opts.outputfile_path, opts)

	// repeat for a binary class dataset
	// opts.datafile_path = 'datasets/bcw350train'
	// opts.testfile_path = 'datasets/bcw174test'
	// opts.purge_flag = false
	// opts.number_of_attributes = [0]
	// ds = load_file(opts.datafile_path)
	// explore(ds, opts)
	// display_file(opts.outputfile_path, opts)
	// display_file(opts.outputfile_path, opts)

	// repeat with purge flag set
	// opts.purge_flag = true
	// _ = explore(ds, opts)
	// display_file(opts.outputfile_path, opts)
	// display_file(opts.outputfile_path, opts)
}
