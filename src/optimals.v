// optimals.v
module vhammll

pub fn optimals(path string, in_opts Options, disp DisplaySettings) OptimalsResult {
	// mut opts := in_opts
	// println('opts in display_file: $opts')
	// determine what kind of file, then call the appropriate functions in show and plot
	// s := os.read_file(path.trim_space()) or { panic('failed to open file ${path}') }
	// println('s in display_file: $s')

	settings := read_multiple_opts(path) or { panic('read_multiple_opts failed') }
	mut result := OptimalsResult{
		classes: []string{len: 5, init: '${index}'}
		raw_accuracy_max: array_max(settings.multiple_classifiers.map(it.raw_acc))
		raw_accuracy_max_classifiers: idxs_max(settings.multiple_classifiers.map(it.raw_acc))
		balanced_accuracy_max: array_max(settings.multiple_classifiers.map(it.balanced_accuracy))
		balanced_accuracy_max_classifiers: idxs_max(settings.multiple_classifiers.map(it.balanced_accuracy))
		correct_inferences_total_max: array_max(settings.multiple_classifiers.map(array_sum(it.correct_counts)))
		correct_inferences_total_max_classifiers: idxs_max(settings.multiple_classifiers.map(array_sum(it.correct_counts)))
	}
	for i, class in result.classes {
		result.correct_inferences_by_class_max << array_max(settings.multiple_classifiers.map(it.correct_counts[i]))
		result.correct_inferences_by_class_max_classifiers << idxs_max(settings.multiple_classifiers.map(it.correct_counts[i]))
	}

	if disp.verbose_flag {
		println('result in optimals: ${result}')
	}
	if disp.expanded_flag {
		show_multiple_classifiers_details(settings.multiple_classifiers, result.balanced_accuracy_max_classifiers)
		for i, class in result.classes {
			println('For class: ${class}')
			show_multiple_classifiers_details(settings.multiple_classifiers, result.correct_inferences_by_class_max_classifiers[i])
		}
	}
	return result
}