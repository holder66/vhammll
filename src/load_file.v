module vhammll

import os
import strconv
// import x.json2
import regex

// load_file returns a struct containing the datafile's contents,
// suitable for generating a classifier
//
// Example:
// ```sh
// ds := load_file('datasets/iris.tab')
// ```

pub fn load_file(path string, opts LoadOptions) Dataset {
	mut ds := Dataset{}
	ds = match file_type(path) {
		'orange_newer' { load_orange_newer_file(path, opts) }
		'orange_older' { load_orange_older_file(path, opts) }
		'arff' { load_arff_file(path) }
		'UKDA' { load_orange_newer_file(path, opts) }
		'csv' { load_csv_file(path) }
		else { panic('unrecognized file type') }
	}
	if opts.balance_prevalences_flag {
		// multiply the instances in each class to approximately balance the prevalences. Approximately, because one can only multiply by an integer value.
		mut transposed_data := transpose(ds.data)
		mut multipliers := map[string]int{}
		for class, count in ds.class_counts {
			multipliers[class] = (ds.class_values.len - count) / count
		}
		mut idx := 0
		for class in ds.class_values {
			if multipliers[class] > 0 {
				for _ in 1 .. multipliers[class] {
					transposed_data.insert(idx, transposed_data[idx])
					idx += 1
				}
			}
			idx += 1
		}
		ds.data = transpose(transposed_data)
		// update the Class struct items
		ds.class_values = ds.data[ds.attribute_names.index(ds.class_name)]
		ds.class_counts = element_counts(ds.class_values)
		// redo the useful_attribute maps
		ds.useful_continuous_attributes = get_useful_continuous_attributes(ds)
		ds.useful_discrete_attributes = get_useful_discrete_attributes(ds)
	}
	return ds
}

// evaluate_class_prevalence_imbalance returns true if the ratio between the
// minimum and maximum class counts for the dataset specified by `datafile_path`
// in Options, exceeds the threshold specified by Options.balance_prevalence_threshold.
fn evaluate_class_prevalence_imbalance(opts Options) bool {
	ds := load_file(opts.datafile_path)
	mut class_counts_array := ds.class_counts.values()
	if f64(array_min(class_counts_array)) / array_max(class_counts_array) <= opts.balance_prevalences_threshold {
		return true
	}
	return false
}

// file_type returns a string identifying how a dataset is structured or
// formatted, eg 'orange_newer', 'orange_older', 'arff', or 'csv'.
// On the assumption that an 'orange_older' file will always identify
// a class attribute by having 'c' or 'class' in the third header line,
// all other tab-delimited datafiles will be typed as 'orange_newer'.
//
// Example:
// ```v
// assert file_type('datasets/iris.tab') == 'orange_older'
// ```
pub fn file_type(path string) string {
	header := os.read_lines(path.trim_space()) or { panic('Failed to open ${path} in file_type()') }
	return match true {
		os.file_ext(path) == '.arff' { 'arff' }
		os.file_ext(path) == '.csv' { 'csv' }
		header[2].split('\t').any(it == 'c' || it == 'class') { 'orange_older' }
		else { 'orange_newer' }
	}
}

fn extract_words(line string) []string {
	mut splitted := []string{}
	for tab_splitted in line.split('\t') {
		splitted << tab_splitted
	}
	// println('splitted: $splitted')
	return splitted
}

// infer_type_from_data
fn infer_type_from_data(values []string, lo LoadOptions) string {
	no_missing_values := values.filter(it !in lo.missings)
	// if no data, 'i'
	if no_missing_values == [] {
		return 'i'
	}
	// if all the elements are identical, then the attribute is useless, so 'i'
	if uniques(no_missing_values).len == 1 {
		return 'i'
	}
	// else, examine individual data elements
	mut re := regex.regex_opt(r'[g-zG-Z]+') or { panic(err) }
	// if any nonmissing element has nonnumeric values
	for element in no_missing_values {
		start, _ := re.find(element)
		if start >= 0 { // ie contains nonnumeric
			return 'D'
		}
	}
	// at this point, we assume all the values are numeric
	// test that non-missing integer values are all in the range for discrete attributes
	// verify that there are no non-integer values
	if no_missing_values.any(it.contains('.')) {
		return 'C'
	}
	if no_missing_values.map(it.int()).all(it in lo.integer_range_for_discrete) {
		return 'D'
	}
	return 'C'
}

fn replace_missing_value(w string, missings []string) f32 {
	if w in missings {
		return nan[f32]()
	}
	return f32(strconv.atof_quick(w))
}

// get_useful_continuous_attributes
pub fn get_useful_continuous_attributes(ds Dataset) map[int][]f32 {
	// initialize the values of the result to -max_f32, to indicate missing values
	// mut min_value := f32(0.)
	// mut max_value := f32{0.}
	mut cont_att := map[int][]f32{}
	for i in 0 .. ds.attribute_names.len {
		if ds.attribute_types[i] == 'C' && element_counts(ds.data[i]).len != 1 {
			nums := ds.data[i].map(replace_missing_value(it, ds.missings))
			cont_att[i] = nums
		}
	}
	return cont_att
}

// get_useful_discrete_attributes
pub fn get_useful_discrete_attributes(ds Dataset) map[int][]string {
	mut disc_att := map[int][]string{}
	for i in 0 .. ds.attribute_names.len {
		// println('i: $i ds.attribute_types[i]: ${ds.attribute_types[i]} uniques(ds.data[i]).len: ${uniques(ds.data[i]).len}')
		if ds.attribute_types[i] == 'D' && uniques(ds.data[i]).len != 1 {
			disc_att[i] = ds.data[i]
		}
	}
	// println('disc_att: $disc_att')
	return disc_att
}

// set_class_struct
pub fn set_class_struct(ds Dataset) Class {
	mut cl := Class{}
	// find the attribute whose type is 'c'
	mut i := identify_class_attribute(ds.attribute_types)
	// println('i in set_class_struct: $i')
	// i == -1 if no class attribute found
	// in this case, set the last Discrete attribute as the class
	// attribute if it does not have a coded type
	if i == -1 {
		i = ds.attribute_names.len
		discrete_atts := ds.useful_discrete_attributes.keys()
		// println('discrete_atts: $discrete_atts')
		for {
			// println('i: ${i}')
			if i in discrete_atts || i < 0 {
				break
			} else {
				i -= 1
			}
		}
	}
	if i < 0 {
		return Class{}
	} else {
		cl = Class{
			class_name:                ds.attribute_names[i]
			class_index:               i
			class_values:              ds.data[i]
			class_counts:              element_counts(ds.data[i])
			prepurge_class_values_len: ds.data[i].len
			// class_counts: class_counts
			classes: uniques(ds.data[i])
		}
	}

	return cl
}

// identify_class_attribute returns the index for the class attribute; if
// none found, returns -1
fn identify_class_attribute(attribute_types []string) int {
	for i, val in attribute_types {
		if val == 'c' {
			return i
		}
	}
	return -1
}
