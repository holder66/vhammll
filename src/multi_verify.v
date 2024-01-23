// multiple_verify.v

module vhammll

fn multi_verify(opts Options, disp DisplaySettings) CrossVerifyResult {
	// load the testfile as a Dataset struct
	mut test_ds := load_file(opts.testfile_path, opts.LoadOptions)
	mut confusion_matrix_map := map[string]map[string]f64{}
	// for each class, instantiate an entry in the confusion matrix map
	for key1, _ in test_ds.class_counts {
		for key2, _ in test_ds.class_counts {
			confusion_matrix_map[key2][key1] = 0
		}
	}
	// instantiate a struct for the result
	mut verify_result := CrossVerifyResult{
		LoadOptions: opts.LoadOptions
		Parameters: opts.Parameters
		DisplaySettings: disp
		MultipleOptions: opts.MultipleOptions
		MultipleClassifiersArray: opts.MultipleClassifiersArray
		datafile_path: opts.datafile_path
		testfile_path: opts.testfile_path
		multiple_classify_options_file_path: opts.multiple_classify_options_file_path
		labeled_classes: test_ds.class_values
		class_counts: test_ds.class_counts
		classes: test_ds.classes
		pos_neg_classes: get_pos_neg_classes(test_ds.class_counts)
		confusion_matrix_map: confusion_matrix_map
	}
	verify_result.binning = get_binning(opts.bins)
	mut ds := load_file(opts.datafile_path)
	mut classifier_array := []Classifier{}
	mut cases := [][][]u8{}
	mut mult_opts := opts
	mult_opts.MultipleClassifiersArray = read_multiple_opts(mult_opts.multiple_classify_options_file_path) or {
		panic('read_multiple_opts failed')
	}
	verify_result.MultipleClassifiersArray = mult_opts.MultipleClassifiersArray
	if mult_opts.classifier_indices == [] {
		mult_opts.classifier_indices = []int{len: mult_opts.multiple_classifiers.len, init: index}
	}
	verify_result.classifier_indices = mult_opts.classifier_indices
	for i in mult_opts.classifier_indices {
		mut params := mult_opts.multiple_classifiers[i].classifier_options
		mult_opts.Parameters = params
		verify_result.Parameters = params
		classifier_array << make_classifier(ds, mult_opts)
		cases << generate_case_array(classifier_array.last(), test_ds)
	}
	cases = transpose(cases)
	// println('classifier_array in multiple_classify_to_verify: ${classifier_array}')
	mut m_classify_result := ClassifyResult{}
	mut maximum_hamming_distance_array := []int{}
	for cl in classifier_array {
		maximum_hamming_distance_array << cl.maximum_hamming_distance
	}
	mut total_nn_params := TotalNnParams{
		maximum_hamming_distance_array: maximum_hamming_distance_array
		total_max_ham_dist: array_sum(maximum_hamming_distance_array)
		lcm_max_ham_dist: lcm(maximum_hamming_distance_array)
	}
	if disp.verbose_flag && opts.total_nn_counts_flag {
		println('maximum_hamming_distance_array: ${total_nn_params.maximum_hamming_distance_array}')
		println('total_max_ham_dist: ${total_nn_params.total_max_ham_dist}')
		println('lcm_max_ham_dist: ${total_nn_params.lcm_max_ham_dist}')
	}
	for i, case in cases {
		if disp.verbose_flag {
			println('\ncase: ${i:-7}     classes: ${classifier_array[0].classes.join(' | ')}')
		}
		m_classify_result = if opts.total_nn_counts_flag {
			multiple_classifier_classify_totalnn(classifier_array, total_nn_params, case,
				[''], opts, disp)
		} else {
			multiple_classifier_classify(classifier_array, case, [''], opts, disp)
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

	if opts.command == 'verify' && (disp.show_flag || disp.expanded_flag) {
		show_verify(verify_result, opts, disp)
	}
	if opts.outputfile_path != '' {
		verify_result.command = 'verify'
		save_json_file(verify_result, opts.outputfile_path)
	}
	return verify_result
}
