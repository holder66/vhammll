// purge_missings.v
module vhammll
pub fn purge_instances_for_missing_class_values_not_inline(mut ds Dataset) Dataset {
	return ds.purge_instances_for_missing_class_values()
}

pub fn (mut ds Dataset) purge_instances_for_missing_class_values() Dataset {
	mut instances_to_purge := []int{}
	println(ds.class_values)
	println('missings in purge_instances_for_missing_class_values: $ds.missings')
	for i, class_val in ds.class_values {
		if class_val in ds.missings {
			instances_to_purge << i
		}
	}
	println('instances_to_purge in purge_instances_for_missing_class_values: ${instances_to_purge.len} $instances_to_purge')
	mut result := []string{cap: ds.class_values.len}
	for i, e in ds.class_values {
		if i !in instances_to_purge {
			result << e
		}
	}
	// println('result.len: ${result.len}')

	ds.classes = uniques(result)
	ds.class_values = purge_array(ds.class_values, instances_to_purge)
	ds.class_counts = element_counts(ds.class_values)
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
	// also purge the useful_discrete_attributes and the useful_continuous_attributes
	for key, val in ds.useful_discrete_attributes {
		ds.useful_discrete_attributes[key] = purge_array(val, instances_to_purge)
	}
	for key, val in ds.useful_continuous_attributes {
		ds.useful_continuous_attributes[key] = purge_array(val, instances_to_purge)
	}
	// println(ds.data)
	return ds
}
