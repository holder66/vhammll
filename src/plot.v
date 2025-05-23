module vhammll

// import arrays
import math
import vsl.plot
import time
// import plotly
// import x.json2 as json

struct RankTrace {
mut:
	label              string
	rank_values        []f64
	maximum_rank_value f32
	hover_text         []string
}

// plot-hits generates a series of scatterplots with smoothed lines of the
// number of hits per bin number,over a range of bin numbers,
// for a continuous attribute, with separate curves for each class.
fn plot_hits(classes_info Class, attr RankedAttribute, weighting bool) {
	mut anno1_text := 'Rank value: ${attr.rank_value:-6.2f} at ${attr.bins} bins'
	mut annotation1 := plot.Annotation{
		x:     0
		text:  anno1_text
		align: 'left'
	}
	for hits_array in attr.array_of_hits_arrays {
		mut plt := plot.Plot.new()
		for i, class in classes_info.classes {
			y := if weighting {
				hits_array[i].map(f64(it) / classes_info.class_counts.values()[i] * 100)
			} else {
				hits_array[i].map(f64(it))
			}
			cases := classes_info.class_counts[class]
			plt.scatter(
				x:    []int{len: hits_array[i].len, init: index}
				y:    y
				mode: 'lines+markers'
				fill: 'tozeroy'
				name: '${class} (${cases})'
			)
			annotation1.y = array_max(classes_info.class_counts.values())
		}
		plt.layout(
			title:       if weighting { 'Weighted h' } else { 'H' } +
				'its per bin, per class, for attribute "${attr.attribute_name}"'
			autosize:    false
			width:       800
			xaxis:       plot.Axis{
				title: plot.AxisTitle{
					text: 'Bin number (bin 0 is for missing values)'
				}
			}
			yaxis:       plot.Axis{
				title: plot.AxisTitle{
					text: if weighting { 'Weighted and normalized n' } else { 'N' } +
						'umber of Hits'
				}
				range: [0.0, if weighting {
					100
				} else {
					array_max(classes_info.class_counts.values())
				}]
			}
			annotations: [annotation1]
		)
		plt.show() or { panic(err) }
	}
}

// plot_rank generates a scatterplot of the rank values
// for continuous attributes, as a function of the number of bins.
fn plot_rank(result RankingResult) {
	// dump(result)
	mut ranked_atts := result.array_of_ranked_attributes.clone()
	mut traces := []RankTrace{}
	mut plt := plot.Plot.new()
	// mut plt := plot.new_plot()
	mut x := []f64{}
	for i in result.binning.lower .. result.binning.upper + 1 {
		x << i
	}
	// dump(x)
	for i, attr in ranked_atts.filter(it.attribute_type == 'C') {
		if result.limit_output > 0 && i >= result.limit_output {
			break
		}
		traces << RankTrace{
			label:              '${attr.attribute_name} ${array_max(attr.rank_value_array):5.2f}'
			rank_values:        attr.rank_value_array.map(f64(it)).reverse()
			maximum_rank_value: array_max(attr.rank_value_array)
			// the tooltip for each point shows the attribute name
			hover_text: ['${attr.attribute_name}'].repeat(result.binning.upper + 1)
		}
	}
	// sort in descending order of maximum_rank_value
	traces.sort(a.maximum_rank_value > b.maximum_rank_value)

	mut attributes := []string{}
	for value in traces {
		attributes << value.hover_text
		y := value.rank_values.map(round_two_decimals(it))
		plt.scatter(
			x:    x
			y:    y
			text: value.hover_text
			mode: 'lines+markers'
			name: value.label
		)
	}
	rank_annotation_string := 'Missing Values<br>' +
		if result.exclude_flag { 'excluded' } else { 'included' } + '<br>    '
	annotation1 := plot.Annotation{
		x:     0.8 * f64(result.binning.upper)
		y:     1.0
		text:  'Hover your cursor<br>over a marker<br>to view details'
		align: 'center'
	}
	annotation2 := plot.Annotation{
		x:     0.3 * f64(result.binning.upper)
		y:     1.0
		text:  rank_annotation_string
		align: 'center'
	}
	plt.layout(
		// plt.set_layout(
		title:       'Rank Values for Continuous Attributes for "${result.path}"'
		autosize:    false
		width:       800
		xaxis:       plot.Axis{
			title: plot.AxisTitle{
				text: 'Number of bins'
			}
		}
		yaxis:       plot.Axis{
			title: plot.AxisTitle{
				text: 'Rank Value'
			}
			range: [0.0, 100]
		}
		annotations: [annotation1, annotation2]
		// annotations: [annotation1]
	)
	plt.show() or { panic(err) }
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

// plot_explore generates a scatterplot for the results of
// an explore.explore() on a dataset.
fn plot_explore(result ExploreResult, opts Options) {
	// println('opts in plot_explore: $opts')
	mut plt := plot.Plot.new()
	mut traces := []ExploreTrace{}
	mut x := []f64{}
	mut y := []f64{}
	mut bin_values_strings := []string{}
	mut bin_values_strings_filtered := []string{}
	mut percents := []f64{}
	mut max_percents := 0.0
	mut bins_for_sorting := []int{}
	for res in result.array_of_results {
		x << f64(res.attributes_used)
		y << res.balanced_accuracy
		bin_values_strings << show_bins_for_trailer(res.bin_values)
		bins_for_sorting << res.bin_values.last()
	}
	// get the unique bin_values, each one will generate a separate trace
	for b in uniques(bins_for_sorting) {
		percents = filter_int(b, bins_for_sorting, y)
		bin_values_strings_filtered = filter_int(b, bins_for_sorting, bin_values_strings)
		max_percents = array_max(percents)
		traces << ExploreTrace{
			label:           'Bins: ${bin_values_strings_filtered[0]} ${array_max(percents):5.2f}'
			percents:        percents
			max_percents:    max_percents
			attributes_used: filter_int(b, bins_for_sorting, x)
			bin_range:       ['${bin_values_strings_filtered[0]}']
			bin_for_sorting: b
		}
	}
	custom_sort_fn := fn (a &ExploreTrace, b &ExploreTrace) int {
		// return -1 when a comes before b
		// return 0, when both are in same order
		// return 1 when b comes before a
		if a.max_percents == b.max_percents {
			if a.bin_for_sorting > b.bin_for_sorting {
				return 1
			}
			if a.bin_for_sorting < b.bin_for_sorting {
				return -1
			}
			return 0
		}
		if a.max_percents > b.max_percents {
			return -1
		} else if a.max_percents < b.max_percents {
			return 1
		}
		return 0
	}
	traces.sort_with_compare(custom_sort_fn)
	for value in traces {
		text := value.bin_range.repeat(value.percents.len)
		plt.scatter(
			x:    value.attributes_used
			y:    value.percents.map((math.round(it * 100)) / 100)
			text: text
			mode: 'lines+markers'
			name: value.label
			// hovertemplate: 'bins: ${text}<br>attributes: ${value.attributes_used}<br>accuracy: S{value.percents.map((math.round(it * 100)) / 100)}%'
		)
	}
	annotation1 := plot.Annotation{
		x:     (array_max(x) + array_min(x)) / 2
		y:     5
		text:  'Hover your cursor over a marker to view details.'
		align: 'center'
		font:  plot.Font{
			color:  'red'
			size:   14.0
			family: 'Times New Roman'
		}
	}
	annotation2 := plot.Annotation{
		x:     (array_max(x) + array_min(x)) / 2
		y:     10
		text:  explore_type_string(opts)
		align: 'center'
		font:  plot.Font{
			color:  'blue'
			size:   12.0
			family: 'Times New Roman'
		}
	}
	annotation3 := plot.Annotation{
		x:     (array_max(x) + array_min(x)) / 2
		y:     15
		text:  'UTC: ${time.utc()}'
		align: 'center'
		font:  plot.Font{
			color:  'blue'
			size:   12.0
			family: 'Times New Roman'
		}
	}
	annotation4 := plot.Annotation{
		x:     (array_max(x) + array_min(x)) / 2
		y:     20
		text:  'args: ${opts.args}'
		align: 'center'
		font:  plot.Font{
			color:  'black'
			size:   12.0
			family: 'Times New Roman'
		}
	}
	title_string := 'Balanced Accuracy by Number of Attributes\n for "${opts.datafile_path}"'
	plt.layout(
		title:       title_string
		width:       900
		xaxis:       plot.Axis{
			tickmode: 'array'
			tickvals: x
			title:    plot.AxisTitle{
				text: 'Number of Attributes Used'
			}
		}
		annotations: [annotation1, annotation2, annotation3, annotation4]
		autosize:    true
	)
	plt.show() or { panic(err) }
}

// explore_type_string
fn explore_type_string(opts Options) string {
	// mut explore_type_string := ''
	if opts.testfile_path == '' {
		return if opts.folds == 0 { 'Leave-one-out ' } else { '${opts.folds}-fold ' } + 'cross-validations' + if opts.repetitions > 0 {
			' (${opts.repetitions} repetitions' + if opts.random_pick {
				', random selection)'
			} else {
				')'
			}
		} else {
			''
		}
	}
	return 'Verifications with "${opts.testfile_path}"'
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

// fn plotly_roc(roc_points []RocPoint, auc f64) {
// 	mut y := roc_points.map(it.sens)
// 	mut x := roc_points.map(it.fpr)
// 	mut plt := plotly.new_figure()
// 	trace := plotly.scatter(plotly.f64_array_to_json(x), plotly.f64_array_to_json(y),
// 		'ROC curve')
// 	plt.add_trace(trace)
// 	plt.update_layout({
// 		'title': json.Any('Receiver Operating Characteristic (AUC: ${auc:.3f})')
// 	})
// 	plt.show()
// }

fn plot_roc(roc_points []RocPoint, auc f64) {
	mut y := roc_points.map(it.sens)
	mut x := roc_points.map(it.fpr)
	mut plt := plot.Plot.new()
	plt.scatter(
		x: x
		y: y
	)
	plt.layout(title: 'Receiver Operating Characteristic (AUC: ${auc:.3f})')
	plt.show() or { panic(err) }
}

pub struct RocData {
pub mut:
	pairs          [][]f64
	classifiers    []string
	classifier_ids [][]int
	trace_text     string
}

pub struct RocFiles {
pub mut:
	datafile     string
	testfile     string
	settingsfile string
}

pub fn plot_mult_roc(rocdata_array []RocData, files RocFiles) {
	annotation1 := plot.Annotation{
		x:     0.8
		y:     0.2
		text:  'Hover your cursor<br>over a marker<br>to view details'
		align: 'center'
	}
	mut plt := plot.Plot.new()
	for rocdata in rocdata_array {
		rocpoints := roc_values(rocdata.pairs, rocdata.classifier_ids)
		auc := auc_roc(rocpoints.map(it.Point))
		mut hovertext := []string{cap: rocdata.classifiers.len + 2}

		for ids in rocpoints.map(it.classifiers) {
			hovertext << 'classifier' + if ids.contains(',') { 's' } else { '' } + ': ' + ids
		}
		plt.scatter(
			x:    rocpoints.map(it.fpr)
			y:    rocpoints.map(it.sens)
			text: hovertext
			mode: 'lines+markers'
			name: rocdata.trace_text + '<br>auc: ${auc:.3f}'
		)
	}

	plt.scatter(
		x:    [0.0, 1.0]
		y:    [0.0, 1.0]
		text: ['text when hovering']
		mode: 'lines'
		line: plot.Line{
			dash: 'dashdot'
		}
		name: 'random guess<br>(probability 0.5)'
	)
	plt.layout(
		title:       'Receiver Operating Characteristic curves<br>Training dataset: ${files.datafile}<br>Settings file: ${files.settingsfile} '
		width:       800
		height:      600
		xaxis:       plot.Axis{
			title: plot.AxisTitle{
				text: 'False Positive Rate (Specificity - 1)'
			}
		}
		yaxis:       plot.Axis{
			title: plot.AxisTitle{
				text: 'True Positive Rate (Sensitivity)'
			}
		}
		annotations: [annotation1]
	)
	plt.show() or { panic(err) }
}

// plot_explore_roc generates plots of receiver operating characteristic curves.
fn plot_explore_roc(result ExploreResult, opts Options) {
	println('attempting to plot an ROC')
	mut roc_results := []ROCResult{}
	mut traces := []ROCTrace{}
	mut x_coordinates := []f64{}
	mut y_coordinates := []f64{}
	mut bin_range_values := []string{}
	mut attributes_used_values := []string{}
	mut bin_range := ''
	// mut pos_class := result.array_of_results[0].pos_neg_classes[0]
	// mut neg_class := result.array_of_results[0].pos_neg_classes[1]
	annotation1 := plot.Annotation{
		x:     0.5
		y:     -0.05
		text:  'Hover your cursor over a marker to view details.'
		align: 'center'
	}
	annotation2 := plot.Annotation{
		x:     0.5
		y:     -0.02
		text:  explore_type_string(opts)
		align: 'left'
	}

	// first, we'll do a series of curves, one per bin range, thus
	// with the number of attributes varying
	// skip this if no binning

	for res in result.array_of_results {
		// println('res: $res')
		// create strings that can be used for filtering
		if res.bin_values.len == 1 {
			bin_range = '${res.bin_values[0]} bins'
		} else {
			bin_range = 'bins ${res.bin_values[0]} - ${res.bin_values[1]}'
		}
		roc_results << ROCResult{
			sensitivity:           res.sens
			one_minus_specificity: 1.0 - res.spec
			bin_range:             bin_range
			attributes_used:       '${res.attributes_used}'
		}
	}
	// sort on the x axis value, ie one_minus_specificity
	roc_results.sort(a.one_minus_specificity < b.one_minus_specificity)
	// get the unique bin_range values, each one will generate a separate trace
	for roc_result in roc_results {
		bin_range_values << roc_result.bin_range
		attributes_used_values << roc_result.attributes_used
		x_coordinates << roc_result.one_minus_specificity
		y_coordinates << roc_result.sensitivity
	}

	for key, _ in element_counts(bin_range_values) {
		traces << ROCTrace{
			curve_series_variable_values: '${key}'
			x_coordinates:                filter(key, bin_range_values, x_coordinates)
			y_coordinates:                filter(key, bin_range_values, y_coordinates)
			curve_variable_values:        filter(key, bin_range_values, attributes_used_values)
		}
	}
	if result.binning.lower != 0 {
		mut plt_bins := plot.Plot.new()
		traces = massage_roc_traces(mut traces)
		make_roc_plot_traces(traces, mut plt_bins, 'attributes used')

		make_roc_plot_layout(mut plt_bins, 'Binning', opts.datafile_path, [
			annotation1,
			annotation2,
		])

		plt_bins.show() or { panic(err) }
	}
	// now a series of curves, one per attributes_used value
	mut plt_atts := plot.Plot.new()
	traces.clear()
	for key, _ in element_counts(attributes_used_values) {
		traces << ROCTrace{
			curve_series_variable_values: '${key}'
			x_coordinates:                filter(key, attributes_used_values, x_coordinates)
			y_coordinates:                filter(key, attributes_used_values, y_coordinates)
			curve_variable_values:        filter(key, attributes_used_values, bin_range_values)
		}
	}

	traces = massage_roc_traces(mut traces)
	make_roc_plot_traces(traces, mut plt_atts, 'binning')
	make_roc_plot_layout(mut plt_atts, 'Attributes Used', opts.datafile_path, [
		annotation1,
		annotation2,
	])

	plt_atts.show() or { panic(err) }
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

// massage_roc_traces appends 0. and 1. to the beginning and end of
// the x and y arrays and 'none' to the curve_variable_values array;
// it then calculates areas under the curve (AUC), and sorts the traces
// in descending order of AUC
fn massage_roc_traces(mut traces []ROCTrace) []ROCTrace {
	for mut trace in traces {
		trace.x_coordinates.prepend(0.0)
		trace.y_coordinates.prepend(0.0)
		trace.curve_variable_values.prepend('none')
		trace.x_coordinates << 1.0
		trace.y_coordinates << 1.0
		trace.curve_variable_values << 'none'
		trace.area_under_curve = area_under_curve(trace.x_coordinates, trace.y_coordinates)
	}
	traces.sort(a.area_under_curve > b.area_under_curve)
	return traces
}

// round_two_decimals
fn round_two_decimals(a f64) f64 {
	return math.round(a * 100.0) / 100.0
}

// make_roc_plot_traces
fn make_roc_plot_traces(traces []ROCTrace, mut plt plot.Plot, hover_variable string) {
	for trace in traces {
		x := trace.x_coordinates.map(round_two_decimals(it))
		y := trace.y_coordinates.map(round_two_decimals(it))
		plt.scatter(
			x:    x
			y:    y
			mode: 'lines+markers'
			name: '${trace.curve_series_variable_values} (AUC=${trace.area_under_curve:3.2})'
			text: trace.curve_variable_values
			// hovertemplate: '${hover_variable}: ${trace.curve_variable_values}<br>sensitivity: ${y}<br>one minus specificity: ${x}'
		)
	}
}

// make_roc_plot_layout
fn make_roc_plot_layout(mut plt plot.Plot, curve_series string, path string, annotations []plot.Annotation) {
	plt.layout(
		title:       'ROC Curves by ${curve_series} for "${path}"'
		width:       800
		height:      800
		xaxis:       plot.Axis{
			title: plot.AxisTitle{
				text: '1 - specificity'
			}
		}
		yaxis:       plot.Axis{
			title: plot.AxisTitle{
				text: 'sensitivity'
			}
		}
		annotations: annotations
	)
}
