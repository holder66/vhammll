// optimals.v
module vhammll

// optimals determines which classifiers provide the best balanced accuracy, highest total for
// correct inferences, and highest correct inferences per class, for multiple classifiers whose
// settings are stored in a settings file.
pub fn optimals(path string, opts Options) OptimalsResult {
	// settings_struct is a MultipleClassifierSettings struct
	// settings is an array of ClassifierSettings structs
	settings := read_multiple_opts(path) or { panic('read_multiple_opts failed') }
	// settings := settings_struct.multiple_classifier_settings
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
	if opts.show_flag {
		println('result in optimals: ${result}')
	}
	if opts.expanded_flag {
		println(m_u('Optimal classifiers in settings file: ${path}'))
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
	}
	return result
}
