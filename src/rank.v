module vhammll

import maps

struct RankValue {
mut:
	attr_indx  int
	rank_value i64
	bin_no     int
	switches   int
}

const rank_help = '
Description:
  "rank" rank orders a dataset\'s attributes in terms of ability 
to distinguish between classes; it takes into account class prevalences.

Usage: `v run main.v rank <options> <path_to_dataset_file>`

Example: `v run .main.v rank -b 3,6 -x -wr datasets/iris.tab`

Options: 
  -b --bins, eg, "3,6" specifies the lower and upper limits for the number 
      of slices or bins for continuous attributes [Options.bins]
  -x --exclude, exclude missing values from rank value calculations [Parameters.exclude_flag]
  -g --graph, produce a plot showing rank values vs number of bins for   
      continuous attributes [DisplaySettings.graph_flag]
  -l --limit-output, followed by an integer which specifies how many
  		attributes should be included in the console listing [DisplaySettings.limit_output]
  -of --overfitting, console output and graph to include information
  		allowing for an assessment of overfitting likelihood [DisplaySettings.overfitting_flag]
  -exr --explore-rank, followed by eg "2,7", will repeat the ranking
  		exercise over the binning range from 2 through 7 [Options.explore_rank]
  -u --uniform, uses uniform binning over all attributes [Parameters.uniform_bins]
  -w --weight, weights and normalizes the graph of hits per bin per class (see -of option)
  -wr, weight contribution to ranking by considering class
      prevalences [Parameters.weight_ranking_flag]
  -sw --switches, enables the dominant-class switch metric for 2-class
      datasets: bin counts whose switch count exceeds the threshold are
      excluded when searching for the maximum rank value; attributes where
      every bin count exceeds the threshold receive rank value 0 [Parameters.switches_flag]
  -swt --switch-threshold, followed by an integer (default 2, min 1, max
      upper binning limit); sets the switch count threshold used when -sw is
      active [Parameters.switches_threshold]

    '

// rank_attributes takes a Dataset and returns a list of all the
// dataset's usable attributes, ranked in order of each attribute's
// ability to separate the classes.
// ```
// Algorithm:
// for each attribute:
// 	create a matrix with attribute values for row headers, and
// 	class values for column headers;
// 	for each unique value `val` for that attribute:
// 		for each unique value `class` of the class attribute:
// 			for each instance:
// 				accumulate a count for those instances whose class value
// 				equals `class`;
// 				populate the matrix with these accumulated counts;
// 	for each `val`:
// 		get the absolute values of the differences between accumulated
// 		counts for each pair of `class` values`;
// 		add those absolute differences;
// 	total those added absolute differences to get the raw rank value
// for that attribute.
// To obtain rank values weighted by class prevalences, use the same algorithm
// except before taking the difference of each pair of accumulated counts,
// multiply each count of the pair by the class prevalence of the other class.
// (Note: rank_attributes always uses class prevalences as weights)
//
// Obtain a maximum rank value by calculating a rank value for the class
// attribute itself.
//
// To obtain normalized rank values:
// for each attribute:
// 	divide its raw rank value by the maximum rank value and multiply by 100.
//
// Sort the attributes by descending rank values.
// ```
//
// ```sh
// Options:
// `binning`: specifies the range for binning (slicing) continous attributes;
// `weight_ranking_flag`: appplies prevalences of each class in calculating rankings;
// `exclude_flag`: exclude missing values when calculating rank values;
// `explore_rank`: gives start and end values for maximum binning number to be
//     over an exploration of ranking for different binning values;
//
// Output options:
// `show_flag`: print the ranked list to the console;
// `graph_flag`: generate plots of rank values for each attribute on the
//     y axis, with number of bins on the x axis.
// `overfitting_flag`: generates metrics/plots to help determine, for continuous
//     attributes, whether overfitting is occurring.
// `weighting_flag`: for the hits per bin graph produced by the overfitting flag,
//     weights and normalizes the hits.
// `outputfile_path`: saves the result as json.
// ```
pub fn rank_attributes(opts Options) RankingResult {
	ds := load_file(opts.datafile_path, opts.LoadOptions)
	mut result := RankingResult{
		Class:                      ds.Class
		LoadOptions:                ds.LoadOptions
		DisplaySettings:            opts.DisplaySettings
		path:                       ds.path
		exclude_flag:               opts.exclude_flag
		weight_ranking_flag:        opts.weight_ranking_flag
		switches_flag:              opts.switches_flag
		switches_threshold:         opts.switches_threshold
		array_of_ranked_attributes: []RankedAttribute{cap: ds.useful_discrete_attributes.len +
			ds.useful_continuous_attributes.len}
	}
	mut binning := Binning{}
	if ds.useful_continuous_attributes.len != 0 {
		if opts.binning.lower > 0 {
			binning = opts.binning
		} else {
			binning = get_binning(opts.bins)
		}
	}
	result.binning = binning
	mut rank_value_map := map[int]i64{}
	mut binning_map := map[int]int{}
	mut rank_value_array_map := map[int][]i64{}
	mut hits_array_map := map[int][][][]int{}
	mut switches_map := map[int]int{}
	mut switches_array_map := map[int][]int{}
	mut highest_rank_value := i64(0) // as generated by the class attribute, used for normalizing other values
	mut array_of_hits_arrays := [][][]int{}
	// for each attribute in the dataset
	for i in 0 .. ds.attribute_names.len {
		// base action on whether the attribute is the class attribute, continuous, discrete, or to be ignored
		match true {
			i == ds.class_index {
				// rank the class attribute and use it to normalize the other rank values
				highest_rank_value = rank_discrete_attribute(i, ds, opts)
			}
			i in ds.useful_continuous_attributes.keys() {
				r_v, bin_number, rank_value_array, hits_array, sw, sw_arr := rank_continuous_attribute(i,
					ds, binning, opts.exclude_flag, opts.weight_ranking_flag, opts.overfitting_flag,
					opts.switches_flag, opts.switches_threshold)
				rank_value_map[i] = r_v
				binning_map[i] = bin_number
				rank_value_array_map[i] = rank_value_array
				hits_array_map[i] = hits_array
				switches_map[i] = sw
				switches_array_map[i] = sw_arr
				array_of_hits_arrays << hits_array
			}
			i in ds.useful_discrete_attributes.keys() {
				rank_value_map[i] = rank_discrete_attribute(i, ds, opts)
				switches_map[i] = -1 // switch count not applicable for discrete attributes
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
		rank_value.switches = switches_map[rank_value.attr_indx]
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
			attribute_index:      attr.attr_indx
			attribute_name:       ds.attribute_names[attr.attr_indx]
			attribute_type:       ds.attribute_types[attr.attr_indx]
			rank_value:           f32(100.0 * f64(attr.rank_value) / highest_rank_value)
			rank_value_array:     rank_value_array_map[attr.attr_indx].map(f32(100.0 * f64(it) / highest_rank_value)).reverse()
			bins:                 attr.bin_no
			array_of_hits_arrays: hits_array_map[attr.attr_indx]
			switches:             attr.switches
			switches_array:       switches_array_map[attr.attr_indx]
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
	if opts.overfitting_flag && opts.command == 'rank' {
		for n, attr in result.array_of_ranked_attributes {
			if opts.limit_output != 0 && n >= opts.limit_output {
				break
			}
			plot_hits(result.Class, attr, opts.weighting_flag)
		}
	}
	return result
}

// get_rank_value_for_strings
fn get_rank_value_for_strings(values []string, class_values []string, class_counts map[string]int, opts Options) i64 {
	// println('values: $values  class_values: $class_values  class_counts: $class_counts')
	mut rank_val := i64(0)
	mut count := 0
	mut row := []int{}
	for unique_val, _ in element_counts(values) {
		if unique_val in opts.missings && opts.exclude_flag {
			continue
		}
		row = []int{}
		// loop through classes
		for class, _ in class_counts {
			// at this point, we have the columns and rows we need
			// now to populate it
			count = 0
			for i, val in values {
				if val == unique_val && class_values[i] == class {
					count += 1
				}
			}
			row << count
		}
		if opts.weight_ranking_flag {
			rank_val += sum_along_row_weighted(row, class_counts.values())
		} else {
			rank_val += sum_along_row_unweighted(row)
		}
	}
	return rank_val
}

// rank_discrete_attribute returns a rank value for attribute i.
fn rank_discrete_attribute(i int, ds Dataset, opts Options) int {
	mut weights := ds.class_counts.values()
	mut class_indices_by_case := []int{len: ds.class_values.len, init: find(ds.classes,
		ds.class_values[index])}
	case_values := if i == ds.class_index {
		ds.class_values
	} else {
		ds.useful_discrete_attributes[i]
	}
	uniques_values := uniques(case_values)
	mut hits := [][]int{len: ds.classes.len, init: []int{len: uniques_values.len}}
	for idx, case in case_values {
		if case in opts.missings && opts.exclude_flag {
			continue
		}
		uniques_index := find(uniques_values, case)
		hits[class_indices_by_case[idx]][uniques_index] += 1
	}
	return sum_absolute_differences(pairs(ds.classes.len), hits, weights, opts.weight_ranking_flag)
}

// rank_continuous_attribute calculates rank values for attribute i over a range
// of bin values given by binning_range. When switches_flag is true and the
// dataset has exactly 2 classes, the dominant-class switch count is computed
// for each bin number and bin counts whose switch count exceeds
// switches_threshold are excluded from the search for the maximum rank value;
// an attribute where every bin count exceeds the threshold receives rank value
// 0. switches_threshold is clamped to [1, binning_range.upper]. When
// switches_flag is false, or for multi-class datasets, every bin count is
// eligible (original behaviour). Returns the best rank value, the
// corresponding bin count, rank values for all bin counts, the full hits
// array, the switch count at the best bin count, and switch counts for all
// bin counts.
fn rank_continuous_attribute(i int, ds Dataset, binning_range Binning, exclude_flag bool, weight_ranking_flag bool, overfitting_flag bool, switches_flag bool, switches_threshold int) (int, int, []i64, [][][]int, int, []int) {
	mut result := 0
	mut max_rank_value := 0
	mut bins_for_max_rank_value := 0
	mut switches_at_best := -1
	mut rank_value_array := []i64{}
	mut switches_array := []int{}
	values := ds.useful_continuous_attributes[i]
	mut weights := ds.class_counts.values()
	mut class_indices_by_case := []int{len: ds.class_values.len, init: find(ds.classes,
		ds.class_values[index])}
	mut hits_array := [][][]int{cap: binning_range.upper}
	two_class := ds.classes.len == 2
	// Clamp threshold to the valid range [1, binning_range.upper].
	effective_threshold := if switches_flag {
		if switches_threshold < 1 {
			1
		} else if switches_threshold > binning_range.upper {
			binning_range.upper
		} else {
			switches_threshold
		}
	} else {
		0 // unused when switches_flag is false
	}
	for bin_number in binning_range.lower .. binning_range.upper + 1 {
		mut hits := [][]int{len: ds.classes.len, init: []int{len: bin_number + 1}}
		binning := discretize_attribute_with_range_check(values, array_min(values.filter(!is_nan(it))),
			array_max(values.filter(!is_nan(it))), bin_number)
		for j, val in binning {
			if val == 0 && exclude_flag {
				continue
			}
			hits[class_indices_by_case[j]][val] += 1
		}
		// if overfitting_flag {
		// 	dump('${i}    ${hits}')
		// 	graph_hits(i, hits)
		// }
		// for each column in hits, sum up the absolute differences between each pair of values
		result = sum_absolute_differences(pairs(ds.classes.len), hits, weights, weight_ranking_flag)
		rank_value_array << result
		// Only compute switch counts when the flag is active and the dataset
		// has exactly 2 classes; otherwise leave sw at -1 (not applicable).
		sw := if switches_flag && two_class {
			count_switches(hits, weights, weight_ranking_flag)
		} else {
			-1
		}
		if switches_flag && two_class {
			switches_array << sw
		}
		// A bin count is eligible for the maximum rank value unless switches_flag
		// is active on a 2-class dataset and its switch count exceeds the
		// (clamped) threshold. Multi-class datasets are always fully eligible.
		eligible := !switches_flag || !two_class || sw <= effective_threshold
		if eligible && result > max_rank_value {
			max_rank_value = result
			bins_for_max_rank_value = bin_number
			switches_at_best = sw
		}
		hits_array << hits
	}
	// If switches_flag is true, two_class, and no eligible bin count was found,
	// max_rank_value remains 0, signalling this attribute should not be used.
	return max_rank_value, bins_for_max_rank_value, rank_value_array, hits_array, switches_at_best, switches_array
}

// sum_absolute_differences sums up the absolute differences for each pair of entries in the hits list.
// if the weight_ranking_flag is set, the hits on either side of each pair are first multiplied by the
// prevalence of the class on the other side of the pair.
fn sum_absolute_differences(pair_values [][]int, hits [][]int, weights []int, weighting bool) int {
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

// sum_along_row_weighted returns the sum of the absolute values of
// the differences between counts multiplied by the class count for
// every combination pair of classes
fn sum_along_row_weighted(row []int, class_counts_array []int) i64 {
	mut row_sum := 0
	mut diff := 0
	for i, count1 in row#[..-1] {
		for j, count2 in row[i + 1..] {
			diff = count1 * class_counts_array[i + j + 1] - count2 * class_counts_array[i]
			// println('${i} ${j} ${count1} ${count2} ${class_counts_array[i + j + 1]} ${class_counts_array[i]}')
			if diff < 0 {
				diff *= -1
			}
			row_sum += diff
		}
	}
	// println('row_sum: $row_sum')
	return row_sum
}

// sum_along_row_unweighted returns the sum of the absolute values of
// the differences between counts
fn sum_along_row_unweighted(row []int) i64 {
	mut row_sum := 0
	mut diff := 0
	for i, count1 in row {
		for count2 in row[i + 1..] {
			diff = count1 - count2
			if diff < 0 {
				diff *= -1
			}
			row_sum += diff
		}
	}
	// println('row_sum: $row_sum')
	return row_sum
}

// abs_diff returns the absolute value of the difference between two numbers.
fn abs_diff[T](a T, b T) T {
	if a >= b {
		return a - b
	}
	return b - a
}

// count_switches counts how many times the dominant class flips as bins are
// traversed from 1 to the last bin (bin 0, used for missing values, is always
// skipped). Empty bins and tied bins are skipped — they carry no directional
// information. If weight_ranking_flag is true, each class's hit count is
// cross-multiplied by the other class's total prevalence before comparison,
// consistent with the weighting used in sum_absolute_differences. Returns -1
// for datasets with more than 2 classes (metric not applicable).
fn count_switches(hits [][]int, weights []int, weighting bool) int {
	if hits.len != 2 {
		return -1
	}
	mut prev_winner := -1
	mut switches := 0
	for b in 1 .. hits[0].len {
		eff0 := if weighting { hits[0][b] * weights[1] } else { hits[0][b] }
		eff1 := if weighting { hits[1][b] * weights[0] } else { hits[1][b] }
		if eff0 == eff1 {
			continue // empty bin or tie — no directional information
		}
		winner := if eff0 > eff1 { 0 } else { 1 }
		if prev_winner != -1 && winner != prev_winner {
			switches += 1
		}
		prev_winner = winner
	}
	return switches
}

// pairs generates a list of combinations of the digits from 0 up to and including n, taken two at a time.
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
