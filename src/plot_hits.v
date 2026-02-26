module vhammll

import vsl.plot

// plot-hits generates a series of scatterplots with smoothed lines of the
// number of hits per bin number,over a range of bin numbers,
// for a continuous attribute, with separate curves for each class.
fn plot_hits(classes_info Class, attr RankedAttribute, weighting bool) {
	mut anno1_text := 'Rank value: ${attr.rank_value:-6.2f} at ${attr.bins} bins'
	y_max := if weighting {
		100.0
	} else {
		f64(array_max(classes_info.class_counts.values()))
	}
	mut annotation1 := plot.Annotation{
		x:     2
		y:     0.3 * y_max
		text:  anno1_text
		align: 'center'
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
