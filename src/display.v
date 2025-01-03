// display.v
module vhammll

import os
import x.json2

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
	// println('opts in display_file: $opts')
	// determine what kind of file, then call the appropriate functions in show and plot
	s := os.read_file(path.trim_space()) or { panic('failed to open ${path}') }
	// println('s in display_file: $s')
	match true {
		s.contains('"struct_type":".ExploreResult"') {
			// mut opts := Options{
			// 	DisplaySettings: settings
			// }
			mut saved_er := json2.decode[ExploreResult](s) or { panic(err) }
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
			saved_cl := json2.decode[Classifier](s) or { panic('Failed to parse json') }
			show_classifier(saved_cl)
		}
		s.contains('"struct_type":".RankingResult"') {
			saved_rr := json2.decode[RankingResult](s) or { panic('Failed to parse json') }
			show_rank_attributes(saved_rr)
			if opts.graph_flag {
				plot_rank(saved_rr)
			}
		}
		s.contains('"struct_type":".AnalyzeResult"') {
			saved_ar := json2.decode[AnalyzeResult](s) or { panic('Failed to parse json') }
			show_analyze(saved_ar)
		}
		s.contains('"struct_type":".ValidateResult"') {
			saved_valr := json2.decode[ValidateResult](s) or { panic('Failed to parse json') }
			show_validate(saved_valr)
		}
		s.contains('"struct_type":".CrossVerifyResult"') && s.contains('"command":"verify"') {
			println('we are here')
			mut saved_vr := json2.decode[CrossVerifyResult](s) or {
				panic('Failed to parse json as CrossVerifyResult')
			}
			show_verify(saved_vr, opts)
		}
		s.contains('"struct_type":".CrossVerifyResult"') && s.contains('"command":"cross"') {
			saved_vr := json2.decode[CrossVerifyResult](s) or { panic('Failed to parse json') }
			show_crossvalidation(saved_vr, opts)
			if opts.append_settings_flag {
				append_cross_settings_to_file(saved_vr, opts)
			}
		}
		s.contains('{"binning":{"lower":') {
			multiple_classifier_settings_array := read_multiple_opts(path) or {
				panic('read_multiple_opts failed')
			}
			// println('multiple_classifier_settings_array in display_file: $multiple_classifier_settings_array')
			opts.MultipleClassifierSettingsArray = multiple_classifier_settings_array

			result := CrossVerifyResult{
				classifier_indices:              []int{len: multiple_classifier_settings_array.multiple_classifier_settings.len, init: index}
				MultipleClassifierSettingsArray: multiple_classifier_settings_array
			}
			// multiple_options := MultipleOptions{
			// 	classifier_indices: []int{len: multiple_classifier_settings_array.multiple_classifier_settings.len, init: index}
			// }
			println(m_u('Multiple Classifier Options file: ${path}'))
			show_multiple_classifier_settings_options(result, opts)
		}
		else {
			println('File type not recognized!')
		}
	}
}
