// load_newer_test.v
module vhammll

fn test_infer_attribute_types_newer() {
	mut ds := load_orange_newer_file('datasets/developer.tab')
	// println('types from file: $ds.attribute_types')
	types := ds.attribute_types
	ds.attribute_types = ['i', '', 'w', 'cD', 'C', 'm', '', 'T', 'S', '']
	assert infer_attribute_types_newer(ds) == ['i', 'D', 'i', 'c', 'C', 'i', 'D', 'i', 'i', 'C']

	assert infer_attribute_types_newer(load_file('datasets/developer.tab')) == ['i', 'D', 'C',
		'c', 'C', 'C', 'D', 'D', 'C', 'C']
}
