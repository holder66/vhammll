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
		idx = []int{len: settings_list.len, init: index}
	}
	for i in idx {
		opts := Options{
			Parameters: settings_list.filter(it.classifier_id == i)[0].Parameters
		}
		cl := make_classifier(ds, opts)
		cll << cl
	}
	return cll
}
