// tools_test.v
module vhammll

// import arrays
import math.unsigned

fn test_idx_max() {
	assert idx_max([5]) == 0
	assert idx_max([3.4, 3.4, 3.4]) == 0
}

fn test_idxs_max() {
	assert idxs_max([5]) == [0]
	assert idxs_max([3.4, 3.4, 3.4]) == [0, 1, 2]
	assert idxs_max([2, 4, 3]) == [1]
	assert idxs_max([2, 4, 3, 4]) == [1, 3]
}

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
	a := []int{}
	assert element_counts(a) == {}
	b := []string{}
	assert element_counts(b) == {}
	c := [2.1, 4.4, 0, 1]
	assert element_counts(c) == {
		2.1: 1
		4.4: 1
		0.0: 1
		1.0: 1
	}
	assert element_counts(['i']) == {
		'i': 1
	}
	mut elements := ['i', '', 'w', 'cD', 'C', 'm', '', 'T', 'S', '']
	assert element_counts(elements) == {
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
	assert parse_range('0,0,1,2,2') == [0, 0, 1, 2, 2]
}

fn test_parse_paths() {
	assert parse_paths('').len == 0
	assert parse_paths('abc123') == ['abc123']
	assert parse_paths('abc,123,0,bd12') == ['abc', '123', '0', 'bd12']
}

fn test_array_min() {
	assert array_min([1.0, 2.0, 3.0]) == 1.0
}

fn test_last() {
	assert [1, 2, 3].last() == 3
	assert ['a'].last() == 'a'
	assert [1.0, 2.0, 3.0].last() == 3.0
}

fn test_discretize_attribute_with_range_check() {
	assert discretize_attribute_with_range_check([]int{}, 0, 5, 1) == []
	assert discretize_attribute_with_range_check([nan[f64]()], 0.0, 5.0, 1) == [0]
	assert discretize_attribute_with_range_check([0.0], 1.0, 5.0, 1) == [0]
	assert discretize_attribute_with_range_check([10.0], 1.0, 5.0, 1) == [0]
	mut values := [1, 6, 9, 10, 0, -1, 12]
	assert discretize_attribute_with_range_check(values, 0, 10, 2) == [1, 2, 2, 2, 1, 0, 0]
	assert discretize_attribute_with_range_check(values, -5, 15, 4) == [2, 3, 3, 4, 2, 1, 4]
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

fn test_lcm_u128() {
	mut arr := [2, 3, 8]
	assert lcm_u128(arr) == unsigned.Uint128{24, 0}
	arr = [11, 22, 33, 44, 55, 66]
	assert lcm_u128(arr) == unsigned.Uint128{660, 0}
	arr = [5421, 5923, 6742, 5949, 5958]
	assert lcm_u128(arr) == unsigned.Uint128{142089045253252578, 0}
	arr = [5421, 5923, 6742, 5949, 5958, 6131, 5918]
	assert lcm_u128(arr).str() == '2577726743948719313369562'
	// class counts for the mnist training set (60,000 cases)
	arr = [5421, 5923, 5842, 6742, 5949, 5958, 6131, 5918, 6265, 5851]
	assert lcm_u128(arr).str() == '276006689320991032513398787039572030'
}

fn test_get_map_key_for_max_and_min_value() {
	mut m := {
		'a': 4
		'b': 7
		'c': 0
		'd': -12
		'e': -2
	}
	assert get_map_key_for_max_value(m) == 'b'
	assert get_map_key_for_min_value(m) == 'd'
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

fn test_purge_array() {
	assert purge_array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], []int{}) == [0, 1, 2, 3, 4, 5, 6, 7,
		8, 9, 10]
	assert purge_array([]int{}, []int{}) == []
	assert purge_array([]int{}, [3]) == []
	assert purge_array([2, 3, 4, 5, 6, 7, 8, 9, 10], [0]) == [3, 4, 5, 6, 7, 8, 9, 10]
	assert purge_array([2, 3, 4, 5, 6, 7, 8, 9, 10], [10]) == [2, 3, 4, 5, 6, 7, 8, 9, 10]
	assert purge_array([2, 3, 4, 5, 6, 7, 8, 9, 10], [1, 8]) == [2, 4, 5, 6, 7, 8, 9]
	assert purge_array(['?', '', 'NA', ' '], [1, 2]) == ['?', ' ']
}

fn test_chlk1() {
	println(g_b('This should show in bold green'))
	println(dg('Printout in dark grey'))
	println(m('Now for magenta!'))
	println(r_b('This should be bold red text.'))
	println(rgb('Bold red text on green background'))
}

fn test_filter_array_by_index() {
	assert filter_array_by_index([36, 40, 66], [0]) == [36]
	assert filter_array_by_index([36, 40, 66], [0, 1]) == [36, 40]
	assert filter_array_by_index([36, 40, 66], [1, 0]) == [36, 40]
	assert filter_array_by_index([36, 40, 66], [2, 0]) == [36, 66]
	assert filter_array_by_index([36, 40, 66], [1, 2]) == [40, 66]
	assert filter_array_by_index([]int{}, [0]) == []
	assert filter_array_by_index([36, 40, 66], [0, 5]) == [36]
	assert filter_array_by_index([36, 40, 66], [5, 1, 1]) == [40]
	assert filter_array_by_index([]string{}, [0]) == []
}

fn test_pick_array_elements_by_index() {
	assert pick_array_elements_by_index([36, 40, 66], [0]) == [36]
	assert pick_array_elements_by_index([36, 40, 66], [0, 1]) == [36, 40]
	assert pick_array_elements_by_index([36, 40, 66], [1, 0]) == [40, 36]
	assert pick_array_elements_by_index([36, 40, 66], [2, 0]) == [66, 36]
	assert pick_array_elements_by_index([36, 40, 66], [1, 2]) == [40, 66]
	assert pick_array_elements_by_index([36, 40, 66], []int{}) == []
	assert pick_array_elements_by_index([]int{}, [0]) == []
	assert pick_array_elements_by_index([36, 40, 66], [0, 5]) == [36]
	assert pick_array_elements_by_index([36, 40, 66], [5, 1, 1]) == [40, 40]
	assert pick_array_elements_by_index([]string{}, [0]) == []
}
