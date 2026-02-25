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
// Flag -mc: sets multi_strategy = 'combined'
//    When multiple classifiers are used, combine the possible hamming
//    distances for each classifier into a single list;
// Flag -mt: sets multi_strategy = 'totalnn'
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
			for j, byte_value in case[i] {
				hamming_dist += int(get_hamming_distance(byte_value, instance[j]) * mcr.lcm_attributes / mcr.number_of_attributes[i])
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
	if mcr.multi_strategy == 'combined' {
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
	// pick the result with the biggest ratio between classes
	// to avoid dividing by zero, if one of the nearest neighbors values
	// is zero, just use the other one as the ratio
	ratios := mcr.results_by_classifier.map(it.results_by_radius.last()).map(it.nearest_neighbors_by_class).map(get_ratio(it))
	return mcr.results_by_classifier[idx_max(ratios)].inferred_class
}
