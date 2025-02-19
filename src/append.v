// append.v
module vhammll

import time

// append_instances extends a classifier by adding more instances.
// It returns the extended classifier struct.
// ```sh
// Output options:
// show_flag: display results on the console;
// outputfile_path: saves the extended classifier to a file.
// ```
pub fn append_instances(cl Classifier, instances_to_append ValidateResult, opts Options) Classifier {
	// append needs to append the array of byte values for each new instance
	// to cl.instances, and append the class value for each new instance
	// cl.class_values, update the cl.class_counts map, and calculate a new lcm
	if opts.verbose_flag {
		println('${cl}\n${instances_to_append}')
	}
	mut ext_cl := cl
	history_event := HistoryEvent{
		Environment:     get_environment()
		instances_count: instances_to_append.inferred_classes.len
		event_date:      time.utc().str()
		// event_environment: get_environment()
		event:     'append'
		file_path: instances_to_append.validate_file_path
	}
	ext_cl.history_events << history_event
	ext_cl.instances << instances_to_append.instances
	ext_cl.class_values << instances_to_append.inferred_classes
	ext_cl.class_counts = element_counts(ext_cl.class_values)
	// calculate lcm_class_counts which is needed when the weighting_flag is set
	ext_cl.lcm_class_counts = i64(lcm(ext_cl.class_counts.values()))
	if opts.show_flag || opts.expanded_flag {
		show_classifier(ext_cl)
	}
	if opts.outputfile_path != '' {
		save_json_file[Classifier](ext_cl, opts.outputfile_path)
	}
	return ext_cl
}
