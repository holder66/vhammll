// cross_validate_test.v
module vhammll

fn test_cross_validate() ? {
	mut opts := Options{
		command:          'cross'
		exclude_flag:     false
		concurrency_flag: true
		verbose_flag:     false
		// expanded_flag: true
	}
	mut result := CrossVerifyResult{}

	opts.datafile_path = 'datasets/anneal.tab'
	opts.number_of_attributes = [28]
	opts.bins = [21, 21]
	opts.folds = 10
	opts.repetitions = 10
	opts.random_pick = true
	result = cross_validate(opts)
	assert result.correct_count >= 878 && result.correct_count <= 883

	opts.weighting_flag = true
	result = cross_validate(opts)
	assert result.correct_count >= 870 && result.correct_count <= 883
	println(r_b('\ndone with anneal.tab'))

	opts.datafile_path = 'datasets/developer.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 4
	opts.weighting_flag = false
	opts.repetitions = 2
	opts.random_pick = false

	result = cross_validate(opts)
	assert result.total_count == 13
	assert result.correct_counts == [8, 2, 2]
	println(r_b('\nDone with developer.tab no weighting'))
	opts.concurrency_flag = false

	opts.datafile_path = 'datasets/developer.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 2
	opts.weighting_flag = true

	result = cross_validate(opts)
	assert result.correct_counts == [8, 3, 0]

	println(r_b('\nDone with developer.tab with weighting'))

	opts.datafile_path = 'datasets/iris.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3, 3]
	opts.folds = 0
	result = cross_validate(opts)
	assert result.correct_count == 147
	assert result.incorrects_count == 3
	assert result.wrong_count == 3
	assert result.total_count == 150
	println(r_b('\nDone with iris.tab'))

	opts.datafile_path = 'datasets/breast-cancer-wisconsin-disc.tab'
	opts.number_of_attributes = [9]
	result = cross_validate(opts)
	assert result.correct_count == 672
	assert result.incorrects_count == 27
	assert result.wrong_count == 27
	assert result.total_count == 699
	println(r_b('\nDone with breast-cancer-wisconsin-disc.tab'))

	// if get_environment().arch_details[0] != '4 cpus' {
	// 	// opts.concurrency_flag = true
	// 	opts.datafile_path = 'datasets/mnist_test.tab'
	// 	opts.number_of_attributes = [313]
	// 	opts.bins = [2, 2]
	// 	opts.folds = 16
	// 	opts.repetitions = 5
	// 	opts.random_pick = true
	// 	opts.weighting_flag = false

	// 	result = cross_validate(opts)
	// 	assert result.correct_count > 9400
	// }
}
