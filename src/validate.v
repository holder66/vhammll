// validate.v
/*
Given a classifier and a validation dataset, classifies each instance
of the validation_set on the trained classifier; returns the predicted classes
for each instance of the validation_set.
If a Kaggle file path is provided, a CSV file will be created with two columns.
The first column is a row identifier, and is taken from the first column of
the file to be validated if that attribute is identified as metadata (ie, m#...)
Thus, for Kaggle, adjust their test file by adding (if necessary) a row
identifier attribute, and make sure that there is a class attribute whose
values are empty.
*/
module vhammll

import os

// validate classifies each instance of a validation datafile against
// a trained Classifier; returns the predicted classes for each instance
// of the validation_set.
// The file to be validated is specified by `opts.testfile_path`.
// Optionally, saves the instances and their predicted classes in a file.
// This file can be used to append these instances to the classifier.
pub fn validate(cl Classifier, opts Options, disp DisplaySettings) !ValidateResult {
	// load the testfile as a Dataset struct
	// println(opts)
	mut test_ds := load_file(opts.testfile_path)
	// instantiate a struct for the result
	mut validate_result := ValidateResult{
		LoadOptions: cl.LoadOptions
		struct_type: '.ValidateResult'
		inferred_classes: []string{}
		validate_file_path: opts.testfile_path
		datafile_path: opts.datafile_path
		exclude_flag: opts.exclude_flag
		purge_flag: opts.purge_flag
		weighting_flag: opts.weighting_flag
		number_of_attributes: opts.number_of_attributes
		binning: cl.binning
		classifier_instances_counts: [cl.history[0].instances_count]
		prepurge_instances_counts_array: [cl.history[0].prepurge_instances_count]
	}
	// for each usable attribute in cl, massage the equivalent test_ds attribute
	mut test_binned_values := []int{}
	mut test_attr_binned_values := [][]u8{}
	mut test_index := 0
	for attr in cl.attribute_ordering {
		// get an index into this attribute in test_ds
		for j, value in test_ds.attribute_names {
			if value == attr {
				test_index = j
			}
		}
		if cl.trained_attributes[attr].attribute_type == 'C' {
			test_binned_values = discretize_attribute[f32](test_ds.useful_continuous_attributes[test_index],
				cl.trained_attributes[attr].minimum, cl.trained_attributes[attr].maximum,
				cl.trained_attributes[attr].bins)
		} else { // ie for discrete attributes
			test_binned_values = test_ds.useful_discrete_attributes[test_index].map(cl.trained_attributes[attr].translation_table[it])
		}
		test_attr_binned_values << test_binned_values.map(u8(it))
	}
	cases := transpose(test_attr_binned_values)
	// for each instance in the test data, perform a classification and compile the results
	validate_result = classify_to_validate(cl, cases, mut validate_result, opts, disp)
	if opts.command == 'validate' && (disp.show_flag || disp.expanded_flag) {
		show_validate(validate_result)
	}
	if opts.outputfile_path != '' {
		validate_result.instances = cases
		save_json_file(validate_result, opts.outputfile_path)
	}
	// println(validate_result)
	// println('opts.kagglefile_path: $opts.kagglefile_path')
	if opts.kagglefile_path != '' {
		// test if there is a metadata attribute as the first attribute (as row identifier)
		if test_ds.attribute_types[0] != 'm' {
			println('Validate failed: the file to be verified, "${opts.testfile_path}", does not have a metadata attribute in the first column, for use as a row identifier.')
			exit(1)
		}
		mut f := os.create(opts.kagglefile_path) or { panic('file not writeable') }
		f.writeln(test_ds.attribute_names[0] + ',' + validate_result.class_name) or {
			panic('write class name problem')
		}
		for i, result in validate_result.inferred_classes {
			// println(test_ds.row_identifiers[i] + ',' + result)
			f.writeln(test_ds.row_identifiers[i] + ',' + result) or { panic('write problem') }
		}
		f.close()
	}
	return validate_result
}

// classify_to_validate
fn classify_to_validate(cl Classifier, cases [][]u8, mut result ValidateResult, opts Options, disp DisplaySettings) ValidateResult {
	result.Class = cl.Class
	mut classify_result := ClassifyResult{}
	// for each case in the test data, perform a classification
	for case in cases {
		classify_result = classify_case(cl, case, opts, disp)
		result.inferred_classes << classify_result.inferred_class
		result.counts << classify_result.nearest_neighbors_by_class
	}
	return result
}
