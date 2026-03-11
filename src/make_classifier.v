module vhammll

import time

const make_help = '
Description:
"make" creates a classifier from the datafile given as the last argument.
Returns a classifier struct.

Usage: v run main.v make -s <path_to_dataset_file>

Options:
  -a --attributes: the number of attributes (picked from the list of
      ranked attributes) to be used in training the classifier
  -b --bins: eg, "3,6" specifies the lower and upper limits for the number
      of slices or bins for continuous attributes;
  -bp --balanced-prevalences: add instances to balance class prevalences;
  -bpt --balance-prevalences-threshold: ratio threshold below which class
      prevalences are considered imbalanced (default 0.9; range 0.0–1.0);
  -e --expanded: display the classifier struct on the console.
  -ms: followed by the path to a settings file; appends the classifier
      settings to that file for later use in multiple classification;
  -o --output: followed by the path to a file in which the classifier will be stored;
  -p --purge: remove instances which are duplicates after binning;
  -sw --switches: use the dominant-class switch count when ranking attributes
      (2-class datasets only); bin counts whose switch count exceeds the
      threshold are excluded from the rank value search;
  -swt --switch-threshold: maximum permitted switches per bin count when
      -sw is active (default 2);
  -wr: when ranking attributes, weight contributions by class prevalences;
  -x --exclude: exclude missing values from rank value calculations.
    '

// make_classifier returns a Classifier struct, given a Dataset (as created by
// load_file).
// ```sh
// Options (also see the Options struct):
// bins: range for binning or slicing of continuous attributes;
// uniform_bins: same number of bins for continuous attributes;
// number_of_attributes: the number of highest-ranked attributes to include;
// exclude_flag: excludes missing values when ranking attributes;
// purge_flag: remove those instances which are duplicates, after
//     binning and based on only the attributes to be used;
// balance_prevalences_flag: when true, duplicates instances of minority
//     classes until class prevalences are sufficiently balanced;
// balance_prevalences_threshold: the min/max class-count ratio below which
//     balancing is triggered (default 0.9; set via -bpt);
// switches_flag: when true and the dataset has exactly 2 classes, excludes
//     bin counts whose dominant-class switch count exceeds switches_threshold
//     from the rank value search; attributes where every bin count exceeds
//     the threshold receive rank value 0;
// switches_threshold: maximum permitted switches per bin count when
//     switches_flag is active (default 2);
// outputfile_path: if specified, saves the classifier to this file;
// append_settings_flag / settingsfile_path: if set, appends the classifier
//     parameters as a ClassifierSettings entry to the given settings file.
// ```
pub fn make_classifier(opts Options) Classifier {
	mut ds := load_file(opts.datafile_path, opts.LoadOptions)
	// if the balance_prevalences flag is set, then we need to possibly add
	// the extra cases at this stage
	if opts.balance_prevalences_flag && evaluate_class_prevalence_imbalance(ds, opts) {
		ds = balance_prevalences(mut ds, opts.balance_prevalences_threshold)
	}
	return make_classifier_using_ds(mut ds, opts)
}

fn make_classifier_using_ds(mut ds Dataset, opts Options) Classifier {
	mut cl := Classifier{
		Class:         ds.Class
		Parameters:    opts.Parameters
		datafile_path: ds.path
		LoadOptions:   opts.LoadOptions
	}
	// // if the balance_prevalences flag is set, then we need to possibly add
	// // the extra cases at this stage
	// if opts.balance_prevalences_flag && evaluate_class_prevalence_imbalance(ds, opts) {
	// 	ds = balance_prevalences(mut ds, opts.balance_prevalences_threshold)
	// }
	// dump(cl)
	// if binning is specified already in parameters, use it
	if opts.binning.lower > 0 {
		cl.binning = opts.binning
	} else {
		cl.binning = get_binning(opts.bins) // this may mean getting default values
	}
	// calculate the least common multiple for class_counts, for use
	// when the weighting_flag is set
	if opts.weighting_flag {
		cl.lcm_class_counts = i64(lcm(ds.class_counts.values()))
	}
	// first, rank the attributes using the bins and exclude params, and take
	// the highest-ranked number_of_attributes (all the usable attributes if
	// number_of_attributes is 0)
	mut rank_opts := opts
	rank_opts.binning = cl.binning
	// Use rank_dataset (not rank_attributes) so ranking is performed on the
	// already-loaded in-memory Dataset ds — which, during cross-validation,
	// is the fold-excluded training partition rather than the full file.
	ranking_result := rank_dataset(ds, rank_opts)
	mut ranked_attributes := ranking_result.array_of_ranked_attributes.clone()

	if opts.number_of_attributes[0] != 0 && opts.number_of_attributes[0] < ranked_attributes.len {
		ranked_attributes = ranked_attributes[..opts.number_of_attributes[0]].clone()
	}
	// for continuous attributes, discretize and get binned values
	// for discrete attributes, create a translation table to go from
	// strings to integers (note that this table needs to be saved)
	mut attr_values := []f32{}
	mut attr_string_values := []string{}
	mut min := f32(0.0)
	mut max := f32(0.0)
	mut binned_values := [1]
	mut translation_table := map[string]int{}
	mut attr_binned_values := [][]u8{}
	mut attr_names := []string{}
	for ra in ranked_attributes {
		attr_names << ra.attribute_name
		if ra.attribute_type == 'C' {
			attr_values = ds.useful_continuous_attributes[ra.attribute_index]
			min = array_min(attr_values.filter(!is_nan(it)))
			max = array_max(attr_values.filter(!is_nan(it)))
			binned_values = discretize_attribute_with_range_check(attr_values, min, max,
				ra.bins)
			cl.trained_attributes[ra.attribute_name] = TrainedAttribute{
				attribute_type: ra.attribute_type
				minimum:        min
				maximum:        max
				bins:           ra.bins
				rank_value:     ra.rank_value
				index:          ra.attribute_index
				switches:       ra.switches
			}
		} else { // ie for discrete attributes
			attr_string_values = ds.useful_discrete_attributes[ra.attribute_index]
			translation_table = make_translation_table(attr_string_values, opts.missings)
			// use the translation table to generate an array of translated values
			binned_values = attr_string_values.map(translation_table[it])
			cl.trained_attributes[ra.attribute_name] = TrainedAttribute{
				attribute_type:    ra.attribute_type
				translation_table: translation_table
				rank_value:        ra.rank_value
				index:             ra.attribute_index
			}
		}
		attr_binned_values << binned_values.map(u8(it))
	}
	// get the maximum possible hamming distance for this classifier
	cl.maximum_hamming_distance = max_ham_dist(cl.trained_attributes)
	cl.instances = transpose(attr_binned_values)
	cl.attribute_ordering = attr_names
	prepurge_instances_count := cl.instances.len
	if opts.purge_flag {
		cl = purge(cl)
		cl.postpurge_class_counts = element_counts(cl.class_values)
		cl.postpurge_lcm_class_counts = i64(lcm(cl.postpurge_class_counts.values()))
		cl.class_counts = element_counts(cl.class_values)
		cl.lcm_class_counts = cl.postpurge_lcm_class_counts
	}
	// create an event
	mut event := HistoryEvent{
		event:                    'make'
		instances_count:          cl.instances.len
		prepurge_instances_count: prepurge_instances_count
	}
	if opts.command in ['make', 'append', 'verify', 'validate', 'query'] {
		event.file_path = ds.path
		event.event_date = time.utc().str()
		event.Environment = get_environment()
	}
	cl.history_events << event
	if (opts.show_flag || opts.expanded_flag) && opts.command == 'make' {
		show_classifier(cl)
	}
	if opts.outputfile_path != '' {
		save_json_file[Classifier](cl, opts.outputfile_path)
	}
	if opts.append_settings_flag && opts.command == 'make' {
		append_make_settings_to_file(cl, opts)
	}
	return cl
}

// make_translation_table returns a map with the integer for each element in
// an array of strings; 0 for missing values. This makes discrete attributes
// resemble binned continuous attributes for subsequent processing
fn make_translation_table(array []string, missings []string) map[string]int {
	mut val := map[string]int{}
	mut i := 1
	for word in array {
		if word in missings {
			val[word] = 0
			continue
		} else if val[word] == 0 {
			val[word] = i
			i += 1
		}
	}
	return val
}

// max_ham_dist returns the maximum possible hamming distance for a classifier
fn max_ham_dist(atts map[string]TrainedAttribute) int {
	mut maximum_hamming_distance := 0
	for _, attr in atts {
		if attr.attribute_type == 'C' {
			maximum_hamming_distance += attr.bins
		} else {
			maximum_hamming_distance += attr.translation_table.len
		}
	}
	return maximum_hamming_distance
}
