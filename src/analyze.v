// analyze.v
module vhammll

// import math
import math.stats

const analyze_help = '
Description:
"analyze" displays on the console, tables containing information about a
datafile\'s type, the attributes, and the class attribute. The tables are:
1. a list of attributes, their types, the unique values, and a count of
missing values;
2. a table with counts for each type of attribute;
3. a list of discrete attributes useful for training a classifier;
4. a list of continuous attributes useful for training a classifier;
5. a breakdown of the class attribute, showing counts for each class.

Usage:
 v run main.v analyze <path_to_dataset_file>

Options:
-h --help:   displays this message.
-o --output: followed by the path to a file in which the analyze 
             result will be saved.
-s --show:   output results to the console.
  '

// analyze_dataset returns a struct with information about a datafile.
// ```sh
// Optional:
// if show_flag is true, displays on the console (using show_analyze):
// 1. a list of attributes, their types, the unique values, and a count of
// missing values;
// 2. a table with counts for each type of attribute;
// 3. a list of discrete attributes useful for training a classifier;
// 4. a list of continuous attributes useful for training a classifier;
// 5. a breakdown of the class attribute, showing counts for each class.
//
// outputfile_path: if specified, saves the analysis results.
// ```
pub fn analyze_dataset(opts Options) AnalyzeResult {
	ds := load_file(opts.datafile_path, opts.LoadOptions)
	mut result := AnalyzeResult{
		environment:              get_environment()
		datafile_path:            ds.path
		datafile_type:            file_type(ds.path)
		class_name:               ds.class_name
		class_index:              ds.class_index
		class_counts:             ds.class_counts
		class_missing_purge_flag: ds.class_missing_purge_flag
	}
	mut missing_vals := ds.data.map(missing_values(it, opts.missings))
	mut indices_of_useful_attributes := ds.useful_continuous_attributes.keys()
	indices_of_useful_attributes << ds.useful_discrete_attributes.keys()
	mut max_values := []f32{}
	mut min_values := []f32{}
	mut atts := []Attribute{}
	for i, name in ds.attribute_names {
		mut att_info := Attribute{
			id:            i
			name:          name
			counts_map:    element_counts(ds.data[i])
			count:         ds.data[i].len
			uniques:       uniques_values(ds.data[i])
			missing:       missing_vals[i]
			raw_type:      ds.raw_attribute_types[i]
			att_type:      ds.attribute_types[i]
			inferred_type: ds.inferred_attribute_types[i]
			for_training:  i in indices_of_useful_attributes
		}
		if i in indices_of_useful_attributes && ds.attribute_types[i] == 'C' {
			att_info.max = array_max(ds.useful_continuous_attributes[i].filter(!is_nan(it)))
			att_info.min = f32(array_min(ds.useful_continuous_attributes[i].filter(!is_nan(it))))
			att_info.mean = f32(stats.mean(ds.useful_continuous_attributes[i].filter(!is_nan(it))))
			att_info.median = stats.median(ds.useful_continuous_attributes[i].filter(!is_nan(it)).sorted())
		}
		if i in indices_of_useful_attributes && ds.attribute_types[i] == 'D' {
			att_info.counts_map = element_counts(ds.data[i])
		}
		atts << att_info
		max_values << att_info.max
		min_values << att_info.min
	}
	result.attributes = atts
	result.overall_max = array_max(max_values)
	result.overall_min = array_min(min_values)
	if opts.show_flag {
		show_analyze(result)
	}
	if opts.outputfile_path != '' {
		save_json_file[AnalyzeResult](result, opts.outputfile_path)
	}
	return result
}

// uniques_values
fn uniques_values(attribute_values []string) int {
	return element_counts(attribute_values).len
}

// missing_values
fn missing_values(attribute_values []string, missings []string) int {
	return attribute_values.filter(it in missings).len
}
