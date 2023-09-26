// data_dict_test.v
module vhammll

// import math
import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder_datadict') {
		os.rmdir_all('tempfolder_datadict')!
	}
	os.mkdir_all('tempfolder_datadict')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolder_datadict')!
}

// fn test_do_query() {
// 	println(do_query('£', '', 'ab£cde'))
// 	println(do_query('', '£', 'ab£cde'))
// }

// fn test_pound() {
// 	path := home_dir + '/pound.txt'
// 	println(os.read_bytes(path)!)
// 	assert os.read_bytes(path)! == [u8(163)]
// 	println(os.read_file(path)!)
// 	assert os.read_file(path)! != '?'
// 	assert os.read_file(path)! != '£'
// 	println(os.read_file(path)!.runes())
// 	assert os.read_file(path)!.runes() == [`£`]
// 	println(os.read_file(path)!.runes().map(it.str()))
// 	assert os.read_file(path)!.runes().map(it.str()) == ['£']
// 	println(os.read_lines(path)!)
// 	assert os.read_lines(path)! != ['?']
// 	assert os.read_lines(path)! != ['£']
// }

fn test_data_dict() {
	mut dd := DataDict{}
	home_dir := os.home_dir()
	if os.exists(home_dir + '/UKDA') {
		dd = data_dict(home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_derived_ukda_data_dictionary.rtf')
		assert dd.file_name == 'mcs6_cm_derived'
		assert dd.number_of_cases == 11859
		assert dd.variables[2] == DataDictVariable{
			pos: 3
			variable: 'FCINTM00'
			variable_label: 'Interview date (month)'
			value_label_map: {
				'1':  'January'
				'2':  'February'
				'3':  'March'
				'4':  'April'
				'5':  'May'
				'6':  'June'
				'7':  'July'
				'8':  'August'
				'9':  'September'
				'10': 'October'
				'11': 'November'
				'12': 'December'
				'-9': 'Refused'
				'-8': 'Dont know'
				'-1': 'Not applicable'
			}
		}
		assert dd.variables[38] == DataDictVariable{
			pos: 39
			variable: 'FCANONSCLID2'
			variable_label: 'School (started at): Anonymised School ID'
			value_label_map: {}
		}

		dd = data_dict(home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_accelerometer_derived_ukda_data_dictionary.rtf')
		assert dd.file_name == 'mcs6_cm_accelerometer_derived'
		assert dd.number_of_cases == 8978
		assert dd.variables[3] == DataDictVariable{
			pos: 4
			variable: 'FCACCMONTH'
			variable_label: 'Date: Month for Physical Activity (Time Use Diary and Accelerometer)'
			value_label_map: {
				'1':  'January'
				'2':  'February'
				'3':  'March'
				'4':  'April'
				'5':  'May'
				'6':  'June'
				'7':  'July'
				'8':  'August'
				'9':  'September'
				'10': 'October'
				'11': 'November'
				'12': 'December'
			}
		}
		assert dd.variables[7] == DataDictVariable{
			pos: 8
			variable: 'FCACC_MEAN_ACC_24H'
			variable_label: 'Mean acceleration (ENMO - Euclidean Norm Minus One) for the day (24 hours)'
			value_label_map: {}
		}
		// the test seems to go into an infinite loop for the following data dictionary, perhaps because it includes the 8-bit encoded British Pound sign
		// dd = data_dict(home_dir + '/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_parent_income_brackets_ukda_data_dictionary.rtf')
		// assert dd.file_name == 'mcs6_cm_derived'
		// assert dd.number_of_cases == 11859
		// assert dd.variables[2] == hamml.DataDictVariable{
		// pos: 3
		// variable: 'FCINTM00'
		// variable_label: 'Interview date (month)'
		// value_label_map: {
		// 		'1':  'January'
		// 		'2':  'February'
		// 		'3':  'March'
		// 		'4':  'April'
		// 		'5':  'May'
		// 		'6':  'June'
		// 		'7':  'July'
		// 		'8':  'August'
		// 		'9':  'September'
		// 		'10': 'October'
		// 		'11': 'November'
		// 		'12': 'December'
		// 	}
		// }
		// assert dd.variables[38] == hamml.DataDictVariable{
		//     pos: 39
		//     variable: 'FCANONSCLID2'
		//     variable_label: 'School (started at): Anonymised School ID'
		//     value_label_map: {}
		// }

		dd = data_dict(home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_tud_parsed_data_web_calendar_format_ukda_data_dictionary.rtf')
		assert dd.file_name == 'mcs6_tud_parsed_data_web_calendar_format'
		assert dd.number_of_cases == 370368
		assert dd.variables[2] == DataDictVariable{
			pos: 3
			variable: 'FCTUDMOD'
			variable_label: 'TUD Mode of data collection'
			value_label_map: {
				'1': 'Mobile Application'
				'2': 'Online (PC)'
				'3': 'Paper'
			}
		}

		dd = data_dict(home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_tud_parsed_data_paper_calendar_format_ukda_data_dictionary.rtf')
		assert dd.file_name == 'mcs6_tud_parsed_data_paper_calendar_format'
		assert dd.number_of_cases == 94752
		assert dd.variables[6].value_label_map['143'] == 'Slot 143 from 03:40 to 03:50'

		dd = data_dict(home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_accelerometer_derived_ukda_data_dictionary.rtf')
		assert dd.variables[7].value_label_map == {}

		dd = data_dict(home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs_sweep6_imd_s_2004_ukda_data_dictionary.rtf')
		assert dd.variables[8].value_label_map['6'] == '50 - < 60%'
		assert dd.variables[9].value_label_map['5'] == 'Accessible rural'

		dd = data_dict(home_dir +
			'/UKDA/UKDA-8156-tab/mrdoc/ukda_data_dictionaries/mcs6_cm_interview_ukda_data_dictionary.rtf')
		assert dd.variables[19].value_label_map['9'] == '.9'
		assert dd.variables[19].value_label_map['-1'] == 'Not applicable'
	} else {
		println('UKDA files not found; skipping tests on UKDA datasets')
	}
}
