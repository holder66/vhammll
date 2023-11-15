// purge_missings_test.v
module vhammll

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
	println(ds)
	assert cl.instances.len == 150
	mut pcl := purge(cl)
	assert pcl.instances.len == 17
	mut pmcds := ds.purge_instances_for_missing_class_values()
	println(pmcds)
	mut pmcl := make_classifier(mut pmcds, opts)
	assert pmcl.instances.len == 12
}
