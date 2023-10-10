// data_dict.v
// module vhammll

// import os
// import regex

// data_dict returns a struct containing a dataset's metadata,
// as specified in a data dictionary file
// This version is specific to the UKDA data dictionary format.
//
// Example:
// ```sh
// dd := data_dict('~/mcs6_cm_derived_ukda_data_dictionary.rtf')
// ```

// pub fn data_dict(path string) DataDict {
// 	// println(path)
// 	text := os.read_file(path.trim_space()) or { panic('failed to open ${path}') }
// 	// get file level info
// 	mut dd := DataDict{
// 		file_name: do_merge_query(r'File Name = .*\\cf\d ?', r'\w+', text)[0]
// 		number_of_variables: do_merge_query(r'Number of variables = .*\\cf\d ', r'\w+',
// 			text)[0].int()
// 		number_of_cases: do_merge_query(r'Number of cases = .*\\cf\d ', r'\w+', text)[0].int()
// 	}

// 	// get variable level info
// 	pos_list := do_merge_query(r'Pos. =( }.{13} )|(.*\\cf\d ?)', r'(1,\d+)|(\d+)', text)
// 	var_list := do_merge_query(r'Variable =( }.* )|(.*\\cf\d ?)', r'\w{4,}\s*', text)
// 	label_list := do_merge_query(r'Variable label =( }.* )|(.*\\cf\d ?)', r'.*\\', text)
// 	mut ddv := DataDictVariable{}
// 	for i in 0 .. dd.number_of_variables {
// 		ddv.pos = pos_list[i].replace(',', '').int()
// 		ddv.variable = var_list[i]
// 		ddv.variable_label = label_list[i]
// 		dd.variables << ddv
// 	}
// 	// println(dd)
// 	// for each variable, get value/label info
// 	mut positions := [][]int{}
// 	for mut var in dd.variables {
// 		mut a := regex.regex_opt('Value label information for ${var.variable}(.*Pos. =) |(.*)$') or {
// 			panic(err)
// 		}
// 		val_labels_list := a.find_all_str(text)
// 		// println(val_labels_list)
// 		// since I am unable to get the val_labels_list for the last variable,
// 		// I am substituting a kluge
// 		val_labels_string := if val_labels_list.len > 0 {
// 			val_labels_list[0]
// 		} else {
// 			text[positions.pop().last()..]
// 		}
// 		// println('val_labels_string: ${val_labels_string}')

// 		vals_list := do_merge_query(r'Value = }.* ', r'-?\d+.0', val_labels_string).map(it.int().str())
// 		// println('vals_list: $vals_list')
// 		labels_list := do_merge_query(r'Label = .* ', r'[.?\w(*)*]+.*\\', val_labels_string)
// 		// println('labels_list: $labels_list')
// 		if vals_list.len > 0 {
// 			var.value_label_map = map[string]string{}
// 			for i, val in vals_list {
// 				var.value_label_map[val] = labels_list[i]
// 			}
// 		}
// 		positions << a.find_all(text)
// 	}
// 	return dd
// }

// do_merge_query() returns a list of strings
// fn do_merge_query(q1 string, q2 string, text string) []string {
// 	mut re := regex.regex_opt(q1 + q2) or { panic(err) }
// 	list := re.find_all_str(text)
// 	re = regex.regex_opt(q1) or { panic(err) }
// 	return list.map(re.replace_simple(it, '').trim_string_right('\\').trim_space())
// }
