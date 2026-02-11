// optimals.v
module vhammll

import arrays

const max_displayed_combinations = 7

const optimals_help = '
Description:
"optimals" determines which classifiers provide the best balanced accuracy values, 
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
-aa --all-attributes: for each category of optimals, show all settings (the default  
		is to show only those settings with unique attribute numbers)
-o --output: followed by the path to a file to save the (purged) settings
-s --show: show only classifier id\'s for each category
'

// optimals determines which classifiers provide the best balanced accuracy, best Matthews
// Correlation Coefficient (MCC), highest total for
// correct inferences, and highest correct inferences per class, for multiple classifiers whose
// settings are stored in a settings file.
// ```sh
// Options (also see the Options struct):
// purge_flag: discard duplicate settings
// all_attributes_flag: show all settings in each category, not only those with unique attribute numbers
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
	mcc_max := array_max(settings.map(it.mcc))
	corrects_max := array_max(settings.map(array_sum(it.correct_counts)))
	mcc_max_ids := settings.filter(it.mcc == mcc_max).map(it.classifier_id)
	corrects_max_ids := settings.filter(array_sum(it.correct_counts) == corrects_max).map(it.classifier_id)
	mut result := OptimalsResult{
		all_attributes_flag: opts.all_attributes_flag
		settingsfile_path:   path
		datafile_path:       settings[0].datafile_path
		settings_length:     all_settings.len
		settings_purged:     all_settings.len - settings.len
		class_counts:        settings[0].class_counts_int
		classes:             []string{len: settings[0].class_counts_int.len, init: '${index}'}

		best_balanced_accuracies:                     balanced_accuracy_values
		mcc_max:                                      mcc_max
		mcc_max_classifiers_all:                      mcc_max_ids
		mcc_max_classifiers:                          limit_to_unique_attribute_number(settings,
			mcc_max_ids)
		correct_inferences_total_max:                 corrects_max
		correct_inferences_total_max_classifiers_all: corrects_max_ids
		correct_inferences_total_max_classifiers:     limit_to_unique_attribute_number(settings,
			corrects_max_ids)
	}
	for value in balanced_accuracy_values {
		matching_ids := settings.filter(it.balanced_accuracy == value).map(it.classifier_id)
		result.best_balanced_accuracies_classifiers_all << matching_ids
		result.best_balanced_accuracies_classifiers << limit_to_unique_attribute_number(settings,
			matching_ids)
	}
	for i, _ in result.classes {
		max_correct := array_max(settings.map(it.correct_counts[i]))
		result.correct_inferences_by_class_max << max_correct
		matching_ids := settings.filter(it.correct_counts[i] == max_correct).map(it.classifier_id)
		result.correct_inferences_by_class_max_classifiers_all << matching_ids
		result.correct_inferences_by_class_max_classifiers << limit_to_unique_attribute_number(settings,
			matching_ids)
	}

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
	all_optimals << result.best_balanced_accuracies_classifiers[0]
	all_optimals << result.mcc_max_classifiers
	all_optimals << result.correct_inferences_total_max_classifiers
	for ids in result.correct_inferences_by_class_max_classifiers {
		all_optimals << ids
	}
	all_optimals = uniques(all_optimals)
	all_optimals.sort(a < b)
	result.all_optimals = all_optimals
	result.all_optimals_unique_attributes = limit_to_unique_attribute_number(settings,
		all_optimals)
	if opts.generate_combinations_flag {
		result.multi_classifier_combinations_for_auc = max_auc_combinations(settings,
			result.all_optimals_unique_attributes.map([it]), opts.DisplaySettings.CombinationSizeLimits)
		// sort by auc in ascending order (makes it easier to see the important ones)
		result.multi_classifier_combinations_for_auc.sort(a.auc > b.auc)
	}
	if opts.show_flag || opts.expanded_flag {
		mut print_result := result
		if opts.generate_combinations_flag {
			slice_size := if result.multi_classifier_combinations_for_auc.len >= max_displayed_combinations {
				max_displayed_combinations
			} else {
				result.multi_classifier_combinations_for_auc.len
			}
			print_result.multi_classifier_combinations_for_auc = result.multi_classifier_combinations_for_auc[0..slice_size]
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
		for i, setting in result.best_balanced_accuracies_classifiers_all {
			println(g_b('For balanced accuracy: ${result.best_balanced_accuracies[i]:6.2f}%'))
			show_multiple_classifier_settings_details(settings.filter(it.classifier_id in setting))
		}
		println(c_u('Best Matthews Correlation Coefficient (MCC): ') + g('${result.mcc_max:7.3f}'))
		show_multiple_classifier_settings_details(settings.filter(it.classifier_id in result.mcc_max_classifiers))
		println(c_u('Highest value for total correct inferences: ') +
			g('${result.correct_inferences_total_max} / ${array_sum(result.class_counts)}'))
		show_multiple_classifier_settings_details(settings.filter(it.classifier_id in result.correct_inferences_total_max_classifiers))
		println(c_u('Best correct inferences by class:'))
		println(c_u('Settings for Receiver Operating Characteristic (ROC) curve:'))
		show_multiple_classifier_settings_details(sorted_roc_settings)
	}

	if opts.graph_flag {
		plot_mult_roc([result.RocData], result.RocFiles)
	}
	if opts.outputfile_path != '' {
		for setting in settings {
			append_json_file(setting, opts.outputfile_path)
		}
	}
	return result
}

fn limit_to_unique_attribute_number(settings_array []ClassifierSettings, classifier_ids []int) []int {
	// Build a lookup map once: classifier_id -> first number_of_attributes value
	mut id_to_first_attr := map[int]int{}
	for setting in settings_array {
		if setting.classifier_id in classifier_ids && setting.classifier_id !in id_to_first_attr {
			id_to_first_attr[setting.classifier_id] = setting.number_of_attributes[0]
		}
	}
	mut uniques_attributes := uniques(arrays.flatten(settings_array.filter(it.classifier_id in classifier_ids).map(it.number_of_attributes)))
	mut uniques_attributes_classifiers := []int{}
	for att in uniques_attributes {
		for id in classifier_ids {
			if id_to_first_attr[id] == att {
				uniques_attributes_classifiers << id
				break
			}
		}
	}
	return uniques_attributes_classifiers
}

fn max_auc_combinations(settings_array []ClassifierSettings, classifier_ids [][]int, limits CombinationSizeLimits) []AucClassifiers {
	mut new_limits := limits
	if limits.min > classifier_ids.len {
		panic('combination size limits exceed the number of classifier settings')
	}
	if limits.max > classifier_ids.len {
		new_limits.max = classifier_ids.len
	}
	mut settings := []ClassifierSettings{cap: classifier_ids.len}
	for id in classifier_ids {
		settings << settings_array.filter(it.classifier_id == id[0])
	}
	mut pairs := [][]f64{}
	mut classifiers := []int{}
	for setting in settings {
		pairs << [setting.sens, setting.spec]
		classifiers << setting.classifier_id
	}
	classifier_combos := combinations(classifiers, new_limits)
	pairs_combos := combinations(pairs, new_limits)
	mut points_array := [][]RocPoint{cap: classifier_combos.len + 2}
	for i, pair_sets in pairs_combos {
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
	// Keep the first occurrence of each unique Parameters
	mut seen := []Parameters{}
	mut result := []ClassifierSettings{cap: settings.len}
	for setting in settings {
		if setting.Parameters !in seen {
			seen << setting.Parameters
			result << setting
		}
	}
	return result
}
