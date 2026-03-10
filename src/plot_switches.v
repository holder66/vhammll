module vhammll

import vsl.plot

// plot_switches generates an interactive scatter plot of the number of
// dominant-class switches per continuous attribute as a function of bin count.
// Each continuous attribute that has switch data produces one trace, sorted
// ascending by minimum switch count so the most monotone attributes appear
// first in the legend.  A dashed horizontal reference line is drawn at
// result.switches_threshold.  Returns immediately without opening a browser
// window when no continuous attributes have switch data (e.g. discrete-only
// datasets or multi-class datasets where switches are not computed).
// Called by rank_attributes when both -g and -sw are active and the dataset
// is binary (classes.len == 2).
fn plot_switches(result RankingResult) {
	mut x := []f64{}
	for i in result.binning.lower .. result.binning.upper + 1 {
		x << f64(i)
	}

	// collect continuous attributes that have switch data; sort most-monotone first
	mut attrs := result.array_of_ranked_attributes.filter(it.attribute_type == 'C'
		&& it.switches_array.len > 0)
	if attrs.len == 0 {
		return
	}
	attrs.sort_with_compare(fn (a &RankedAttribute, b &RankedAttribute) int {
		a_min := array_min(a.switches_array)
		b_min := array_min(b.switches_array)
		if a_min < b_min {
			return -1
		} else if a_min > b_min {
			return 1
		}
		return 0
	})

	mut plt := plot.Plot.new()
	for i, attr in attrs {
		if result.limit_output > 0 && i >= result.limit_output {
			break
		}
		plt.scatter(
			x:    x
			y:    attr.switches_array.map(f64(it))
			text: ['${attr.attribute_name}'].repeat(x.len)
			mode: 'lines+markers'
			name: '${attr.attribute_name}  min:${array_min(attr.switches_array)}'
		)
	}

	// horizontal reference line at the threshold
	plt.scatter(
		x:    [f64(result.binning.lower), f64(result.binning.upper)]
		y:    [f64(result.switches_threshold), f64(result.switches_threshold)]
		mode: 'lines'
		line: plot.Line{
			dash: 'dashdot'
		}
		name: 'threshold (${result.switches_threshold})'
	)

	annotation1 := plot.Annotation{
		x:     0.8 * f64(result.binning.upper)
		y:     f64(result.switches_threshold) + 0.5
		text:  'Hover your cursor<br>over a marker<br>to view attribute name'
		align: 'center'
	}
	annotation2 := plot.Annotation{
		x:     0.3 * f64(result.binning.upper)
		y:     f64(result.switches_threshold) - 0.5
		text:  'Missing Values<br>' + if result.exclude_flag { 'excluded' } else { 'included' } +
			'<br>    '
		align: 'center'
	}

	plt.layout(
		title:       'Switches per Continuous Attribute for "${result.path}"'
		autosize:    false
		width:       800
		height:      600
		xaxis:       plot.Axis{
			title: plot.AxisTitle{
				text: 'Number of bins'
			}
		}
		yaxis:       plot.Axis{
			title: plot.AxisTitle{
				text: 'Number of switches'
			}
		}
		annotations: [annotation1, annotation2]
	)
	plt.show() or { panic(err) }
}
