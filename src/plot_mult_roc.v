module vhammll

import vsl.plot

// plot_mult_roc generates an interactive Receiver Operating
// Characteristic plot in the default web browser for one or more
// ROC traces. Each element of rocdata_array produces one scatter
// trace; the AUC is computed and shown in the plot title.
pub fn plot_mult_roc(rocdata_array []RocData, files RocFiles) {
	annotation1 := plot.Annotation{
		x:     0.8
		y:     0.2
		arrowcolor: 'white'
		text:  'Hover your cursor over<br>a marker to view sensitivity,<br>specificity, and classifier ID'
		align: 'center'
		showarrow:false
	}
	mut plt := plot.Plot.new()
	for rocdata in rocdata_array {
		rocpoints := roc_values(rocdata.coordinates, rocdata.classifier_ids)
		auc := auc_roc(rocpoints)
		mut hovertext := []string{}
		hovertext << '${rocdata.classifier_ids[0]}'
		// for id in rocdata {
		// 	hovertext << 'classifier ${ids}
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
		title:       'Receiver Operating Characteristic Curves For ' +
			if rocdata_array.len == 1 { 'Individual Classifiers<br>' } else { 'Combos of ${rocdata_array.len} Classifiers<br>' } +
			'Training dataset: ${files.datafile}<br>Settings file: ${files.settingsfile} '
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
