module vhammll

import math
// import vsl.plot

// RocPoint is a point on a Receiver Operating Characteristic curve,
// extending Point with the classifier identifiers that produced it.
struct RocPoint {
	Point
mut:
	classifier_ids []int
}

// Point is a 2D coordinate used for ROC plots:
// fpr is 1 − specificity (false positive rate); sens is sensitivity.
struct Point {
mut:
	fpr  f64 // 1 - specificity
	sens f64 // sensitivity
}

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

// AucClassifiers associates a set of classifier IDs with the
// Area Under the ROC Curve (AUC) value they jointly achieved.
struct AucClassifiers {
mut:
	classifier_ids []int
	auc            f64
}

// RocData holds the data for one ROC curve trace: the (sensitivity,
// specificity) pairs, the classifier description strings, the
// classifier ID arrays for each point, and an optional hover-text
// annotation.
struct RocData {
mut:
	coordinates    [][]f64
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

// roc_values takes a list of pairs of sensitivity and specificity values,
// along with the corresponding list of classifier ID's,
// and returns a list of Receiver Operating Characteristic plot points
// (sensitivity vs 1 - specificity).
pub fn roc_values(pairs [][]f64, classifier_ids [][]int) []RocPoint {
	if pairs.len < 1 {
		panic('no sensitivity/specificity pairs provided to roc_values()')
	}
	if pairs.len != classifier_ids.len {
		panic('mismatch between pairs and classifier_ids')
	}
	mut big_pairs := pairs.clone()
	mut big_classifiers := classifier_ids.clone()
	if [0.0, 1.0] !in pairs {
		big_pairs << [0.0, 1.0]
		big_classifiers << []int{}
	}
	mut roc_points := []RocPoint{cap: big_pairs.len}
	// Convert to FPR/sens and create points
	for i, p in big_pairs {
		roc_points << RocPoint{
			fpr:            1 - p[1] // Convert specificity to FPR
			sens:           p[0]     // Sensitivity = sens
			classifier_ids: big_classifiers[i]
		}
	}
	// Sort points by FPR ascending, then sens ascending
	custom_sort_fn := fn (a &RocPoint, b &RocPoint) int {
		if a.fpr == b.fpr {
			if a.sens < b.sens {
				return -1
			}
			if a.sens > b.sens {
				return 1
			}
			{
				return 0
			}
		}
		if a.fpr < b.fpr {
			return -1
		} else if a.fpr > b.fpr {
			return 1
		}
		return 0
	}
	roc_points.sort_with_compare(custom_sort_fn)
	// filter out points which are below and to the right of other points
	mut result := []RocPoint{cap: roc_points.len}
	result << roc_points[0]
	for point in roc_points[1..] {
		if point.sens >= array_max(result.map(it.sens)) {
			result << point
		}
	}
	points := result.map(it.Point)
	// if result does not include [1.0,1.0] then tack it on
	if Point{1, 1} !in points {
		result << RocPoint{Point{1, 1}, []}
	}
	return result
}

// auc_roc returns the area under the Receiver Operating Characteristic
// curve, for an array of points.
pub fn auc_roc(roc_points []RocPoint) f64 {
	if roc_points.len < 2 {
		panic('cannot calculate area_roc with fewer than 2 roc_points')
	}
	mut auc := f64(0)
	for i in 0 .. roc_points.len - 1 {
		// Calculate trapezoid area between consecutive points
		x1 := roc_points[i].fpr
		y1 := roc_points[i].sens
		x2 := roc_points[i + 1].fpr
		y2 := roc_points[i + 1].sens
		width := x2 - x1
		avg_height := (y1 + y2) / 2
		auc += width * avg_height
	}
	return auc
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
