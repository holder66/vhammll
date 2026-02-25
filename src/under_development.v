// under_development.v
// This file holds structs and functions that are not yet wired into
// the active codebase but are retained for future use.

module vhammll

// OneVsRestClassifier holds metadata for a one-vs-rest classification
// strategy, used when classifying multiclass problems by training a
// separate binary classifier for each class against all other classes.
pub struct OneVsRestClassifier {
	Parameters
	LoadOptions
	Class
	History
pub mut:
	struct_type   string = '.OneVsRestClassifier'
	datafile_path string
}

// ResultForClass holds per-class tabulation of labeled, correct,
// incorrect, and wrong inferences for a single class in a
// verification or cross-validation run.
pub struct ResultForClass {
pub mut:
	labeled_instances    int
	correct_inferences   int
	incorrect_inferences int
	wrong_inferences     int
	confusion_matrix_row map[string]int
}

// SettingsForROC collects the per-fold classifier settings and
// correct-count arrays needed to generate a ROC curve after a
// cross-validation run.
pub struct SettingsForROC {
pub mut:
	master_class_index      int
	classifiers_for_roc     []ClassifierSettings
	array_of_correct_counts [][]int
}

// PlotResult holds a single data point for plotting accuracy vs
// parameter settings: bin count, number of attributes used,
// correct-inference count, and total instance count.
pub struct PlotResult {
pub mut:
	bin             int
	attributes_used int
	correct_count   int
	total_count     int
}

// BinaryCounts holds the raw binary-classification confusion counts
// (true positives, false negatives, true negatives, false positives)
// before metric calculation.
pub struct BinaryCounts {
pub mut:
	t_p int
	f_n int
	t_n int
	f_p int
}

// purge_instances_for_missing_class_values_not_inline removes all
// instances whose class value is in the missings list, returning the
// modified dataset. This is a non-method wrapper around the method
// form; prefer the method form where possible.
pub fn purge_instances_for_missing_class_values_not_inline(mut ds Dataset) Dataset {
	return ds.purge_instances_for_missing_class_values()
}
