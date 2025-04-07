// plot_test.v
// for some reason, we are unable to actually generate plots from this code.
// It seems using the vhamm CLI is the only way to have plots actually show up.

module vhammll

import os

const main_text = '// temp.v
module main
import vhammll

fn main() {
	vhammll.cli()!
}'

fn testsuite_begin() ? {
	os.chdir('..')!
	mut f := os.create(os.abs_path('') + '/temp.v')!
	f.write_string(main_text)!
	f.close()

	os.execute_or_panic('v -keepc run temp.v')
	if os.is_dir('tempfolders/tempfolder_plot') {
		os.rmdir_all('tempfolders/tempfolder_plot')!
	}
	os.mkdir_all('tempfolders/tempfolder_plot')!
}

fn testsuite_end() ? {
	if os.exists('temp') {
		os.rm('temp')!
	}
	if os.exists('temp.v') {
		os.rm('temp.v')!
	}
	os.rmdir_all('tempfolders/tempfolder_plot')!
}

fn test_plot_hits() {
	mut r := os.execute_or_panic('./temp rank -of vhammll/datasets/developer.tab')
	r = os.execute_or_panic('./temp rank -of -b 2,7 vhammll/datasets/iris.tab')
	r = os.execute_or_panic('./temp rank -of vhammll/datasets/anneal.tab')
	r = os.execute_or_panic('./temp rank -of -l 3 vhammll/datasets/anneal.tab')
}

fn test_plot_rank() {
	mut r := os.execute_or_panic('./temp rank -g vhammll/datasets/developer.tab')
	r = os.execute_or_panic('./temp rank -g -b 2,7 vhammll/datasets/iris.tab')
	r = os.execute_or_panic('./temp rank -g vhammll/datasets/anneal.tab')
	r = os.execute_or_panic('./temp rank -g -l 3 vhammll/datasets/anneal.tab')
}

fn test_plot_explore() {
	assert true
}

fn test_plot_roc() {
	assert true
}

fn test_plot_multi_roc() {
	assert true
}

// fn test_area_under_curve() {
// 	mut x := []f64{}
// 	mut y := []f64{}
// 	x = [0.0, 1]
// 	y = [0.0, 1]
// 	assert area_under_curve(x, y) == 0.5
// 	x = [0.2, 0.4]
// 	y = [0.3, 0.4]
// 	assert area_under_curve(x, y) == 0.07
// 	x = [0.2, 0.3, 0.4]
// 	y = [0.5, 0.3, 0.1]
// 	assert area_under_curve(x, y) == 0.06
// }

// fn test_rank_attributes_plot() {
// 	mut result := RankingResult{}
// 	mut opts := Options{
// 		datafile_path: '/vhammll/datasets/developer.tab'
// 		command:       'rank'
// 	}
// 	opts.graph_flag = true
// 	result = rank_attributes(opts)
// 	opts.exclude_flag = true
// 	result = rank_attributes(opts)
// 	opts.exclude_flag = false
// 	opts.datafile_path = 'vhammll/datasets/anneal.tab'
// 	result = rank_attributes(opts)
// 	opts.exclude_flag = true
// 	result = rank_attributes(opts)
// }

// // test_explore_plot
// fn test_explore_plot() ? {
// 	mut results := ExploreResult{}
// 	mut opts := Options{
// 		command: 'explore'
// 		// number_of_attributes: [2, 7]
// 		bins: [3, 7]

// 		weighting_flag:   true
// 		exclude_flag:     true
// 		concurrency_flag: true
// 		// uniform_bins: true
// 		purge_flag: true
// 		// folds: 10
// 		// repetitions: 50
// 		// random_pick: true
// 		// datafile_path: 'datasets/2_class_developer.tab'
// 	}
// 	// cross with 2 classes (generates ROC plots)
// 	// results = explore(load_file(opts.datafile_path, opts.LoadOptions), opts)

// 	// test for cross with more than 2 classes
// 	opts.datafile_path = 'datasets/iris.tab'
// 	results = explore(opts)

// 	// verify with 2 classes (generates ROC plots)
// 	opts.datafile_path = 'datasets/bcw350train'
// 	opts.testfile_path = 'datasets/bcw174test'
// 	opts.number_of_attributes = [0]

// 	results = explore(opts)

// 	// verify with more than 2 classes
// 	opts.datafile_path = 'datasets/soybean-large-train.tab'
// 	opts.testfile_path = 'datasets/soybean-large-test.tab'
// 	opts.number_of_attributes = [0]

// 	results = explore(opts)
// }
