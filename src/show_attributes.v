// show_attributes.v
// The possibility to show a list of trained attributes applies to make_classifier,
// verify, validate, and query operations. It does not apply to cross-validation,
// because the attributes used may change from one fold or repetition to the next.
//
// For simplicity, this will be called

module vhammll

// import arrays
// import strings

// show_trained_attributes outputs to the console information about the trained attributes
pub fn show_trained_attributes(atts map[string]TrainedAttribute) {
	println(b_u('Index  Attribute                   Type  Rank Value   Uniques       Min        Max  Bins'))
	for attr, val in atts {
		println('${val.index:5}  ${attr:-27} ${val.attribute_type:-4}  ${val.rank_value:10.2f}' +
			if val.attribute_type == 'C' { '          ${val.minimum:10.2f} ${val.maximum:10.2f} ${val.bins:5}' } else { '      ${val.translation_table.len:4}' })
	}
}

fn show_attributes(result CrossVerifyResult) {
	// println('result.trained_attributes_array in show_trained_attributes: ${result.trained_attributes_array}')
	// max_attributes := array_max(result.trained_attributes_array.map(it.len))
	// total_attributes := arrays.sum(result.trained_attributes_array.map(it.len)) or {
	// 	eprintln('Error: no trained attributes!')
	// 	exit(1)
	// }
	// println('max_attributes: ${max_attributes}')
	mut rows := []string{}

	// mut row_data := [][]string{len: max_attributes, init: []string{len: attribute_headings.len, init: ''}}
	// println('row_data in show_trained_attributes: ${row_data}')
	// mut columns := [][][]string{len: result.trained_attributes_array.len, init: [][]string{len: max_attributes, init: []string{len: 2, init: ''}}}
	println(g_b('Trained attributes, by classifier index, sorted by attribute ranking:'))
	println('Classifier    Attribute Name         Index  Rank Value')
	for classifier_index, atts in result.trained_attributes_array {
		for att_no, att_vals in atts {
			row := '${classifier_index:10}    ${att_no:-21}  ${att_vals.index:5}      ${att_vals.rank_value:6.2f}'
			rows << row
		}
	}
	print_array(rows)
}
