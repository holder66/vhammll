module vhammll

import math
import vsl.plot
import time

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
