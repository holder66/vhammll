// rank_new.v

module vhammll

pub fn rank_attributes_new(ds Dataset, opts Options) RankingResult {
	dump(ds.Class)
	mut rank_value_map := map[string]int{}
	mut binning_map := map[string]int{}
	// mut bin_number := 0
	mut max_rank_value := 0
	// for each attribute in the dataset
	for i, attribute in ds.attribute_names {
		dump(attribute)
		// base action on whether the attribute is the class attribute, continuous, discrete, or to be ignored
		match true {
			i == ds.class_index {
				// rank the class attribute and use it to normalize the other rank values
				max_rank_value = rank_discrete_attribute(i, ds, opts)
			}
			i in ds.useful_continuous_attributes.keys() {
				// rank continuous attribute
				dump(rank_continuous_attribute(i, ds, opts))
				r_v, bin_number := rank_continuous_attribute(i, ds, opts)
				rank_value_map[attribute] = r_v
				binning_map[attribute] = bin_number
			}
			i in ds.useful_discrete_attributes.keys() {
				dump(ds.useful_discrete_attributes[i])
				rank_value_map[attribute] = rank_discrete_attribute(i, ds, opts)			}
			else {}
		}
	}
	dump(max_rank_value)
	dump(rank_value_map)
	dump(binning_map)
	return RankingResult{}
}

fn rank_discrete_attribute(i int, ds Dataset, opts Options) int {
		// values := ds.useful_continuous_attributes[i]
	mut weights := ds.class_counts.values()
	mut class_indices_by_case := []u8{len: ds.class_values.len, init: find(ds.classes,
		ds.class_values[index])}
	dump(class_indices_by_case)
	case_values := if i == ds.class_index {ds.class_values} else {ds.useful_discrete_attributes[i]}
	uniques_values := uniques(case_values)
	mut hits := [][]u8{len: ds.classes.len, init: []u8{len: uniques_values.len}}
	dump(uniques_values)
	// mut binning := []int{len: ds.class_values.len, init: 0}
	// the binning values are based on cycling through the cases
	for idx, case in case_values {
		uniques_index := find(uniques_values, case)
		hits[class_indices_by_case[idx]][uniques_index] += 1
	}
	dump(hits)
	return sum_absolute_differences(pairs(ds.classes.len), hits, weights, opts.weight_ranking_flag)
}

fn rank_continuous_attribute(i int, ds Dataset, opts Options) (int, int) {
	mut result := 0 
	mut max_rank_value := 0
	mut bins_for_max_rank_value := 0
	values := ds.useful_continuous_attributes[i]
	mut weights := ds.class_counts.values()
	mut class_indices_by_case := []u8{len: ds.class_values.len, init: find(ds.classes,
		ds.class_values[index])}
	for bin_number in opts.bins[0] .. opts.bins[1] + 1 {
		mut hits := [][]u8{len: ds.classes.len, init: []u8{len: bin_number + 1}}
		binning := discretize_attribute_with_range_check(values, array_min(values), array_max(values),
			bin_number)
		for j, val in binning {
			hits[class_indices_by_case[j]][val] += 1
		}
		// for each column in hits, sum up the absolute differences between each pair of values
		result = sum_absolute_differences(pairs(ds.classes.len), hits, weights, opts.weight_ranking_flag)
		if result > max_rank_value {
			max_rank_value = result
			bins_for_max_rank_value = bin_number
		}
	}
	return max_rank_value, bins_for_max_rank_value
}

fn sum_absolute_differences(pair_values [][]int, hits [][]u8, weights []int, weighting bool) int {
	mut rank_value := 0
	for k in pair_values {
		for m in 0 .. hits[0].len {
			if weighting {
				// dump('k: $k  m: $m   ${hits[k[0]][m]} ${weights[k[1]]}    ${hits[k[1]][m]} ${weights[k[0]]}')
				rank_value += abs_diff(hits[k[0]][m] * weights[k[1]], hits[k[1]][m] * weights[k[0]])
			} else {
				rank_value += abs_diff(hits[k[0]][m], hits[k[1]][m])
			}
		}
	}
	return rank_value
}

fn abs_diff[T](a T, b T) T {
	if a >= b {
		return a - b
	}
	return b - a
}

fn pairs(n int) [][]int {
	mut pair_list := [][]int{cap: n}
	for i in 0 .. n {
		for j in i + 1 .. n {
			pair_list << [i, j]
		}
	}
	return pair_list
}
