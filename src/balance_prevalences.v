// balance_prevalences.v
module vhammll

// evaluate_class_prevalence_imbalance returns true if the ratio between the
// minimum and maximum class counts for the dataset exceeds the threshold specified by
// Options.balance_prevalence_threshold.
fn evaluate_class_prevalence_imbalance(ds Dataset, opts Options) bool {
	class_counts_array := ds.class_counts.values()
	if f64(array_min(class_counts_array)) / array_max(class_counts_array) <= opts.balance_prevalences_threshold {
		return true
	}
	return false
}

fn balance_prevalences(mut ds Dataset, threshold f64) Dataset {
	ds.pre_balance_prevalences_class_counts = ds.class_counts.clone()
	mut transposed_data := transpose(ds.data)

	// new version using arrays
	mut new_class_counts_array := ds.class_counts.values()
	// initialize multipliers, including changing 0's to 1's
	mut multipliers := ([]int{len: new_class_counts_array.len, init: (array_sum(new_class_counts_array) - new_class_counts_array[index]) / new_class_counts_array[index]}).map(if it == 0 {
		1
	} else {
		it
	})
	// determine if the threshold condition is met
	for {
		new_class_counts_array = array_multiply(ds.class_counts.values(), multipliers)
		if (f64(array_min(new_class_counts_array)) / f64(array_max(new_class_counts_array))) >= threshold {
			break
		}
		for i in 0 .. multipliers.len {
			if new_class_counts_array[i] == array_min(new_class_counts_array) {
				multipliers[i] += 1
			}
		}
	}
	mut multipliers_map := ds.class_counts.clone()
	mut i := 0
	for key, _ in multipliers_map {
		multipliers_map[key] = multipliers[i]
		i += 1
	}
	mut new_class_data_indices_map := map[string][]int{}
	for key, _ in multipliers_map {
		new_class_data_indices_map[key] = idxs_match(ds.class_values, key)
	}
	// strip off first element in each array, as it is set to 0 when the map was created
	for _, mut val in new_class_data_indices_map {
		val.delete(0)
	}
	// create a new set of data rows
	mut new_data := [][]string{}
	for class, multiplier in multipliers_map {
		for _ in 0 .. multiplier {
			for idx in new_class_data_indices_map[class] {
				new_data << transposed_data[idx]
			}
		}
	}
	ds.data = transpose(new_data)
	ds.class_values = ds.data[ds.attribute_names.index(ds.class_name)]
	ds.class_counts = element_counts(ds.class_values)
	ds.useful_continuous_attributes = get_useful_continuous_attributes(ds)
	ds.useful_discrete_attributes = get_useful_discrete_attributes(ds)
	return ds
}
