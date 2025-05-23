// make_multi_classifiers.v

module vhammll

// make_multi_classifiers takes a dataset, an array of classifier settings, and
// a list of classifier indices. It outputs an array of trained classifiers,
// one for each entry in the list of indices. If the list of indices is empty,
// classifiers will be generated for all the entries in the settings array.
fn make_multi_classifiers(ds Dataset, settings_list []ClassifierSettings, classifier_indices []int) []Classifier {
	mut cll := []Classifier{}
	mut idx := classifier_indices.clone()
	if idx.len == 0 {
		idx = settings_list.map(it.classifier_id)
	}
	for i in idx {
		opts := Options{
			Parameters:    settings_list.filter(it.classifier_id == i)[0].Parameters
			datafile_path: settings_list.filter(it.classifier_id == i)[0].datafile_path
		}
		cl := make_classifier_using_ds(ds, opts)
		cll << cl
	}
	return cll
}
