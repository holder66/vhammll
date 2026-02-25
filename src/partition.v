// partition.v
module vhammll

const partition_help = '
Description:
"partition" splits a datafile into two or more partitions, saving each partition
into a separate datafile which includes the header from the original datafile.
The size of each partition is specified in a list of integers, each of which
represents the numerator of a fraction of which the denominator is the sum of
the integers. For example: 2,1 splits into 2 partitions, the first being 2/3 of
the total cases, the second comprising the remaining one third. 5,2,2 splits into
3 partitions, the first 5/9 of the cases, the other two both 2/9 of the total.
If the total cases do not divide equally, the remainder go into the last partition.
Cases for each partition are picked randomly (but a case can only be in one
partition).

Usage: v run main.v partition <options> <path_to_dataset_file>

Options:
  -p#:             followed by a list of integers specifying the relative
                   sizes of each partition (used with the partition command);
  -ps:             followed by a list of partition file paths;
  -rand:           cases are picked randomly (no repeats)
'

// partition splits a dataset into a fold set of instances, and the remainder
// of the dataset (ie with the fold instances taken out).
fn partition(pick_list []int, current_fold int, folds int, ds Dataset, opts Options) (Dataset, Fold) {
	// fold will be the fold instance, part_ds will be the rest of the dataset.
	mut part_ds := ds
	mut total_instances := ds.Class.class_values.len

	// calculate array indices for partitioning
	mut s, mut e := get_partition_indices(total_instances, folds, current_fold)
	// println('s: $s e: $e')
	mut fold_indices := pick_list[s..e].clone()
	mut part_indices := get_rest_of_array(pick_list, s, e)
	fold_class_values := get_index_items(ds.class_values, fold_indices)
	// update the Class struct for the rest of the dataset
	part_ds.class_name = ds.class_name // for some reason, this gets emptied
	part_ds.class_values = get_index_items(ds.class_values, part_indices)
	part_ds.class_counts = element_counts(part_ds.class_values)
	part_ds.data = transpose(get_index_items(transpose(ds.data), part_indices))
	part_ds.useful_continuous_attributes = get_useful_continuous_attributes(part_ds)
	part_ds.useful_discrete_attributes = get_useful_discrete_attributes(part_ds)

	mut fold := Fold{
		fold_number:     current_fold
		attribute_names: ds.attribute_names
		indices:         fold_indices
		data:            transpose(get_index_items(transpose(ds.data), fold_indices))
		class_name:      ds.class_name
		class_values:    fold_class_values
		class_counts:    element_counts(fold_class_values)
	}
	return part_ds, fold
}

// get_partition_indices returns indices start & end, for the start and end of a fold, given the total number of indices `total`, the number of folds `n`, and the fold number `curr`
fn get_partition_indices(total int, n int, curr int) (int, int) {
	mut start := 0
	mut end := 0
	if n == 0 { // ie each fold will be length 1, thus the total number of folds
		// will be the same as the array length
		return curr, curr + 1
	}
	if curr > n || n == 1 {
		return 0, 0
	}
	mut n1 := f64(n)
	real := total / n1
	mut fold_size := int(real) + 1
	r := (n * fold_size) - total
	if curr < r {
		start = curr * (fold_size - 1)
		end = start + fold_size - 1
	} else {
		start = curr * fold_size - r
		end = start + fold_size
	}
	return start, end
}

// get_rest_of_array given the start s and the end e of the slice to be removed,
// returns the rest of the array
fn get_rest_of_array[T](arr []T, s int, e int) []T {
	mut rest := []T{}
	for i, val in arr {
		if i < s || i >= e {
			rest << val
		}
	}
	return rest
}

// get_index_items
fn get_index_items[T](arr []T, indices []int) []T {
	mut sel := []T{}
	for i, val in arr {
		if i in indices {
			sel << val
		}
	}
	return sel
}
