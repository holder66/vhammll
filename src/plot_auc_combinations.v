module vhammll

import vsl.plot

// plot_auc_combinations generates an interactive scatter plot of the Area Under
// the ROC Curve (AUC) for each multi-classifier combination, with one trace per
// combination length.  X-axis is rank within the length group (1 = highest AUC);
// Y-axis is AUC; hovering over a marker shows the constituent classifier IDs.
// The incoming `combos` slice must already be sorted descending by AUC (as done
// in optimals()).  If `top_n` is greater than zero, only the `top_n` highest-AUC
// combinations are shown for each length; passing zero shows all combinations.
// Called by optimals when -g and -cl are both active on a binary dataset.
pub fn plot_auc_combinations(combos []AucClassifiers, files RocFiles, top_n int) {
	// collect unique combination lengths, sorted ascending
	mut lengths := []int{}
	for combo in combos {
		l := combo.classifier_ids.len
		if l !in lengths {
			lengths << l
		}
	}
	lengths.sort(a < b)

	mut plt := plot.Plot.new()
	for length in lengths {
		// combos is already sorted desc by auc; take the top slice if requested
		mut group := combos.filter(it.classifier_ids.len == length)
		if top_n > 0 && group.len > top_n {
			group = group[..top_n].clone()
		}
		mut x := []f64{}
		mut y := []f64{}
		mut hover := []string{}
		for i, combo in group {
			x << f64(i + 1)
			y << combo.auc
			hover << combo.classifier_ids.map('${it}').join(',')
		}
		plt.scatter(
			x:    x
			y:    y
			text: hover
			mode: 'lines+markers'
			name: '${length}-classifier combinations'
		)
	}

	top_n_label := if top_n > 0 { 'top ${top_n} per length' } else { 'all' }
	plt.layout(
		title:  'AUC by Multi-Classifier Combination<br>' + 'Settings: ${files.settingsfile}<br>' +
			'Data: ${files.datafile} (${top_n_label})'
		width:  800
		height: 600
		xaxis:  plot.Axis{
			title: plot.AxisTitle{
				text: 'Rank within combination length (1 = highest AUC)'
			}
		}
		yaxis:  plot.Axis{
			title: plot.AxisTitle{
				text: 'AUC'
			}
		}
	)
	plt.show() or { panic(err) }
}
