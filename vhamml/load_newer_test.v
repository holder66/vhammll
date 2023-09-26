// load_newer_test.v
module vhammll

import os

fn test_infer_attribute_types_newer() {
	mut ds := load_orange_newer_file('datasets/developer.tab')
	// println('types from file: $ds.attribute_types')
	types := ds.attribute_types
	ds.attribute_types = ['i', '', 'w', 'cD', 'C', 'm', '', 'T', 'S', '']
	assert infer_attribute_types_newer(ds) == ['i', 'D', 'i', 'c', 'C', 'i', 'D', 'i', 'i', 'C']

	assert infer_attribute_types_newer(load_file('datasets/developer.tab')) == ['i', 'D', 'C',
		'c', 'C', 'C', 'D', 'D', 'C', 'C']
	home_dir := os.home_dir()
	if os.exists(home_dir + '/UKDA') {
		mut datafile := home_dir + '/UKDA/UKDA-8156-tab/tab/mcs6_cm_accelerometer_derived.tab'
		mut dictfile := home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_accelerometer_derived_ukda_data_dictionary.rtf'
		ds = load_file(datafile, dictionaryfile_path: dictfile)
		assert infer_attribute_types_newer(ds) == ['m', 'D', 'D', 'D', 'C', 'D', 'C', 'C', 'C',
			'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C']

		datafile = home_dir + '/UKDA/UKDA-8156-tab/tab/mcs6_cm_derived.tab'
		dictfile = home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_derived_ukda_data_dictionary.rtf'
		ds = load_file(datafile, dictionaryfile_path: dictfile)
		// println(os.execute_or_panic('v run . analyze -d $dictfile $datafile'))
		assert infer_attribute_types_newer(ds) == ['m', 'D', 'D', 'C', 'D', 'D', 'C', 'C', 'D',
			'D', 'D', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'D', 'D', 'C', 'D', 'C', 'C', 'C', 'C',
			'C', 'C', 'C', 'D', 'D', 'D', 'D', 'D', 'C', 'D', 'D', 'D', 'D', 'D', 'D']
	}
}

fn test_load_ukda_file() ! {
	home_dir := os.home_dir()
	if os.exists(home_dir + '/UKDA') {
		mut datafile := home_dir + '/UKDA/UKDA-8156-tab/tab/mcs6_cm_accelerometer_derived.tab'
		mut dictfile := home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_accelerometer_derived_ukda_data_dictionary.rtf'
		mut ds := load_file(datafile, dictionaryfile_path: dictfile)
		assert ds.class_name == ''
		assert ds.file_name == 'mcs6_cm_accelerometer_derived'
		assert ds.variables.len == 19
		assert ds.attribute_names[8] == 'FCACC_MEAN_ACC_5AM_9AM'
		assert ds.inferred_attribute_types[0..4] == ['m', 'D', 'D', 'D']

		datafile = home_dir + '/UKDA/UKDA-8156-tab/tab/mcs6_cm_interview.tab'
		dictfile = home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_interview_ukda_data_dictionary.rtf'
		ds = load_file(datafile, dictionaryfile_path: dictfile)
		assert ds.class_name == ''
		assert ds.file_name == 'mcs6_cm_interview'
		assert ds.variables.len == 412
		assert ds.attribute_names[2] == 'FCCSEX00'
		assert ds.inferred_attribute_types[0] == 'm'

		// test purging of cases where the class value is missing
		datafile = home_dir + '/UKDA/UKDA-8156-tab/tab/mods_for_vhamml/mcs6_cm_derived_FCUK90O6.tab'
		dictfile = home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_derived_ukda_data_dictionary.rtf'
		// first, do without purging
		ds = load_file(datafile, dictionaryfile_path: dictfile)
		// println(ds)
		assert ds.path == home_dir +
			'/UKDA/UKDA-8156-tab/tab/mods_for_vhamml/mcs6_cm_derived_FCUK90O6.tab'
		assert ds.class_name == 'FCUK90O6'
		assert ds.file_name == 'mcs6_cm_derived'
		assert ds.variables.len == 41
		assert ds.attribute_names[2] == 'FCINTM00'
		assert ds.inferred_attribute_types[0..4] == ['m', 'D', 'D', 'C']
		assert ds.class_counts == {
			'2':  7080
			'4':  2192
			'1':  175
			'3':  1638
			'-1': 774
		}
		assert ds.data.len == 41
		assert ds.data[3].len == 11859
		// now, with purging
		ds = load_file(datafile, dictionaryfile_path: dictfile, class_missing_purge_flag: true)
		assert ds.path == home_dir +
			'/UKDA/UKDA-8156-tab/tab/mods_for_vhamml/mcs6_cm_derived_FCUK90O6.tab'
		assert ds.class_name == 'FCUK90O6'
		assert ds.file_name == 'mcs6_cm_derived'
		assert ds.variables.len == 41
		assert ds.attribute_names[2] == 'FCINTM00'
		assert ds.class_counts == {
			'2': 7080
			'4': 2192
			'1': 175
			'3': 1638
		}
		assert ds.data.len == 41
		assert ds.data[3].len == 11085
	}
}
