// make_multi_classifiers.v

module vhammll

// make_multi_classifiers takes a dataset and an array of classifier settings. It
// outputs an array of trained classifiers.
fn make_multi_classifiers(ds Dataset, settings_list []ClassifierSettings) []Classifier {
	mut cll := []Classifier{}
	for settings in settings_list {
		opts := Options{
			Parameters: settings.Parameters
		}
		cl := make_classifier(ds, opts)
		cll << cl
	}
	return cll
}
