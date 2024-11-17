// totalnn.v

module vhammll

import arrays

// this version of multi_classify.v is to add up the nearest neighbors for the
// multiple classifiers prior to making the inference

// multiple_classifier_classify_totalnn calculates hamming distances between the case to be classified,
// and each instance in each of the classifiers. Starting with a hamming distance (ie, sphere radius)
// of zero, the instances with that hamming distance are tallied for each class, and weighted by the
// class prevalences if the particular classifier calls for it. These (possibly weighted) tallies
// for each classifier are totalled up for each class, weighted by the maximum hamming distance
// for each classifier. If these weighted totals yield a single maximum, that maximum yields
// the inferred class. If no single maximum, the sphere radius is incremented, and the process
// repeats for hamming distances which fit within the sphere, until a single maximum is found.
// If the sphere radius reaches the maximum possible hamming distance and no single maximum
// is found, then no class is inferred.
fn multiple_classifier_classify_totalnn(classifiers []Classifier, case [][]u8, labeled_classes []string, opts Options) ClassifyResult {
	mut final_cr := ClassifyResult{
		multiple_flag: true
		Class:         classifiers[0].Class
	}
	// println('case in multiple_classifier_classify_totalnn: $case')
	mut total_nns_by_class := []i64{len: 2}
	mut single_maxima := []bool{len: classifiers.len}
	// mut weighted_totals := []f64{len: 2}
	// mut lcm_val := lcm(get_map_values(classifiers[0].class_counts))
	mut nearest_neighbors_by_class := []i64{len: classifiers[0].prepurge_class_values_len}
	mut nearest_neighbors_by_class_unweighted := []i64{len: classifiers[0].prepurge_class_values_len}
	mut hamming_distances_array := [][]int{}
	// calculate hamming distances
	for i, cl in classifiers {
		// println('i in multiple_classifier_classify_totalnn: $i')
		mut hamming_distances := []int{}
		// println('cl.instances in multiple_classifier_classify_totalnn: $cl.instances')
		for instance in cl.instances {
			mut hamming_dist := 0
			for j, byte_value in case[i] {
				// println('j in multiple_classifier_classify_totalnn: $j')
				hamming_dist += get_hamming_distance(byte_value, instance[j])
			}
			hamming_distances << hamming_dist
		}
		hamming_distances_array << hamming_distances
	}
	// println('hamming_distances_array: $hamming_distances_array')
	mut radii := element_counts(arrays.flatten(hamming_distances_array)).keys()
	radii.sort()
	if opts.verbose_flag {
		println('radii: ${radii}')
	}
	mut nearest_neighbors_by_class_array := [][]i64{}
	mut classifier_weights := []i64{}
	mut class_weights := []int{}
	radius_loop: for radius in radii {
		nearest_neighbors_by_class_array = [][]i64{}
		classifier_weights.clear()
		for i, cl in classifiers {
			class_weights.clear()
			classifier_weighted_increment := opts.lcm_max_ham_dist / opts.maximum_hamming_distance_array[i]
			// classes_weighting := cl.lcm_max_ham_dist / cl.maximum_hamming_distance_array
			classifier_weights << classifier_weighted_increment

			nearest_neighbors_by_class = []i64{len: cl.class_counts.len, init: 0}
			nearest_neighbors_by_class_unweighted = []i64{len: cl.class_counts.len, init: 0}
			for class_index in 0 .. cl.classes.len {
				classes_weighting := int(i64(lcm(get_map_values(cl.class_counts))) / cl.class_counts[cl.classes[class_index]])
				class_weights << classes_weighting
				// 	if disp.verbose_flag {
				// 	println('classifier_weighted_increment: ${classifier_weighted_increment}     classes_weighting: ${classes_weighting}')
				// }
				for j, dist in hamming_distances_array[i] {
					if dist <= radius && cl.class_values[j] == cl.classes[class_index] {
						if opts.verbose_flag {
							nearest_neighbors_by_class_unweighted[class_index] += 1
						}
						nearest_neighbors_by_class[class_index] += (if !cl.weighting_flag
							|| cl.lcm_class_counts == 0 {
							classifier_weighted_increment
						} else {
							classifier_weighted_increment * classes_weighting
						})
					}
				}
			}
			if opts.verbose_flag {
				println('classifier: ${i}   radius: ${radius}    class_weights: ${class_weights}    classifier_weights: ${classifier_weights}   nearest_neighbors_by_class_unweighted: ${nearest_neighbors_by_class_unweighted}     lcm_class_counts: ${cl.lcm_class_counts}     nearest_neighbors_by_class: ${nearest_neighbors_by_class}')
			}
			nearest_neighbors_by_class_array << nearest_neighbors_by_class
		}
		for i, val in nearest_neighbors_by_class_array {
			if single_array_maximum(val) {
				single_maxima[i] = true
			}
		}
		// println('single_maxima: $single_maxima')
		if opts.break_on_all_flag {
			// continue until a class has been inferred for all the classifiers

			if single_maxima.all(it == true) {
				// println('not reached all yet')
				break radius_loop
			}
		} else {
			if single_maxima.any(it == true) {
				break radius_loop
			}
		}
	}
	// total up the nearest neighbors by class, for all the classifierss
	for nn in nearest_neighbors_by_class_array {
		for j, count in nn {
			total_nns_by_class[j] += count
		}
	}
	if opts.verbose_flag {
		println('total_nns_by_class: ${total_nns_by_class}')
	}
	if single_array_maximum(total_nns_by_class) {
		final_cr.inferred_class = classifiers[0].classes[idx_max(total_nns_by_class)]
		if opts.verbose_flag {
			println('final_cr.inferred_class: ${final_cr.inferred_class}')
		}
		return final_cr
	}

	// mut radius_row := []int{len:cl.class_counts.len}
	// for sphere_index, radius in radii {

	// // get nearest neighbors for this classifier
	// 	for class_index, class in cl.classes {
	// 		println('class_index: $class_index   class: $class')
	// 		for instance, distance in hamming_distances {
	// 			if distance <= radius && class == cl.class_values[instance] {
	// 				radius_row[class_index] += 1
	// 			}
	// 		}
	// 	}
	// 	println('radius_row: $radius_row')
	// 	if !single_array_maximum(radius_row) {continue}
	// 	nearest_neighbors_by_class = radius_row.clone()
	// 	println('perhaps hamming distance?: ${radii[sphere_index]}')
	// 	break

	// }

	// the nearest neighbor counts need to be weighted by
	// the maximum hamming distance for each classifier
	// if classifiers.len > 1 {
	// 	nearest_neighbors_by_class_array << nearest_neighbors_by_class.map(it * total_nn_params.lcm_max_ham_dist / (total_nn_params.total_max_ham_dist - total_nn_params.maximum_hamming_distance_array[i]))
	// } else {
	// 	nearest_neighbors_by_class_array << nearest_neighbors_by_class
	// }
	// // if disp.verbose_flag {
	// // 	println('${i:-7}       ${nearest_neighbors_by_class.map(int(it))}')
	// // }
	// // }
	// if disp.verbose_flag {
	// 	print('nearest_neighbors_by_class_array: ')
	// 	println(nearest_neighbors_by_class_array.map(it.map(int(it))))
	// }

	// println('total_nns_by_class: ${total_nns_by_class}')
	// // weight by class prevalences
	// if disp.verbose_flag {
	// 	println('lcm: ${lcm_val}')
	// }
	// for j, nn in total_nns_by_class {
	// 	weighted_totals[j] = f64(nn) * lcm_val / classifiers[0].class_counts[classifiers[0].class_values[j]]
	// }
	// for cl in classifiers {
	// 	println(cl.class_counts)
	// }
	// if disp.verbose_flag {
	// 	println('weighted_totals: ${weighted_totals}')
	// }
	// if single_array_maximum(weighted_totals) {
	// 	final_cr.inferred_class = classifiers[0].classes[idx_max(weighted_totals)]
	// 	// return final_cr
	// }
	// if disp.verbose_flag {
	// 	println('inferred class: ${final_cr.inferred_class}')
	// }
	return final_cr
}
