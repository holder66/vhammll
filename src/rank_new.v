// rank_new.v

module vhammll

import maps

struct RankValue {
mut:
	attr_indx  int
	rank_value i64
	bin_no     int
}

pub fn rank_attributes(ds Dataset, opts Options) RankingResult {
	mut result := RankingResult{
		LoadOptions:                ds.LoadOptions
		DisplaySettings:            opts.DisplaySettings
		path:                       ds.path
		binning:                    get_binning(opts.bins)
		exclude_flag:               opts.exclude_flag
		weight_ranking_flag:        opts.weight_ranking_flag
		array_of_ranked_attributes: []RankedAttribute{cap: ds.useful_discrete_attributes.len +
			ds.useful_continuous_attributes.len}
	}
	mut rank_value_map := map[int]i64{}
	mut binning_map := map[int]int{}
	mut rank_value_array_map := map[int][]i64{}
	mut max_rank_value := f32(0)
	// for each attribute in the dataset
	for i, _ in ds.attribute_names {
		// base action on whether the attribute is the class attribute, continuous, discrete, or to be ignored
		match true {
			i == ds.class_index {
				// rank the class attribute and use it to normalize the other rank values
				max_rank_value = f32(rank_discrete_attribute(i, ds, opts))
			}
			i in ds.useful_continuous_attributes.keys() {
				r_v, bin_number, rank_value_array := rank_continuous_attribute(i, ds,
					opts)
				rank_value_map[i] = r_v
				binning_map[i] = bin_number
				rank_value_array_map[i] = rank_value_array
			}
			i in ds.useful_discrete_attributes.keys() {
				rank_value_map[i] = rank_discrete_attribute(i, ds, opts)
			}
			else {}
		}
	}
	mut rank_values_array := maps.to_array(rank_value_map, fn (k int, v i64) RankValue {
		return RankValue{
			attr_indx:  k
			rank_value: v
		}
	})
	for mut rank_value in rank_values_array {
		rank_value.bin_no = binning_map[rank_value.attr_indx]
	}
	// custom sort on descending rank value, then ascending bins, then index
	custom_sort_fn := fn (a &RankValue, b &RankValue) int {
		if a.rank_value > b.rank_value {
			return -1
		}
		if a.rank_value < b.rank_value {
			return 1
		}
		if a.rank_value == b.rank_value {
			if a.bin_no > b.bin_no {
				return 1
			}
			if a.bin_no < b.bin_no {
				return -1
			}
			if a.bin_no == b.bin_no {
				if a.attr_indx < b.attr_indx {
					return -1
				}
				return 1
			}
			return 0
		}
		return 0
	}
	rank_values_array.sort_with_compare(custom_sort_fn)
	// rank_values_array.sort(a.rank_value > b.rank_value)
	for attr in rank_values_array {
		result.array_of_ranked_attributes << RankedAttribute{
			attribute_index:  attr.attr_indx
			attribute_name:   ds.attribute_names[attr.attr_indx]
			attribute_type:   ds.attribute_types[attr.attr_indx]
			rank_value:       100.0 * f32(attr.rank_value) / max_rank_value
			rank_value_array: rank_value_array_map[attr.attr_indx].map(100.0 * f32(it) / max_rank_value).reverse()
			bins:             attr.bin_no
		}
	}
	if (opts.show_flag || opts.expanded_flag) && opts.command == 'rank' {
		show_rank_attributes(result)
	}
	if opts.graph_flag && opts.command == 'rank' {
		plot_rank(result)
	}
	if opts.outputfile_path != '' {
		save_json_file[RankingResult](result, opts.outputfile_path)
	}
	return result
}

// rank_discrete_attribute returns a rank value for attribute i.
fn rank_discrete_attribute(i int, ds Dataset, opts Options) int {
	mut weights := ds.class_counts.values()
	mut class_indices_by_case := []u8{len: ds.class_values.len, init: find(ds.classes,
		ds.class_values[index])}
	case_values := if i == ds.class_index {
		ds.class_values
	} else {
		ds.useful_discrete_attributes[i]
	}
	uniques_values := uniques(case_values)
	mut hits := [][]u8{len: ds.classes.len, init: []u8{len: uniques_values.len}}
	for idx, case in case_values {
		if case in opts.missings && opts.exclude_flag {
			continue
		}
		uniques_index := find(uniques_values, case)
		hits[class_indices_by_case[idx]][uniques_index] += 1
	}
	return sum_absolute_differences(pairs(ds.classes.len), hits, weights, opts.weight_ranking_flag)
}

// rank_continuous_attribute calculates rank values for attribute i over a range of bin values given
// by opts.bins. It returns the maximum rank value found and the corresponding number of bins.
fn rank_continuous_attribute(i int, ds Dataset, opts Options) (int, int, []i64) {
	mut result := 0
	mut max_rank_value := 0
	mut bins_for_max_rank_value := 0
	mut rank_value_array := []i64{}
	values := ds.useful_continuous_attributes[i]
	mut weights := ds.class_counts.values()
	mut class_indices_by_case := []u8{len: ds.class_values.len, init: find(ds.classes,
		ds.class_values[index])}
	for bin_number in opts.bins[0] .. opts.bins[1] + 1 {
		mut hits := [][]u8{len: ds.classes.len, init: []u8{len: bin_number + 1}}
		binning := discretize_attribute_with_range_check(values, array_min(values), array_max(values),
			bin_number)
		for j, val in binning {
			if val == 0 && opts.exclude_flag {
				continue
			}
			hits[class_indices_by_case[j]][val] += 1
		}
		// for each column in hits, sum up the absolute differences between each pair of values
		result = sum_absolute_differences(pairs(ds.classes.len), hits, weights, opts.weight_ranking_flag)
		rank_value_array << result
		if result > max_rank_value {
			max_rank_value = result
			bins_for_max_rank_value = bin_number
		}
	}
	return max_rank_value, bins_for_max_rank_value, rank_value_array
}

// sum_absolute_differences sums up the absolute differences for each pair of entries in the hits list.
// if the weight_ranking_flag is set, the hits on either side of each pair are first multiplied by the
// prevalence of the class on the other side of the pair.
fn sum_absolute_differences(pair_values [][]int, hits [][]u8, weights []int, weighting bool) int {
	mut rank_value := 0
	for k in pair_values {
		for m in 0 .. hits[0].len {
			if weighting {
				rank_value += abs_diff(hits[k[0]][m] * weights[k[1]], hits[k[1]][m] * weights[k[0]])
			} else {
				rank_value += abs_diff(hits[k[0]][m], hits[k[1]][m])
			}
		}
	}
	return rank_value
}

// abs_diff returns the absolute value of the difference between two numbers.
fn abs_diff[T](a T, b T) T {
	if a >= b {
		return a - b
	}
	return b - a
}

// pairs generates a list of permutations of the digits from 0 up to and including n, taken two at a time.
// Example: assert pairs(3) == [[0, 1], [0, 2], [1, 2]]
fn pairs(n int) [][]int {
	mut pair_list := [][]int{cap: n}
	for i in 0 .. n {
		for j in i + 1 .. n {
			pair_list << [i, j]
		}
	}
	return pair_list
}
