// load_older.v
module vhammll

import os

// load_orange_older_file loads from a file into a Dataset struct
fn load_orange_older_file(path string, opts LoadOptions) Dataset {
	content := os.read_lines(path.trim_space()) or { panic('failed to open ${path}') }
	mut ds := Dataset{
		path: path
		class_missing_purge_flag: opts.class_missing_purge_flag
		attribute_names: extract_words(content[0])
		raw_attribute_types: extract_words(content[1])
		attribute_flags: extract_words(content[2])
		data: transpose(content[3..].map(extract_words(it)))
	}
	attr_count := ds.attribute_names.len
	ds.raw_attribute_types = pad_string_array_to_length(mut ds.raw_attribute_types, attr_count)
	// println('ds.raw_attribute_types in load_older: $ds.raw_attribute_types')
	ds.attribute_flags = pad_string_array_to_length(mut ds.attribute_flags, attr_count)
	ds.attribute_types = get_specified_attribute_types_older(ds)
	// ds.inferred_attribute_types = infer_attribute_types_older(ds)
	// ds.attribute_types = combine_raw_and_inferred_types(ds)
	ds.Class = set_class_struct(ds)
	ds.useful_continuous_attributes = get_useful_continuous_attributes(ds)
	ds.useful_discrete_attributes = get_useful_discrete_attributes(ds)
	if opts.class_missing_purge_flag {
		// println('gonna purge!')
		ds.purge_instances_for_missing_class_values()
	}
	return ds
}

// infer_attribute_types_older gets inferred attribute types for orange-older files
// returns an array to plug into the Dataset struct
/*
For orange-older:
in the second line (ds.attribute_types):
  	'd' or 'discrete' or a list of values: denotes a discrete attribute
  	'c' or 'continuous': denotes a continuous attribute
  	'string' denotes a string variable, which we ignore
  	'basket': these are continuous-valued meta attributes; ignore
  	it may also contain a string of values separated by spaces. Use these
  	as the values for a discrete attribute.
  the third line (ds.attribute_flags) contains optional flags:
  	'i' or 'ignore'
  	'c' or 'class': there can only be one class attribute. If none is found,
  	 use the last attribute as the class attribute.
  	'm' or 'meta': meta attribute, eg weighting information; ignore
  	'-dc' followed by a value: indicates how a don't care is represented.
*/
fn get_specified_attribute_types_older(ds Dataset) []string {
	mut specified_attribute_types := []string{}
	mut attr_type := ''
	mut attr_flag := ''
	mut specified := ''
	for i in 0 .. ds.attribute_names.len {
		attr_type = ds.raw_attribute_types[i]
		attr_flag = ds.attribute_flags[i]
		if attr_flag in ['c', 'class'] {
			specified = 'c'
		} else if attr_type in ['d', 'discrete'] {
			specified = 'D'
		} else if attr_type in ['c', 'continuous'] {
			specified = 'C'
		} else if attr_type in ['string', 'basket'] || attr_flag in ['i', 'ignore'] {
			specified = 'i'
		}
		// if the entry contains a list of items separated by spaces
		else if attr_type.contains(' ') {
			specified = 'D'
		} else if attr_type == '' && attr_flag == '' {
			// specified = ''
			specified = infer_type_from_data(ds.data[i])
		} else {
			panic('unrecognized attribute type "${attr_type}" for attribute "${ds.attribute_names[i]}"')
		}
		specified_attribute_types << specified
	}
	return specified_attribute_types
}

// pad_string_array_to_length adds empty strings to arr to extend to length l
fn pad_string_array_to_length(mut arr []string, l int) []string {
	if arr.len >= l {
		return arr
	}
	for {
		arr << ['']
		if arr.len >= l {
			break
		}
	}
	return arr
}
