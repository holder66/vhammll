// rank_switches_test.v
module vhammll

// Tests for count_switches and the -sw / -swt behaviour in rank_attributes.

// ---------------------------------------------------------------------------
// count_switches — pure unit tests using hand-constructed hits arrays
// ---------------------------------------------------------------------------

fn test_count_switches_non_two_class() {
	// Returns -1 for anything other than exactly 2 classes
	assert count_switches([], [], false) == -1
	assert count_switches([[1, 2, 3]], [10], false) == -1
	assert count_switches([[1, 2], [3, 4], [5, 6]], [10, 10, 10], false) == -1
}

fn test_count_switches_all_empty_or_tied() {
	// All bins empty → 0
	assert count_switches([[0, 0, 0], [0, 0, 0]], [0, 0], false) == 0
	// All bins tied → 0
	assert count_switches([[0, 5, 5], [0, 5, 5]], [10, 10], false) == 0
}

fn test_count_switches_bin0_skipped() {
	// Bin 0 holds missing values and must never influence the count.
	// Class 0 "wins" bin 0 massively but that should be ignored;
	// only bin 1 is non-empty and class 1 wins there → 0 switches.
	assert count_switches([[100, 2], [0, 8]], [102, 8], false) == 0
}

fn test_count_switches_zero_switches() {
	// One class wins every non-empty bin → 0 switches
	// hits[0]=[0,10,8,5], hits[1]=[0,2,3,4] — class 0 wins bins 1-3
	assert count_switches([[0, 10, 8, 5], [0, 2, 3, 4]], [23, 9], false) == 0
}

fn test_count_switches_one_switch() {
	// Clean monotone threshold: class 0 wins low bins, class 1 wins high bins
	// hits[0]=[0,10,8,2,1], hits[1]=[0,1,2,8,10]
	assert count_switches([[0, 10, 8, 2, 1], [0, 1, 2, 8, 10]], [21, 21], false) == 1
}

fn test_count_switches_two_switches() {
	// U-shaped: class 0 wins bin 1, class 1 wins bin 2, class 0 wins bin 3
	assert count_switches([[0, 10, 2, 10], [0, 1, 8, 1]], [22, 10], false) == 2
}

fn test_count_switches_three_switches() {
	// Fully alternating over 4 bins → 3 switches
	assert count_switches([[0, 8, 1, 8, 1], [0, 1, 8, 1, 8]], [18, 18], false) == 3
}

fn test_count_switches_ties_skipped() {
	// bin 1: class 0 wins; bin 2: tie (skipped); bin 3: class 1 wins → 1 switch
	assert count_switches([[0, 5, 5, 3], [0, 3, 5, 5]], [13, 13], false) == 1
}

fn test_count_switches_empty_bins_skipped() {
	// bin 1: class 0 wins; bins 2 and 3: both zero (skipped); bin 4: class 1 wins → 1 switch
	assert count_switches([[0, 10, 0, 0, 0], [0, 0, 0, 0, 8]], [10, 8], false) == 1
}

fn test_count_switches_weighting() {
	// hits[0]=[0,3,8], hits[1]=[0,10,1], weights=[100,5]
	//
	// Unweighted:
	//   bin 1: 3 vs 10  → class 1 wins
	//   bin 2: 8 vs 1   → class 0 wins  → 1 switch
	//
	// Weighted (cross-multiply by other class's total count):
	//   bin 1: eff0 = 3*5=15,  eff1 = 10*100=1000 → class 1 wins
	//   bin 2: eff0 = 8*5=40,  eff1 =  1*100= 100 → class 1 wins → 0 switches
	assert count_switches([[0, 3, 8], [0, 10, 1]], [100, 5], false) == 1
	assert count_switches([[0, 3, 8], [0, 10, 1]], [100, 5], true) == 0
}

// ---------------------------------------------------------------------------
// rank_attributes — integration tests for -sw / -swt behaviour
// ---------------------------------------------------------------------------

fn test_rank_attributes_no_switches_flag() {
	// Without -sw the old algorithm is used: switches fields stay at their
	// default sentinel value (-1) and switches_array is empty for all attributes.
	result := rank_attributes(opts('-wr -b 2,6 datasets/2_class_developer.tab',
		cmd: 'rank'))
	assert result.switches_flag == false
	for attr in result.array_of_ranked_attributes {
		assert attr.switches == -1
		assert attr.switches_array.len == 0
	}
}

fn test_rank_attributes_switches_flag_two_class() {
	// With -sw on a 2-class dataset:
	//   • continuous attributes get a switches_array with one entry per bin count
	//   • switches holds the count at the selected bin count (≥0), or -1 if every
	//     bin count exceeded the threshold
	//   • discrete attributes remain at -1 / empty
	// Bin range 2..6 → 5 bin counts tested.
	result := rank_attributes(opts('-sw -wr -b 2,6 datasets/2_class_developer.tab',
		cmd: 'rank'))
	assert result.switches_flag == true
	assert result.switches_threshold == 2 // default
	for attr in result.array_of_ranked_attributes {
		if attr.attribute_type == 'C' {
			assert attr.switches_array.len == 5
			assert attr.switches >= -1 // -1 only when all bin counts exceeded threshold
		} else {
			assert attr.switches == -1
			assert attr.switches_array.len == 0
		}
	}
}

fn test_rank_attributes_switches_flag_multiclass() {
	// -sw has no effect on multi-class datasets; switches stays -1 everywhere.
	result := rank_attributes(opts('-sw -wr -b 2,6 datasets/iris.tab', cmd: 'rank'))
	assert result.switches_flag == true
	for attr in result.array_of_ranked_attributes {
		assert attr.switches == -1
	}
}

fn test_rank_attributes_switches_loose_threshold_matches_old() {
	// A threshold well above the maximum possible switch count (bin-count − 1)
	// makes every bin count eligible, so rank values must equal the old algorithm.
	// Upper limit is 6, max switches for 6 bins = 5; -swt 16 is clamped to 6.
	result_loose := rank_attributes(opts('-sw -swt 16 -wr -b 2,6 datasets/2_class_developer.tab',
		cmd: 'rank'))
	result_old := rank_attributes(opts('-wr -b 2,6 datasets/2_class_developer.tab',
		cmd: 'rank'))
	assert result_loose.array_of_ranked_attributes.len == result_old.array_of_ranked_attributes.len
	for i, attr in result_loose.array_of_ranked_attributes {
		assert attr.rank_value == result_old.array_of_ranked_attributes[i].rank_value
	}
	// With a loose threshold all continuous attributes should have switches >= 0
	for attr in result_loose.array_of_ranked_attributes {
		if attr.attribute_type == 'C' {
			assert attr.switches >= 0
		}
	}
}

fn test_rank_attributes_switches_threshold_one() {
	// With threshold=1 (strict), no bin count with more than 1 switch may be
	// selected; any attribute that does receive a switches value must have it ≤ 1.
	result := rank_attributes(opts('-sw -swt 1 -wr -b 2,6 datasets/2_class_developer.tab',
		cmd: 'rank'))
	assert result.switches_threshold == 1
	for attr in result.array_of_ranked_attributes {
		if attr.attribute_type == 'C' && attr.switches != -1 {
			assert attr.switches <= 1
		}
	}
}

fn test_rank_attributes_switches_threshold_stored_in_result() {
	// The threshold value used is recorded in RankingResult for display.
	result := rank_attributes(opts('-sw -swt 3 -b 2,8 datasets/2_class_developer.tab',
		cmd: 'rank'))
	assert result.switches_flag == true
	assert result.switches_threshold == 3
}
