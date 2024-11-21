// show_explore.v
// in order to establish style consistency, aim to use magenta underline
// for the first line of each output, and blue underline for table headings.
// use bold green for subheadings
// ie, println(m_u('\nfirst line')
// println(b_u('table header')
// println(g_b('subheading')
//
// this website https://towardsdatascience.com/multi-class-metrics-made-simple-part-ii-the-f1-score-ebe8b2c2ca1 gives the
// best explanation of multiclass metrics and how they're calculated

module vhammll

import arrays
// import strings
// import math

// show_expanded_explore_result
fn show_expanded_explore_result(result CrossVerifyResult, opts Options) {
	if result.pos_neg_classes[0] != '' {
		println('${opts.number_of_attributes[0]:10} ${get_show_bins(opts.bins)}  ${get_binary_stats_line(result)}')
	} else {
		println('${opts.number_of_attributes[0]:10} ${get_show_bins(opts.bins)}')
		show_multiple_classes_stats(result)
	}
}

// show_explore_header
fn show_explore_header(results ExploreResult, settings DisplaySettings) {
	// println(results)
	mut binary := false
	if results.pos_neg_classes[0] != '' {
		binary = true
	}
	mut explore_type_string := ''
	if results.testfile_path == '' {
		explore_type_string = if results.folds == 0 { 'leave-one-out ' } else { '${results.folds}-fold ' } + 'cross-validation' + if results.repetitions > 0 { '\n (${results.repetitions} repetitions' + if results.random_pick { ', with random selection of instances)' } else { ')' }
		 } else { ''
		 }
	} else {
		explore_type_string = 'verification of "${results.testfile_path}"'
	}
	println(m_u('\nExplore ${explore_type_string} using classifiers from "${results.path}"'))
	show_parameters(results.Parameters, results.LoadOptions)
	println('Over attribute range from ${results.start} to ${results.end} by interval ${results.att_interval}')
	if !settings.expanded_flag {
		println(b_u('Attributes     Bins' +
			if results.purge_flag { '       Purged instances     (%)' } else { '' } +
			'  Matches  Nonmatches  Accuracy: Raw  Balanced        MCC'))
	} else {
		if binary {
			println('A correct classification to "${results.pos_neg_classes[0]}" is a True Positive (TP);\nA correct classification to "${results.pos_neg_classes[1]}" is a True Negative (TN).')
			println(b_u('Attributes    Bins' +
				if results.purge_flag { '        Purged instances     (%)' } else { '' } +
				"     TP    FN    TN    FP  Sens'y Spec'y    PPV    NPV  F1 Score  Accuracy: Raw  Balanced     MCC"))
		} else {
			println(b_u('Attributes    Bins' +
				if results.purge_flag { '        Purged instances     (%)' } else { '' }))
			println(b_u('    Class                     Instances    True Positives    Precision    Recall    F1 Score'))
		}
	}
}

// show_explore_trailer
fn show_explore_trailer(results ExploreResult, opts Options) {
	if opts.args.len > 0 {
		println('Command line arguments: ${opts.args}')
	} else {
		println('Flags: u: ${results.uniform_bins} x: ${results.exclude_flag} p: ${results.purge_flag} w: ${results.weighting_flag} wr: ${results.weight_ranking_flag} bp: ${results.balance_prevalences_flag}')
	}
	println(g('Maximum accuracies obtained:'))
	analytics := explore_analytics2(results)
	label_column_width := array_max(analytics.keys().map(it.len)) + 5
	// println('label_column_width: $label_column_width')
	for label, a in analytics {
		print('${pad(label_column_width - label.len)}${label}: ')
		print(match a.valeur {
			f64 {
				if a.valeur < 1 && a.valeur > 0 { '${a.valeur:7.3f}' } else { '${a.valeur:6.2f}%' }
			}
			int {
				'${a.valeur:7}'
			}
		})
		if a.binary_counts.all(it == 0) {
			print(' ${a.multiclass_correct_counts} ${a.multiclass_incorrect_counts}')
		} else {
			print(' ${a.binary_counts}')
		}
		print(' using ${a.settings.attributes_used} attributes')
		if show_bins_for_trailer(a.settings.binning) != '' {
			print(', with binning ${show_bins_for_trailer(a.settings.binning)}')
		}
		if a.settings.purged_percent > 0.0 {
			print(', ${a.settings.purged_percent:5.2f}% instances purged.')
		}
		println('')
	}
	println('')
}

// get_purged_percent
fn get_purged_percent(result CrossVerifyResult) (f64, f64, f64) {
	total_count_avg := arrays.sum(result.prepurge_instances_counts_array) or { panic(err) } / f64(result.prepurge_instances_counts_array.len)
	purged_count_avg := total_count_avg - arrays.sum(result.classifier_instances_counts) or {
		panic(err)
	} / f64(result.classifier_instances_counts.len)
	return purged_count_avg, total_count_avg, 100 * purged_count_avg / total_count_avg
}

// show_explore_line displays on the console the results of each
// cross-validation or verification during an explore session.
fn show_explore_line(result CrossVerifyResult, settings DisplaySettings) {
	// println(result)
	// do nothing if neither the -s or the -e flag was set
	if settings.show_flag || settings.expanded_flag {
		purged, total, purged_percent := get_purged_percent(result)
		if !settings.expanded_flag {
			accuracy_percent := (f32(result.correct_count) * 100 / result.labeled_classes.len)
			println('${result.attributes_used:10}  ${get_show_bins(result.bin_values)}' +
				if result.purge_flag {
				'${purged:10.1f} out of ${total} (${purged_percent:5.2f})'
			} else {
				''
			} +
				'  ${result.correct_count:7}  ${result.labeled_classes.len - result.correct_count:10}       ${accuracy_percent:7.2f}%  ${result.balanced_accuracy:7.2f}%      ${result.mcc:5.3f}')
		} else {
			if result.pos_neg_classes[0] != '' {
				println('${result.attributes_used:10} ${get_show_bins(result.bin_values)}' + if result.purge_flag {
					' ${purged:10.1f} out of ${total} (${purged_percent:5.2f})'
				} else {
					''
				} + '  ${get_binary_stats_line(result)}')
			} else {
				println('${result.attributes_used:10} ${get_show_bins(result.bin_values)}' + if result.purge_flag {
					' ${purged:10.1f} out of ${total} (${purged_percent:5.2f})'
				} else {
					''
				})
				show_multiple_classes_stats(result)
			}
		}
	}
}

fn explore_analytics2(expr ExploreResult) map[string]Analytics {
	mut m := map[string]Analytics{}
	m['raw accuracy'] = Analytics{
		valeur: expr.array_of_results.map(it.raw_acc)[idx_max(expr.array_of_results.map(it.raw_acc))]
		idx:    idx_max(expr.array_of_results.map(it.raw_acc))
	}
	m['balanced accuracy'] = Analytics{
		idx:    idx_max(expr.array_of_results.map(it.balanced_accuracy))
		valeur: expr.array_of_results.map(it.balanced_accuracy)[idx_max(expr.array_of_results.map(it.balanced_accuracy))]
	}
	m['MCC (Matthews Correlation Coefficient)'] = Analytics{
		idx:    idx_max(expr.array_of_results.map(it.mcc))
		valeur: expr.array_of_results.map(it.mcc)[idx_max(expr.array_of_results.map(it.mcc))]
	}
	if expr.array_of_results[0].classes.len > 2 {
		// println('expr.array_of_results[0].correct_inferences: ${expr.array_of_results[0].correct_inferences}')
		m['correct inferences total'] = Analytics{
			idx:    idx_max(expr.array_of_results.map(it.correct_count))
			valeur: expr.array_of_results.map(it.correct_count)[idx_max(expr.array_of_results.map(it.correct_count))]
		}
		for class in expr.array_of_results[0].classes {
			// m['$class'] = Analytics{
			// 	idx: idx_max(expr.array_of_results.map(it.correct_inferences[class]))
			// }
			// println(idx_max(expr.array_of_results.map(it.correct_inferences[class])))
			// println(expr.array_of_results.map(it.correct_inferences[class])[idx_max(expr.array_of_results.map(it.correct_inferences[class]))])
			m['${class}'] = Analytics{
				idx:    idx_max(expr.array_of_results.map(it.correct_inferences[class]))
				valeur: expr.array_of_results.map(it.correct_inferences[class])[idx_max(expr.array_of_results.map(it.correct_inferences[class]))]
			}
		}
		m['incorrect inferences'] = Analytics{
			idx:    idx_max(expr.array_of_results.map(it.incorrects_count))
			valeur: expr.array_of_results.map(it.incorrects_count)[idx_max(expr.array_of_results.map(it.incorrects_count))]
		}
	} else {
		// println('in explore_analytics2: $expr.array_of_results[0]')
		m['true positives'] = Analytics{
			idx:    idx_max(expr.array_of_results.map(it.t_p))
			valeur: expr.array_of_results.map(it.t_p)[idx_max(expr.array_of_results.map(it.t_p))]
		}
		m['true negatives'] = Analytics{
			idx:    idx_max(expr.array_of_results.map(it.t_n))
			valeur: expr.array_of_results.map(it.t_n)[idx_max(expr.array_of_results.map(it.t_n))]
		}
	}
	for _, mut s in m {
		cvr := expr.array_of_results[s.idx]
		s.settings = analytics_settings(cvr)
		s.binary_counts = [cvr.t_p, cvr.f_n, cvr.t_n, cvr.f_p]
		s.multiclass_correct_counts = get_map_values(cvr.correct_inferences)
		s.multiclass_incorrect_counts = get_map_values(cvr.incorrect_inferences)
	}
	// println('m in explore_analytics2: $m')
	return m
}

// analytics_settings
fn analytics_settings(cvr CrossVerifyResult) MaxSettings {
	_, _, purged_percent := get_purged_percent(cvr)
	return MaxSettings{
		attributes_used: cvr.attributes_used
		binning:         cvr.bin_values
		purged_percent:  purged_percent
	}
}
