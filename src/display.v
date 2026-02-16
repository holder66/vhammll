// display.v
module vhammll

import os
// import x.json2
import json

const display_help = '
Description:
"display" regenerates the console display produced by other commands, from 
the file saved by those commands when run with the -o or --output flag followed
by the path to a file. It can also generate the plots produced by certain 
commands (rank, explore).
Display can be used to print out a multiple classifier settings file.

Usage:
first save a results file, eg 
v run main.v rank -o <path_to_results_file> <path_to_dataset_file>
Then: v run main.v display <path_to_results_file>

Options:
-e --expanded: show expanded results on the console 
-g --graph:    show plots on the default web browser
-ms:           save multiple classifier parameters to a file

Options when displaying a classifier settings file (suffix .opts):
-m#: list the classifier id\'s to be displayed
-ea: show the attributes used for each classifier
-g: displays a Receiver Operating Characteristic curve.
'

// display_file displays on the console, a results file as produced by other
// hamnn functions; a multiple classifier settings file; or graphs for explore,
// ranking, or crossvalidation results.
// ```sh
// display_file('path_to_saved_results_file', expanded_flag: true)
// Output options:
// expanded_flag: display additional information on the console, including
//     a confusion matrix for cross-validation or verification operations;
// graph_flag: generates plots for display in the default web browser;
// Options for displaying classifier settings files (suffix .opts):
// show_attributes_flag: list the attributes used by each classifier;
// classifiers: a list of classifier id's to display.
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
			analytics := explore_analytics(saved_er)
			show_explore_trailer(saved_er, analytics, opts)
			if opts.append_settings_flag {
				// save the settings for the explore results with the
				// highest balanced accuracy, true positives, and true
				// negatives
				append_explore_settings_to_file(saved_er, analytics, opts)
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
			// dump(s)
			saved_valr := json.decode(ValidateResult, s) or { panic('Failed to parse json') }
			// dump(saved_valr)
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
			// 	append_cross_verify_settings_to_file(saved_vr, opts)
			// }
		}
		// test for a multiple classifier settings file
		s.contains('"binning":{"lower":') {
			mut multiple_classifier_settings := read_multiple_opts(path) or {
				panic('read_multiple_opts failed')
			}
			mut filtered_settings := []ClassifierSettings{cap: opts.classifiers.len}
			if multiple_classifier_settings.len > 0 {
				// if display for specific classifiers was requested, ie -m#, replace the
				// settings array with just the requested settings, in the order requested
				if opts.classifiers.len > 0 {
					for id in opts.classifiers {
						filtered_settings << multiple_classifier_settings.filter(it.classifier_id == id)
					}
					multiple_classifier_settings = filtered_settings.clone()
				} else {
					opts.classifiers = multiple_classifier_settings.map(it.classifier_id)
				}
				// if binary classification, calculate auc
				mut auc := 0.0
				if multiple_classifier_settings[0].class_counts_int.len == 2 {
					mut pairs := [][]f64{len: multiple_classifier_settings.len, init: []f64{len: 2}}
					// mut classifiers := []string{len: multiple_classifier_settings.len}
					mut classifiers := [][]int{len: multiple_classifier_settings.len}
					for i, setting in multiple_classifier_settings {
						pairs[i] = [setting.sens, setting.spec]
						classifiers[i] = [setting.classifier_id]
					}
					roc_points := roc_values(pairs, classifiers)
					auc = auc_roc(roc_points.map(it.Point))
					if opts.graph_flag {
						plot_roc(roc_points, auc)
						// plotly_roc(roc_points, auc)
					}
				}
				if opts.expanded_flag {
					println(m_u('Multiple Classifier Settings: file: ${path}' +
						if auc != 0.0 { '    AUC = ${auc:.3f}' } else { '' }))
					show_multiple_classifier_settings_details(multiple_classifier_settings)
				} else {
					println('auc = ${auc:.3f} for classifiers ${opts.classifiers} in settings file ${path}')
				}
				if opts.show_attributes_flag {
					// we need to generate a classifier for each of the settings!
					mut ds := load_file(multiple_classifier_settings[0].datafile_path)
					mut classifiers_array := make_multi_classifiers(mut ds, multiple_classifier_settings,
						opts.classifiers)
					for i, idx in classifiers_array {
						println(g_b('Trained attributes for classifier ${opts.classifiers[i]} on dataset ${multiple_classifier_settings[0].datafile_path}'))
						show_trained_attributes(idx.trained_attributes)
					}
				}
			}
		}
		else {
			println('File type not recognized!')
		}
	}
}
