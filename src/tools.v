// v contains functions used elsewhere in hamnn
module vhammll

import math
import chalk
import math.unsigned
import arrays

// roc_values takes a list of pairs of sensitivity and specificity values,
// along with the corresponding list of classifier ID's,
// and returns a list of Receiver Operating Characteristic plot points
// (sensitivity vs 1 - specificity).
pub fn roc_values(pairs [][]f64, classifier_ids [][]int) []RocPoint {
	if pairs.len < 1 {
		panic('no sensitivity/specificity pairs provided to roc_values()')
	}
	if pairs.len != classifier_ids.len {
		panic('mismatch between pairs and classifiers')
	}
	mut big_pairs := pairs.clone()
	mut big_classifiers := classifier_ids.map('${it}')
	if [0.0, 1.0] !in pairs {
		big_pairs << [0.0, 1.0]
		big_classifiers << ''
	}
	mut roc_points := []RocPoint{cap: big_pairs.len}
	// Convert to FPR/sens and create points
	for i, p in big_pairs {
		roc_points << RocPoint{
			fpr:         1 - p[1] // Convert specificity to FPR
			sens:        p[0]     // Sensitivity = sens
			classifiers: big_classifiers[i]
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
		result << RocPoint{Point{1, 1}, '', []}
	}
	return result
}

// auc_roc returns the area under the Receiver Operating Characteristic
// curve, for an array of points.
pub fn auc_roc(points []Point) f64 {
	if points.len < 2 {
		panic('cannot calculate area_roc with fewer than 2 points')
	}
	mut auc := f64(0)
	for i in 0 .. points.len - 1 {
		// Calculate trapezoid area between consecutive points
		x1 := points[i].fpr
		y1 := points[i].sens
		x2 := points[i + 1].fpr
		y2 := points[i + 1].sens
		width := x2 - x1
		avg_height := (y1 + y2) / 2
		auc += width * avg_height
	}
	return auc
}

fn combinations[T](arr []T, limits CombinationSizeLimits) [][]T {
	if arr == [] {
		panic("can't make combinations from an empty array!")
	}

	max := if limits.max == 0 { arr.len } else { limits.max }
	mut result := [][]T{}
	n := arr.len
	for size in limits.min .. max + 1 {
		mut indices := []int{len: size}
		for i in 0 .. size {
			indices[i] = i
		}
		for {
			mut combo := []T{len: size}
			for i, idx in indices {
				combo[i] = arr[idx]
			}
			result << combo
			mut i := size - 1
			for i >= 0 && indices[i] == n - size + i {
				i--
			}
			if i < 0 {
				break
			}
			indices[i]++
			for j in i + 1 .. size {
				indices[j] = indices[j - 1] + 1
			}
		}
	}
	return result
}

// idx_true returns the index of the first true element in boolean array a.
// Returns -1 if no true element found.
fn idx_true(a []bool) int {
	for i, val in a {
		if val {
			return i
		}
	}
	return -1
}

// transpose a 2d array
pub fn transpose[T](matrix [][]T) [][]T {
	mut matrix_t := [][]T{len: matrix[0].len, init: []T{len: matrix.len}}
	for i, row_element in matrix {
		for j, col_element in row_element {
			matrix_t[j][i] = col_element
		}
	}
	return matrix_t
}

fn element_counts[T](array []T) map[T]int {
	mut counts := map[T]int{}
	for element in array {
		counts[element]++
	}
	return counts
}

// parse_range takes a string like '3,6,8' and returns [3, 6, 8]
fn parse_range(arg string) []int {
	if arg == '' {
		return [0]
	}
	return arg.split(',').map(it.int())
}

// parse_paths takes a string of file paths separated by commas
// and returns an array of strings, one per path
fn parse_paths(arg string) []string {
	if arg == '' {
		return []string{len: 0}
	}
	return arg.split(',').map(it)
}

// print_array
fn print_array(array []string) {
	for line in array {
		println(line)
	}
}

// discretize_attribute_with_range_check takes an array of generic attribute values, as
// well as minimum and maximum values for that attribute, and the number of bins to use.
// Bin numbering starts at 1, as bin 0 is used for missing values).
// If the value to be binned is a nan (ie a missing value, or if it is outside of the
// range given by min and max), the assigned bin number will be zero.
fn discretize_attribute_with_range_check[T](values []T, min T, max T, bins int) []int {
	mut bin_values := []int{cap: values.len}
	for val in values {
		match true {
			is_nan(val) || val > max || val < min { bin_values << 0 }
			val == max { bin_values << bins }
			else { bin_values << int((val - min) / ((max - min) / bins)) + 1 }
		}
	}
	return bin_values
}

// bin_values_array
fn bin_values_array[T](values []T, min T, max T, bins int) []u8 {
	bin_size := (max - min) / bins
	mut bin_values := []u8{}
	mut bin := u8(0)
	for value in values {
		if is_nan(value) { // ie, a missing value
			bin = u8(0)
		} else if value == max {
			bin = u8(bins)
		} else {
			bin = u8(int((value - min) / bin_size) + 1)
		}
		bin_values << bin
	}
	return bin_values
}

// bin_single_value
fn bin_single_value[T](value T, min T, max T, bins int) u8 {
	bin_size := (max - min) / bins
	mut bin := u8(0)
	if is_nan(value) {
		bin = u8(0)
	} else if value == max {
		bin = u8(bins)
	} else {
		bin = u8(int((value - min) / bin_size) + 1)
	}
	return bin
}

// convert_to_one_bit
fn convert_to_one_bit(value int) u32 {
	mut one_bit := u32(0)
	if value == 1 {
		one_bit = u32(1)
	} else if value > 1 {
		one_bit = 1 << value
	}
	return one_bit
}

// hamming_distance returns the Hamming distance between two arrays of bit
// values; it is predicated on each value having at most one bit set.
fn hamming_distance(a []u32, b []u32) int {
	mut sum := 0
	for i in 0 .. a.len {
		mut d := 0
		if a[i] ^ b[i] != 0 {
			if a[i] != 0 && b[i] != 0 {
				d = 2
			} else {
				d = 1
			}
		}
		sum += d
	}
	return sum
}

// Euclidean algorithm to calculate gcd, used for getting lcm
fn gcd(a i64, b i64) i64 {
	if b == 0 || a == b {
		return a
	}
	mut a1 := a
	mut b1 := b
	for a1 % b1 > 0 {
		r := a1 % b1
		a1 = b1
		b1 = r
	}
	return b1
}

// Euclidean algorithm to calculate gcd, using Uint128
fn gcd_u128(a unsigned.Uint128, b unsigned.Uint128) unsigned.Uint128 {
	mut zero := unsigned.Uint128{}
	if b == zero || a == b {
		return a
	}
	mut a1 := a
	mut b1 := b
	for a1.mod(b1) > zero {
		r := a1.mod(b1)
		a1 = b1
		b1 = r
	}
	return b1
}

// least common multiple, using gcd; returns 0 if the lcd
// cannot be calculated because of overflow
fn lcm(arr []int) i64 {
	mut res := i64(1)
	for a in arr {
		res *= i64(a) / gcd(res, i64(a))
	}
	// since for large or many arguments, overflow may occur, test
	for a in arr {
		if res % a != 0 {
			return 0
		}
	}
	return res
}

// least common multiple, using gcd; returns 0 if the lcd
// cannot be calculated because of overflow. This version uses Uint128
// The places where it's needed, ie the mnist datasets, we can't use
// it (2025-4-5) because it would require wideranging changes to the structs
// that contain lcm, as well as all the code that uses lcm.
fn lcm_u128(arr []int) unsigned.Uint128 {
	mut res := unsigned.Uint128{1, 0}
	for a in arr {
		au128 := unsigned.Uint128{u64(a), 0}
		res = res * au128 / gcd_u128(res, au128)
	}
	// test for overflow
	for a in arr {
		if res.mod(unsigned.Uint128{u64(a), 0}) != unsigned.Uint128{} {
			return unsigned.Uint128{}
		}
	}
	return res
}

// the five functions below were suggested by @spytheman as a way to implement
// NaN for both f64 and f32 types.
fn f64_from_bits(b u64) f64 {
	return *unsafe { &f64(&b) }
}

fn f64_bits(b f64) u64 {
	return *unsafe { &u64(&b) }
}

fn f32_from_bits(b u32) f32 {
	return *unsafe { &f32(&b) }
}

fn f32_bits(b f32) u32 {
	return *unsafe { &u32(&b) }
}

pub fn nan[T]() T {
	$if T is f64 {
		return f64_from_bits(u64(0x7FF8000000000001))
	}
	$if T is f32 {
		return f32_from_bits(u32(0x7FF80001))
	}
	return 0
}

pub fn is_nan[T](f T) bool {
	$if fast_math {
		if f64_bits(f) == u64(0x7FF8000000000001) || f32_bits(f) == u32(0x7FF80001) {
			return true
		}
	}
	return f != f
}

// array_min returns the minimum value in the array
fn array_min[T](a []T) T {
	if a.len == 0 {
		panic('array_min called on an empty array')
	}
	mut val := a[0]
	for e in a {
		if e < val {
			val = e
		}
	}
	return val
}

fn array_max[T](array []T) T {
	return arrays.max(array) or { panic('array is empty') }
}

// array_sum returns the sum of an array's numeric values
fn array_sum[T](list []T) T {
	if list.len == 0 {
		panic('array_sum called on an empty array')
	}
	mut head := list[0]
	for e in list[1..] {
		head += e
	}
	return head
}

// array_multiply performs a scalar multiply of two equal length arrays, returning an array.
fn array_multiply[T](a []T, b []T) []T {
	if a.len != b.len {
		panic('array_multiply called on arrays with different lengths')
	}
	mut product := []T{len: a.len}
	for i in 0 .. a.len {
		product[i] = a[i] * b[i]
	}
	return product
}

fn ratio[T](a []T) f64 {
	if a.len < 2 {
		panic('array too short to calculate a ratio')
	}
	return round_two_decimals(f64(array_min(a)) / f64(array_max(a)))
}

// uniques returns the unique items in a list, without sorting.
fn uniques[T](list []T) []T {
	if list.len <= 1 {
		return list
	}
	mut result := []T{cap: list.len}
	for item in list {
		if item !in result {
			result << item
		}
	}
	return result
}

// find the index of b in arr. Returns -1 if not found.
fn find[T](arr []T, b T) int {
	for i, a in arr {
		if a == b {
			return i
		}
	}
	return -1
}

// idx_max
fn idx_max[T](a []T) int {
	if a == [] {
		panic('idx_max was called on an empty array')
	}
	if a.len == 1 {
		return 0
	}
	mut idx := 0
	mut val := a[0]
	for i, e in a {
		if e > val {
			val = e
			idx = i
		}
	}
	return idx
}

// idxs_max returns an array of indices of the array's maximum values
fn idxs_max[T](a []T) []int {
	if a == [] {
		panic('idxs_max was called on an empty array')
	}
	if a.len == 1 {
		return [0]
	}
	mut idxs := []int{}
	max_val := array_max(a)
	for i, val in a {
		if val == max_val {
			idxs << i
		}
	}
	return idxs
}

// idxs_zero returns an array of indices pointing to all the elements
// of the original array which are zero
fn idxs_zero[T](a []T) []int {
	if a == [] {
		panic('idxs_zero was called on an empty array')
	}
	mut idxs := []int{cap: a.len}
	for i, val in a {
		if val == 0 {
			idxs << i
		}
	}
	return idxs
}

fn idxs_match[T](a []T, val T) []int {
	if a == [] {
		panic('idxs_zero was called on an empty array')
	}
	mut idxs := [int{
		cap: a.len
	}]
	for i, value in a {
		if value == val {
			idxs << i
		}
	}
	return idxs
}

// get_binning
fn get_binning(bins []int) Binning {
	if bins == [0] {
		return Binning{
			lower:    0
			upper:    0
			interval: 1
		}
	}
	if bins.len == 1 {
		return Binning{
			lower:    bins[0]
			upper:    bins[0]
			interval: 1
		}
	}
	if bins.len == 2 {
		return Binning{
			lower:    bins[0]
			upper:    bins[1]
			interval: 1
		}
	}
	return Binning{
		lower:    bins[0]
		upper:    bins[1]
		interval: bins[2]
	}
}

fn get_map_key_for_max_value(m map[string]int) string {
	max := array_max(m.values())
	for key, val in m {
		if val == max {
			return key
		}
	}
	return ''
}

fn get_map_key_for_min_value(m map[string]int) string {
	min := array_min(m.values())
	for key, val in m {
		if val == min {
			return key
		}
	}
	return ''
}

// plurality_vote returns the string whose count is greater
// than the count of any other string in arr
fn plurality_vote(arr []string) string {
	if arr == [] {
		return ''
	}
	ec := element_counts(arr)
	counts := ec.values()
	max := array_max(counts)
	// there should only be one maximum value
	if counts.filter(it == max).len == 1 {
		return get_map_key_for_max_value(ec)
	}
	return ''
}

// majority_vote returns the string whose count is more than half
// the total of counts in arr
fn majority_vote(arr []string) string {
	if arr == [] {
		return ''
	}
	ec := element_counts(arr)
	vals := ec.values()
	max := array_max(vals)
	if max * 2 > array_sum(vals) {
		return get_map_key_for_max_value(ec)
	}
	return ''
}

pub fn close[T](a T, b T) bool {
	if typeof(a).name == 'f32' {
		return math.tolerance(a, b, 1e-6)
	}
	return math.tolerance(a, b, 1e-14)
}

struct Styles {
	fg    string
	bg    string
	style string
}

const m_u = Styles{
	fg:    'magenta'
	style: 'underline'
}
const lg = Styles{
	fg: 'light_gray'
}
const m_ = Styles{
	fg: 'magenta'
}
const g_b = Styles{
	fg:    'green'
	style: 'bold'
}
const b_u = Styles{
	fg:    'blue'
	style: 'underline'
}
const dg = Styles{
	fg: 'dark_gray'
}
const c_u = Styles{
	fg:    'cyan'
	style: 'underline'
}
const r_ = Styles{
	fg: 'red'
}
const r_b = Styles{
	fg:    'red'
	style: 'bold'
}
const b_ = Styles{
	fg: 'blue'
}
const g_ = Styles{
	fg: 'green'
}
const y_ = Styles{
	fg: 'yellow'
}
const c_ = Styles{
	fg: 'cyan'
}
const rgb = Styles{
	fg:    'red'
	bg:    'green'
	style: 'bold'
}

// chlk adds font colour and style information to a string
fn chlk(s string, style_code Styles) string {
	match true {
		style_code.style == '' && style_code.bg == '' {
			return chalk.fg(s, style_code.fg)
		}
		style_code.bg == '' {
			return chalk.fg(chalk.style(s, style_code.style), style_code.fg)
		}
		else {}
	}
	return chalk.fg(chalk.bg(chalk.style(s, style_code.style), style_code.bg), style_code.fg)
}

fn c(s string) string {
	return chlk(s, c_)
}

fn m_u(s string) string {
	return chlk(s, m_u)
}

fn lg(s string) string {
	return chlk(s, lg)
}

fn m(s string) string {
	return chlk(s, m_)
}

fn g_b(s string) string {
	return chlk(s, g_b)
}

fn b_u(s string) string {
	return chlk(s, b_u)
}

fn dg(s string) string {
	return chlk(s, dg)
}

fn c_u(s string) string {
	return chlk(s, c_u)
}

fn r(s string) string {
	return chlk(s, r_)
}

fn r_b(s string) string {
	return chlk(s, r_b)
}

fn rgb(s string) string {
	return chlk(s, rgb)
}

fn b(s string) string {
	return chlk(s, b_)
}

fn g(s string) string {
	return chlk(s, g_)
}

fn y(s string) string {
	return chlk(s, y_)
}

// purge_array filters an array of generic types, removing those elements
// whose indices in the original array are in a list.
fn purge_array[T](array []T, purge_indices []int) []T {
	mut result := []T{cap: array.len}
	for i, val in array {
		if i !in purge_indices {
			result << val
		}
	}
	return result
}

// filter_array_by_index filters an array of generic types, keeping those
// elements whose indices in the original array are in a list.
fn filter_array_by_index[T](array []T, keep_indices []int) []T {
	mut result := []T{cap: array.len}
	for i, val in array {
		if i in keep_indices {
			result << val
		}
	}
	return result
}

// pick_array_elements_by_index outputs an array of elements from the
// original, picked by using the values in a second array as indices into
// the first.
fn pick_array_elements_by_index[T](array []T, indices []int) []T {
	if array.len == 0 || indices.len == 0 {
		return []T{}
	}
	mut result := []T{cap: array.len}
	for indx in indices {
		if indx >= array.len {
			continue
		}
		result << array[indx]
	}
	return result
}
