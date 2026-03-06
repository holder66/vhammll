module vhammll

import math
// import vsl.plot

struct RankTrace {
mut:
	label              string
	rank_values        []f64
	maximum_rank_value f32
	hover_text         []string
}

struct ExploreTrace {
mut:
	label           string
	percents        []f64
	max_percents    f64
	attributes_used []f64
	bin_range       []string
	bin_for_sorting int
}

struct ROCResult {
	sensitivity           f64
	one_minus_specificity f64
	bin_range             string
	attributes_used       string
}

struct ROCTrace {
mut:
	x_coordinates                []f64
	y_coordinates                []f64
	area_under_curve             f64
	curve_series_variable_values string
	curve_variable_values        []string
}

// RocData holds the data for one ROC curve trace: the (sensitivity,
// specificity) pairs, the classifier description strings, the
// classifier ID arrays for each point, and an optional hover-text
// annotation.
pub struct RocData {
pub mut:
	pairs          [][]f64
	classifiers    []string
	classifier_ids [][]int
	trace_text     string
}

// RocFiles holds the file paths associated with a ROC plot:
// the training datafile, the test/verification file, and the
// classifier settings file used to generate the curves.
pub struct RocFiles {
pub mut:
	datafile     string
	testfile     string
	settingsfile string
}

// round_two_decimals
fn round_two_decimals(a f64) f64 {
	return math.round(a * 100.0) / 100.0
}

// filter takes two coordinated arrays. It filters array b
// to include only elements whose corresponding element
// in array a is equal to the match_value.
fn filter[T](match_value string, a []string, b []T) []T {
	mut result := []T{}
	for i, value in a {
		if match_value == value {
			result << b[i]
		}
	}
	return result
}

// filter_int takes two coordinated arrays. It filters array b
// to include only elements whose corresponding element
// in array a is equal to the match_value.
fn filter_int[T](match_value int, a []int, b []T) []T {
	mut result := []T{}
	for i, value in a {
		if match_value == value {
			result << b[i]
		}
	}
	return result
}

// area_under_curve calculates area under the curve
// as the areas of a series of rectangles and triangles
fn area_under_curve(x []f64, y []f64) f64 {
	mut area := 0.0
	mut b := 0.0
	if x.len != 0 {
		for i in 0 .. (x.len - 1) {
			b = (x[i + 1] - x[i])
			area += b * y[i] + 0.5 * b * (y[i + 1] - y[i])
		}
	}
	return area
}
