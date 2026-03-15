module vhammll

import vsl.plot
import time

// plot_hits generates a series of plots of hits per bin for a continuous
// attribute, one plot per bin count in the tested range.
//
// For binary (2-class) datasets the chart uses a butterfly / back-to-back
// layout: bin numbers run down the vertical axis, hit counts run along the
// horizontal axis, with class 0 negated (bars grow leftward) and class 1
// positive (bars grow rightward).  The central vertical line at x = 0 is the
// zero-hits axis.  fill: 'tozerox' shades the area between each trace and
// that zero axis.
//
// For datasets with three or more classes the original layout is kept: bin
// numbers on the horizontal axis and hit counts on the vertical axis with
// fill: 'tozeroy'.

fn plot_hits(datapath string, classes_info Class, attr RankedAttribute, weighting bool) {
	hits_title_text0 := 'Ranked Continuous Attributes for "${datapath}"<br>' +
		if weighting { 'Weighted h' } else { 'H' } +
		'its per bin, per class, for attribute #${attr.attribute_index} "${attr.attribute_name}" over '
	hits_title_text1 := ' bins<br>Max rank value: ${attr.rank_value:-5.2f} at ${attr.bins} bins'
	two_class := classes_info.classes.len == 2
	// max hit count (or 100 when weighting normalises to a percentage)
	hit_max := if weighting {
		100.0
	} else {
		f64(array_max(classes_info.class_counts.values()))
	}

	for hits_array in attr.array_of_hits_arrays {
		n_bins := hits_array[0].len // includes bin 0 (missing values)
		mut plt := plot.Plot.new()

		if two_class {
			// ── Butterfly layout ────────────────────────────────────────────
			// y = bin index (0 … n_bins-1); x = hit count (class 0 negated)
			// annotation1 := plot.Annotation{
			// 	x:     0.7 * hit_max
			// 	y:     f64(n_bins - 2)
			// 	text:  anno1_text
			// 	align: 'right'
			// }
			for i, class in classes_info.classes {
				raw := if weighting {
					hits_array[i].map(f64(it) / classes_info.class_counts.values()[i] * 100)
				} else {
					hits_array[i].map(f64(it))
				}
				// class 0 goes left (negative), class 1 goes right (positive)
				x := if i == 0 { raw.map(-it) } else { raw }
				cases := classes_info.class_counts[class]
				plt.scatter(
					x:    x
					y:    []int{len: n_bins, init: index}
					mode: 'lines+markers'
					fill: 'tozerox'
					name: '${class} (${cases} cases) '
				)
			}
			plt.layout(
				title:    hits_title_text0 + '${n_bins - 1}' + hits_title_text1
				autosize: false
				width:    800
				height:   600
				xaxis:    plot.Axis{
					title: plot.AxisTitle{
						text: if weighting { 'Weighted and normalized n' } else { 'N' } +
							'umber of Hits  (left: ${classes_info.classes[0]}  |  right: ${classes_info.classes[1]} )'
					}
					range: [-hit_max, hit_max]
				}
				yaxis:    plot.Axis{
					title:    plot.AxisTitle{
						text: 'Bin number (bin 0 is for missing values)'
					}
					tickmode: 'linear'
					dtick:    1.0
				}
			)
		} else {
			// ── Original multi-class layout ─────────────────────────────────
			// x = bin index; y = hit count
			for i, class in classes_info.classes {
				y := if weighting {
					hits_array[i].map(f64(it) / classes_info.class_counts.values()[i] * 100)
				} else {
					hits_array[i].map(f64(it))
				}
				cases := classes_info.class_counts[class]
				plt.scatter(
					x:    []int{len: n_bins, init: index}
					y:    y
					mode: 'lines+markers'
					fill: 'tozeroy'
					name: '${class} (${cases} cases)'
				)
			}
			plt.layout(
				title:    hits_title_text0 + '${n_bins - 1}' + hits_title_text1
				autosize: false
				width:    800
				height:   600
				xaxis:    plot.Axis{
					title:    plot.AxisTitle{
						text: 'Bin number (bin 0 is for missing values)'
					}
					tickmode: 'linear'
					// tick0: 0.0
					dtick: 1.0
				}
				yaxis:    plot.Axis{
					title: plot.AxisTitle{
						text: if weighting { 'Weighted and normalized n' } else { 'N' } +
							'umber of Hits'
					}
					range: [0.0, hit_max]
				}
			)
		}
		plt.show() or { panic(err) }
		// the time delay is to prevent a "page unable to load" error
		time.sleep(1 * time.second)
	}
}
