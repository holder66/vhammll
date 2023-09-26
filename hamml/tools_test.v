// tools_test.v
module hamml

// import arrays

fn test_close() {
	assert close(1.0, 1.0)
	assert close(1.000000001, 1.0) == false
	assert close(f32(1.000000001), f32(1.0))
}

fn test_uniques() {
	assert uniques([1]) == [1]
	assert uniques([1, 4, 5, 1, 1, 4]) == [1, 4, 5]
	assert uniques(['a', 'b', 'a']) == ['a', 'b']
	assert uniques([0.1, 0.11]) == [0.1, 0.11]
}

fn test_transpose() {
	matrix := [['1', '2', '3'], ['4', '5', '6']]
	assert transpose(matrix) == [['1', '4'], ['2', '5'], ['3', '6']]
	matrix2 := [[1, 2, 3], [4, 5, 6]]
	assert transpose(matrix2) == [[1, 4], [2, 5], [3, 6]]
}

fn test_element_counts() {
	assert string_element_counts(['i']) == {
		'i': 1
	}
	assert string_element_counts([]) == map[string]int{}
	mut elements := ['i', '', 'w', 'cD', 'C', 'm', '', 'T', 'S', '']
	assert string_element_counts(elements) == {
		'i':  1
		'':   3
		'w':  1
		'cD': 1
		'C':  1
		'm':  1
		'T':  1
		'S':  1
	}
}

fn test_parse_range() {
	assert parse_range('256,257') == [256, 257]
	assert parse_range('') == [0]
	assert parse_range('256,257,abc') == [256, 257, 0]
	assert parse_range('abc,3') == [0, 3]
	assert parse_range('3,3') == [3, 3]
	assert parse_range('4,5,2') == [4, 5, 2]
	assert parse_range('0') == [0]
	assert parse_range('5') == [5]
}

// test_array_min
// fn test_array_min() {
// 	// mut values := []{}f32
// 	// values = [1.0, 2.0, 3.0]
// 	println(array_min([1.0, 2.0, 3.0]))
// }

// test_discretize_attribute
fn test_discretize_attribute() {
	mut values := [1.0, 2, 0, 3.0]
	assert discretize_attribute(values, array_min(values), array_max(values), 3) == [
		2,
		3,
		1,
		3,
	]
	mut values_int := [-10, -5, 0, 5, 10, 15, 19, 20]
	assert discretize_attribute(values_int, array_min(values_int), array_max(values_int),
		3) == [
		1,
		1,
		2,
		2,
		3,
		3,
		3,
		3,
	]
	assert discretize_attribute(values_int, array_min(values_int), array_max(values_int),
		2) == [
		1,
		1,
		1,
		2,
		2,
		2,
		2,
		2,
	]
	assert discretize_attribute(values_int, array_min(values_int), array_max(values_int),
		1) == [
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
	]
	values = [1.0, 2, 0, -3.4028234663852886e+38, 3.0]
	assert discretize_attribute(values, 0.0, array_max(values), 3) == [2, 3, 1, 0, 3]
	values = [-10.0, -5, 0, 5, -3.4028234663852886e+38, 10, 15, 19, 20]
	assert discretize_attribute(values, -10.0, array_max(values), 3) == [1, 1, 2, 2, 0, 3, 3, 3,
		3]
}

// test_get_map_values
fn test_get_map_values() {
	mut elements := ['i', '', 'w', 'cD', 'C', 'm', '', 'T', 'S', '']
	assert get_map_values(string_element_counts(elements)) == [1, 3, 1, 1, 1, 1, 1, 1]
}

// test_convert_to_one_bit
fn test_convert_to_one_bit() {
	assert convert_to_one_bit(0) == 0
	assert convert_to_one_bit(1) == 1
	assert convert_to_one_bit(3) == 8
	assert convert_to_one_bit(8) == 256
	assert convert_to_one_bit(16) == 65536
	assert convert_to_one_bit(31) == 2147483648
	assert convert_to_one_bit(32) == 1 // wraps around
}

// test_hamming_distance
fn test_hamming_distance() {
	assert hamming_distance([u32(1)], [u32(0)]) == 1
	assert hamming_distance([u32(1)], [u32(2)]) == 2
	assert hamming_distance([u32(1)], [u32(1)]) == 0
	assert hamming_distance([u32(0)], [u32(0)]) == 0
	assert hamming_distance([u32(1), u32(1), u32(1), u32(0)], [u32(0), u32(2), u32(1), u32(0)]) == 3
}

// test_lcm
fn test_lcm() {
	mut arr := [2, 3, 8]
	assert lcm(arr) == 24
	arr = [11, 22, 33, 44, 55, 66]
	assert lcm(arr) == 660
	arr = [5421, 5923, 6742, 5949, 5958]
	assert lcm(arr) == 142089045253252578
	arr = [5421, 5923, 6742, 5949, 5958, 6131, 5918]
	assert lcm(arr) == 0
	arr = [4684, 4132, 4072, 4401, 4351, 3795, 4063, 4188, 4177, 4137]
	assert lcm(arr) == 0
}

// test_plurality_vote
fn test_plurality_vote() ? {
	assert plurality_vote(['a', 'a', 'b']) == 'a'
	assert plurality_vote([]) == ''
	assert plurality_vote(['a']) == 'a'
	assert plurality_vote(['a', 'a', 'b', 'b']) == ''
	assert plurality_vote(['a', 'a', 'b', 'c']) == 'a'
}

// test_majority_vote
fn test_majority_vote() ? {
	assert majority_vote(['a', 'a', 'b']) == 'a'
	assert majority_vote([]) == ''
	assert majority_vote(['a']) == 'a'
	assert majority_vote(['a', 'a', 'b', 'b']) == ''
	assert majority_vote(['a', 'a', 'b', 'c']) == ''
}
