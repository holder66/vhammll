// optimals.v
module vhammll

// optimals determines which classifiers provide the best balanced accuracy, highest total for
// correct inferences, and highest correct inferences per class, for multiple classifiers whose
// settings are stored in a settings file.
pub fn optimals(path string, in_opts Options, disp DisplaySettings) OptimalsResult {
	settings := read_multiple_opts(path) or { panic('read_multiple_opts failed') }
	mut result := OptimalsResult{
		classes: []string{len: 5, init: '${index}'}
		balanced_accuracy_max: array_max(settings.multiple_classifier_settings.map(it.balanced_accuracy))
		balanced_accuracy_max_classifiers: idxs_max(settings.multiple_classifier_settings.map(it.balanced_accuracy))
		correct_inferences_total_max: array_max(settings.multiple_classifier_settings.map(array_sum(it.correct_counts)))
		correct_inferences_total_max_classifiers: idxs_max(settings.multiple_classifier_settings.map(array_sum(it.correct_counts)))
	}
	for i, _ in result.classes {
		result.correct_inferences_by_class_max << array_max(settings.multiple_classifier_settings.map(it.correct_counts[i]))
		result.correct_inferences_by_class_max_classifiers << idxs_max(settings.multiple_classifier_settings.map(it.correct_counts[i]))
	}
	if disp.show_flag {
		println('result in optimals: ${result}')
	}
	if disp.expanded_flag {
		println(m_u('Optimal classifiers in settings file: ${path}'))
		println(b_u('Best balanced accuracy: ') + g('${result.balanced_accuracy_max:6.2f}%'))
		show_multiple_classifier_settings_details(settings.multiple_classifier_settings, result.balanced_accuracy_max_classifiers)
		println(b_u('Highest value for total correct inferences: ') + g('$result.correct_inferences_total_max'))
		show_multiple_classifier_settings_details(settings.multiple_classifier_settings, result.correct_inferences_total_max_classifiers)
		println(b_u('Best correct inferences by class:'))
		for i, class in result.classes {
			println(g_b('For class: ${class}'))
			show_multiple_classifier_settings_details(settings.multiple_classifier_settings, result.correct_inferences_by_class_max_classifiers[i])
		}
	}
	return result
}
