// optimals.v
module vhammll

const optimals_help = '
Description:
"optimals" determines which classifiers provide the best balanced accuracy, 
best Matthews Correlation Coefficient (MCC), highest total for
correct inferences, and highest correct inferences per class, for multiple classifiers whose
settings are stored in a settings file specified by the last command line argument.

Usage:
v run main.v optimals -e <path_to_settings_file>
v run main.v optimals -e -p -o <path_to_new_settings_file> <path_to_settings_file>

Options:
-cl --combination-limits: generates combinations of classifiers and calculates 
       the area under the Receiver Operating Characteristic curve for each combination;
       if -cl is followed by a pair of integers, those values are used as the lower 
       and upper limits of combination length.
-e --expanded: show expanded results on the console
-g --graph: display a plot of the Receiver Operating Characteristic curve
-p --purge: remove duplicate settings (ie settings with identical parameters)
-o --output: followed by the path to a file to save the (purged) settings
'

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
// graph_flag: plots a receiver operating characteristic curve
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
	mut balanced_accuracy_values := uniques(settings.map(it.balanced_accuracy))
	balanced_accuracy_values.sort(a > b)
	mut result := OptimalsResult{
		settingsfile_path:                        path
		datafile_path:                            settings[0].datafile_path
		settings_length: all_settings.len  
		purged_settings_count: settings.len
		class_counts:                             settings[0].class_counts_int
		classes:                                  []string{len: settings[0].class_counts_int.len, init: '${index}'}

		best_balanced_accuracies:                    balanced_accuracy_values
		mcc_max:                                  array_max(settings.map(it.mcc))
		mcc_max_classifiers:                      settings.filter(it.mcc == array_max(settings.map(it.mcc))).map(it.classifier_id)
		correct_inferences_total_max:             array_max(settings.map(array_sum(it.correct_counts)))
		correct_inferences_total_max_classifiers: settings.filter(array_sum(it.correct_counts) == array_max(settings.map(array_sum(it.correct_counts)))).map(it.classifier_id)
	}
	for value in balanced_accuracy_values {
		result.best_balanced_accuracies_classifiers << settings.filter(it.balanced_accuracy == value).map(it.classifier_id)
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
	mut pairs := [][]f64{cap: sorted_roc_settings.len}
	mut classifiers := []string{cap: sorted_roc_settings.len}
	mut classifier_ids := [][]int{cap: sorted_roc_settings.len}
	for setting in sorted_roc_settings {
		pairs << [setting.sens, setting.spec]
		classifier_ids << [setting.classifier_id]
		classifiers << '${setting.classifier_id}'
	}
	result.RocData = RocData{
		pairs:          pairs
		classifiers:    classifiers
		classifier_ids: classifier_ids
		trace_text:     'Single classifier<br>cross-validations'
	}
	result.RocFiles = RocFiles{
		datafile:     result.datafile_path
		settingsfile: path
	}
	// collect all the optimal classifiers
	mut all_optimals := []int{}
	for ids in result.best_balanced_accuracies_classifiers {
		all_optimals << ids
	}
	all_optimals << result.mcc_max_classifiers
	all_optimals << result.correct_inferences_total_max_classifiers
	for ids in result.correct_inferences_by_class_max_classifiers {
		all_optimals << ids
	}
	all_optimals = uniques(all_optimals)
	all_optimals.sort(a < b)
	result.all_optimals = all_optimals
	if opts.generate_combinations_flag {
		result.multi_classifier_combinations_for_auc = max_auc_combinations(settings,
			result.all_optimals.map([it]), opts.DisplaySettings.CombinationSizeLimits)
		// sort by auc in ascending order (makes it easier to see the important ones)
		result.multi_classifier_combinations_for_auc.sort(a.auc > b.auc)
	}
	if opts.show_flag || opts.expanded_flag {
		mut print_result := result
		if opts.generate_combinations_flag {
			print_result.multi_classifier_combinations_for_auc = result.multi_classifier_combinations_for_auc[0..7]
		}
		println('result in optimals: ${print_result}')
	}
	if opts.expanded_flag {
		println(m_u('Optimal classifiers in settings file: ${path}'))
		println(lg('Total number of settings: ${all_settings.len}'))
		if opts.purge_flag {
			println(lg('Duplicates purged: ${all_settings.len - settings.len}'))
		}
		print(c_u('Highest balanced accuracy values (%): '))
		println(g(result.best_balanced_accuracies.map('${it:6.2f}').join(', ')))
		for i, setting in result.best_balanced_accuracies_classifiers {
			println(g_b('For balanced accuracy: ${result.best_balanced_accuracies[i]:6.2f}%'))
			show_multiple_classifier_settings_details(settings.filter(it.classifier_id in setting))
		}
		// dump(result.best_balanced_accuracies.map('${it:6.2f}').join(', '))
		 // + g('${result.best_balanced_accuracies:6.2f}%'))
		// show_multiple_classifier_settings_details(settings.filter(it.classifier_id in result.best_balanced_accuracies_classifiers))
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

	if opts.graph_flag {
		plot_mult_roc([result.RocData], result.RocFiles)
		// mut roc_points := roc_values(pairs, classifiers)
		// mut auc := auc_roc(roc_points.map(it.Point))
		// plot_roc(roc_points, auc)
	}
	if opts.outputfile_path != '' {
		for setting in settings {
			append_json_file(setting, opts.outputfile_path)
		}
	}

	return result
}

fn max_auc_combinations(settings_array []ClassifierSettings, classifier_ids [][]int, limits CombinationSizeLimits) []AucClassifiers {
	mut settings := []ClassifierSettings{cap: classifier_ids.len}
	for id in classifier_ids {
		settings << settings_array.filter(it.classifier_id == id[0])
	}
	// dump(settings.len)
	mut pairs := [][]f64{}
	mut classifiers := []int{}
	for setting in settings {
		pairs << [setting.sens, setting.spec]
		classifiers << setting.classifier_id
	}
	// dump(classifiers)
	classifier_combos := combinations(classifiers, limits)
	pairs_combos := combinations(pairs, limits)
	// for i, pair_sets in pairs_combos {
	// 	dump('$pair_sets ${classifier_combos[i]}')
	// }
	mut points_array := [][]RocPoint{cap: classifier_combos.len + 2}
	// now convert the pair sets into points, for each combo
	for i, pair_sets in pairs_combos {
		// dump(classifier_combos[i])
		// dump(pair_sets)
		points_array << roc_values(pair_sets, classifier_combos[i].map([it]))
	}
	// calculate auc values
	mut auc_classifiers := []AucClassifiers{cap: points_array.len}
	for i, points in points_array {
		auc_classifiers << AucClassifiers{
			classifier_ids: classifier_combos[i]
			auc:            auc_roc(points.map(it.Point))
		}
	}
	return auc_classifiers
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
