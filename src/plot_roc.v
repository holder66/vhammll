module vhammll

import math
import vsl.plot

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

// plot_mult_roc generates an interactive Receiver Operating
// Characteristic plot in the default web browser for one or more
// ROC traces. Each element of rocdata_array produces one scatter
// trace; the AUC is computed and shown in the plot title.
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
