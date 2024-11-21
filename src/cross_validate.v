// cross_validate.v
module vhammll

import strconv
import runtime
import rand

// cross_validate performs n-fold cross-validation on a dataset: it
// partitions the instances in a dataset into a fold, trains
// a classifier on all the dataset instances not in the fold, and
// then uses this classifier to classify the fold cases. This
// process is repeated for each of n folds, and the classification
// results are summarized.
// ```sh
// Options (also see the Options struct):
// bins: range for binning or slicing of continuous attributes;
// number_of_attributes: the number of attributes to use, in descending
// 	order of rank value;
// exclude_flag: excludes missing values when ranking attributes;
// weighting_flag: nearest neighbor counts are weighted by
// 	class prevalences;
// folds: number of folds n to use for n-fold cross-validation (default
// 	is leave-one-out cross-validation);
// repetitions: number of times to repeat n-fold cross-validations;
// random-pick: choose instances randomly for n-fold cross-validations.
// Output options:
// show_flag: prints results to the console;
// expanded_flag: prints additional information to the console, including
// 	a confusion matrix.
// outputfile_path: saves the result as a json file.
// ```
pub fn cross_validate(ds Dataset, opts Options) CrossVerifyResult {
	// disp := opts.DisplaySettings
	// println('disp in cross_validate: $disp')
	// println('ds.class_counts in cross_validate.v: ${ds.class_counts}')
	// to sort out what is going on, run the test file with concurrency off.
	mut cross_opts := opts
	cross_opts.datafile_path = ds.path
	mut total_instances := ds.Class.class_values.len

	repeats := if opts.repetitions == 0 { 1 } else { opts.repetitions }
	// for each class, instantiate an entry in the confusion matrix map
	mut confusion_matrix_map := map[string]map[string]f64{}
	for key1, _ in ds.class_counts {
		for key2, _ in ds.class_counts {
			confusion_matrix_map[key2][key1] = 0
		}
	}
	// instantiate a struct for the result
	mut inferences_map := map[string]int{}
	for key, _ in ds.class_counts {
		inferences_map[key] = 0
	}
	mut cross_result := CrossVerifyResult{
		Parameters:      cross_opts.Parameters
		LoadOptions:     cross_opts.LoadOptions
		DisplaySettings: opts.DisplaySettings
		MultipleOptions: cross_opts.MultipleOptions
		// MultipleClassifierSettingsArray: cross_opts.MultipleClassifierSettingsArray
		datafile_path:                       ds.path
		multiple_classify_options_file_path: cross_opts.multiple_classify_options_file_path
		labeled_classes:                     ds.class_values
		class_counts:                        ds.class_counts
		classes:                             ds.classes
		pos_neg_classes:                     get_pos_neg_classes(ds.class_counts)
		confusion_matrix_map:                confusion_matrix_map
		correct_inferences:                  inferences_map.clone()
		incorrect_inferences:                inferences_map.clone()
		wrong_inferences:                    inferences_map.clone()
		true_positives:                      inferences_map.clone()
		true_negatives:                      inferences_map.clone()
		false_positives:                     inferences_map.clone()
		false_negatives:                     inferences_map.clone()
	}
	if opts.multiple_flag {
		// println('yes! opts.multiple flag is set')
		// disable concurrency, as not implemented for multiple classifiers
		cross_opts.concurrency_flag = false
		mut classifier_array := []Classifier{}

		// cross_opts.MultipleClassifierSettingsArray = read_multiple_opts(cross_opts.multiple_classify_options_file_path) or {
		// 	panic('read_multiple_opts failed')
		// }
		// classifier_settings is a MultipleClassifierSettingsArray struct; first, read in all the classifier settings
		classifier_settings := read_multiple_opts(cross_opts.multiple_classify_options_file_path) or {
			panic('read_multiple_opts failed')
		}
		settings_array := classifier_settings.multiple_classifier_settings
		cross_opts.break_on_all_flag = opts.break_on_all_flag
		cross_opts.combined_radii_flag = opts.combined_radii_flag
		// cross_opts.classifier_indices = opts.classifier_indices
		if opts.classifier_indices == [] {
			// cross_opts.classifier_indices = []int{len: cross_opts.multiple_classifier_settings.len, init: index}
			cross_opts.classifier_indices = []int{len: settings_array.len, init: index}
		} else {
			cross_opts.classifier_indices = opts.classifier_indices
		}
		cross_result.classifier_indices = cross_opts.classifier_indices
		// cross_result.MultipleClassifierSettingsArray = cross_opts.MultipleClassifierSettingsArray
		for ci in cross_opts.classifier_indices {
			cross_opts.multiple_classifier_settings << settings_array[ci]
		}
		for i, _ in cross_opts.classifier_indices {
			mut params := cross_opts.multiple_classifier_settings[i].Parameters
			params.multiple_flag = true
			cross_opts.Parameters = params
			cross_result.Parameters = params
			// cross_result.MultipleClassifierSettingsArray.multiple_classifier_settings << cross_opts.MultipleClassifierSettingsArray.multiple_classifier_settings[i]
			// cross_result.multiple_classifier_settings >> params

			classifier_array << make_classifier(ds, cross_opts)
		}
		// println('cross_result.MultipleClassifierSettingsArray.multiple_classifier_settings: $cross_result.MultipleClassifierSettingsArray.multiple_classifier_settings')
		// println('cross_result.MultipleClassifierSettingsArray in cross_validate: $cross_result.MultipleClassifierSettingsArray')
		// println('classifier_array in cross_validate: $classifier_array')
		// mut m_classify_result := ClassifyResult{}
		mut maximum_hamming_distance_array := []int{}
		for cl in classifier_array {
			maximum_hamming_distance_array << cl.maximum_hamming_distance
		}
		// cases = transpose(cases)

		cross_opts.maximum_hamming_distance_array = maximum_hamming_distance_array
		cross_opts.total_max_ham_dist = array_sum(maximum_hamming_distance_array)
		cross_opts.lcm_max_ham_dist = lcm(maximum_hamming_distance_array)

		if opts.verbose_flag {
			println('cross_opts in cross_validate.v: ${cross_opts}')
		}
	}
	// println(cross_opts.classifier_indices)

	// if there are no useful continuous attributes, set binning to 0
	if ds.useful_continuous_attributes.len == 0 {
		cross_opts.bins = [0]
	}
	cross_result.binning = get_binning(cross_opts.bins)
	mut repetition_result := CrossVerifyResult{}
	for rep in 0 .. repeats {
		// generate a pick list of indices
		mut pick_list := []int{}
		if opts.random_pick {
			mut n := 0
			for pick_list.len < total_instances {
				n = rand.int_in_range(0, total_instances) or { 0 }
				if n in pick_list {
					continue
				}
				pick_list << n
			}
		} else {
			for i in 0 .. total_instances {
				pick_list << i
			}
		}
		repetition_result = do_repetition(pick_list, rep, ds, cross_opts) or { panic(err) }
		// println('repetition_result in cross_validate.v: ${repetition_result}')
		cross_result.inferred_classes << repetition_result.inferred_classes
		cross_result.actual_classes << repetition_result.actual_classes
		cross_result.binning = repetition_result.binning
		cross_result.classifier_instances_counts << repetition_result.classifier_instances_counts
		cross_result.prepurge_instances_counts_array << repetition_result.prepurge_instances_counts_array
		cross_result.maximum_hamming_distance = repetition_result.maximum_hamming_distance
	}
	cross_result = summarize_results(repeats, mut cross_result)
	cross_result.Metrics = get_metrics(cross_result)
	// println('cross_result.pos_neg_classes: $cross_result.pos_neg_classes')
	if cross_result.pos_neg_classes.len == 2 {
		cross_result.BinaryMetrics = get_binary_stats(cross_result)
	}

	if opts.command == 'cross' && (opts.show_flag || opts.expanded_flag) {
		// cross_result.MultipleClassifierSettingsArray = cross_opts.MultipleClassifierSettingsArray
		show_crossvalidation(cross_result, cross_opts)
	}
	// dump(opts)
	if opts.outputfile_path != '' {
	cross_result.command = 'cross'
		save_json_file(cross_result, opts.outputfile_path)
	}
	if opts.multiple_flag && opts.append_settings_flag && opts.command == 'cross' {
		append_cross_settings_to_file(cross_result, opts)
	}
	return cross_result
}

// append_cross_settings_to_file
fn append_cross_settings_to_file(result CrossVerifyResult, opts Options) {
	// println('opts in append_cross_settings_to_file: $opts')
	// println('result in append_cross_settings_to_file: $result')
	append_json_file(ClassifierSettings{
		Parameters:    result.Parameters
		BinaryMetrics: result.BinaryMetrics
		Metrics:       result.Metrics
		datafile_path: ''
	}, opts.settingsfile_path)
}

// do_repetition
fn do_repetition(pick_list []int, rep int, ds Dataset, cross_opts Options) ?CrossVerifyResult {
	mut fold_result := CrossVerifyResult{}
	// instantiate a struct for the result
	mut repetition_result := CrossVerifyResult{}
	// test if leave-one-out crossvalidation is requested
	folds := if cross_opts.folds == 0 { ds.class_values.len } else { cross_opts.folds }
	if cross_opts.verbose_flag {
		// println(g('repetition: ${rep}'))
	}
	// if the concurrency flag is set
	if cross_opts.concurrency_flag {
		// we are not implementing this for multiple classifiers
		mut result_channel := chan CrossVerifyResult{cap: folds}
		// queue all work + the sentinel values:
		jobs := runtime.nr_jobs()
		mut work_channel := chan int{cap: folds + jobs}
		for i in 0 .. folds {
			work_channel <- i
		}
		for _ in 0 .. jobs {
			work_channel <- -1
		}
		// start a thread pool to do the work:
		mut tpool := []thread{}
		for _ in 0 .. jobs {
			tpool << spawn option_worker(work_channel, result_channel, pick_list, folds,
				ds, cross_opts)
		}
		tpool.wait()
		//
		for _ in 0 .. folds {
			fold_result = <-result_channel
			// println(summarize_results(1, mut fold_result).incorrects_count)
			repetition_result.inferred_classes << fold_result.inferred_classes
			repetition_result.actual_classes << fold_result.labeled_classes
			repetition_result.binning = fold_result.binning
			repetition_result.classifier_instances_counts << fold_result.classifier_instances_counts
			repetition_result.prepurge_instances_counts_array << fold_result.prepurge_instances_counts_array
		}
	} else { // ie the concurrency flag is not set
		// for each fold
		for current_fold in 0 .. folds {
			fold_result = do_one_fold(pick_list, current_fold, folds, ds, cross_opts)
			// println('fold_result in do_repetition(): $fold_result')
			repetition_result.inferred_classes << fold_result.inferred_classes
			repetition_result.actual_classes << fold_result.labeled_classes
			repetition_result.binning = fold_result.binning
			repetition_result.classifier_instances_counts << fold_result.classifier_instances_counts
			repetition_result.prepurge_instances_counts_array << fold_result.prepurge_instances_counts_array
			repetition_result.maximum_hamming_distance = fold_result.maximum_hamming_distance
			// println('repetition_result in do_repetition(): ${repetition_result}')
		}
	}
	// println('repetition_result.maximum_hamming_distance: ${repetition_result.maximum_hamming_distance}')
	// println('repetition_result.MultipleClassifierSettingsArray.multiple_classifier_settings.len: ${repetition_result.MultipleClassifierSettingsArray.multiple_classifier_settings.len}')
	return repetition_result
}

// summarize_results
fn summarize_results(repeats int, mut result CrossVerifyResult) CrossVerifyResult {
	// println(result.classifier_instances_counts)
	mut inferred := ''
	for i, actual in result.actual_classes {
		inferred = result.inferred_classes[i]

		result.labeled_instances[actual] += 1
		result.total_count += 1
		if inferred != '' {
			result.confusion_matrix_map[actual][inferred] += 1
		}
		// println('actual: ${actual}   inferred: ${inferred}   map: ${result.confusion_matrix_map}')
		if actual == inferred {
			result.correct_inferences[actual] += 1
			result.correct_count += 1
			result.true_positives[actual] += 1
		} else {
			if inferred != '' {
				result.wrong_inferences[inferred] += 1
				result.false_positives[inferred] += 1
			}
			result.incorrect_inferences[actual] += 1
			result.false_negatives[actual] += 1
			result.incorrects_count += 1
			result.wrong_count += 1
		}
	}
	if repeats > 1 {
		result.correct_count /= repeats
		result.incorrects_count /= repeats
		result.wrong_count /= repeats
		result.total_count /= repeats

		for _, mut v in result.labeled_instances {
			v /= f64(repeats)
		}
		for _, mut v in result.correct_inferences {
			v /= f64(repeats)
		}
		for _, mut v in result.incorrect_inferences {
			v /= f64(repeats)
		}
		for _, mut v in result.wrong_inferences {
			v /= f64(repeats)
		}
		for _, mut v in result.true_positives {
			v /= f64(repeats)
		}
		for _, mut v in result.false_positives {
			v /= f64(repeats)
		}
		for _, mut v in result.false_negatives {
			v /= f64(repeats)
		}

		for _, mut m in result.confusion_matrix_map {
			for _, mut v in m {
				v /= f64(repeats)
			}
		}
	}
	return result
}

// div_map
fn div_map(n int, mut m map[string]int) map[string]int {
	for _, mut a in m {
		a /= n
	}
	return m
}

// do_one_fold
fn do_one_fold(pick_list []int, current_fold int, folds int, ds Dataset, cross_opts Options) CrossVerifyResult {
	// println('cross_opts in do_one_fold: ${cross_opts}')
	mut byte_values_array := [][]u8{}
	// partition the dataset into a partial dataset and a fold
	mut part_ds, fold := partition(pick_list, current_fold, folds, ds, cross_opts)
	// println('fold in do_one_fold: $fold')
	mut fold_result := CrossVerifyResult{
		labeled_classes:  fold.class_values
		instance_indices: fold.indices
	}
	if cross_opts.verbose_flag {
		println(y('current fold: ${current_fold}'))
	}

	if !cross_opts.multiple_flag {
		part_cl := make_classifier(part_ds, cross_opts)
		// println('attribute_ordering in do_one_fold: $part_cl.attribute_ordering')
		// println('part_cl.maximum_hamming_distance: ${part_cl.maximum_hamming_distance}')
		fold_result.binning = part_cl.binning
		fold_result.maximum_hamming_distance = part_cl.maximum_hamming_distance

		fold_result.classifier_instances_counts << part_cl.instances.len
		fold_result.prepurge_instances_counts_array << part_cl.history[0].prepurge_instances_count
		for attr in part_cl.attribute_ordering {
			// get the index of the corresponding attribute in the fold
			j := fold.attribute_names.index(attr)
			// create byte_values for the fold data
			byte_values_array << process_fold_data(part_cl.trained_attributes[attr], fold.data[j])
		}
		// since the arrays in byte_values_array correspond to attributes,
		// we need to transpose the array so that the top level corresponds to the cases in a fold
		// to be classified, and the values in each array correspond to the trained attributes.
		fold_cases := transpose(byte_values_array)
		// for each class, instantiate an entry in the class table for the result
		// note that this needs to use the classes in the partition portion, not
		// the fold, so that wrong inferences get recorded properly.
		mut confusion_matrix_row := map[string]int{}
		// for each class, instantiate an entry in the confusion matrix row
		for key, _ in ds.Class.class_counts {
			confusion_matrix_row[key] = 0
		}

		// fold_result = classify_in_cross(part_cl, fold_cases, mut fold_result, cross_opts, disp)
		// println('disp in do_one_fold: $disp')
		for i, case in fold_cases {
			classify_result := classify_case(part_cl, case, cross_opts)
			if cross_opts.verbose_flag {
				verbose_result(i, part_cl, classify_result)
			}
			fold_result.inferred_classes << classify_result.inferred_class
			fold_result.actual_classes << fold_result.labeled_classes[i]
		}
	} else { // ie, asking for multiple classifiers...
		// note that in this situation, a case will consist of an array of arrays of differing lengths,
		// corresponding to the differing classifiers.
		// conceptually, doing one fold with multiple classifiers is like doing
		// a multi_verify,
		mut classifier_array := []Classifier{}
		mut mult_fold_cases := [][][]u8{}
		mut mult_opts := cross_opts
		// println('mult_opts in do_one_fold: $mult_opts')
		// create an array of classifiers, one for each index in classifier_indices
		for i, _ in mult_opts.classifier_indices {
			mut params := mult_opts.multiple_classifier_settings[i].Parameters
			mult_opts.Parameters = params
			fold_result.Parameters = params
			part_cl := make_classifier(part_ds, mult_opts)
			classifier_array << part_cl
			byte_values_array = [][]u8{}
			// mult_byte_values_array := [][]u8{}
			for attr in part_cl.attribute_ordering {
				j := fold.attribute_names.index(attr)
				byte_values_array << process_fold_data(part_cl.trained_attributes[attr],
					fold.data[j])
			}

			fold_cases := transpose(byte_values_array)
			// println('byte_values_array in do_one_fold: $byte_values_array')
			// println('fold_cases in do_one_fold: $fold_cases')

			mult_fold_cases << [fold_cases]
		}
		// mut mult_fold_cases := [][][]u8{}
		// for i, case in fold_cases {
		// 	mult_fold_cases[i] = case
		// }
		// if cross_opts.multiple_flag {
		// 	println('mult_fold_cases in do_one_fold: $mult_fold_cases')
		// 	println('transposed: ${transpose(mult_fold_cases)}')
		// }
		// fold_result = multiple_classify_in_cross(current_fold, classifier_array, transpose(instances_to_be_classified), mut fold_result, mult_opts)
		for i, case in transpose(mult_fold_cases) {
			if cross_opts.verbose_flag {
				println('\ncase: ${i:-7}  ${case}    classes: ${classifier_array[0].classes.join(' | ')}')
			}
			// println('i: $i test_instance: $test_instance')
			// m_classify_result := multiple_classifier_classify(classifier_array, case,
			// fold_result.labeled_classes, mult_opts, disp)
			// println('just before classify')
			m_classify_result := if mult_opts.total_nn_counts_flag {
				multiple_classifier_classify_totalnn(classifier_array, case, fold_result.labeled_classes,
					mult_opts)
			} else {
				multiple_classifier_classify(classifier_array, case, fold_result.labeled_classes,
					mult_opts)
			}
			fold_result.inferred_classes << m_classify_result.inferred_class
			fold_result.actual_classes << fold_result.labeled_classes[i]
			fold_result.nearest_neighbors_by_class << m_classify_result.nearest_neighbors_by_class
		}
		fold_result.MultipleOptions = mult_opts.MultipleOptions
		fold_result.MultipleClassifierSettingsArray = mult_opts.MultipleClassifierSettingsArray
		// println('fold_result.MultipleClassifierSettingsArray.len: ${fold_result.MultipleClassifierSettingsArray.multiple_classifier_settings.len}')
	}
	// println('fold_result.maximum_hamming_distance: ${fold_result.maximum_hamming_distance}')
	return fold_result
}

// process_fold_data takes the data array corresponding to a specific attribute for all the
// cases to be classified, and for each case to be classified,
// gets either the translation table value for that case's value if a discrete attribute,
// or gets the bin number for the value if a continuous attribute.
// These byte values are returned in an array, one byte value for each case to be classified.
fn process_fold_data(part_attr TrainedAttribute, fold_data []string) []u8 {
	mut byte_vals := []u8{cap: fold_data.len}
	// for a continuous attribute
	if part_attr.attribute_type == 'C' {
		values := fold_data.map(f32(strconv.atof_quick(it)))
		byte_vals << bin_values_array(values, part_attr.minimum, part_attr.maximum, part_attr.bins)
	} else {
		byte_vals << fold_data.map(u8(part_attr.translation_table[it]))
	}
	return byte_vals
}

// option_worker
fn option_worker(work_channel chan int, result_channel chan CrossVerifyResult, pick_list []int, folds int, ds Dataset, opts Options) {
	for {
		mut current_fold := <-work_channel
		if current_fold < 0 {
			break
		}
		result_channel <- do_one_fold(pick_list, current_fold, folds, ds, opts)
	}
}
