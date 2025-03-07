// rank_new_test.v

module vhammll

fn test_pairs() {
	assert pairs(0) == []
	assert pairs(1) == []
	assert pairs(2) == [[0, 1]]
	assert pairs(3) == [[0, 1], [0, 2], [1, 2]]
	assert pairs(4) == [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3]]
}

fn test_abs_diff() {
	assert abs_diff(0, 0) == 0
	assert abs_diff(0, 4) == 4
	assert abs_diff(3, -9) == 12
	assert abs_diff(-2, -8) == 6
	assert abs_diff(-0, 5) == 5
}

fn test_new_ranking_function() {
	mut opts := Options{
		bins: [3,6]
		weight_ranking_flag: true
		show_flag: true
		command: 'rank'
	}
	mut ds := load_file('datasets/developer.tab')
	rank_attributes_old(ds, opts)
	rank_attributes(ds, opts)
}
