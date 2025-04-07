// module main
// import os
// import holder66.vhammll
// // import strings

// fn main() {
// 	home_dir := os.home_dir()
// 	// run optimals as the result includes plotting data
// 	optimals_result := vhammll.optimals(os.join_path(home_dir, 'metabolomics', 'ox1trainb2-6a2-15.opts'))
// 	mut files := optimals_result.RocFiles
// 	files.datafile = files.datafile.replace(home_dir, '~')
// 	files.settingsfile = files.settingsfile.replace(home_dir, '~')
// 	files.testfile = '~/metabolomics/ox1_test.tab'
// 	rocdata2 := RocData{
// 		pairs:       [[0.941, 0.720], [1.000, 0.600], [0.882, 0.737],
// 			[0.824, 0.743], [0.647, 0.966], [0.706, 0.966], [0.706, 0.971],
// 			[0.765, 0.937], [0.588, 0.846]]
// 		classifiers: ['118, 113, 5', '118, 113, 120', '118, 113, 120', '120, 113, 118',
// 			'70, 5, 120, 14, 113, 118', '70, 118, 113, 135, 14', '70, 118, 113, 135, 14',
// 			'70, 5, 120, 14, 113, 118', '70, 118, 113, 135, 14']
// 		trace_text:  'Multi-classifier<br>cross-validations'
// 	}
// 	rocdata3 := RocData{
// 		pairs:       [[0.857, 0.671], [0.857, 0.612], [0.857, 0.682],
// 			[0.286, 0.824], [0.714, 0.824], [0.286, 0.800], [0.857, 0.706]]
// 		classifiers: ['5, 113, 118', '120, 113, 118', '120, 113, 118', '70, 5, 120, 14, 113, 118',
// 			'70, 118, 113, 135, 14', '70, 5, 120, 14, 113, 118', '120, 113, 118']
// 		trace_text:  'Verifications on file<br>${files.testfile}'
// 	}

// 	plot_mult_roc([optimals_result.RocData, rocdata2, rocdata3], files)
// }
