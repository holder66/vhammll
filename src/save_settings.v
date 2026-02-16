// save_settings.v

module vhammll

import os

// append_cross_verify_settings_to_file
fn append_cross_verify_settings_to_file(result CrossVerifyResult, opts Options) {
	mut settings_to_append := ClassifierSettings{
		Parameters:    result.Parameters
		BinaryMetrics: result.BinaryMetrics
		Metrics:       result.Metrics
		LoadOptions:   result.LoadOptions

		datafile_path: os.abs_path(result.datafile_path)
	}
	settings_to_append.classifier_id = get_next_classifier_index(opts.settingsfile_path)
	append_json_file(settings_to_append, opts.settingsfile_path)
}

fn append_roc_settings_to_file(roc_settings ClassifierSettings, roc_settingsfile_path string) {
	mut settings_to_append := roc_settings
	settings_to_append.classifier_id = get_next_classifier_index(roc_settingsfile_path)
	append_json_file(settings_to_append, roc_settingsfile_path)
}

fn get_next_classifier_index(settingsfile_path string) int {
	// check if there is already a settings file
	if !os.is_file(settingsfile_path.trim_space()) {
		return 0
	}
	previously_stored_settings := read_multiple_opts(settingsfile_path) or {
		panic('Failed to read ${settingsfile_path} in get_next_classifier_index()')
	}
	return array_max(previously_stored_settings.map(it.classifier_id)) + 1
}

// append_explore_settings_to_file
fn append_explore_settings_to_file(results ExploreResult, explore_analytics_values map[string]Analytics, opts Options) {
	next_classifier_index := get_next_classifier_index(opts.settingsfile_path)
	mut indices := opts.classifiers.clone()
	if indices == [] {
		indices = []int{len: explore_analytics_values.len, init: index}
	}
	mut i := 0
	for _, a in explore_analytics_values {
		if i in indices {
			mut u := ClassifierSettings{
				classifier_id: next_classifier_index + i
				Parameters:    results.array_of_results[a.idx].Parameters
				BinaryMetrics: results.array_of_results[a.idx].BinaryMetrics
				Metrics:       results.array_of_results[a.idx].Metrics
				LoadOptions:   results.array_of_results[a.idx].LoadOptions
				datafile_path: os.abs_path(opts.datafile_path)
			}
			append_json_file(u, opts.settingsfile_path)
		}
		i += 1
	}
}
