// load_newer.v
module vhammll

import os

// load_orange_newer_file loads from an orange-newer file into a Dataset struct
fn load_orange_newer_file(path string, opts LoadOptions) Dataset {
	// println('opts in load_orange_newer_file: ${opts}')
	content := os.read_lines(path.trim_space()) or { panic('failed to open ${path}') }
	attribute_words := extract_words(content[0])
	types_attributes := attribute_words.map(extract_types(it))
	mut ds := Dataset{
		LoadOptions: opts
		path: path
		attribute_names: types_attributes.map(it[1])
		raw_attribute_types: types_attributes.map(it[0])
		// class_missing_purge_flag: opts.class_missing_purge_flag
		// ox_spectra: content[1..].map(extract_words(it))
	}
	// ds.data = transpose(ds.ox_spectra)
	ds.data = transpose(content[1..].map(extract_words(it)))
	ds.inferred_attribute_types = []string{len: ds.attribute_names.len}
	ds.attribute_types = combine_raw_and_inferred_types(ds)

	ds.Class = set_class_struct(ds)
	// println('ds.Class: $ds.Class')
	if opts.class_missing_purge_flag {
		// println('gonna purge in load_newer.v!')
		ds.purge_instances_for_missing_class_values()
	}

	ds.useful_continuous_attributes = get_useful_continuous_attributes(ds)
	ds.useful_discrete_attributes = get_useful_discrete_attributes(ds)
	if ds.attribute_types[0] == 'm' {
		ds.row_identifiers = ds.data[0]
	}

	return ds
}

fn extract_types(word string) []string {
	type_att := word.split('#')
	if type_att.len == 1 {
		return ['', type_att[0]]
	} else {
		return type_att
	}
}

pub fn combine_raw_and_inferred_types(ds Dataset) []string {
	mut combined_types := ds.raw_attribute_types.clone()
	for i, t in ds.raw_attribute_types {
		combined_types[i] = match true {
			t in ['C', 'D', 'c', 'i', 'm'] { t }
			t.contains('c') { 'c' }
			t in ['w', 'S', 'T'] { 'i' }
			t == '' && ds.inferred_attribute_types[i] != '' { ds.inferred_attribute_types[i] }
			else { infer_type_from_data(ds.data[i], ds.LoadOptions) }
			// else { panic('unrecognized attribute type "${t}" for aLttribute "${ds.attribute_names[i]}"') }
		}
	}
	// println('ds.raw_attribute_types: ${ds.raw_attribute_types}')
	// println('combined_types: $combined_types')
	return combined_types
}

// infer_attribute_types_newer gets inferred attribute types for orange-newer files
// returns an array to plug into the Dataset struct
/*
The existing attribute type codes are, for orange-newer:
Attribute names in the column header can be preceded with a label followed by a hash. Use c for class and m for meta attribute, i to ignore a column, w for weights column, and C, D, T, S for continuous, discrete, time, and string attribute types. Examples: C#mph, mS#name, i#dummy.
If no prefix, treat numbers as continuous, otherwise discrete
['i', 'mS', 'D', 'cD', 'C', 'm', 'iB', 'T', 'S', ''] should code as:
['i', 'i', 'D', 'c', 'C', 'i', 'i', 'i', 'i', 'C']
*/
fn infer_attribute_types_newer(ds Dataset) []string {
	mut inferred_attribute_types := []string{}
	mut inferred := ''
	for i, attr_type in ds.raw_attribute_types {
		inferred = match true {
			attr_type in ['C', 'D', 'c', 'i', 'm'] {
				attr_type
			}
			attr_type.contains('c') {
				'c'
			}
			attr_type in ['w', 'S', 'T'] {
				'i'
			}
			attr_type == '' {
				// println('and now here')
				infer_type_from_data(ds.data[i], ds.LoadOptions)
			}
			else {
				panic('unrecognized attribute type "${attr_type}" for attribute "${ds.attribute_names[i]}"')
			}
		}
		inferred_attribute_types << inferred
	}
	return inferred_attribute_types
}
