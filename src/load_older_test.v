// load_file_test.v
module vhammll

fn test_file_type() {
	assert file_type('datasets/iris.tab') == 'orange_older'
}

fn test_load_file() {
	mut ds := Dataset{}
	ds = load_file('datasets/leukemia34test.tab')
	// println(ds.Class)
	assert ds.class_values == ['ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL',
		'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'ALL', 'AML', 'AML', 'AML',
		'AML', 'AML', 'AML', 'AML', 'AML', 'AML', 'AML', 'AML', 'AML', 'AML', 'AML']

	ds = load_file('datasets/iris.tab')
	assert ds.class_counts == {
		'Iris-setosa':     50
		'Iris-versicolor': 50
		'Iris-virginica':  50
	}
	assert ds.lcm_class_counts == 0
	assert ds.attribute_names == ['sepal length', 'sepal width', 'petal length', 'petal width',
		'iris']
	assert ds.data[0][0..4] == ['5.1', '4.9', '4.7', '4.6']
	assert ds.inferred_attribute_types == ['C', 'C', 'C', 'C', 'c']
	assert ds.useful_continuous_attributes[1][0] == 3.5
	assert ds.useful_discrete_attributes == {}

	// test that header lines get padded out
	ds = load_file('datasets/wine.tab')
	assert ds.attribute_flags == ['class', '', '', '', '', '', '', '', '', '', '', '', '', '']
}

fn test_load_file_with_purging() ! {
	// first, no purging
	mut ds := Dataset{}
	mut datafile := 'datasets/class_missing_iris.tab'
	ds = load_file(datafile)
	assert ds.class_name == 'iris'
	assert ds.class_counts == {
		'Iris-setosa':     47
		'':                8
		'Iris-versicolor': 48
		'Iris-virginica':  47
	}
	// repeat with purging of instances where the class value is missing
	// NOTE: this is not implemented for orange_older file types
	ds = load_file(datafile, class_missing_purge_flag: true)
	assert ds.class_counts == {
		'Iris-setosa':     47
		'Iris-versicolor': 48
		'Iris-virginica':  47
	}
}
