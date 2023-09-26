// load_arff_file
module hamml

import os
import encoding.utf8

fn load_arff_file(path string) Dataset {
	content := os.read_lines(path.trim_space()) or { panic('failed to open ${path}') }
	mut ds := Dataset{
		path: path
	}
	attributes := content.filter(it != '').map(utf8.to_lower(it)).filter(it.starts_with('@attribute'))
	for line in attributes {
		if line.ends_with('}') {
			ds.attribute_names << strip(line.split('{')[0].split(' ')[1].trim_space())
			ds.attribute_types << 'string'
			ds.attribute_flags << [line.split_any('{}')[1]]
		} else {
			ds.attribute_names << [strip(line.split_any(' \t')[1])]
			ds.attribute_types << [line.split_any(' \t').last()]
			ds.attribute_flags << ['']
		}
	}
	// println('$ds.attribute_names $ds.attribute_types $ds.attribute_flags')
	mut start_data := 0
	for i, line in content {
		if line.to_lower().starts_with('@data') {
			start_data = i + 1
			break
		}
	}
	data := transpose(content[start_data..].filter(!it.starts_with('%')).filter(it != '').map(it.split(',')))
	ds.data = data.map(it.map(strip(it)))
	ds.inferred_attribute_types = infer_attribute_types_arff(ds)
	ds.Class = set_class_struct(ds)
	ds.useful_continuous_attributes = get_useful_continuous_attributes(ds)
	ds.useful_discrete_attributes = get_useful_discrete_attributes(ds)
	return ds
}

// infer_attribute_types_arff
fn infer_attribute_types_arff(ds Dataset) []string {
	mut inferred_attribute_types := []string{}
	mut attr_type := ''
	// mut attr_flag := ''
	mut inferred := ''
	should_be_discrete := integer_range_for_discrete.map(it.str())
	for i in 0 .. ds.attribute_names.len {
		attr_type = ds.attribute_types[i].to_lower()
		// println(integer_range_for_discrete)
		// println(ds.data[i].all(it in should_be_discrete))
		if attr_type in ['numeric', 'real', 'integer'] {
			if ds.data[i].all(it in should_be_discrete) {
				inferred = 'D'
			} else {
				inferred = 'C'
			}
		} else if attr_type == 'string' {
			inferred = 'D'
		} else if attr_type in ['date', 'relational'] {
			inferred = 'i'
		} else if attr_type == 'class' {
			inferred = 'c'
		}
		// if the entry contains a list of items separated by commas
		else if attr_type.contains(',') {
			inferred = 'D'
		} else {
			panic('unrecognized attribute type "${attr_type}" for attribute "${ds.attribute_names[i]}"')
		}
		inferred_attribute_types << inferred
	}
	if 'c' !in inferred_attribute_types {
		inferred_attribute_types.pop()
		inferred_attribute_types << ['c']
	}
	return inferred_attribute_types
}

fn strip(s string) string {
	if s.starts_with("'") && s.ends_with("'") {
		return s[1..s.len - 1]
	}
	return s
}
