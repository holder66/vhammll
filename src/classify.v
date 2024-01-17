// classify.v
module vhammll

// import math

// to simplify the documentation, we will change "instance to be classified"
// to "case", and leave "instance" as referring to the classifier data.

// classify_instance takes a trained classifier and a case to be
// classified; it returns the inferred class for the case and the
// counts of nearest neighbors to all the classes.
// The classification algorithm calculates Hamming distances between
// the case to be classified and all the instances in the trained
// classifier; for the minimum hamming distance, the class with the
// most neighbors at that distance is the inferred class. In case of
// ties, the algorithm moves on to the next minimum hamming distance.
// ```sh
// Optional (specified in opts):
// weighting_flag: when true, nearest neighbor counts are weighted
// by class prevalences.
// ```
fn classify_case(cl Classifier, case []u8, opts Options, disp DisplaySettings) ClassifyResult {
	mut result := ClassifyResult{
		classes: cl.classes
		weighting_flag: cl.weighting_flag
	}
	// to classify, get Hamming distances between the entered instance and
	// all the instances in the classifier; return the class for the instance
	// giving the lowest Hamming distance.
	mut hamming_dist_array := []int{cap: cl.instances.len}
	mut hamming_dist := 0
	// classes := cl.class_counts.keys()
	// get the hamming distance for each of the corresponding byte_values
	// in each classifier instance and the instance to be classified
	for instance in cl.instances {
		hamming_dist = 0
		for i, byte_value in case {
			hamming_dist += get_hamming_distance(byte_value, instance[i])
		}
		hamming_dist_array << hamming_dist
	}
	// get unique values in hamming_dist_array; these are the radii
	// of the nearest-neighbor "spheres"
	mut radii := element_counts(hamming_dist_array).keys()
	radii.sort()
	mut radius_row := []int{len: cl.class_counts.len}
	for sphere_index, radius in radii {
		// populate the counts by class for this radius
		for class_index, class in cl.classes {
			for instance, distance in hamming_dist_array {
				if distance <= radius && class == cl.class_values[instance] {
					radius_row[class_index] += (if !opts.weighting_flag {
						1
					} else {
						// int(i64(lcm(get_map_values(cl.class_counts))) / cl.class_counts[cl.classes[class_index]])
						int(cl.lcm_class_counts / cl.class_counts[cl.classes[class_index]])
					})
				}
			}
		}
		if !single_array_maximum(radius_row) {
			continue
		}
		result.inferred_class = cl.classes[idx_max(radius_row)]
		// result.index = index
		result.nearest_neighbors_by_class = radius_row
		// result.classes = cl.classes
		// result.weighting_flag = cl.weighting_flag
		result.hamming_distance = radii[sphere_index]
		result.sphere_index = sphere_index
		break
	}
	// if disp.verbose_flag && opts.command == 'classify' {
	// 	println('ClassifyResult in classify.v: ${result}')
	// }
	if disp.verbose_flag {
		println('sphere index  radius  nearest neighbors  ratio  inferred class')
		// for i, icr in mcr.results_by_classifier {
		// 	a := icr.results_by_radius.last()
		println('${result.sphere_index:12}  ${result.hamming_distance:6}  ${result.nearest_neighbors_by_class:-17} ${get_ratio(result.nearest_neighbors_by_class):6.2f}  ${result.inferred_class} ')
		// }
		// println('${index:-7} ${class} ')
	}
	return result
}

// get_hamming_distance returns hamming distance between left and right,
// when both left and right are values which can be represented by a single
// bit if a bitstring were created
fn get_hamming_distance[T](left T, right T) int {
	if left == right {
		return 0
	}
	if left == u8(0) || right == u8(0) {
		return 1
	}
	return 2
}

// single_array_maximum returns true if a has only one maximum
fn single_array_maximum[T](a []T) bool {
	if a == [] {
		panic('single_array_maximum was called on an empty array')
	}
	if a.len == 1 {
		return true
	}
	mut b := a.clone()
	b.sort(a > b)
	if b[0] != b[1] {
		return true
	}
	return false
}
