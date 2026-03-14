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

	mut plt := plot.Plot.new()
	// mut max_x := 1.0
	mut max_y := 1.0
	for i, attr in attrs {
		max_y = array_max([max_y, f64(array_max(attr.switches_array))])
		if result.limit_continuous > 0 && i >= result.limit_continuous {
			break
		}
		plt.scatter(
			x:    x
			y:    attr.switches_array.map(f64(it))
			text: ['${attr.attribute_name}'].repeat(x.len)
			mode: 'lines+markers'
			name: '#${attr.attribute_index:4} ${attr.attribute_name} ${array_max(attr.rank_value_array):5.2f} @ ${attr.bins} bins'
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
		name: 'switches threshold: ${result.switches_threshold}'
	)

	annotation1 := plot.Annotation{
		x:     0.3 * f64(result.binning.upper)
		y:     max_y -0.5
		showarrow:false
		arrowcolor: 'white'
		text:  'Hover your cursor<br>over a marker<br>to view attribute name'
		align: 'center'
		font:  plot.Font{
			color: 'blue'
			size:  12.0
		}
	}
	annotation2 := plot.Annotation{
		x:     0.3 * f64(result.binning.upper)
		y:     max_y - 1.5
		showarrow:false
		arrowcolor: 'white'
		text:  'Missing Values<br>' + if result.exclude_flag { 'excluded' } else { 'included' }
		align: 'center'
		font:  plot.Font{
			color: 'blue'
			size:  12.0
		}
	}

	plt.layout(
		title:       'Switches per Continuous Attribute for "${result.path}"' + if result.limit_continuous > 0 {'<br>(${result.limit_continuous} highest-ranked continuous attributes shown)' } else {''}
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
