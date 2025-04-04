// classify_test.v
module vhammll

fn test_classify_case() {
	mut opts := Options{
		datafile_path:        'datasets/developer.tab'
		bins:                 [2, 12]
		exclude_flag:         false
		command:              'classify'
		number_of_attributes: [6]
		weighting_flag:       false
	}
	mut cl := make_classifier(opts)
	assert classify_case(cl, cl.instances[0], opts).inferred_class == 'm'
	assert classify_case(cl, cl.instances[0], opts).nearest_neighbors_by_class == [
		1,
		0,
		0,
	]
	opts.weighting_flag = true
	cl = make_classifier(opts)
	assert classify_case(cl, cl.instances[3], opts).inferred_class == 'f'
	assert classify_case(cl, cl.instances[3], opts).nearest_neighbors_by_class == [
		0,
		8,
		0,
	]
}

fn test_get_hamming_distance() {
	assert get_hamming_distance(0, 0) == 0
	assert get_hamming_distance(0, 1) == 1
	assert get_hamming_distance(2, 0) == 1
	assert get_hamming_distance(1, 2) == 2
	assert get_hamming_distance(16, 128) == 2
}
