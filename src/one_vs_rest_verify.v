// one_vs_rest_verify.v
module vhammll

// import arrays

// one_vs_rest_verify classifies all the cases in a verification datafile (specified
// by `opts.testfile_path`) using an array of trained Classifiers, one per class;
// each classifier is trained using a one class vs all the other classes. It returns metrics
// comparing the inferred classes to the labeled (assigned) classes
// of the verification datafile.
// ```sh
// Optional (also see `make_classifier.v` for options in training a classifier)
// weighting_flag: nearest neighbor counts are weighted by
// 	class prevalences.
// Output options:
// show_flag: display results on the console;
// expanded_flag: display additional information on the console, including
// 		a confusion matrix.
// outputfile_path: saves the result as a json file
// ```
pub fn one_vs_rest_verify(opts Options) CrossVerifyResult {
	// load the testfile as a Dataset struct
	mut test_ds := load_file(opts.testfile_path, opts.LoadOptions)
	mut confusion_matrix_map := map[string]StringFloatMap{}
	// for each class, instantiate an entry in the confusion matrix map
	for key1, _ in test_ds.class_counts {
		for key2, _ in test_ds.class_counts {
			confusion_matrix_map[key2][key1] = 0
		}
	}
	// instantiate a struct for the result
	// println('opts.Parameters in verify: $opts.Parameters')
	mut verify_result := CrossVerifyResult{
		LoadOptions:     opts.LoadOptions
		Parameters:      opts.Parameters
		DisplaySettings: opts.DisplaySettings
		MultipleOptions: opts.MultipleOptions
		// MultipleClassifierSettings:     opts.MultipleClassifierSettings
		datafile_path:                       opts.datafile_path
		testfile_path:                       opts.testfile_path
		multiple_classify_options_file_path: opts.multiple_classify_options_file_path
		multiple_classifier_settings:        opts.multiple_classifier_settings
		labeled_classes:                     test_ds.class_values
		actual_classes:                      test_ds.class_values
		class_counts:                        test_ds.class_counts
		classes:                             test_ds.classes
		pos_neg_classes:                     get_pos_neg_classes(test_ds)
		confusion_matrix_map:                confusion_matrix_map
	}
	verify_result.binning = get_binning(opts.bins)
	mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	// println('verify_result in verify: ${verify_result}')

	// if !opts.multiple_flag {
	mut cl := Classifier{}
	mut one_vs_rest_cl_array := []Classifier{len: ds.classes.len}
	// println('ds.classes in one_vs_rest_verify: $ds.classes')
	// case_indices := []int{len: ds.class_values.len, init: index}
	// println('case_indices in one_vs_rest_verify: $case_indices')
	one_vs_rest_cl_array.clear()
	for class in ds.classes {
		// class_cases := case_indices.filter(ds.class_values[it] == class)
		// other_cases := case_indices.filter(ds.class_values[it] != class)
		// println('class_cases in one_vs_rest_verify: $class_cases')
		// we need to generate a classifier for each class at this point.
		// since make_classifier() nees a Dataset struct, we will need to formulate
		// a struct for each class.
		mut one_vs_rest_ds := ds
		one_vs_rest_ds.classes = [class, 'not_${class}']
		one_vs_rest_ds.class_values = ds.class_values.map(if it == class {
			it
		} else {
			'not_${class}'
		})
		one_vs_rest_ds.class_counts = element_counts(one_vs_rest_ds.class_values)
		// one_vs_rest_ds.data = purge_array(ds.data, class_cases)
		// println('one_vs_rest_ds in one_vs_rest_verify: $one_vs_rest_ds')
		mut one_vs_rest_cl := make_classifier_using_ds(mut one_vs_rest_ds, opts)
		// println('one_vs_rest_cl in one_vs_rest_verify: $one_vs_rest_cl')
		one_vs_rest_cl_array << one_vs_rest_cl
	}

	// println('one_vs_rest_cl_array in one_vs_rest_verify: $one_vs_rest_cl_array')
	// if opts.classifierfile_path == '' {
	// 	cl = make_classifier(opts, disp)
	// } else {
	// 	cl = load_classifier_file(opts.classifierfile_path) or { panic(err) }
	// }
	// verify_result.command = 'verify' // override the 'make' command from cl.Parameters
	// for each classifier, massage the cases in the test dataset according to the
	// attribute parameters in the classifier
	mut cases := [][]u8{}
	mut inferred_classes := []string{len: test_ds.class_values.len}
	for classifier in one_vs_rest_cl_array {
		cases = generate_case_array(classifier, test_ds)
		// println('cases in one_vs_rest_verify: $cases')
		for j, case in cases {
			// println('classify_result: ${classify_case(classifier, case, opts, disp).inferred_class}')
			inf_class := classify_case(classifier, case, opts).inferred_class
			if !inf_class.contains('not_') {
				inferred_classes[j] = inf_class
			}
		}
	}
	// println('inferred_classes in one_vs_rest_verify: $inferred_classes')
	verify_result.inferred_classes = inferred_classes
	// println(opts)
	// for the instances in the test data, perform classifications
	if opts.verbose_flag {
		println('cl.classes in verify: ${cl.classes}')
	}
	// verify_result = classify_to_verify(cl, case, mut verify_result, opts, disp)
	// for each instance in the test data, perform a classification
	// mut classify_result := ClassifyResult{}
	// if opts.concurrency_flag {
	// 	mut work_channel := chan int{cap: runtime.nr_jobs()}
	// 	mut result_channel := chan ClassifyResult{cap: case.len}
	// 	for i, _ in case {
	// 		work_channel <- i
	// 		spawn option_worker_verify(work_channel, result_channel, cl, case, verify_result.labeled_classes,
	// 			opts, disp)
	// 	}
	// 	for i, _ in case {
	// 		classify_result = <-result_channel
	// 		// println(classify_result)
	// 		if disp.verbose_flag {
	// 			verbose_result(i, cl, classify_result)
	// 		}
	// 		verify_result.inferred_classes << classify_result.inferred_class
	// 		verify_result.actual_classes << classify_result.labeled_class
	// 		verify_result.nearest_neighbors_by_class << classify_result.nearest_neighbors_by_class
	// 	}
	// } else {
	// 	for i, test_instance in case {
	// 		classify_result = classify_case(cl, test_instance, opts, disp)
	// 		// result.inferred_classes << classify_case(cl, test_instance, opts).inferred_class
	// 		verify_result.inferred_classes << classify_result.inferred_class
	// 		verify_result.nearest_neighbors_by_class << classify_result.nearest_neighbors_by_class
	// 		verify_result.actual_classes << verify_result.labeled_classes[i]
	// 		if disp.verbose_flag {
	// 			verbose_result(i, cl, classify_result)
	// 		}
	// 	}
	// }
	// verify_result.classifier_instances_counts << cl.history[0].instances_count
	// verify_result.prepurge_instances_counts_array << cl.history[0].prepurge_instances_count
	// // if disp.verbose_flag && !opts.multiple_flag && opts.command == 'verify' {
	// // 	println('result in classify_to_verify(): ${result}')
	// // }
	verify_result = summarize_results(1, mut verify_result)
	// if disp.verbose_flag && !opts.multiple_flag && opts.command == 'verify' {
	// 	println('summarize_result: ${result}')
	// }
	// } else { // ie, asking for multiple classifiers
	// 	mut classifier_array := []Classifier{}
	// 	mut instances_to_be_classified := [][][]u8{}
	// 	// mut mult_opts := []Parameters{}
	// 	mut mult_opts := opts
	// 	mult_opts.MultipleClassifierSettings = read_multiple_opts(mult_opts.multiple_classify_options_file_path) or {
	// 		panic('read_multiple_opts failed')
	// 	}
	// 	// println(mult_opts)
	// 	verify_result.MultipleClassifierSettings = mult_opts.MultipleClassifierSettings
	// 	// mult_opts.break_on_all_flag = opts.break_on_all_flag
	// 	// mult_opts.combined_radii_flag = opts.combined_radii_flag
	// 	if mult_opts.classifiers == [] {
	// 		mult_opts.classifiers = []int{len: mult_opts.multiple_classifier_settings.len, init: index}
	// 	}
	// 	verify_result.classifier_indices = mult_opts.classifiers
	// 	// mut ds := load_file(opts.datafile_path)
	// 	// mut saved_params := read_multiple_opts(opts.multiple_classify_options_file_path) or {
	// 	// 	MultipleClassifierSettings{}
	// 	// }
	// 	// println('mult_opts: $mult_opts')
	// 	for i in mult_opts.classifiers {
	// 		mut params := mult_opts.multiple_classifier_settings[i].Parameters

	// 		// for params in saved_params.multiple_classifier_settings {
	// 		// println('params: $params')
	// 		// println('number of attributes: $params.number_of_attributes')
	// 		mult_opts.Parameters = params
	// 		verify_result.Parameters = params
	// 		// println('mult_opts: $mult_opts')
	// 		classifier_array << make_classifier(mult_opts)
	// 		instances_to_be_classified << generate_case_array(classifier_array.last(),
	// 			test_ds)
	// 	}
	// 	// println('classifier_array: ${classifier_array}')
	// 	// println(mult_opts)
	// 	// println('instances_to_be_classified: $instances_to_be_classified')
	// 	instances_to_be_classified = transpose(instances_to_be_classified)
	// 	// println('instances_to_be_classified: $instances_to_be_classified')
	// 	verify_result = multiple_classify_to_verify(classifier_array, instances_to_be_classified, mut
	// 		verify_result, mult_opts, disp)
	// }
	// println(verify_result.Metrics)
	verify_result.Metrics = get_metrics(verify_result)
	// println(verify_result.Metrics)
	// println('cross_result.pos_neg_classes: $cross_result.pos_neg_classes')
	if verify_result.pos_neg_classes.len == 2 {
		verify_result.BinaryMetrics = get_binary_stats(verify_result)
	}

	// verify_result.command = 'verify'
	// println('verify_result: $verify_result')
	if opts.command == 'verify' && (opts.show_flag || opts.expanded_flag) {
		show_verify(verify_result, opts)
	}
	if opts.outputfile_path != '' {
		verify_result.command = 'verify'
		save_json_file[CrossVerifyResult](verify_result, opts.outputfile_path)
	}
	// println(opts)
	if opts.append_settings_flag {
		append_cross_verify_settings_to_file(verify_result, opts)
	}
	return verify_result
}

// // generate_case_array
// fn generate_case_array(cl Classifier, test_ds Dataset) [][]u8 {
// 	// for each usable attribute in cl, massage the equivalent test_ds attribute
// 	// println(cl)
// 	mut test_binned_values := []int{}
// 	mut test_attr_binned_values := [][]u8{}
// 	mut test_index := 0
// 	for attr in cl.attribute_ordering {
// 		// get an index into this attribute in test_ds
// 		for j, value in test_ds.attribute_names {
// 			if value == attr {
// 				test_index = j
// 			}
// 		}
// 		if cl.trained_attributes[attr].attribute_type == 'C' {
// 			test_binned_values = discretize_attribute[f32](test_ds.useful_continuous_attributes[test_index],
// 				cl.trained_attributes[attr].minimum, cl.trained_attributes[attr].maximum,
// 				cl.trained_attributes[attr].bins)
// 		} else { // ie for discrete attributes
// 			test_binned_values = test_ds.useful_discrete_attributes[test_index].map(cl.trained_attributes[attr].translation_table[it])
// 		}
// 		test_attr_binned_values << test_binned_values.map(u8(it))
// 	}
// 	// println('test_attr_binned_values in generate_case_array: $test_attr_binned_values')
// 	return transpose(test_attr_binned_values)
// }

// // option_worker_verify
// fn option_worker_verify(work_channel chan int, result_channel chan ClassifyResult, cl Classifier, case [][]u8, labeled_classes []string, opts Options, disp DisplaySettings) {
// 	mut index := <-work_channel
// 	mut classify_result := classify_case(cl, case[index], opts)
// 	classify_result.labeled_class = labeled_classes[index]
// 	result_channel <- classify_result
// 	// dump(result_channel)
// 	return
// }
