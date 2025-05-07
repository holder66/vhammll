// explore_analytics.v

module vhammll

struct BalAcc {
	MaxSettings
mut:
	idx              int
	accuracy_percent f64
}

// explore_analytics identifies the sets of classifier settings which provide the
// maximum values for raw accuracy, balanced accuracy, maximum correct inferences for each
// class, maximum incorrect inferences, and for datasets with two classes, maximum
// Matthews Correlation Coefficient (MCC), true positives, and true negatives.
fn explore_analytics(expr ExploreResult) map[string]Analytics {
	mut m := map[string]Analytics{}
	m['raw accuracy'] = Analytics{
		valeur: expr.array_of_results.map(it.raw_acc)[idx_max(expr.array_of_results.map(it.raw_acc))]
		idx:    idx_max(expr.array_of_results.map(it.raw_acc))
	}
	// m['balanced accuracy'] = Analytics{
	// 	idx:    idx_max(expr.array_of_results.map(it.balanced_accuracy))
	// 	valeur: expr.array_of_results.map(it.balanced_accuracy)[idx_max(expr.array_of_results.map(it.balanced_accuracy))]
	// }
	mut bal_acc := []BalAcc{}
	for i, value in expr.array_of_results {
		bal_acc << BalAcc{
			MaxSettings:      analytics_settings(value)
			accuracy_percent: value.balanced_accuracy
			idx:              i
		}
	}
	bal_acc.sort(a.accuracy_percent > b.accuracy_percent)
	if bal_acc.len > 3 {
		bal_acc = bal_acc[..3].clone()
	}
	for i, value in bal_acc {
		m['balanced accuracy ${i}'] = Analytics{
			idx:    value.idx
			valeur: value.accuracy_percent
		}
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
		// println('in explore_analytics: $expr.array_of_results[0]')
		m['true positives'] = Analytics{
			idx:    idx_max(expr.array_of_results.map(it.t_p))
			valeur: expr.array_of_results.map(it.t_p)[idx_max(expr.array_of_results.map(it.t_p))]
		}
		m['true negatives'] = Analytics{
			idx:    idx_max(expr.array_of_results.map(it.t_n))
			valeur: expr.array_of_results.map(it.t_n)[idx_max(expr.array_of_results.map(it.t_n))]
		}
	}
	// dump(m)
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
