// show_attributes_test.v

module vhammll

fn test_show_crossvalidation() ? {
	println(rgb('test_show_crossvalidation prints out cross-validation results for developer.tab, breast-cancer-wisconsin-disc.tab, and iris.tab'))
	mut cvr := CrossVerifyResult{}
	mut opts := Options{
		concurrency_flag: true
		command: 'cross'
	}
	println('\n\ndeveloper.tab')
	cvr = cross_validate(load_file('datasets/developer.tab'), opts, show_flag: true)
	println('\ndeveloper.tab with expanded results')
	cvr = cross_validate(load_file('datasets/developer.tab'), opts, expanded_flag: true)
	println('\ndeveloper.tab with show_attributes')
	cvr = cross_validate(load_file('datasets/developer.tab'), opts, expanded_flag: true, show_attributes_flag: true)

	// println('\n\nbreast-cancer-wisconsin-disc.tab')
	// opts.number_of_attributes = [4]
	// cvr = cross_validate(load_file('datasets/breast-cancer-wisconsin-disc.tab'), opts,
	// 	show_flag: true
	// )
	// println('\nbreast-cancer-wisconsin-disc.tab with expanded results')
	// cvr = cross_validate(load_file('datasets/breast-cancer-wisconsin-disc.tab'), opts,
	// 	expanded_flag: true
	// )

	// println('\n\niris.tab')
	// opts.bins = [3, 6]
	// opts.number_of_attributes = [2]
	// cvr = cross_validate(load_file('datasets/iris.tab'), opts)
	// println('\niris.tab with expanded results')
	// cvr = cross_validate(load_file('datasets/iris.tab'), opts, expanded_flag: true)
	// // now with purging for missing classes
	// cvr = cross_validate(load_file('datasets/class_missing_iris.tab', class_missing_purge_flag: true),
	// 	opts, expanded_flag: true)
}