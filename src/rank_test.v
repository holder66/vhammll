// rank_test.v
module vhammll

fn test_sum_along_row_unweighted() {
	assert sum_along_row_unweighted([]int{}) == 0
	assert sum_along_row_unweighted([0]) == 0
	assert sum_along_row_unweighted([2, 3, 4]) == 4
	assert sum_along_row_unweighted([-2, 3, -4]) == 14
	assert sum_along_row_unweighted([0, 0, 8]) == 16
}

fn test_sum_along_row_weighted() {
	cca := [4, 8, 3]
	assert sum_along_row_weighted([0], cca) == 0
	assert sum_along_row_weighted([2, 3, 4], cca) == 37
	assert sum_along_row_weighted([-2, 3, -4], cca) == 79
	assert sum_along_row_weighted([0, 0, 8], cca) == 96
}

fn test_rank_attributes() {
	mut rank_value := rank_attributes(opts('-x -wr -b 3,3 datasets/developer.tab', cmd: 'rank')).array_of_ranked_attributes[1].rank_value
	assert rank_value >= 66.30434
	assert rank_value <= 66.30435
	assert rank_attributes(opts('-wr -b 3,3 datasets/developer.tab', cmd: 'rank')).array_of_ranked_attributes[2].attribute_name == 'lastname'
	assert rank_attributes(opts('-wr -b 2,16 datasets/developer.tab', cmd: 'rank')).array_of_ranked_attributes[7].attribute_index == 7
	rank_value = rank_attributes(opts('-x -wr -b 2,16 datasets/developer.tab', cmd: 'rank')).array_of_ranked_attributes[0].rank_value
	assert rank_value >= 95.65217
	assert rank_value <= 95.65219
	assert rank_attributes(opts('-x -wr -b 2,16 datasets/anneal.tab', cmd: 'rank')).array_of_ranked_attributes[3].attribute_name == 'formability'
	rank_value = rank_attributes(opts('-x -wr -b 2,2 datasets/mnist_test.tab', cmd: 'rank')).array_of_ranked_attributes[0].rank_value
	assert rank_value >= 38.08885
	assert rank_value <= 38.08886
	rank_value = rank_attributes(opts('-x -b 3,3 datasets/developer.tab', cmd: 'rank')).array_of_ranked_attributes[1].rank_value
	assert rank_value >= 69.23077
	assert rank_value <= 69.23078
	assert rank_attributes(opts('-b 3,3 datasets/developer.tab', cmd: 'rank')).array_of_ranked_attributes[2].attribute_name == 'city'
	assert rank_attributes(opts('-b 2,16 datasets/developer.tab', cmd: 'rank')).array_of_ranked_attributes[7].attribute_index == 6
	rank_value = rank_attributes(opts('-x -b 2,16 datasets/developer.tab', cmd: 'rank')).array_of_ranked_attributes[0].rank_value
	assert rank_value >= 92.30769
	assert rank_value <= 92.30770
	assert rank_attributes(opts('-x -b 2,16 datasets/anneal.tab', cmd: 'rank')).array_of_ranked_attributes[3].attribute_name == 'strength'
	rank_value = rank_attributes(opts('-x -b 2,2 datasets/mnist_test.tab', cmd: 'rank')).array_of_ranked_attributes[0].rank_value
	assert rank_value >= 38.48
	assert rank_value <= 38.49
}

fn test_get_rank_value_for_strings() {
	mut ds := load_file('datasets/developer.tab')
	assert get_rank_value_for_strings(ds.data[1], ds.class_values, ds.class_counts, opts('-x -wr')) == 60
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		opts('-x -wr')) == 92
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		opts('-wr')) == 92
	assert get_rank_value_for_strings(ds.data[1], ds.class_values, ds.class_counts, opts('-x')) == 18
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		opts('-x')) == 26
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		opts('')) == 26
	ds = load_file('datasets/anneal.tab')
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		opts('-x -wr')) == 322594
	assert get_rank_value_for_strings(ds.class_values, ds.class_values, ds.class_counts,
		opts('-x')) == 3592
}

fn test_rank_attribute_sorting() {
	mut result := rank_attributes(opts('-wr datasets/developer.tab', cmd: 'rank'))
	mut atts := []string{}
	for att in result.array_of_ranked_attributes {
		atts << att.attribute_name
	}
	assert atts == ['height', 'negative', 'weight', 'number', 'age', 'lastname', 'SEC', 'city']
	atts = []
	result = rank_attributes(opts('-wr -b 3,3 datasets/developer.tab', cmd: 'rank'))
	for att in result.array_of_ranked_attributes {
		atts << att.attribute_name
	}
	assert atts == ['height', 'negative', 'lastname', 'number', 'SEC', 'city', 'age', 'weight']
	atts = []
	result = rank_attributes(opts('-wr -b 4,9 datasets/developer.tab', cmd: 'rank'))
	for att in result.array_of_ranked_attributes {
		atts << att.attribute_name
	}
	assert atts == ['height', 'number', 'weight', 'negative', 'age', 'lastname', 'SEC', 'city']
	result = rank_attributes(opts('-b 4,9 datasets/developer.tab', cmd: 'rank'))
	atts = []
	for att in result.array_of_ranked_attributes {
		atts << att.attribute_name
	}
	assert atts == ['height', 'weight', 'number', 'negative', 'age', 'lastname', 'city', 'SEC']
	atts = []
	result = rank_attributes(opts('-b 3,3 datasets/developer.tab', cmd: 'rank'))
	for att in result.array_of_ranked_attributes {
		atts << att.attribute_name
	}
	assert atts == ['height', 'lastname', 'city', 'SEC', 'age', 'number', 'negative', 'weight']
	atts = []
	result = rank_attributes(opts('-b 4,9 datasets/developer.tab', cmd: 'rank'))
	for att in result.array_of_ranked_attributes {
		atts << att.attribute_name
	}
	assert atts == ['height', 'weight', 'number', 'negative', 'age', 'lastname', 'city', 'SEC']
}

fn test_pairs() {
	assert pairs(0) == []
	assert pairs(1) == []
	assert pairs(2) == [[0, 1]]
	assert pairs(3) == [[0, 1], [0, 2], [1, 2]]
	assert pairs(4) == [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3],
		[2, 3]]
}

fn test_abs_diff() {
	assert abs_diff(0, 0) == 0
	assert abs_diff(0, 4) == 4
	assert abs_diff(3, -9) == 12
	assert abs_diff(-2, -8) == 6
	assert abs_diff(-0, 5) == 5
}
