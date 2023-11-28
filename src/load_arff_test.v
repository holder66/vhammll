// load_arff_test.v
module vhammll

fn test_load_arff_files() {
	mut ds := Dataset{}
	ds = load_file('datasets/contact-lenses.arff')
	assert ds.attribute_names == ['age', 'spectacle-prescrip', 'astigmatism', 'tear-prod-rate',
		'contact-lenses']
	assert ds.attribute_flags == ['young, pre-presbyopic, presbyopic', 'myope, hypermetrope',
		'no, yes', 'reduced, normal', 'soft, hard, none']
	assert ds.raw_attribute_types == ['string', 'string', 'string', 'string', 'string']
	assert ds.attribute_types == ['D', 'D', 'D', 'D', 'c']
	assert ds.useful_continuous_attributes == {}

	ds = load_file('datasets/UCI/iris.arff')
	assert ds.attribute_names == ['sepallength', 'sepalwidth', 'petallength', 'petalwidth', 'class']
	assert ds.attribute_flags == ['', '', '', '', 'iris-setosa,iris-versicolor,iris-virginica']
	assert ds.raw_attribute_types == ['real', 'real', 'real', 'real', 'string']
	assert ds.attribute_types == ['C', 'C', 'C', 'C', 'c']
	assert ds.useful_discrete_attributes == {}
}
