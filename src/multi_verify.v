// multiple_verify.v

module vhammll

fn multi_verify(opts Options) CrossVerifyResult {
	// load the testfile as a Dataset struct
	mut test_ds := load_file(opts.testfile_path, opts.LoadOptions)
	// println('classes in multi_verify: ${test_ds.classes}')
	mut confusion_matrix_map := map[string]map[string]f64{}
	// for each class, instantiate an entry in the confusion matrix map
	for key1, _ in test_ds.class_counts {
		for key2, _ in test_ds.class_counts {
			confusion_matrix_map[key2][key1] = 0
		}
	}
	// instantiate a struct for the result
	mut verify_result := CrossVerifyResult{
		LoadOptions:     opts.LoadOptions
		Parameters:      opts.Parameters
		DisplaySettings: opts.DisplaySettings
		MultipleOptions: opts.MultipleOptions
		// MultipleClassifierSettingsArray: opts.MultipleClassifierSettingsArray
		datafile_path:                       opts.datafile_path
		testfile_path:                       opts.testfile_path
		multiple_classify_options_file_path: opts.multiple_classify_options_file_path
		labeled_classes:                     test_ds.class_values
		class_counts:                        test_ds.class_counts
		classes:                             test_ds.classes
		pos_neg_classes:                     get_pos_neg_classes(test_ds.class_counts)
		confusion_matrix_map:                confusion_matrix_map
	}
	verify_result.binning = get_binning(opts.bins)
	mut ds := load_file(opts.datafile_path)
	mut classifier_array := []Classifier{}
	mut cases := [][][]u8{}
	mut mult_opts := opts
	// classifier_settings is a MultipleClassifierSettingsArray struct; first, read in all the classifier settings
	classifier_settings := read_multiple_opts(mult_opts.multiple_classify_options_file_path) or {
		panic('read_multiple_opts failed')
	}
	settings_array := classifier_settings.multiple_classifier_settings
	// verify_result.MultipleClassifierSettingsArray = mult_opts.MultipleClassifierSettingsArray
	if mult_opts.classifier_indices == [] {
		// println('now we are here')
		mult_opts.classifier_indices = []int{len: settings_array.len, init: index}
	}
	verify_result.classifier_indices = mult_opts.classifier_indices
	// println('verify_result.classifier_indices in multi_verify: ${verify_result.classifier_indices}')
	// println('classifier_settings.multiple_classifier_settings.len in multi_verify: ${classifier_settings.multiple_classifier_settings.len}')
	for ci in mult_opts.classifier_indices {
		mult_opts.multiple_classifier_settings << settings_array[ci]
	}
	// println('we are here')
	for i, _ in mult_opts.classifier_indices {
		mut params := mult_opts.multiple_classifier_settings[i].Parameters
		mult_opts.Parameters = params
		mult_opts.multiple_flag = true
		verify_result.Parameters = params
		verify_result.multiple_flag = true
		// println('verify_result.Parameters in multi_verify: $verify_result.Parameters')
		// println('mult_opts in multi_verify: $mult_opts')
		classifier := make_classifier(ds, mult_opts)
		classifier_array << classifier
		verify_result.trained_attributes_array << [classifier.trained_attributes]
		cases << generate_case_array(classifier_array.last(), test_ds)
	}
	cases = transpose(cases)

	// println('classifier_array in multiple_classify_to_verify: ${classifier_array}')
	mut m_classify_result := ClassifyResult{}
	mut maximum_hamming_distance_array := []int{}
	for cl in classifier_array {
		maximum_hamming_distance_array << cl.maximum_hamming_distance
	}

	mult_opts.maximum_hamming_distance_array = maximum_hamming_distance_array
	mult_opts.total_max_ham_dist = array_sum(maximum_hamming_distance_array)
	mult_opts.lcm_max_ham_dist = lcm(maximum_hamming_distance_array)

	if opts.verbose_flag && opts.total_nn_counts_flag {
		println('maximum_hamming_distance_array: ${mult_opts.maximum_hamming_distance_array}')
		println('total_max_ham_dist: ${mult_opts.total_max_ham_dist}')
		println('lcm_max_ham_dist: ${mult_opts.lcm_max_ham_dist}')
	}
	for i, case in cases {
		if opts.verbose_flag {
			println('\ncase: ${i:-7}  ${case}   classes: ${classifier_array[0].classes.join(' | ')}')
		}
		m_classify_result = if opts.total_nn_counts_flag {
			multiple_classifier_classify_totalnn(classifier_array, case, [''], mult_opts)
		} else {
			multiple_classifier_classify(classifier_array, case, test_ds.classes, mult_opts)
		}
		// println('m_classify_result: $m_classify_result.inferred_class')
		verify_result.inferred_classes << m_classify_result.inferred_class
		verify_result.actual_classes << verify_result.labeled_classes[i]
		verify_result.nearest_neighbors_by_class << m_classify_result.nearest_neighbors_by_class
	}
	verify_result.classifier_instances_counts << classifier_array[0].history[0].instances_count
	verify_result.prepurge_instances_counts_array << classifier_array[0].history[0].prepurge_instances_count
	// if disp.verbose_flag && !opts.multiple_flag && opts.command == 'verify' {
	// 	println('result in classify_to_verify(): ${result}')
	// }
	verify_result = summarize_results(1, mut verify_result)
	// if disp.verbose_flag && !opts.multiple_flag && opts.command == 'verify' {
	// 	println('summarize_result: ${result}')
	// }
	verify_result.Metrics = get_metrics(verify_result)
	// println('cross_result.pos_neg_classes: $cross_result.pos_neg_classes')
	if verify_result.pos_neg_classes.len == 2 {
		verify_result.BinaryMetrics = get_binary_stats(verify_result)
	}

	if opts.command == 'verify' && (opts.show_flag || opts.expanded_flag) {
		show_verify(verify_result, mult_opts)
	}
	if opts.outputfile_path != '' {
		verify_result.command = 'verify'
		save_json_file[CrossVerifyResult](verify_result, opts.outputfile_path)
	}
	// println('trained_attributes_array in multi_verify: $verify_result.trained_attributes_array')
	return verify_result
}
