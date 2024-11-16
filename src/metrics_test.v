// metrics_test.v

module vhammll

// import os
import math

// fn testsuite_begin() ! {
// 	if os.is_dir('tempfolder_metrics') {
// 		os.rmdir_all('tempfolder_metrics')!
// 	}
// 	os.mkdir_all('tempfolder_metrics')!
// }

// fn testsuite_end() ! {
// 	os.rmdir_all('tempfolder_metrics')!
// }

fn test_wt_avg() ? {
	assert wt_avg([0.0], [1]) == 0.0
	// assert wt_avg([], []) or { 1.0 } == 0.0, 'cannot sum over an empty array'
	assert wt_avg([1.0, 2.0, 3.0], [3, 2, 1]) == 10.0 / 6
	// assert wt_avg([1.0, 2.0, 3.0], [-3, 2, 1])? == 10.0 / 0
}

fn test_mcc() {
	// mcc(tp int, tn int, fp int, ffn int)
	assert mcc(95, 0, 5, 0) == 0.0
	assert mcc(90, 1, 4, 5) == 0.13524203070138519
	assert mcc(6, 3, 1, 2) == 0.47809144373375745
	assert mcc(0, 5, 0, 95) == 0.0
	assert mcc(15, 782, 9, 10) == 0.6003804231419032
	// reversing the true positive class
	assert mcc(782, 15, 10, 9) == 0.6003804231419032
	// with floating point values
	// assert mcc(8.6, 783.1, 7.9, 16.4) == 0.4089497479969868
	assert math.veryclose(mcc(8.6, 783.1, 7.9, 16.4), 0.4089497479969868)
}
