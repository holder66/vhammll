// verify.v
module vhammll

import runtime

// verify classifies all the instances in a verification datafile (specified
// by `opts.testfile_path`) using a trained Classifier; returns metrics
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
// show_attributes_flag: list the trained attributes for the classifier used
// outputfile_path: saves the result as a json file
// ```
pub fn verify(opts Options) CrossVerifyResult {
	if opts.traverse_all_flags && opts.multiple_flag {
		// in a series of nested loops, repeatedly execute the mu
		// function over both true and false settings for the various
		// flags in opts.Parameters
		mut af_opts := opts
		af_opts.show_flag = false
		mut af_result := CrossVerifyResult{}
		ft := [false, true]
		for ma in ft {
			af_opts.break_on_all_flag = ma
			for mc in ft {
				af_opts.combined_radii_flag = mc
				for mt in ft {
					af_opts.total_nn_counts_flag = mt
					dump(af_opts)
					af_result = run_verify(af_opts)
					println('corrects: ${af_result.correct_counts} balanced accuracy: ${af_result.balanced_accuracy:-6.2f} MCC: ${af_result.mcc:-7.3f} sens: ${af_result.sens:-7.3f} spec: ${af_result.spec:-4.3f} ma ${ma} mc ${mc} mt ${mt} ${af_opts.classifiers}')
				}
			}
		}
		return af_result // returns just the last result
	}
	if opts.multiple_flag {
		return multi_verify(opts)
	}
	if opts.one_vs_rest_flag {
		return one_vs_rest_verify(opts)
	}
	return run_verify(opts)
}

fn run_verify(opts Options) CrossVerifyResult {
	mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	// if the balance_prevalences flag is set, then we need to possibly add
	// the extra cases at this stage
	if opts.balance_prevalences_flag && evaluate_class_prevalence_imbalance(ds, opts) {
		ds = balance_prevalences(mut ds, opts.balance_prevalences_threshold)
	}
	// load the testfile as a Dataset struct, but reset
	mut testfile_load_opts := opts.LoadOptions
	{}
	mut test_ds := load_file(opts.testfile_path, testfile_load_opts)
	mut confusion_matrix_map := map[string]StringFloatMap{}
	// for each class, instantiate an entry in the confusion matrix map
	for key1, _ in test_ds.class_counts {
		for key2, _ in test_ds.class_counts {
			confusion_matrix_map[key2][key1] = 0
		}
	}
	// instantiate a struct for the result
	mut inferences_map := map[string]int{}
	for key, _ in ds.class_counts {
		inferences_map[key] = 0
	}
	mut verify_result := CrossVerifyResult{
		LoadOptions:                         opts.LoadOptions
		Parameters:                          opts.Parameters
		DisplaySettings:                     opts.DisplaySettings
		MultipleOptions:                     opts.MultipleOptions
		Class:                               ds.Class
		datafile_path:                       opts.datafile_path
		testfile_path:                       opts.testfile_path
		multiple_classify_options_file_path: opts.multiple_classify_options_file_path
		multiple_classifier_settings:        opts.multiple_classifier_settings
		labeled_classes:                     test_ds.class_values
		// class_counts:                         test_ds.class_counts
		// pre_balance_prevalences_class_counts: ds.pre_balance_prevalences_class_counts
		// classes:                              test_ds.classes
		pos_neg_classes:      get_pos_neg_classes(test_ds)
		confusion_matrix_map: confusion_matrix_map
		correct_inferences:   inferences_map.clone()
		incorrect_inferences: inferences_map.clone()
		wrong_inferences:     inferences_map.clone()
		true_positives:       inferences_map.clone()
		true_negatives:       inferences_map.clone()
		false_positives:      inferences_map.clone()
		false_negatives:      inferences_map.clone()
	}
	verify_result.binning = get_binning(opts.bins)
	// mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	mut cl := Classifier{}
	if opts.classifierfile_path == '' {
		cl = make_classifier_using_ds(mut ds, opts)
	} else {
		cl = load_classifier_file(opts.classifierfile_path) or { panic(err) }
	}
	verify_result.trained_attribute_maps_array << cl.trained_attributes
	// verify_result.command = 'verify' // override the 'make' command from cl.Parameters
	// massage each case in the test dataset according to the
	// attribute parameters in the classifier
	case_array := generate_case_array(cl, test_ds)
	// for the instances in the test data, perform classifications
	// verify_result = classify_to_verify(cl, case_array, mut verify_result, opts, disp)
	// for each instance in the test data, perform a classification
	mut classify_result := ClassifyResult{}
	if opts.concurrency_flag && !opts.multiple_flag {
		mut work_channel := chan int{cap: runtime.nr_jobs()}
		mut result_channel := chan ClassifyResult{cap: case_array.len}
		for i, _ in case_array {
			work_channel <- i
			spawn option_worker_verify(work_channel, result_channel, cl, case_array, verify_result.labeled_classes,
				opts)
		}
		for i, _ in case_array {
			classify_result = <-result_channel
			if opts.verbose_flag {
				verbose_result(i, cl, classify_result)
			}
			verify_result.inferred_classes << classify_result.inferred_class
			verify_result.actual_classes << classify_result.labeled_class
			verify_result.nearest_neighbors_by_class << classify_result.nearest_neighbors_by_class
		}
	} else {
		for i, test_instance in case_array {
			classify_result = classify_case(cl, test_instance, opts)
			// result.inferred_classes << classify_case(cl, test_instance, opts).inferred_class
			verify_result.inferred_classes << classify_result.inferred_class
			verify_result.nearest_neighbors_by_class << classify_result.nearest_neighbors_by_class
			verify_result.actual_classes << verify_result.labeled_classes[i]
			if opts.verbose_flag {
				verbose_result(i, cl, classify_result)
			}
		}
	}
	verify_result.classifier_instances_counts << cl.history_events[0].instances_count
	verify_result.prepurge_instances_counts_array << cl.history_events[0].prepurge_instances_count
	// if opts.verbose_flag && !opts.multiple_flag && opts.command == 'verify' {
	// 	println('result in classify_to_verify(): ${result}')
	// }
	verify_result = summarize_results(1, mut verify_result)
	// if disp.verbose_flag && !opts.multiple_flag && opts.command == 'verify' {
	// 	println('summarize_result: ${result}')
	// }
	// } else { // ie, asking for multiple classifiers
	// 	mut classifier_array := []Classifier{}
	// 	mut instances_to_be_classified := [][][]u8{}
	// 	// mut mult_opts := []Parameters{}
	// 	mut mult_opts := opts
	// 	mult_opts.MultipleClassifierSettingsArray = read_multiple_opts(mult_opts.multiple_classify_options_file_path) or {
	// 		panic('read_multiple_opts failed')
	// 	}
	// 	// println(mult_opts)
	// 	verify_result.MultipleClassifierSettingsArray = mult_opts.MultipleClassifierSettingsArray
	// 	// mult_opts.break_on_all_flag = opts.break_on_all_flag
	// 	// mult_opts.combined_radii_flag = opts.combined_radii_flag
	// 	if mult_opts.classifiers == [] {
	// 		mult_opts.classifiers = []int{len: mult_opts.multiple_classifier_settings.len, init: index}
	// 	}
	// 	verify_result.classifier_indices = mult_opts.classifiers
	// 	// mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	// 	// mut saved_params := read_multiple_opts(opts.multiple_classify_options_file_path) or {
	// 	// 	MultipleClassifierSettingsArray{}
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
	if verify_result.pos_neg_classes.len == 2 {
		verify_result.BinaryMetrics = get_binary_stats(verify_result)
	}
	// assert verify_result.correct_counts.len == verify_result.classes.len

	// verify_result.command = 'verify'
	if opts.command != 'explore' && (opts.show_flag || opts.expanded_flag) {
		show_verify(verify_result, opts)
	}
	if opts.outputfile_path != '' {
		verify_result.command = 'verify'
		save_json_file[CrossVerifyResult](verify_result, opts.outputfile_path)
	}
	// println(opts)
	if opts.append_settings_flag && opts.command != 'explore' {
		append_cross_verify_settings_to_file(verify_result, opts)
	}
	verify_result.train_dataset_class_counts = ds.class_counts.clone()
	return verify_result
}

// generate_case_array
fn generate_case_array(cl Classifier, test_ds Dataset) [][]u8 {
	// for each usable attribute in cl, massage the equivalent test_ds attribute
	// println(cl)
	mut test_binned_values := []int{}
	mut test_attr_binned_values := [][]u8{}
	mut test_index := 0
	for attr in cl.attribute_ordering {
		// get an index into this attribute in test_ds
		for j, value in test_ds.attribute_names {
			if value == attr {
				test_index = j
			}
		}
		if cl.trained_attributes[attr].attribute_type == 'C' {
			test_binned_values = discretize_attribute_with_range_check[f32](test_ds.useful_continuous_attributes[test_index],
				cl.trained_attributes[attr].minimum, cl.trained_attributes[attr].maximum,
				cl.trained_attributes[attr].bins)
		} else { // ie for discrete attributes
			test_binned_values = test_ds.useful_discrete_attributes[test_index].map(cl.trained_attributes[attr].translation_table[it])
		}
		test_attr_binned_values << test_binned_values.map(u8(it))
	}
	// println('test_attr_binned_values in generate_case_array: $test_attr_binned_values')
	return transpose(test_attr_binned_values)
}

// option_worker_verify
fn option_worker_verify(work_channel chan int, result_channel chan ClassifyResult, cl Classifier, case_array [][]u8, labeled_classes []string, opts Options, disp DisplaySettings) {
	mut index := <-work_channel
	mut classify_result := classify_case(cl, case_array[index], opts)
	classify_result.labeled_class = labeled_classes[index]
	result_channel <- classify_result
	// dump(result_channel)
	return
}

fn instantiate_cross_verify_result_struct(ds Dataset, opts Options) CrossVerifyResult {
	// mut inferences_map := map[string]int
	return CrossVerifyResult{}
}

// // classify_to_verify classifies each case in an array, and
// // returns the results of the classification.
// fn classify_to_verify(cl Classifier, case [][]u8, mut result CrossVerifyResult, opts Options, disp DisplaySettings) CrossVerifyResult {
// 	// for each instance in the test data, perform a classification
// 	mut classify_result := ClassifyResult{}
// 	if opts.concurrency_flag {
// 		mut work_channel := chan int{cap: runtime.nr_jobs()}
// 		mut result_channel := chan ClassifyResult{cap: case.len}
// 		for i, _ in case {
// 			work_channel <- i
// 			spawn option_worker_verify(work_channel, result_channel, cl, case, result.labeled_classes,
// 				opts, disp)
// 		}
// 		for i, _ in case {
// 			classify_result = <-result_channel
// 			// println(classify_result)
// 			if disp.verbose_flag {
// 				verbose_result(i, cl, classify_result)
// 			}
// 			result.inferred_classes << classify_result.inferred_class
// 			result.actual_classes << classify_result.labeled_class
// 			result.nearest_neighbors_by_class << classify_result.nearest_neighbors_by_class
// 		}
// 	} else {
// 		for i, test_instance in case {
// 			classify_result = classify_case(cl, test_instance, opts, disp)
// 			// result.inferred_classes << classify_case(cl, test_instance, opts).inferred_class
// 			result.inferred_classes << classify_result.inferred_class
// 			result.nearest_neighbors_by_class << classify_result.nearest_neighbors_by_class
// 			result.actual_classes << result.labeled_classes[i]
// 			if opts.verbose_flag {
// 				verbose_result(i, cl, classify_result)
// 			}
// 		}
// 	}
// 	result.classifier_instances_counts << cl.history[0].instances_count
// 	result.prepurge_instances_counts_array << cl.history[0].prepurge_instances_count
// 	// if opts.verbose_flag && !opts.multiple_flag && opts.command == 'verify' {
// 	// 	println('result in classify_to_verify(): ${result}')
// 	// }
// 	result = summarize_results(1, mut result)
// 	// if opts.verbose_flag && !opts.multiple_flag && opts.command == 'verify' {
// 	// 	println('summarize_result: ${result}')
// 	// }
// 	return result
// }
