// purge_missings_test.v
module vhammll

fn test_purge_array() {

	assert purge_array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], []int) == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
	assert purge_array([]int, []int) == []
	assert purge_array([]int, [3]) == []
	assert purge_array([2, 3, 4, 5, 6, 7, 8, 9, 10], [0]) == [3, 4, 5, 6, 7, 8, 9, 10]
	assert purge_array([2, 3, 4, 5, 6, 7, 8, 9, 10], [10]) == [2, 3, 4, 5, 6, 7, 8, 9, 10]
	assert purge_array([2, 3, 4, 5, 6, 7, 8, 9, 10], [1, 8]) == [2, 4, 5, 6, 7, 8, 9]
	assert purge_array(['?', '', 'NA', ' '], [1,2]) == ['?', ' ']
}

fn test_purge_instances_for_missing_class_values() {
	mut opts := Options{
		bins: [3, 3]
		exclude_flag: false
		verbose_flag: false
		command: 'make'
		number_of_attributes: [2]
		show_flag: false
		weighting_flag: false
	}
	mut ds := load_file('datasets/class_missing_iris.tab')
	mut cl := make_classifier(mut ds, opts)
	assert cl.instances.len == 150
	mut pmcds := ds.purge_instances_for_missing_class_values()
	mut pmcl := make_classifier(mut pmcds, opts)
	assert pmcl.instances.len == 142

	// now for an orange_newer file
	ds = load_file('datasets/class_missing_developer.tab')
	cl = make_classifier(mut ds, opts)
	assert cl.instances.len == 15
	pmcds = ds.purge_instances_for_missing_class_values()
	pmcl = make_classifier(mut pmcds, opts)
	assert pmcl.instances.len == 13
}
