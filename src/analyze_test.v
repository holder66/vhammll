// test_analyze
module vhammll

fn test_analyze_dataset() ? {
	mut opts := Options{
		show_flag: false
	}
	// orange_newer file
	mut ds := load_file('datasets/developer.tab')
	mut pr := analyze_dataset(ds, opts)
	assert pr.datafile_path == 'datasets/developer.tab'
	assert pr.datafile_type == 'orange_newer'
	assert pr.attributes[2].name == 'age'
	assert pr.attributes[9].min == -90
	assert pr.class_counts == {
		'm': 8
		'f': 3
		'X': 2
	}
	assert close(pr.attributes[8].mean, 47.27273)
	assert close(pr.attributes[8].median, 45.0)

	// orange_older file
	ds = load_file('datasets/iris.tab')
	pr = analyze_dataset(ds, opts)
	assert pr.datafile_path == 'datasets/iris.tab'
	assert pr.datafile_type == 'orange_older'
	assert pr.attributes[2].name == 'petal length'
	assert pr.attributes[3].max == 2.5
	assert pr.class_counts == {
		'Iris-setosa':     50
		'Iris-versicolor': 50
		'Iris-virginica':  50
	}
}

fn test_analyze_dataset_with_purging_of_instances_with_missing_class_values() {
	mut opts := Options{
		show_flag: false
		datafile_path: 'datasets/class_missing_developer.tab'
	}
	mut ds := Dataset{}
	ds = load_file(opts.datafile_path)
	mut pr := analyze_dataset(ds, opts)
	assert pr.datafile_path == 'datasets/class_missing_developer.tab'
	assert pr.datafile_type == 'orange_newer'
	assert pr.class_name == 'gender'
	assert pr.class_counts == {
		'm': 8
		'':  1
		'f': 3
		'X': 2
		'?': 1
	}
	assert pr.attributes[3] == Attribute{
		id: 3
		name: 'gender'
		count: 15
		counts_map: {
			'm': 8
			'':  1
			'f': 3
			'X': 2
			'?': 1
		}
		uniques: 5
		missing: 2
		att_type: ''
		inferred_type: 'c'
		for_training: false
		min: 0.0
		max: 0.0
		mean: 0.0
		median: 0.0
	}

	// println(pr)
	// repeat with purging of instances where the class value is missing
	ds = load_file(opts.datafile_path, class_missing_purge_flag: true)
	pr = analyze_dataset(ds, opts)
	assert pr.datafile_path == 'datasets/class_missing_developer.tab'
	assert pr.datafile_type == 'orange_newer'

	assert pr.class_name == 'gender'
	assert pr.class_counts == {
		'm': 8
		'f': 3
		'X': 2
	}
	assert pr.attributes[3] == Attribute{
		id: 3
		name: 'gender'
		count: 13
		counts_map: {
			'm': 8
			'f': 3
			'X': 2
		}
		uniques: 3
		missing: 0
		att_type: ''
		inferred_type: 'c'
		for_training: false
		min: 0.0
		max: 0.0
		mean: 0.0
		median: 0.0
	}
}
