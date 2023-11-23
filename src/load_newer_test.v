// load_newer_test.v
module vhammll

// fn test_infer_attribute_types_newer() {
// 	mut ds := load_orange_newer_file('datasets/developer.tab')
// 	// println('types from file: $ds.attribute_types')
// 	types := ds.attribute_types
// 	ds.attribute_types = ['i', '', 'w', 'cD', 'C', 'm', '', 'T', 'S', '']
// 	assert infer_attribute_types_newer(ds) == ['i', 'D', 'i', 'c', 'C', 'i', 'D', 'i', 'i', 'C']

// 	assert infer_attribute_types_newer(load_file('datasets/developer.tab')) == ['i', 'D', 'C',
// 		'c', 'C', 'C', 'D', 'D', 'C', 'C']
// }

fn test_combine_raw_and_inferred_types() {
	mut ds := load_orange_newer_file('datasets/developer.tab')
	// println('types from file: $ds.attribute_types')
	types := ds.attribute_types
	ds.attribute_types = ['i', '', 'w', 'cD', 'C', 'm', '', 'T', 'S', '']
	assert combine_raw_and_inferred_types(ds) == ['i', 'D', 'C', 'c', 'C', 'C', 'D', 'D', 'C', 'C']

	assert combine_raw_and_inferred_types(load_file('datasets/developer.tab')) == ['i', 'D', 'C',
		'c', 'C', 'C', 'D', 'D', 'C', 'C']
}

fn test_load_with_purge_instances_for_missing_class_values() {
	mut ds := load_orange_newer_file('datasets/class_missing_developer.tab')
	// println(ds)
	mut dspmc := load_orange_newer_file('datasets/class_missing_developer.tab',
		class_missing_purge_flag: true
	)
	// println(dspmc)
	assert ds.class_values.len - 2 == dspmc.class_values.len
	assert analyze_dataset(ds, Options{}).class_counts == {
		'm': 8
		'':  1
		'f': 3
		'X': 2
		'?': 1
	}
	assert analyze_dataset(dspmc, Options{}).class_counts == {
		'm': 8
		'f': 3
		'X': 2
	}
}
