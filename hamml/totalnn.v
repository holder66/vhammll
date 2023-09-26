// totalnn.v

module hamml

// import arrays

// this version of multiple.v is to add up the nearest neighbors for the
// multiple classifiers prior to making the inference

// multiple_classifier_classify_totalnn
fn multiple_classifier_classify_totalnn(index int, classifiers []Classifier, instances_to_be_classified [][]u8, labeled_classes []string, opts Options) ClassifyResult {
	mut final_cr := ClassifyResult{
		index: index
		multiple_flag: true
		Class: classifiers[0].Class
	}

	// get the lcm of the maximum hamming distances for each classifier
	mut maximum_hamming_distance_array := []int{}
	for cl in classifiers {
		maximum_hamming_distance_array << max_ham_dist(cl)
	}
	total_max_ham_dist := array_sum(maximum_hamming_distance_array)
	println('total_max_ham_dist: ${total_max_ham_dist}')
	lcm_max_ham_dist := lcm(maximum_hamming_distance_array)
	println('lcm_max_ham_dist: ${lcm_max_ham_dist}')
	// // println(opts.MultipleOptions)
	mut total_nns_by_class := []f64{len: 2}
	mut weighted_totals := []f64{len: 2}
	mut lcm_val := lcm(get_map_values(classifiers[0].class_counts))
	// mut lcm_val := lcm(get_map_values(classifiers[0].postpurge_class_counts))
	mut radius := 1

	mut nearest_neighbors_by_class_array := [][]f64{}
	// 	// mut mcr := MultipleClassifierResults{
	// 	// 	MultipleOptions: opts.MultipleOptions
	// 	// 	results_by_classifier: []IndividualClassifierResults{len: classifiers.len}
	// 	// }

	for i, cl in classifiers {
		// println('weighting_flag: $cl.weighting_flag')

		mut hamming_distances := []int{}
		for instance in cl.instances {
			mut hamming_dist := 0
			for j, byte_value in instances_to_be_classified[i] {
				hamming_dist += get_hamming_distance(byte_value, instance[j])
			}
			hamming_distances << hamming_dist
		}
		// get nearest neighbors for this classifier
		mut nearest_neighbors_by_class := []f64{len: cl.class_counts.len}
		// mut nearest_neighbors_by_class := []f64{len: cl.postpurge_class_counts.len}
		for class_index, class in cl.classes {
			for instance, distance in hamming_distances {
				if distance <= radius && class == cl.class_values[instance] {
					nearest_neighbors_by_class[class_index] += 1
				}
			}
		}

		// total nearest neigbors by class for all classifiers
		print('nearest_neighbors_by_class: ')
		println(nearest_neighbors_by_class)

		// the nearest neighbor counts need to be weighted by
		// the maximum hamming distance for each classifier
		if classifiers.len > 1 {
			nearest_neighbors_by_class_array << nearest_neighbors_by_class.map(it * lcm_max_ham_dist / (total_max_ham_dist - maximum_hamming_distance_array[i]))
		} else {
			nearest_neighbors_by_class_array << nearest_neighbors_by_class
		}
	}
	print('nearest_neighbors_by_class_array: ')
	println(nearest_neighbors_by_class_array)

	for nn in nearest_neighbors_by_class_array {
		for j, count in nn {
			total_nns_by_class[j] += count
		}
	}
	// println('total_nns_by_class: ${total_nns_by_class}')
	// weight by class prevalences
	println('lcm: ${lcm_val}')
	for j, nn in total_nns_by_class {
		weighted_totals[j] = f64(nn) * lcm_val / classifiers[0].class_counts[classifiers[0].class_values[j]]
	}
	// for cl in classifiers { println(cl.class_counts)}
	println('weighted_totals: ${weighted_totals}')

	if single_array_maximum(weighted_totals) {
		final_cr.inferred_class = classifiers[0].classes[idx_max(weighted_totals)]
		return final_cr
	}
	return final_cr
}

// max_ham_dist returns the maximum possible hamming distance for a classifier
fn max_ham_dist(cl Classifier) int {
	mut maximum_hamming_distance := 0
	for _, attr in cl.trained_attributes {
		// println(attr)
		if attr.attribute_type == 'C' {
			maximum_hamming_distance += attr.bins
		} else {
			maximum_hamming_distance += attr.translation_table.len
		}
	}
	return maximum_hamming_distance
}
