// save_settings.v

module vhammll

import os

// append_cross_verify_settings_to_file
fn append_cross_verify_settings_to_file(result CrossVerifyResult, opts Options) {
	mut settings_to_append := ClassifierSettings{
		Parameters:    result.Parameters
		BinaryMetrics: result.BinaryMetrics
		Metrics:       result.Metrics
		datafile_path: os.abs_path(result.datafile_path)
	}
	settings_to_append.classifier_index = get_next_classifier_index(opts.settingsfile_path)
	append_json_file(settings_to_append, opts.settingsfile_path)
}

fn append_roc_settings_to_file(roc_settings ClassifierSettings, roc_settingsfile_path string) {
	mut settings_to_append := roc_settings
	settings_to_append.classifier_index = get_next_classifier_index(roc_settingsfile_path)
	append_json_file(settings_to_append, roc_settingsfile_path)
}

fn get_next_classifier_index(settingsfile_path string) int {
	// check if there is already a settings file
	if os.is_file(settingsfile_path.trim_space()) {
		previously_stored_settings := os.read_lines(settingsfile_path.trim_space()) or {
			panic('failed to open ${settingsfile_path} in get_next_classifier_index()')
		}
		return previously_stored_settings.len
	}
	return 0
}

// append_explore_settings_to_file
fn append_explore_settings_to_file(results ExploreResult, explore_analytics map[string]Analytics, opts Options) {
	next_classifier_index := get_next_classifier_index(opts.settingsfile_path)
	mut indices := opts.classifier_indices.clone()
	if indices == [] {
		indices = []int{len: explore_analytics.len, init: index}
	}
	mut i := 0
	for _, a in explore_analytics {
		if i in indices {
			mut u := ClassifierSettings{
				classifier_index: next_classifier_index + i
				Parameters:       results.array_of_results[a.idx].Parameters
				BinaryMetrics:    results.array_of_results[a.idx].BinaryMetrics
				Metrics:          results.array_of_results[a.idx].Metrics
				datafile_path:    os.abs_path(opts.datafile_path)
			}
			append_json_file(u, opts.settingsfile_path)
		}
		i += 1
	}
}
