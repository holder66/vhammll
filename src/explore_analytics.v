// explore_analytics.v

module vhammll

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
		m['MCC (Matthews Correlation Coefficient)'] = Analytics{
			idx:    idx_max(expr.array_of_results.map(it.mcc))
			valeur: expr.array_of_results.map(it.mcc)[idx_max(expr.array_of_results.map(it.mcc))]
		}
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
		s.multiclass_correct_counts = cvr.correct_inferences.values()
		s.multiclass_incorrect_counts = cvr.incorrect_inferences.values()
	}
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
