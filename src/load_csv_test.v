// load_csv_test.v

module vhammll

// import os

fn test_load_csv_file() {
	mut ds := load_csv_file('datasets/play_tennis.csv')
	assert ds.Class == Class{
		class_name: 'play'
		class_index: 5
		classes: ['No', 'Yes']
		class_values: ['No', 'No', 'Yes', 'Yes', 'Yes', 'No', 'Yes', 'No', 'Yes', 'Yes', 'Yes',
			'Yes', 'Yes', 'No']
		missing_class_values: []
		class_counts: {
			'No':  5
			'Yes': 9
		}
		lcm_class_counts: 0
		postpurge_class_counts: {}
		postpurge_lcm_class_counts: 0
	}

	assert ds.attribute_types == ['m', 'D', 'D', 'D', 'D', 'c']
}
