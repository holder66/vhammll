// optimals.v
module vhammll

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
		balanced_accuracy_max_classifiers:        settings.filter(it.balanced_accuracy == array_max(settings.map(it.balanced_accuracy))).map(it.classifier_id)
		mcc_max:                                  array_max(settings.map(it.mcc))
		mcc_max_classifiers:                      settings.filter(it.mcc == array_max(settings.map(it.mcc))).map(it.classifier_id)
		correct_inferences_total_max:             array_max(settings.map(array_sum(it.correct_counts)))
		correct_inferences_total_max_classifiers: settings.filter(array_sum(it.correct_counts) == array_max(settings.map(array_sum(it.correct_counts)))).map(it.classifier_id)
	}

	for i, _ in result.classes {
		result.correct_inferences_by_class_max << array_max(settings.map(it.correct_counts[i]))
		result.correct_inferences_by_class_max_classifiers << settings.filter(it.correct_counts[i] == array_max(settings.map(it.correct_counts[i]))).map(it.classifier_id)
	}

	// new routine
	struct Counts {
		pos           int
		neg           int
		classifier_id int
	}

	mut uniques_structs_array := []Counts{cap: settings.len}
	for setting in settings {
		uniques_structs_array << Counts{setting.correct_counts[1], setting.correct_counts[0], setting.classifier_id}
	}
	mut roc_settings := []Counts{cap: settings.len}
	// filter by unique values of positive counts
	for val in uniques(uniques_structs_array.map(it.pos)) {
		mut val_items := uniques_structs_array.filter(it.pos == val)
		roc_settings << val_items.filter(it.neg == array_max(val_items.map(it.neg)))[0]
		// filter by maximum value of neg in that set
	}
	roc_settings.sort(a.pos < b.pos)
	result.receiver_operating_characteristic_settings = roc_settings.map(it.classifier_id)
	mut sorted_roc_settings := []ClassifierSettings{cap: roc_settings.len}
	for classifier_id in roc_settings.map(it.classifier_id) {
		sorted_roc_settings << settings.filter(it.classifier_id == classifier_id)
	}

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
		show_multiple_classifier_settings_details(settings.filter(it.classifier_id in result.balanced_accuracy_max_classifiers))
		println(c_u('Best Matthews Correlation Coefficient (MCC): ') + g('${result.mcc_max:7.3f}'))
		show_multiple_classifier_settings_details(settings.filter(it.classifier_id in result.mcc_max_classifiers))
		println(c_u('Highest value for total correct inferences: ') +
			g('${result.correct_inferences_total_max} / ${array_sum(result.class_counts)}'))
		show_multiple_classifier_settings_details(settings.filter(it.classifier_id in result.correct_inferences_total_max_classifiers))
		println(c_u('Best correct inferences by class:'))
		for i, class in result.classes {
			println(g_b('For class: ${class}') +
				g('  ${result.correct_inferences_by_class_max[i]} / ${result.class_counts[i]}'))
			show_multiple_classifier_settings_details(settings.filter(it.classifier_id in result.correct_inferences_by_class_max_classifiers[i]))
		}
		println(c_u('Settings for Receiver Operating Characteristic (ROC) curve:'))
		show_multiple_classifier_settings_details(sorted_roc_settings)
		// println(c_u('Settings for Reversed Receiver Operating Characteristic (ROC) curve:'))
		// show_multiple_classifier_settings_details(filtered_reversed_settings)
	}
	if opts.outputfile_path != '' {
		for setting in settings {
			append_json_file(setting, opts.outputfile_path)
		}
	}
	return result
}

fn purge_duplicate_settings(settings []ClassifierSettings) []ClassifierSettings {
	// reverse the array, then purge
	mut result := settings.reverse()
	mut indices_to_keep := []int{}
	for i in 0 .. settings.len {
		a := result[i]
		b := result[i + 1..].clone()
		c := b.map(it.Parameters)
		if a.Parameters !in c {
			indices_to_keep << i
		}
	}
	result_purged := filter_array_by_index(result, indices_to_keep)
	return result_purged.reverse()
}
