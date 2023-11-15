// purge_missings.v
module vhammll

pub fn (mut ds Dataset) purge_instances_for_missing_class_values() Dataset {
	mut instances_to_purge := []int{}
	for i, class_val in ds.class_values {
		if class_val in missings {
			instances_to_purge << i
		}
	}
	// println('instances_to_purge: ${instances_to_purge.len} $instances_to_purge')
	// println(ds.class_values.filter(it !in missings))
	mut result := []string{cap: ds.class_values.len}
	for i, e in ds.class_values {
		if i !in instances_to_purge {
			result << e
		}
	}
	ds.classes = uniques(result)
	ds.class_values = result
	ds.class_counts = element_counts(result)
	// println(ds.data)
	// println('result after clear: $result')
	mut result_data := [][]string{cap: ds.class_values.len * ds.data.len}
	// println('result_data after create: ${result_data}')
	// result_data.clear()
	for attr_val in ds.data {
		result = []
		// println('result_data before concat: ${result_data}')
		// println(attr_val)
		for i, e in attr_val {
			if i !in instances_to_purge {
				result << e
			}
		}
		// println('result after purge: ${result}')
		result_data << result
		// println('result_data after concat: ${result_data}')
	}
	// println('result_data: $result_data')
	ds.data = result_data
	// println(ds.data)
	return ds
}
