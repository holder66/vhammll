// optimals_test.v

module vhammll

fn test_optimals() {
	mut opts := Options{}
	mut disp := DisplaySettings{
		verbose_flag: true
		expanded_flag: true
	}
	optimals('/Users/henryolders/data2/data2_for_multiple_classes_6_march 2024.opts',
		opts, disp)
}

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

fn show_multiple_classifiers_details(classifier_settings_array []ClassifierSettings, classifier_list []int) {
	mut row_data := []string{len: headers.len, init: ''}
	for idx, ci in classifier_list {
		par := classifier_settings_array[ci]
		a := par.Parameters
		b := par.BinaryMetrics
		c := par.Metrics
		corrects := c.correct_counts.map(it.str()).join(' ')
		incorrects := c.incorrect_counts.map(it.str()).join(' ')
		col_width := array_max([corrects.len, incorrects.len]) + 2
		row_data[0] += '${ci:-13}' + pad(col_width - 13)
		row_data[1] += '${a.number_of_attributes[0]:-13}' + pad(col_width - 13)
		binning := '${a.binning.lower}, ${a.binning.upper}, ${a.binning.interval}'
		row_data[2] += '${binning:-13}' + pad(col_width - 13)
		row_data[3] += '${a.exclude_flag:-13}' + pad(col_width - 13)
		row_data[4] += '${a.weight_ranking_flag:-13}' + pad(col_width - 13)
		row_data[5] += '${a.weighting_flag:-13}' + pad(col_width - 13)
		row_data[6] += '${a.balance_prevalences_flag:-13}' + pad(col_width - 13)
		row_data[7] += '${a.purge_flag:-13}' + pad(col_width - 13)
		if c.class_counts.len > 2 {
			row_data[8] += corrects + pad(col_width - corrects.len)
			row_data[9] += incorrects + pad(col_width - incorrects.len)
			row_data[10] += '${b.raw_acc:-6.2f}%      ' + pad(col_width - 13)
			row_data[11] += '${c.balanced_accuracy:-6.2f}%      ' + pad(col_width - 13)
		} else {
			row_data[8] += '${b.t_p:-6} ${b.t_n:-6}' + pad(col_width - 13)
			row_data[9] += '${b.f_n:-6} ${b.f_p:-6}' + pad(col_width - 13)
			row_data[10] += '${b.raw_acc:-6.2f}%      ' + pad(col_width - 13)
			row_data[11] += '${b.bal_acc:-6.2f}%      ' + pad(col_width - 13)
		}
		row_data[12] += '${a.maximum_hamming_distance:-13}' + pad(col_width - 13)
	}
	for i, row in row_data {
		println('${headers[i]:25}   ${row}')
	}
}
