// load_csv.v
module vhammll

import os

// load_csv_file loads a comma-separated file (as used by Kaggle) into a
// Dataset struct. It sets the attribute type for the first column as
// metadata, and the last column as the class attribute.
fn load_csv_file(path string) Dataset {
	mut content_csv := os.read_lines(path.trim_space()) or { panic('failed to open ${path}') }
	mut content := content_csv.map(it.split(','))
	mut attr_names := content[0]
	mut raw_attr_types := []string{len: attr_names.len}
	raw_attr_types[0] = 'm'
	raw_attr_types[raw_attr_types.len - 1] = 'c'
	mut ds := Dataset{
		path:                     path
		data:                     transpose(content[1..])
		attribute_names:          attr_names
		raw_attribute_types:      raw_attr_types
		inferred_attribute_types: []string{len: attr_names.len}
	}
	ds.attribute_types = combine_raw_and_inferred_types(ds)
	// println('ds in load_csv_file: ${ds}')
	ds.Class = set_class_struct(ds)
	ds.useful_continuous_attributes = get_useful_continuous_attributes(ds)
	ds.useful_discrete_attributes = get_useful_discrete_attributes(ds)
	if ds.attribute_types[0] == 'm' {
		ds.row_identifiers = ds.data[0]
	}
	return ds
}
