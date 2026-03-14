module vhammll

import vsl.plot

// plot_rank generates a scatterplot of the rank values for continuous
// attributes as a function of the number of bins.  Each attribute produces
// one trace, sorted descending by its maximum rank value.  Returns immediately
// without opening a browser window when the dataset has no continuous attributes.
fn plot_rank(result RankingResult) {
	// dump(result)
	mut ranked_atts := result.array_of_ranked_attributes.clone()
	mut traces := []RankTrace{}
	mut x := []f64{}
	for i in result.binning.lower .. result.binning.upper + 1 {
		x << i
	}
	// dump(x)
	for i, attr in ranked_atts.filter(it.attribute_type == 'C') {
		if result.limit_output > 0 && i >= result.limit_output {
			break
		}
		traces << RankTrace{
			label:              '#${attr.attribute_index:4} ${attr.attribute_name} ${array_max(attr.rank_value_array):5.2f} @ ${attr.bins} bins'
			rank_values:        attr.rank_value_array.map(f64(it)).reverse()
			maximum_rank_value: array_max(attr.rank_value_array)
			// the tooltip for each point shows the attribute name
			hover_text: ['#${attr.attribute_index}<br>${attr.attribute_name}']
		}
	}
	if traces.len == 0 {
		return
	}
	// sort in descending order of maximum_rank_value
	traces.sort(a.maximum_rank_value > b.maximum_rank_value)
	mut plt := plot.Plot.new()

	mut attributes := []string{}
	for value in traces {
		attributes << value.hover_text
		y := value.rank_values.map(round_two_decimals(it))
		plt.scatter(
			x:    x
			y:    y
			text: value.hover_text
			mode: 'lines+markers'
			name: value.label
		)
	}
	rank_annotation_string := 'Missing Values<br>' +
		if result.exclude_flag { 'excluded' } else { 'included' }
	annotation1 := plot.Annotation{
		x:     0.8 * f64(result.binning.upper)
		y:     1.0
		arrowcolor: 'white'
		text:  'Hover your cursor<br>over a marker<br>to view details'
		showarrow:false
		align: 'center'
	}
	annotation2 := plot.Annotation{
		x:     0.3 * f64(result.binning.upper)
		y:     1.0
		arrowcolor: 'white'
		text:  rank_annotation_string
		showarrow:false
		align: 'center'
	}
	plt.layout(
		// plt.set_layout(
		title:       'Rank Values for Continuous Attributes for "${result.path}"'
		autosize:    false
		width:       800
		xaxis:       plot.Axis{
			title: plot.AxisTitle{
				text: 'Number of bins'
			}
		}
		yaxis:       plot.Axis{
			title: plot.AxisTitle{
				text: 'Rank Value'
			}
			range: [0.0, 100]
		}
		annotations: [annotation1, annotation2]
		// annotations: [annotation1]
	)
	plt.show() or { panic(err) }
}
