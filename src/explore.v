// explore.v
module vhammll

// explore runs a series of cross-validations or verifications,
// over a range of attributes and a range of binning values.
// ```sh
// Options (also see the Options struct):
// bins: range for binning or slicing of continuous attributes;
// uniform_bins: same number of bins for all continuous attributes;
// number_of_attributes: range for attributes to include;
// exclude_flag: excludes missing values when ranking attributes;
// weighting_flag: nearest neighbor counts are weighted by
// 	class prevalences;
// folds: number of folds n to use for n-fold cross-validation (default
// 	is leave-one-out cross-validation);
// repetitions: number of times to repeat n-fold cross-validations;
// random-pick: choose instances randomly for n-fold cross-validations.
// Output options:
// show_flag: display results on the console;
// expanded_flag: display additional information on the console, including
// 	a confusion matrix for each explore step;
// graph_flag: generate plots of Receiver Operating Characteristics (ROC)
// 	by attributes used; ROC by bins used, and accuracy by attributes
//	used.
// traverse_all_flags: repeat the explore operation for all possible
//  combinations of the flags uniform_bins, weight_ranking_flag, etc;
// outputfile_path: saves the result to a file.
// ```
pub fn explore(ds Dataset, opts Options) ExploreResult {
	// dump(opts)
	// instantiate a struct for SettingsForROC
	mut roc_master_class := opts.positive_class
	if opts.positive_class == '' {
		// look for the class with the fewest instances
		roc_master_class = get_map_key_for_min_value(ds.class_counts)
	}
	// master_class_index := ds.classes.index(get_map_key_for_min_value(ds.class_counts))
	// dump(roc_master_class)
	// dump(master_class_index)
	mut roc_settings := SettingsForROC{
		master_class_index:      ds.classes.index(roc_master_class)
		classifiers_for_roc:     []ClassifierSettings{len: ds.class_counts[roc_master_class] + 1}
		array_of_correct_counts: [][]int{len: ds.class_counts[roc_master_class] + 1, init: []int{len: ds.classes.len}}
	}
	if opts.traverse_all_flags {
		// in a series of nested loops, repeatedly execute the explore
		// function over both true and false settings for the various
		// flags in opts.Parameters
		mut af_opts := opts
		// dump(af_opts)
		mut af_result := ExploreResult{}
		ft := [false, true]
		for ub in ft {
			af_opts.uniform_bins = ub
			for wr in ft {
				af_opts.weight_ranking_flag = wr
				for w in ft {
					af_opts.weighting_flag = w
					for p in ft {
						af_opts.purge_flag = p
						for bp in ft {
							af_opts.balance_prevalences_flag = bp
							af_result = run_explore(ds, af_opts)
							// dump(af_result)
							if af_opts.generate_roc_flag {
								roc_settings = update_settings_for_roc(roc_settings, af_result)
								// dump(roc_settings)
							}
						}
					}
				}
			}
		}
		if af_opts.generate_roc_flag {
			for roc in cleanup_roc_settings(roc_settings).classifiers_for_roc {
				println('${roc.t_p:5}   ${roc.t_n:5}   ${roc.sens:-5.4f}   ${1 - roc.spec:-5.4f}')

				if af_opts.roc_settingsfile_path != '' {
					append_roc_settings_to_file(roc, af_opts.roc_settingsfile_path)
				}
			}
		}
		return af_result // returns just the last result for multiple explores
	}
	return run_explore(ds, opts)
}

fn update_settings_for_roc(previous SettingsForROC, af_result ExploreResult) SettingsForROC {
	mut updated := previous
	for i, stored_counts in previous.array_of_correct_counts {
		for j, new_counts in af_result.array_of_results.map(it.correct_counts) {
			if array_sum(stored_counts) < array_sum(new_counts)
				&& new_counts[previous.master_class_index] == i {
				// dump('${i}  ${stored_counts}       ${j}  ${new_counts}')
				updated.array_of_correct_counts[i] = new_counts
				updated.classifiers_for_roc[i] = ClassifierSettings{
					Parameters:    af_result.array_of_results[j].Parameters
					Metrics:       af_result.array_of_results[j].Metrics
					BinaryMetrics: af_result.array_of_results[j].BinaryMetrics
					LoadOptions:   af_result.array_of_results[j].LoadOptions
				}
				break
			}
		}
	}
	dump(updated.array_of_correct_counts)
	return updated
}

fn cleanup_roc_settings(starting SettingsForROC) SettingsForROC {
	// dump(starting)
	mut cleaned := SettingsForROC{
		master_class_index:      starting.master_class_index
		array_of_correct_counts: starting.array_of_correct_counts.filter(array_sum(it) > 0)
		classifiers_for_roc:     purge_array(starting.classifiers_for_roc, idxs_zero(starting.array_of_correct_counts.map(array_sum(it))))
	}
	// dump(cleaned)
	return cleaned
}

fn run_explore(ds Dataset, opts Options) ExploreResult {
	mut ex_opts := opts
	mut results := ExploreResult{
		LoadOptions:     ds.LoadOptions
		path:            opts.datafile_path
		testfile_path:   opts.testfile_path
		Parameters:      opts.Parameters
		DisplaySettings: opts.DisplaySettings
		AttributeRange:  get_attribute_range(opts.number_of_attributes,
			ds.useful_continuous_attributes.len + ds.useful_discrete_attributes.len)
		pos_neg_classes: get_pos_neg_classes(ds)
		args:            opts.args
	}
	mut result := CrossVerifyResult{
		pos_neg_classes: results.pos_neg_classes
	}
	// mut attribute_max := ds.useful_continuous_attributes.len + ds.useful_discrete_attributes.len
	// if there are no useful continuous attributes, skip the binning
	if ds.useful_continuous_attributes.len == 0 {
		ex_opts.bins = [0]
	}
	results.binning = get_binning(ex_opts.bins)
	binning := results.binning
	if opts.command == 'explore' && (opts.show_flag || opts.expanded_flag) {
		// show_explore_header(pos_neg_classes, binning, opts)
		show_explore_header(results, results.DisplaySettings)
	}
	mut atts := results.start
	// mut cl := Classifier{}
	mut array_of_results := []CrossVerifyResult{}
	// mut plot_data := [][]PlotResult{}

	for atts <= results.end {
		ex_opts.number_of_attributes = [atts]
		mut bin := binning.lower
		for bin <= binning.upper {
			if ex_opts.uniform_bins {
				ex_opts.bins = [bin, bin]
			} else {
				ex_opts.bins = [1, bin]
			}
			if ex_opts.testfile_path == '' {
				result = cross_validate(ds, ex_opts)
			} else {
				// cl = make_classifier(mut ds, ex_opts)
				result = verify(ex_opts)
			}
			result.bin_values = ex_opts.bins
			result.attributes_used = atts
			show_explore_line(result, results.DisplaySettings)

			array_of_results << result
			bin += binning.interval
		}
		atts += results.att_interval
	}
	// println('maximum_hamming_distance in explore: ${results.maximum_hamming_distance}')
	results.array_of_results = array_of_results
	// results.analytics = get_explore_analytics(results)
	if opts.outputfile_path != '' {
		save_json_file[ExploreResult](results, opts.outputfile_path)
	}
	mut explore_analytics := explore_analytics2(results)
	if opts.command == 'explore' && (opts.show_flag || opts.expanded_flag) {
		show_explore_trailer(results, explore_analytics, opts)
	}
	// println(ds.class_counts.len)
	if opts.graph_flag {
		// println('Just prior to plot_explore')
		plot_explore(results, opts)
		// println('Just after plot_explore')
		if ds.class_counts.len == 2 {
			// println('should be printing ROC here')
			plot_roc(results, opts)
		}
	}
	if opts.append_settings_flag {
		// save the settings for the explore results with the
		// highest balanced accuracy, true positives, and true
		// negatives
		// append_explore_settings_to_file(results, opts)
		append_explore_settings_to_file(results, explore_analytics, opts)
	}
	return results
}

// get_attribute_range
fn get_attribute_range(atts []int, max int) AttributeRange {
	if atts == [0] {
		return AttributeRange{
			start:        1
			end:          max
			att_interval: 1
		}
	}
	if atts.len == 1 {
		return AttributeRange{
			start:        1
			end:          atts[0]
			att_interval: 1
		}
	}
	if atts.len == 2 {
		return AttributeRange{
			start:        atts[0]
			end:          atts[1]
			att_interval: 1
		}
	}
	return AttributeRange{
		start:        atts[0]
		end:          atts[1]
		att_interval: atts[2]
	}
}
