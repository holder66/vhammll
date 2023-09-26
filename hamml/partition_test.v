// partition_test.v
module hamml

// test_get_partition_indices
fn test_get_partition_indices() {
	mut arr := [11, 22, 33, 44, 55, 66]
	mut len := arr.len
	// leave-one-out, first fold
	mut s, mut e := get_partition_indices(len, 0, 0)
	assert s == 0
	assert e == 1
	assert arr[s..e] == [11]
	assert get_rest_of_array(arr, s, e) == [22, 33, 44, 55, 66]
	s, e = get_partition_indices(len, 0, 1)
	assert s == 1
	assert e == 2
	assert arr[s..e] == [22]
	assert get_rest_of_array(arr, s, e) == [11, 33, 44, 55, 66]

	s, e = get_partition_indices(len, 0, 5)
	assert s == 5
	assert e == 6
	assert arr[s..e] == [66]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55]

	s, e = get_partition_indices(len, 3, 2)
	assert s == 4
	assert e == 6
	assert arr[s..e] == [55, 66]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44]

	arr = [11, 22, 33, 44, 55, 66, 77, 88, 99, 100, 111, 122, 133]
	len = arr.len
	s, e = get_partition_indices(len, 2, 0)
	assert s == 0
	assert e == 6
	assert arr[s..e] == [11, 22, 33, 44, 55, 66]
	assert get_rest_of_array(arr, s, e) == [77, 88, 99, 100, 111, 122, 133]

	s, e = get_partition_indices(len, 2, 1)
	assert s == 6
	assert e == 13
	assert arr[s..e] == [77, 88, 99, 100, 111, 122, 133]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66]

	s, e = get_partition_indices(len, 3, 1)
	assert s == 4
	assert e == 8
	assert arr[s..e] == [55, 66, 77, 88]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 99, 100, 111, 122, 133]

	s, e = get_partition_indices(len, 3, 2)
	assert s == 8
	assert e == 13
	assert arr[s..e] == [99, 100, 111, 122, 133]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66, 77, 88]

	s, e = get_partition_indices(len, 4, 2)
	assert s == 6
	assert e == 9
	assert arr[s..e] == [77, 88, 99]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66, 100, 111, 122, 133]

	s, e = get_partition_indices(len, 4, 3)
	assert s == 9
	assert e == 13
	assert arr[s..e] == [100, 111, 122, 133]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66, 77, 88, 99]

	s, e = get_partition_indices(len, 5, 2)
	assert s == 4
	assert e == 7
	assert arr[s..e] == [55, 66, 77]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 88, 99, 100, 111, 122, 133]

	s, e = get_partition_indices(len, 5, 4)
	assert s == 10
	assert e == 13
	assert arr[s..e] == [111, 122, 133]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66, 77, 88, 99, 100]

	s, e = get_partition_indices(len, 6, 5)
	assert s == 10
	assert e == 13
	assert arr[s..e] == [111, 122, 133]
	assert get_rest_of_array(arr, s, e) == [11, 22, 33, 44, 55, 66, 77, 88, 99, 100]
}

// test_partition
fn test_partition() {
	mut opts := Options{}
	mut part_ds, mut fold := partition([1, 8, 0, 2, 4, 9, 12, 5, 11, 10, 6, 7, 3], 1,
		4, load_file('datasets/developer.tab'), opts)
	assert fold.class_values == ['m', 'f', 'm']
	assert part_ds.class_counts == {
		'm': 6
		'f': 2
		'X': 2
	}
}
