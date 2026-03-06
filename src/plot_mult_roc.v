module vhammll

import math
import vsl.plot

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
		auc := auc_roc(rocpoints)
		mut hovertext := []string{cap: rocdata.classifiers.len + 2}

		// for ids in rocpoints.map(it.classifier_ids) {
		// 	hovertext << 'classifier' + if ids.contains(',') { 's' } else { '' } + ': ' + ids
		// }
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
