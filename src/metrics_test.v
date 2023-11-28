// metrics_test.v

module vhammll

import os

fn testsuite_begin() ! {
	if os.is_dir('tempfolder_metrics') {
		os.rmdir_all('tempfolder_metrics')!
	}
	os.mkdir_all('tempfolder_metrics')!
}

fn testsuite_end() ! {
	os.rmdir_all('tempfolder_metrics')!
}

// test_wt_avg
fn test_wt_avg() ? {
	assert wt_avg([0.0], [1]) == 0.0
	// assert wt_avg([], []) or { 1.0 } == 0.0, 'cannot sum over an empty array'
	assert wt_avg([1.0, 2.0, 3.0], [3, 2, 1]) == 10.0 / 6
	// assert wt_avg([1.0, 2.0, 3.0], [-3, 2, 1])? == 10.0 / 0
}
