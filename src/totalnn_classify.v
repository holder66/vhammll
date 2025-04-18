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
// case_array has an array for each classifier; these arrays contain bin numbers, one for each attribute
// used in the classifier, which corresponds to the actual case value for that attribute (ie after binning)
fn multiple_classifier_classify_totalnn(classifier_array []Classifier, case_array [][]u8, labeled_classes []string, opts Options) ClassifyResult {
	mut final_cr := ClassifyResult{
		multiple_flag: true
		Class:         classifier_array[0].Class
	}
	mut total_nns_by_class := []i64{len: classifier_array[0].classes.len}
	mut single_maxima := []bool{len: classifier_array.len}
	mut nearest_neighbors_by_class := []i64{len: classifier_array[0].classes.len}
	mut hamming_distances_array := [][]int{}
	mut maximum_hamming_distance_array := []int{}
	for cl in classifier_array {
		maximum_hamming_distance_array << cl.maximum_hamming_distance
	}
	// calculate hamming distances
	for i, cl in classifier_array {
		mut hamming_distances := []int{}
		for instance in cl.instances {
			mut hamming_dist := 0
			for j, byte_value in case_array[i] {
				hamming_dist += get_hamming_distance(byte_value, instance[j])
			}
			hamming_distances << hamming_dist
		}
		final_cr.weighting_flag_array << cl.weighting_flag
		hamming_distances_array << hamming_distances
	}
	mut radii := element_counts(arrays.flatten(hamming_distances_array)).keys()
	radii.sort()
	mut nearest_neighbors_by_class_array := [][]i64{}
	mut classifier_weights := []i64{}
	radius_loop: for radius in radii {
		nearest_neighbors_by_class_array = [][]i64{}
		classifier_weights.clear()
		for i, cl in classifier_array {
			classifier_weighted_increment := lcm(maximum_hamming_distance_array) / maximum_hamming_distance_array[i]
			classifier_weights << classifier_weighted_increment
			nearest_neighbors_by_class = []i64{len: cl.class_counts.len, init: 0}
			for class_index in 0 .. cl.classes.len {
				classes_weighting := int(i64(lcm(cl.class_counts.values())) / cl.class_counts[cl.classes[class_index]])
				for j, dist in hamming_distances_array[i] {
					if dist <= radius && cl.class_values[j] == cl.classes[class_index] {
						nearest_neighbors_by_class[class_index] += (if !cl.weighting_flag
							|| cl.lcm_class_counts == 0 {
							classifier_weighted_increment
						} else {
							classifier_weighted_increment * classes_weighting
						})
					}
				}
			}
			nearest_neighbors_by_class_array << nearest_neighbors_by_class
		}
		for i, val in nearest_neighbors_by_class_array {
			if single_array_maximum(val) {
				single_maxima[i] = true
			}
		}
		if opts.break_on_all_flag {
			// continue until a class has been inferred for all the classifiers
			if single_maxima.all(it == true) {
				break radius_loop
			}
		} else {
			if single_maxima.any(it == true) {
				break radius_loop
			}
		}
	}
	// total up the nearest neighbors by class, for all the classifiers
	for i, nn in nearest_neighbors_by_class_array {
		for j, count in nn {
			total_nns_by_class[j] += count * opts.lcm_max_ham_dist / classifier_weights[i]
		}
	}
	if single_array_maximum(total_nns_by_class) {
		final_cr.inferred_class = classifier_array[0].classes[idx_max(total_nns_by_class)]
		return final_cr
	}
	return final_cr
}
