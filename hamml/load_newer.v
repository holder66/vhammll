// load_newer.v
module vhammll

import os

// load_orange_newer_file loads from an orange-newer file into a Dataset struct
// It also load UKDA data files with data dictionaries
fn load_orange_newer_file(path string, opts LoadOptions) Dataset {
	content := os.read_lines(path.trim_space()) or { panic('failed to open ${path}') }
	attribute_words := extract_words(content[0])
	types_attributes := attribute_words.map(extract_types(it))
	mut ds := Dataset{
		path: path
		attribute_names: types_attributes.map(it[1])
		attribute_types: types_attributes.map(it[0])
		// ox_spectra: content[1..].map(extract_words(it))
		DataDict: if opts.dictionaryfile_path != '' {
			data_dict(opts.dictionaryfile_path)
		} else {
			DataDict{}
		}
	}
	// ds.data = transpose(ds.ox_spectra)
	ds.data = transpose(content[1..].map(extract_words(it)))
	ds.inferred_attribute_types = infer_attribute_types_newer(ds)
	ds.Class = set_class_struct(ds)
	if opts.class_missing_purge_flag {
		// println('gonna purge!')
		ds = purge_instances_for_missing_class_values(mut ds)
	}
	ds.useful_continuous_attributes = get_useful_continuous_attributes(ds)
	ds.useful_discrete_attributes = get_useful_discrete_attributes(ds)
	if ds.attribute_types[0] == 'm' {
		ds.row_identifiers = ds.data[0]
	}
	// println(ds)

	return ds
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
	for i, attr_type in ds.attribute_types {
		inferred = match true {
			attr_type in ['C', 'D', 'c', 'i'] {
				attr_type
			}
			attr_type.contains('c') {
				'c'
			}
			attr_type in ['m', 'w', 'S', 'T'] {
				'i'
			}
			attr_type == '' {
				if ds.DataDict == DataDict{} {
					// println('and now here')
					infer_type_from_data(ds.data[i])
				} else {
					if ds.attribute_names[i] in ukda_metadata {
						'm'
					} else {
						// test whether the data dictionary specifies more than one
						// label (other than labels for missing values, eg negative
						// integers)
						if ds.variables[i].value_label_map.keys().filter(it !in missings).len > 1 {
							'D'
						} else {
							infer_type_from_data(ds.data[i])
						}
					}
				}
			}
			else {
				panic('unrecognized attribute type "${attr_type}" for attribute "${ds.attribute_names[i]}"')
			}
		}
		inferred_attribute_types << inferred
	}
	return inferred_attribute_types
}
