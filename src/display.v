// display.v
module vhammll

import os
import json

// display_file displays on the console, a results file as produced by other
// hamnn functions; a multiple classifier settings file; or graphs for explore,
// ranking, or crossvalidation results.
// ```sh
// display_file('path_to_saved_results_file', expanded_flag: true)
// Output options:
// expanded_flag: display additional information on the console, including
// 	a confusion matrix for cross-validation or verification operations;
// graph_flag: generates plots for display in the default web browser.
// ```
pub fn display_file(path string, in_opts Options) {
	mut opts := in_opts
	// determine what kind of file, then call the appropriate functions in show and plot
	s := os.read_file(path.trim_space()) or { panic('failed to open ${path}') }
	match true {
		s.contains('"struct_type":".ExploreResult"') {
			mut saved_er := json.decode(ExploreResult, s) or { panic(err) }
			show_explore_header(saved_er, opts.DisplaySettings)
			for mut result in saved_er.array_of_results {
				show_explore_line(result, opts.DisplaySettings)
			}
			show_explore_trailer(saved_er, opts)
			if opts.append_settings_flag {
				// save the settings for the explore results with the
				// highest balanced accuracy, true positives, and true
				// negatives
				append_explore_settings_to_file(saved_er, opts)
			}
		}
		s.contains('"struct_type":".Classifier"') {
			saved_cl := json.decode(Classifier, s) or { panic('Failed to parse json') }
			show_classifier(saved_cl)
		}
		s.contains('"struct_type":".RankingResult"') {
			saved_rr := json.decode(RankingResult, s) or { panic('Failed to parse json') }
			show_rank_attributes(saved_rr)
			if opts.graph_flag {
				plot_rank(saved_rr)
			}
		}
		s.contains('"struct_type":".AnalyzeResult"') {
			saved_ar := json.decode(AnalyzeResult, s) or { panic('Failed to parse json') }
			show_analyze(saved_ar)
		}
		s.contains('"struct_type":".ValidateResult"') {
			saved_valr := json.decode(ValidateResult, s) or { panic('Failed to parse json') }
			show_validate(saved_valr)
		}
		s.contains('"struct_type":".CrossVerifyResult"') && s.contains('"command":"verify"') {
			mut saved_vr := json.decode(CrossVerifyResult, s) or {
				panic('Failed to parse json as CrossVerifyResult')
			}
			show_verify(saved_vr, opts)
		}
		s.contains('"struct_type":".CrossVerifyResult"') && s.contains('"command":"cross"') {
			saved_vr := json.decode(CrossVerifyResult, s) or { panic('Failed to parse json') }
			show_crossvalidation(saved_vr, opts)
			// if opts.append_settings_flag {
			// 	append_cross_settings_to_file(saved_vr, opts)
			// }
		}
		// test for a multiple classifier settings file
		s.contains('{"binning":{"lower":') {
			multiple_classifier_settings := read_multiple_opts(path) or {
				panic('read_multiple_opts failed')
			}
			// settings := multiple_classifier_settings_list.multiple_classifier_settings
			if multiple_classifier_settings.len > 0 {
				println(m_u('Multiple Classifier Options file: ${path}'))
				// create an array for fictitious classifier indices
				classifier_indices := []int{len: multiple_classifier_settings.len, init: index}
				show_multiple_classifier_settings_details(multiple_classifier_settings, classifier_indices)
				if opts.show_attributes_flag {
					// we need to generate a classifier for each of the settings!
					mut classifiers := make_multi_classifiers(load_file(multiple_classifier_settings[0].datafile_path),
						multiple_classifier_settings, classifier_indices)
					for idx in classifier_indices {
						println(g_b('Trained attributes for classifier ${idx} on dataset ${multiple_classifier_settings[0].datafile_path}'))
						show_trained_attributes(classifiers[idx].trained_attributes)
					}
				}
			}
		}
		else {
			println('File type not recognized!')
		}
	}
}
