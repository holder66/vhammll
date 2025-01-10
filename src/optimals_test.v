// optimals_test.v

module vhammll

fn test_optimals() {
	mut opts := Options{
		verbose_flag:  false
		expanded_flag: true
	}
	optimals('/Users/henryolders/use_vhammll/vhammll/src/testdata/ox_mets_settings.opts',
		opts)
}
