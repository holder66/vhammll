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
	// println('opts.Parameters in verify: $opts.Parameters')
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
	// mut mult_opts := []Parameters{}
	mut mult_opts := opts
	mult_opts.MultipleClassifiersArray = read_multiple_opts(mult_opts.multiple_classify_options_file_path) or {
		panic('read_multiple_opts failed')
	}
	// println(mult_opts)
	verify_result.MultipleClassifiersArray = mult_opts.MultipleClassifiersArray
	// mult_opts.break_on_all_flag = opts.break_on_all_flag
	// mult_opts.combined_radii_flag = opts.combined_radii_flag
	if mult_opts.classifier_indices == [] {
		mult_opts.classifier_indices = []int{len: mult_opts.multiple_classifiers.len, init: index}
	}
	verify_result.classifier_indices = mult_opts.classifier_indices
	// mut ds := load_file(opts.datafile_path)
	// mut saved_params := read_multiple_opts(opts.multiple_classify_options_file_path) or {
	// 	MultipleClassifiersArray{}
	// }
	// println('mult_opts: $mult_opts')
	for i in mult_opts.classifier_indices {
		mut params := mult_opts.multiple_classifiers[i].classifier_options

		// for params in saved_params.multiple_classifiers {
		// println('params: $params')
		// println('number of attributes: $params.number_of_attributes')
		mult_opts.Parameters = params
		verify_result.Parameters = params
		// println('mult_opts: $mult_opts')
		classifier_array << make_classifier(ds, mult_opts)
		cases << generate_case_array(classifier_array.last(), test_ds)
	}
	// println('classifier_array: ${classifier_array}')
	// println(mult_opts)
	// println('cases: $cases')
	cases = transpose(cases)
	// println('cases: $cases')
	verify_result = multiple_classify_to_verify(classifier_array, cases, mut
		verify_result, mult_opts, disp)
	verify_result.Metrics = get_metrics(verify_result)
	// println(verify_result.Metrics)
	// println('cross_result.pos_neg_classes: $cross_result.pos_neg_classes')
	if verify_result.pos_neg_classes.len == 2 {
		verify_result.BinaryMetrics = get_binary_stats(verify_result)
	}

	// verify_result.command = 'verify'
	// println('verify_result: $verify_result')

	if opts.command == 'verify' && (disp.show_flag || disp.expanded_flag) {
		println('we are here in multi_verify')
		show_verify(verify_result, opts, disp)
	}
	if opts.outputfile_path != '' {
		verify_result.command = 'verify'
		save_json_file(verify_result, opts.outputfile_path)
	}
	return verify_result
}

// multiple_classify_to_verify
fn multiple_classify_to_verify(m_cl []Classifier, m_cases [][][]u8, mut result CrossVerifyResult, opts Options, disp DisplaySettings) CrossVerifyResult {
	// println('result in multiple_classify_to_verify: $result')
	mut m_classify_result := ClassifyResult{}
	for i, case in m_cases {
		if disp.verbose_flag {println('\ncase: ${i:-7}     classes: ${m_cl[0].classes.join(' | ')}')}

		m_classify_result = multiple_classifier_classify(m_cl, case, [''], opts, disp)
		m_classify_result = if opts.total_nn_counts_flag {
			multiple_classifier_classify_totalnn(m_cl, case, [''], opts, disp)
		} else {
			multiple_classifier_classify(m_cl, case, [''], opts, disp)
		}
		// println('m_classify_result: $m_classify_result.inferred_class')
		result.inferred_classes << m_classify_result.inferred_class
		result.actual_classes << result.labeled_classes[i]
		result.nearest_neighbors_by_class << m_classify_result.nearest_neighbors_by_class
	}
	result.classifier_instances_counts << m_cl[0].history[0].instances_count
	result.prepurge_instances_counts_array << m_cl[0].history[0].prepurge_instances_count
	// if disp.verbose_flag && !opts.multiple_flag && opts.command == 'verify' {
	// 	println('result in classify_to_verify(): ${result}')
	// }
	result = summarize_results(1, mut result)
	// if disp.verbose_flag && !opts.multiple_flag && opts.command == 'verify' {
	// 	println('summarize_result: ${result}')
	// }
	// println('result at end of multiple_classify_to_verify: $result')
	return result
}
