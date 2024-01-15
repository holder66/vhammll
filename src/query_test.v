// query_test.v
module vhammll

// test_query
fn test_query() ? {
	mut opts := Options{
		number_of_attributes: [2]
		bins: [2, 2]
		exclude_flag: false
	}
	mut ds := load_file('datasets/developer.tab')
	mut cl := make_classifier(ds, opts)
	// println(query(cl, opts))
}
