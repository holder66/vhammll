// optimals_test.v

module vhammll

fn test_optimals() {
	mut opts := Options{}
	mut disp := DisplaySettings{
		verbose_flag: false
		expanded_flag: true
	}
	optimals('/Users/henryolders/data2/data2_for_multiple_classes_6_march_2024.opts',
		opts, disp)
	optimals('/Users/henryolders/data2/mets2024_3_17.opts',
		opts, disp)
}
