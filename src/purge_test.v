// purge_test.v
module vhammll

// test_purge
fn test_purge() ? {
	mut opts := Options{
		datafile_path:        'datasets/iris.tab'
		bins:                 [3, 3]
		exclude_flag:         false
		command:              'make'
		number_of_attributes: [2]
		weighting_flag:       false
	}
	mut cl := make_classifier(opts)
	assert cl.instances.len == 150
	mut pcl := purge(cl)
	assert pcl.instances.len == 12

	// now for an orange_newer file
	opts.datafile_path = 'datasets/class_missing_developer.tab'
	cl = make_classifier(opts)
	assert cl.instances.len == 15
	pcl = purge(cl)
	assert pcl.instances.len == 13
}
