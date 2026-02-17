// cross_validate_test.v
module vhammll

fn test_cross_validate() ? {
	mut result := CrossVerifyResult{}

	result = cross_validate(opts('-c -a 28 -b 21,21 -f 10 -r 10 -rand datasets/anneal.tab',
		cmd: 'cross'
	))
	assert result.correct_count >= 878 && result.correct_count <= 883

	result = cross_validate(opts('-c -w -a 28 -b 21,21 -f 10 -r 10 -rand datasets/anneal.tab',
		cmd: 'cross'
	))
	assert result.correct_count >= 870 && result.correct_count <= 883
	println(r_b('\ndone with anneal.tab'))

	result = cross_validate(opts('-c -a 2 -b 3,3 -f 4 -r 2 datasets/developer.tab', cmd: 'cross'))
	assert result.total_count == 13
	assert result.correct_counts == [8, 2, 2]
	println(r_b('\nDone with developer.tab no weighting'))

	result = cross_validate(opts('-w -a 2 -b 3,3 -f 2 -r 2 datasets/developer.tab', cmd: 'cross'))
	assert result.correct_counts == [8, 3, 0]
	println(r_b('\nDone with developer.tab with weighting'))

	result = cross_validate(opts('-w -a 2 -b 3,3 datasets/iris.tab', cmd: 'cross'))
	assert result.correct_count == 147
	assert result.incorrects_count == 3
	assert result.wrong_count == 3
	assert result.total_count == 150
	println(r_b('\nDone with iris.tab'))

	result = cross_validate(opts('-w -a 9 -b 3,3 datasets/breast-cancer-wisconsin-disc.tab',
		cmd: 'cross'
	))
	assert result.correct_count == 672
	assert result.incorrects_count == 27
	assert result.wrong_count == 27
	assert result.total_count == 699
	println(r_b('\nDone with breast-cancer-wisconsin-disc.tab'))
}
