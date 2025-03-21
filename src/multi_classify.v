// multiple.v

module vhammll

import arrays

// when multiple classifiers have been generated with different settings,
// a given case to be classified will take multiple values, one for
// each classifier, and corresponding to the settings for that classifier.
// If all the classifiers when applied to a given case agree, the final
// result is the agreed-upon class.
// If there is disagreement in the result from different classifiers for
// a given case,
// there are several options for coming up with a final result for that case:
// the default is to start with the lowest hamming distance which obtained
// a classification for any of the classifiers, and simply use the class
// chosen by the greatest number of classifiers at that hamming distance.
// If there are ties, go to the next lowest hamming distance and repeat.
// Variations which have been implemented:
// Flag -ma: break_on_all_flag
//    When multiple classifiers are used, stop classifying when matches
//    have been found for all classifiers;
// Flag -mc: combined_radii_flag
//    When multiple classifiers are used, combine the possible hamming
//    distances for each classifier into a single list;
// Flag -mt: total_nn_counts_flag
//    When multiple classifiers are used, add the nearest neighbors from
//    each classifier, weight by class prevalences, and then infer
//    from the totals;
// Not yet implemented:
// -mr for multiclass datasets, perform classification using a classifier for
//    each class, based on cases for that class set against all the other cases.

// multiple_classifier_classify
fn multiple_classifier_classify(classifier_array []Classifier, case [][]u8, labeled_classes []string, opts Options) ClassifyResult {
	mut final_cr := ClassifyResult{
		multiple_flag: true
		Class:         classifier_array[0].Class
	}
	mut mcr := MultipleClassifierResults{
		MultipleOptions:       opts.MultipleOptions
		results_by_classifier: []IndividualClassifierResults{len: classifier_array.len}
	}

	// to classify, get Hamming distances between the entered case and
	// all the instances in all the classifiers; return the class for the
	// instance giving the lowest Hamming distance.
	mut hamming_dist_arrays := [][]int{}
	// find the max number of attributes used
	for cl in classifier_array {
		mcr.number_of_attributes << cl.attribute_ordering.len
	}
	mcr.maximum_number_of_attributes = array_max(mcr.number_of_attributes)
	// and get the Least Common Multiple (lcm)
	mcr.lcm_attributes = lcm(mcr.number_of_attributes)
	// get the hamming distance for each of the corresponding byte_values
	// in each classifier instance and the case to be classified
	// note that to compare hamming distances between classifiers using
	// different numbers of attributes, the distances need to be weighted.
	for i, cl in classifier_array {
		mut hamming_distances := []int{}
		for instance in cl.instances {
			mut hamming_dist := 0
			// for j, byte_value in case[i] {
			// 	hamming_dist += int(get_hamming_distance(byte_value, instance[j]) * mcr.lcm_attributes / mcr.number_of_attributes[i])
			// }
			for j, byte_value in case[i] {
				hamming_dist += get_hamming_distance(byte_value, instance[j])
			}
			hamming_distances << hamming_dist
		}
		mut radii := uniques(hamming_distances)
		radii.sort()
		mut icr := IndividualClassifierResults{
			radii: radii
		}
		mcr.results_by_classifier[i] = icr
		final_cr.weighting_flag_array << cl.weighting_flag
		// multiply each value by the maximum number of attributes, and
		// divide by this classifier's number of attributes
		// hamming_dist_arrays << hamming_distances.map(it * mcr.maximum_number_of_attributes / cl.attribute_ordering.len)
		hamming_dist_arrays << hamming_distances
	}
	// mut nearest_neighbors_array := [][]int{cap: hamming_dist_arrays.len}
	// mut inferred_class_array := []string{len: hamming_dist_arrays.len, init: ''}
	mcr.max_sphere_index = array_max(mcr.results_by_classifier.map(it.radii.len))
	mut found := false
	if mcr.combined_radii_flag {
		// first, get a sorted list of all possible hamming distances
		for row in hamming_dist_arrays {
			mcr.combined_radii = arrays.merge(mcr.combined_radii, uniques(row))
		}
		mcr.combined_radii = uniques(mcr.combined_radii)
		mcr.combined_radii.sort()
		mcr.max_sphere_index = mcr.combined_radii.len
		// for each possible hamming distance...
		combined_radii_loop: for sphere_index, radius in mcr.combined_radii {
			// cycle through each classifier...
			for i, row in hamming_dist_arrays {
				// if we've already found an inferred class with this classifier, skip
				lcm_class_counts := classifier_array[i].lcm_class_counts
				if mcr.results_by_classifier[i].inferred_class == '' {
					mut rr := RadiusResults{
						sphere_index:               sphere_index
						radius:                     radius
						nearest_neighbors_by_class: []int{len: classifier_array[i].class_counts.len}
					}
					// cycle through each class...
					for class_index, class in classifier_array[i].classes {
						for instance, distance in row {
							if distance <= radius
								&& class == classifier_array[i].class_values[instance] {
								rr.nearest_neighbors_by_class[class_index] += if !classifier_array[i].weighting_flag {
									1
								} else {
									int(lcm_class_counts / classifier_array[i].class_counts[classifier_array[i].classes[class_index]])
									// 1
								}
							}
						}
					}
					if single_array_maximum(rr.nearest_neighbors_by_class) {
						rr.inferred_class_found = true
						rr.inferred_class = classifier_array[i].classes[idx_max(rr.nearest_neighbors_by_class)]
						mcr.results_by_classifier[i].inferred_class = rr.inferred_class
					}
					mcr.results_by_classifier[i].results_by_radius << rr
				}
			} // end of loop cycling thru classifier_array
			// collect the inferred_class_found values
			if mcr.break_on_all_flag {
				found = mcr.results_by_classifier.map(it.results_by_radius.last().inferred_class_found).all(it)
			} else {
				found = mcr.results_by_classifier.any(it.results_by_radius.any(it.inferred_class_found))
			}
			if found {
				break combined_radii_loop
			}
			final_cr.sphere_index = sphere_index
		} // end of loop through radii
	} else { // ie, do not use combined radii
		mut sphere_index := 0
		// cycle through each sphere_index
		sphere_index_loop: for {
			// cycle through each classifier...
			for i, row in hamming_dist_arrays {
				// if we've already found an inferred class with this classifier, or if no more radii left, skip
				if mcr.results_by_classifier[i].inferred_class == ''
					&& sphere_index < mcr.results_by_classifier[i].radii.len {
					radius := mcr.results_by_classifier[i].radii[sphere_index]
					mut rr := RadiusResults{
						sphere_index:               sphere_index
						radius:                     radius
						nearest_neighbors_by_class: []int{len: classifier_array[i].class_counts.len}
					}
					// cycle through each class...
					for class_index, class in classifier_array[i].classes {
						for instance, distance in row {
							if distance <= radius
								&& class == classifier_array[i].class_values[instance] {
								rr.nearest_neighbors_by_class[class_index] += if !classifier_array[i].weighting_flag {
									1
								} else {
									int(i64(lcm(classifier_array[i].class_counts.values())) / classifier_array[i].class_counts[classifier_array[i].classes[class_index]])
									// 1
								}
							}
						}
					}
					if single_array_maximum(rr.nearest_neighbors_by_class) {
						rr.inferred_class_found = true
						rr.inferred_class = classifier_array[i].classes[idx_max(rr.nearest_neighbors_by_class)]
						mcr.results_by_classifier[i].inferred_class = rr.inferred_class
					}
					mcr.results_by_classifier[i].results_by_radius << rr
				}
			} // end of loop cycling thru classifier_array
			// collect the inferred_class_found values
			if mcr.break_on_all_flag {
				found = mcr.results_by_classifier.map(it.results_by_radius.last().inferred_class_found).all(it)
			} else {
				found = mcr.results_by_classifier.any(it.results_by_radius.any(it.inferred_class_found))
			}
			if found || sphere_index >= mcr.max_sphere_index {
				break sphere_index_loop
			}
			final_cr.sphere_index = sphere_index
			sphere_index++
		} // end of loop through sphere indices
	} // end of else if (ie not using combined radii)
	// if !found {
	// 	println(mcr)
	// 	panic('failed to infer a class')
	// }
	// if inferred_class_array.all(it == '') {
	// 	panic('failed to infer a class')
	// }
	// collect the classes inferred by each classifier
	// dump(mcr.results_by_classifier.map(it.inferred_class))
	inferred_classes_by_classifier := mcr.results_by_classifier.map(it.inferred_class)
	if inferred_classes_by_classifier.len > 1
		&& uniques(inferred_classes_by_classifier.filter(it != '')).len > 1 {
		final_cr.inferred_class = resolve_conflict(mcr, opts)
		if opts.verbose_flag {
			show_detailed_result(final_cr.inferred_class, labeled_classes, mcr)
		}
	} else {
		// this breaks if the inferred class is '' ! What now?
		if inferred_classes_by_classifier.filter(it != '').len == 0 {
			final_cr.inferred_class = ''
		} else {
			// dump(inferred_classes_by_classifier.filter(it != ''))
			final_cr.inferred_class = uniques(inferred_classes_by_classifier.filter(it != ''))[0]
		}
	}

	// final_cr.inferred_class_array = inferred_class_array
	// final_cr.nearest_neighbors_array = nearest_neighbors_array
	if opts.verbose_flag {
		show_detailed_result(final_cr.inferred_class, labeled_classes, mcr)
	}
	return final_cr
}

// resolve_conflict
fn resolve_conflict(mcr MultipleClassifierResults, opts Options) string {
	// println(mcr)
	// at the smallest sphere radius, can we get a majority vote?
	// note that there should only be one maximum value
	mut sphere_index := 0
	for {
		mut infs := arrays.flatten(mcr.results_by_classifier.map(it.results_by_radius.filter(
			it.sphere_index == sphere_index && it.inferred_class_found).map(it.inferred_class)))
		// println(infs)
		// println(element_counts(infs))
		// if element_counts(infs).len > 0 {
		// 	// get maximum value of element_counts
		// 	// max := array_max(infs)
		// 	// println(infs.filter(it == array_max(element_counts(infs).values())))
		// 	println('Majority vote')
		// 	println(get_map_key_for_max_value(element_counts(infs)))
		// 	return get_map_key_for_max_value(element_counts(infs))
		// }

		// test for a plurality vote
		if plurality_vote(infs) != '' {
			if opts.verbose_flag {
				println('Plurality_vote')
			}
			return plurality_vote(infs)
		}

		// test for a majority vote
		if majority_vote(infs) != '' {
			if opts.verbose_flag {
				println('Majority vote')
			}
			return majority_vote(infs)
		}
		// println(mcr.results_by_classifier.map(it.results_by_radius.map(it.inferred_class_found.)))
		sphere_index++
		if sphere_index >= mcr.max_sphere_index {
			break
		}
	}
	if opts.verbose_flag {
		println('Majority vote fell through')
	}
	// pick the result with the greatest number of nearest neighbors
	// sums := mcr.results_by_classifier.map(it.results_by_radius.last()).map(it.nearest_neighbors_by_class).map(array_sum(it))
	// return mcr.results_by_classifier[idx_max(sums)].inferred_class

	// pick the result with the biggest ratio between classes
	// to avoid dividing by zero, if one of the nearest neighbors values
	// is zero, just use the other one as the ratio
	ratios := mcr.results_by_classifier.map(it.results_by_radius.last()).map(it.nearest_neighbors_by_class).map(get_ratio(it))
	// println(ratios)
	return mcr.results_by_classifier[idx_max(ratios)].inferred_class

	// if mcr.results_by_classifier.len == 2 {
	// 	absolute_differences := mcr.results_by_classifier.map(it.results_by_radius.map(math.abs(it.nearest_neighbors_by_class[0] - it.nearest_neighbors_by_class[1]))).map(it[0])
	// 	println('absolute nearest neighbor differences: ${absolute_differences}')
	// 	// println(idx_max(absolute_differences))
	// 	icr_idx := idx_max(absolute_differences)
	// 	return mcr.results_by_classifier[icr_idx].inferred_class
	// }
	// println('inside resolve_conflict()')
	// return 'unresolved conflict'
	// return get_map_key_for_max_value(element_counts(inferred_class_array_filtered))
	// filter out the null classifier results
	// inferred_class_array_filtered := inferred_class_array.filter(it != '')
	// return get_map_key_for_max_value(element_counts(inferred_class_array_filtered))
	// nearest_neighbors_array_filtered := nearest_neighbors_array.filter(it.len == 0)
	// zero_nn := nearest_neighbors_array.filter(0 in it).len
	// println(uniques(inferred_class_array).filter(it != ''))
	// println(uniques(inferred_class_array).filter(it != '')[0])
	// match true {
	// if only one of the nearest neighbors lists has entries,
	// use that inferred class
	// inferred_class_array.filter(it != '').len == 1 {
	// 	println('only one entry in inferred class array')
	// 	return inferred_class_array.filter(it != '')[0]
	// }
	// if the number of inferred classes is an odd number, pick
	// the winner
	// inferred_class_array_filtered.len % 2 != 0 {
	// 	return get_map_key_for_max_value(element_counts(inferred_class_array_filtered))
	// }

	// if only one of the nearest neighbors lists has a zero, use that
	// inferred class
	// zero_nn == 1 {
	// 	println('only one entry has a zero')
	// return inferred_class_array[idx_max(nearest_neighbors_array.map(math.abs(it[0]-it[1])))]
	// 	// println(inferred_class_array[idx_true(nearest_neighbors_array.map(0 in it))])
	// 	// return inferred_class_array[idx_true(nearest_neighbors_array.map(0 in it))]
	// }

	// zero_nn > 1 {
	// 	// 	when there are 2 or more results with zeros, pick the
	// 	// 	result having the largest maximum, and use that maximum
	// 	// 	to get the inferred class
	// 	println(nearest_neighbors_array.map(array_max(it)))
	// 	println(idx_max(nearest_neighbors_array.map(array_max(it))))
	// 	// println(classifier_array[i].classes[idx_max(nearest_neighbors_array[idx_max(nearest_neighbors_array.map(array_max(it)))])])
	// 	// classifier_array[i].classes[idx_max(nearest_neighbors_array[idx_max(nearest_neighbors_array.map(array_max(it)))])]
	// 	return inferred_class_array[idx_true(nearest_neighbors_array.map(0 in it))]
	// }
	// else {
	// 	// when none of the results have zeros in them, pick the
	// 	// result having the largest ratio of its maximum to the
	// 	// average of the other nearest neighbor counts
	// 	mut max_nn := 0
	// 	mut sum_nn := 0
	// 	mut avg_nn := 0.0
	// 	mut ratios_array := []f64{}

	// 	for nearest_neighbors in nearest_neighbors_array {
	// 		// i_nn := idx_max(nearest_neighbors)
	// 		if nearest_neighbors.len > 0 {
	// 			max_nn = array_max(nearest_neighbors)
	// 			sum_nn = array_sum(nearest_neighbors)
	// 			// average of non-maximum values
	// 			avg_nn = (sum_nn - max_nn) / (nearest_neighbors.len - 1)
	// 			// println('i_nn: $i_nn max_nn: $max_nn sum_nn: $sum_nn avg_nn: $avg_nn')
	// 			// get ratio
	// 			// println(max_nn / avg_nn)
	// 			ratios_array << (max_nn / avg_nn)
	// 		} else {
	// 			ratios_array << 0
	// 		}
	// 		// println('ratios_array: $ratios_array')
	// 	}
	// 	return inferred_class_array[idx_max(nearest_neighbors_array.map(math.abs(it[0]-it[1])))]
	// 	// return inferred_class_array[idx_max(ratios_array)]
	// 	// println(cl0.classes[idx_max(nearest_neighbors_array[idx_max(ratios_array)])])
	// 	// final_cr.inferred_class = cl.classes[idx_max(mcr.nearest_neighbors_array[idx_max(ratios_array)])]
	// }
	// }
}
