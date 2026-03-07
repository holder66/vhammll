module vhammll

import vsl.plot

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
		height:      600
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
