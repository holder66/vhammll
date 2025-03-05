// optimals.v
module vhammll

// import arrays

// optimals determines which classifiers provide the best balanced accuracy, best Matthews
// Correlation Coefficient (MCC), highest total for
// correct inferences, and highest correct inferences per class, for multiple classifiers whose
// settings are stored in a settings file.
// ```sh
// Options (also see the Options struct):
// purge_flag: discard duplicate settings
// Output options:
// show_flag: prints a list of classifier settings indices for each category;
// expanded_flag: for each setting, prints the Parameters, results obtained, and Metrics
// outputfile_path: saves the settings in a file given by the path. Useful if the settings are purged.
// ```
pub fn optimals(path string, opts Options) OptimalsResult {
	// settings_struct is a MultipleClassifierSettings struct
	// settings is an array of ClassifierSettings structs
	all_settings := read_multiple_opts(path) or { panic('read_multiple_opts failed') }
	mut settings := []ClassifierSettings{cap: all_settings.len}
	if opts.purge_flag {
		settings = purge_duplicate_settings(all_settings)
	} else {
		settings = all_settings.clone()
	}
	mut result := OptimalsResult{
		class_counts:                             settings[0].class_counts_int
		classes:                                  []string{len: settings[0].class_counts_int.len, init: '${index}'}
		balanced_accuracy_max:                    array_max(settings.map(it.balanced_accuracy))
		balanced_accuracy_max_classifiers:        idxs_max(settings.map(it.balanced_accuracy))
		mcc_max:                                  array_max(settings.map(it.mcc))
		mcc_max_classifiers:                      idxs_max(settings.map(it.mcc))
		correct_inferences_total_max:             array_max(settings.map(array_sum(it.correct_counts)))
		correct_inferences_total_max_classifiers: idxs_max(settings.map(array_sum(it.correct_counts)))
	}

	for i, _ in result.classes {
		result.correct_inferences_by_class_max << array_max(settings.map(it.correct_counts[i]))
		result.correct_inferences_by_class_max_classifiers << idxs_max(settings.map(it.correct_counts[i]))
	}
	// to display the settings for ROC, we assume the first entry in correct_counts is the master class
	// thus the highest value for the entries in this position is
	max_roc_entry := result.correct_inferences_by_class_max[0]
	correct_counts := settings.map(it.correct_counts)
	mut roc_classifier_indices := []int{len: max_roc_entry + 1, init: -1}
	mut roc_table := [][]int{len: max_roc_entry + 1, init: []int{len: result.classes.len}}
	for i, mut counts in roc_table { // i is the value for the master class's correct count
		for j, corrects in correct_counts { // j is the classifier index
			if corrects[0] == i {
				if array_sum(corrects) > array_sum(counts) {
					roc_table[i] = corrects
					roc_classifier_indices[i] = j
				}
				continue
			}
		}
	}
	result.receiver_operating_characteristic_settings = roc_classifier_indices.filter(it != -1)

	if opts.show_flag || opts.expanded_flag {
		println('result in optimals: ${result}')
	}
	if opts.expanded_flag {
		println(m_u('Optimal classifiers in settings file: ${path}'))
		println(lg('Total number of settings: ${all_settings.len}'))
		if opts.purge_flag {
			println(lg('Duplicates purged: ${all_settings.len - settings.len}'))
		}
		println(c_u('Best balanced accuracy: ') + g('${result.balanced_accuracy_max:6.2f}%'))
		show_multiple_classifier_settings_details(filter_array_by_index(settings, result.balanced_accuracy_max_classifiers),
			result.balanced_accuracy_max_classifiers)
		println(c_u('Best Matthews Correlation Coefficient (MCC): ') + g('${result.mcc_max:7.3f}'))
		show_multiple_classifier_settings_details(filter_array_by_index(settings, result.mcc_max_classifiers),
			result.mcc_max_classifiers)
		println(c_u('Highest value for total correct inferences: ') +
			g('${result.correct_inferences_total_max} / ${array_sum(result.class_counts)}'))
		show_multiple_classifier_settings_details(filter_array_by_index(settings, result.correct_inferences_total_max_classifiers),
			result.correct_inferences_total_max_classifiers)
		println(c_u('Best correct inferences by class:'))
		for i, class in result.classes {
			println(g_b('For class: ${class}') +
				g('  ${result.correct_inferences_by_class_max[i]} / ${result.class_counts[i]}'))
			show_multiple_classifier_settings_details(filter_array_by_index(settings,
				result.correct_inferences_by_class_max_classifiers[i]), result.correct_inferences_by_class_max_classifiers[i])
		}
		println(c_u('Settings for Receiver Operating Characteristic (ROC) curve:'))
		show_multiple_classifier_settings_details(pick_array_elements_by_index(settings,
			result.receiver_operating_characteristic_settings), result.receiver_operating_characteristic_settings)
	}
	if opts.outputfile_path != '' {
		for setting in settings {
			append_json_file(setting, opts.outputfile_path)
		}
	}
	return result
}

fn purge_duplicate_settings(settings []ClassifierSettings) []ClassifierSettings {
	// in a loop, compare the last element to all the previous elements. If a match is found, discard
	// that element, and repeat with the remaining elements
	params := []Parameters{len: settings.len, init: settings[index].Parameters}
	mut purged_settings := []int{cap: settings.len}
	for i in 1 .. settings.len {
		idx := settings.len - i
		// println('${idx}, ${settings[idx].classifier_index}')
		// test if the last element has the same parameters as any of the elements is the remainder;
		// if not, move its index into the purged_settings array

		if params[idx] !in params[0..idx] {
			// println('no match')
			purged_settings << idx
		}
	}
	// println(purged_settings)
	return filter_array_by_index(settings, purged_settings)
}
