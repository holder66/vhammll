// test_analyze
module vhammll

import os

fn test_analyze_dataset() ? {
	mut opts := Options{
		show_flag: false
	}
	// orange_newer file
	mut ds := load_file('datasets/developer.tab')
	mut pr := analyze_dataset(ds, opts)
	assert pr.datafile_path == 'datasets/developer.tab'
	assert pr.datafile_type == 'orange_newer'
	assert pr.attributes[2].name == 'age'
	assert pr.attributes[9].min == -90
	assert pr.class_counts == {
		'm': 8
		'f': 3
		'X': 2
	}
	assert close(pr.attributes[8].mean, 47.27273)
	assert close(pr.attributes[8].median, 45.0)

	// orange_older file
	ds = load_file('datasets/iris.tab')
	pr = analyze_dataset(ds, opts)
	assert pr.datafile_path == 'datasets/iris.tab'
	assert pr.datafile_type == 'orange_older'
	assert pr.attributes[2].name == 'petal length'
	assert pr.attributes[3].max == 2.5
	assert pr.class_counts == {
		'Iris-setosa':     50
		'Iris-versicolor': 50
		'Iris-virginica':  50
	}

	// UKDA file with a data dictionary
	home_dir := os.home_dir()
	if os.exists(home_dir + '/UKDA') {
		opts.dictionaryfile_path = home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_accelerometer_derived_ukda_data_dictionary.rtf'
		ds = load_file(home_dir + '/UKDA/UKDA-8156-tab/tab/mcs6_cm_accelerometer_derived.tab',
			dictionaryfile_path: opts.dictionaryfile_path
		)
		// println('ds in analyze_test.v: $ds.DataDict')
		pr = analyze_dataset(ds, opts)
		assert pr.datafile_type == 'UKDA'
		assert pr.dictionaryfile_path == opts.dictionaryfile_path
		assert pr.attributes[18].name == 'FCACC_MVPA_E5S_B10M80_T100_ENMO'
		assert pr.number_of_variables == 19
		assert pr.variables[15].variable == 'FCACC_MVPA_MEAN_ACC_E5MIN_100MG'
		assert pr.variables[14].variable_label == 'Total minutes in MVPA: 1min epochs where ENMO > 100mg'
		assert pr.variables[5].value_label_map == {
			'1': 'Sunday'
			'2': 'Monday'
			'3': 'Tuesday'
			'4': 'Wednesday'
			'5': 'Thursday'
			'6': 'Friday'
			'7': 'Saturday'
		}
	} else {
		println('UKDA files not found; skipping tests on UKDA datasets')
	}

	// opts.dictionaryfile_path = home_dir + '/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_interview_ukda_data_dictionary.rtf'
	// ds = load_file(home_dir + '/UKDA/UKDA-8156-tab/tab/mcs6_cm_interview.tab',
	// 	dictionaryfile_path: opts.dictionaryfile_path
	// )
	// // println('ds in analyze_test.v: $ds.DataDict')
	// pr = analyze_dataset(ds, opts)
	// assert pr.datafile_type == 'UKDA'
	// assert pr.dictionaryfile_path == opts.dictionaryfile_path
	// assert pr.attributes[318].name == 'FCHACK00'
	// assert pr.number_of_variables == 412
	// assert pr.variables[411].variable == 'FCCARR11_TR3'
	// assert pr.variables[411].variable_label == 'Aspirations: what CM would like to be when grow up [SOC code] R11    [truncated at 3 chars]'
	// assert pr.variables[19].value_label_map == {
	// 	'1':  '.1'
	// 	'2':  '.2'
	// 	'3':  '.3'
	// 	'4':  '.4'
	// 	'5':  '.5'
	// 	'6':  '.6'
	// 	'7':  '.7'
	// 	'8':  '.8'
	// 	'9':  '.9'
	// 	'10': '.0'
	// 	'-1': 'Not applicable'
	// }
}

fn test_analyze_dataset_with_purging_of_instances_with_missing_class_values() {
	mut opts := Options{
		show_flag: false
		datafile_path: 'datasets/class_missing_developer.tab'
	}
	mut ds := Dataset{}
	ds = load_file(opts.datafile_path)
	mut pr := analyze_dataset(ds, opts)
	assert pr.datafile_path == 'datasets/class_missing_developer.tab'
	assert pr.datafile_type == 'orange_newer'
	assert pr.dictionaryfile_path == ''
	assert pr.class_name == 'gender'
	assert pr.class_counts == {
		'm': 8
		'':  1
		'f': 3
		'X': 2
		'?': 1
	}
	assert pr.attributes[3] == Attribute{
		id: 3
		name: 'gender'
		count: 15
		counts_map: {
			'm': 8
			'':  1
			'f': 3
			'X': 2
			'?': 1
		}
		uniques: 5
		missing: 2
		att_type: 'c'
		for_training: false
		min: 0.0
		max: 0.0
	}
	// println(pr)
	// repeat with purging of instances where the class value is missing
	ds = load_file(opts.datafile_path, class_missing_purge_flag: true)
	pr = analyze_dataset(ds, opts)
	assert pr.datafile_path == 'datasets/class_missing_developer.tab'
	assert pr.datafile_type == 'orange_newer'
	assert pr.dictionaryfile_path == ''
	assert pr.class_name == 'gender'
	assert pr.class_counts == {
		'm': 8
		'f': 3
		'X': 2
	}
	assert pr.attributes[3] == Attribute{
		id: 3
		name: 'gender'
		count: 13
		counts_map: {
			'm': 8
			'f': 3
			'X': 2
		}
		uniques: 3
		missing: 0
		att_type: 'c'
		for_training: false
		min: 0.0
		max: 0.0
	}

	home_dir := os.home_dir()
	if os.exists(home_dir + '/UKDA') {
		opts.datafile_path = home_dir +
			'/UKDA/UKDA-8156-tab/tab/mods_for_vhamml/mcs6_cm_derived_FCUK90O6.tab'
		opts.dictionaryfile_path = home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_derived_ukda_data_dictionary.rtf'
		// first, do without purging
		ds = load_file(opts.datafile_path, dictionaryfile_path: opts.dictionaryfile_path)
		pr = analyze_dataset(ds, opts)
		assert pr.datafile_path == opts.datafile_path
		assert pr.datafile_type == 'UKDA'
		assert pr.dictionaryfile_path == opts.dictionaryfile_path
		assert pr.class_name == 'FCUK90O6'
		assert pr.class_counts == {
			'2':  7080
			'4':  2192
			'1':  175
			'3':  1638
			'-1': 774
		}
		assert pr.attributes[3] == Attribute{
			id: 3
			name: 'FCINTY00'
			count: 11859
			counts_map: {
				'2015': 11458
				'2016': 401
			}
			uniques: 2
			missing: 0
			att_type: 'C'
			for_training: true
			min: 2015.0
			max: 2016.0
			mean: 2015.321
			median: 2015.0
		}
		// now, with purging
		ds = load_file(opts.datafile_path,
			dictionaryfile_path: opts.dictionaryfile_path
			class_missing_purge_flag: true
		)
		pr = analyze_dataset(ds, opts)
		assert pr.class_name == 'FCUK90O6'
		assert pr.class_counts == {
			'2': 7080
			'4': 2192
			'1': 175
			'3': 1638
		}
		assert pr.attributes[3].min == 2015.0

		assert pr.attributes[4] == Attribute{
			id: 4
			name: 'FCCSEX00'
			count: 11085
			counts_map: {
				'1': 5623
				'2': 5462
			}
			uniques: 2
			missing: 0
			att_type: 'D'
			for_training: true
			min: 0.0
			max: 0.0
			mean: 0.0
			median: 0.0
		}
		opts.datafile_path = home_dir +
			'/UKDA/UKDA-8156-tab/tab/mods_for_vhamml/mcs6_cm_cognitive_assessment_FCCMCOGO.tab'
		opts.dictionaryfile_path = home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_cognitive_assessment_ukda_data_dictionary.rtf'
		// first, do without purging
		ds = load_file(opts.datafile_path, dictionaryfile_path: opts.dictionaryfile_path)
		pr = analyze_dataset(ds, opts)
		assert pr.datafile_path == opts.datafile_path
		assert pr.datafile_type == 'UKDA'
		assert pr.dictionaryfile_path == opts.dictionaryfile_path
		assert pr.class_name == 'FCCMCOGO'
		assert pr.class_counts == {
			'5':  2350
			'1':  2517
			'3':  2354
			'4':  2269
			'2':  733
			'-1': 949
			'6':  683
			'-3': 4
		}
		assert pr.attributes[7].uniques == 1221
		assert pr.attributes[7].missing == 781
		assert pr.attributes[7].count == 11859
		assert pr.attributes[7].counts_map.len == 1221
		assert pr.attributes[7].min == 6.0
		assert pr.attributes[7].max == 6.549189e+06
		assert close(pr.attributes[7].mean, 1656.461)
		assert pr.attributes[7].median == 1043.0
		// now, with purging
		ds = load_file(opts.datafile_path,
			dictionaryfile_path: opts.dictionaryfile_path
			class_missing_purge_flag: true
		)
		pr = analyze_dataset(ds, opts)
		assert pr.class_counts == {
			'5': 2350
			'1': 2517
			'3': 2354
			'4': 2269
			'2': 733
			'6': 683
		}
		assert pr.attributes[7].uniques == 1151
		assert pr.attributes[7].missing == 0
		assert pr.attributes[7].count == 10906
		assert pr.attributes[7].counts_map.len == 1151
		assert close(pr.attributes[7].min, 298.0)
		assert close(pr.attributes[7].max, 11703.0)
		println(pr.attributes[7].mean)
		assert close(pr.attributes[7].mean, 1069.535)
		assert pr.attributes[7].median == 1045.0
	}
}
