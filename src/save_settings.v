// save_settings.v

module vhammll

import os

// append_cross_verify_settings_to_file
fn append_cross_verify_settings_to_file(result CrossVerifyResult, opts Options) {
	mut settings_to_append := ClassifierSettings{
		Parameters:       result.Parameters
		BinaryMetrics:    result.BinaryMetrics
		Metrics:          result.Metrics
		datafile_path:    os.abs_path(result.datafile_path)
	}
	path := opts.settingsfile_path.trim_space()
	// check if there is already a settings file
	if os.is_file(path) {
	previously_stored_settings := os.read_lines(opts.settingsfile_path.trim_space()) or {
		panic('failed to open ${opts.settingsfile_path} in append_cross_verify_settings_to_file')}
		settings_to_append.classifier_index = previously_stored_settings.len + 1
	} else {
		settings_to_append.classifier_index = 0
	}
	
	append_json_file(settings_to_append, opts.settingsfile_path)
}

// append_explore_settings_to_file
fn append_explore_settings_to_file(results ExploreResult, explore_analytics map[string]Analytics, opts Options) {
	mut indices := opts.classifier_indices.clone()
	if indices == [] {
		indices = []int{len: 7, init: index}
	}
	// m := explore_analytics2(results)
	// m := explore_analytics
	mut i := 0
	for _, a in explore_analytics {
		if i in indices {
			mut u := ClassifierSettings{
				classifier_index: i
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
