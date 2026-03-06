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

// fn test_plot_hits() {
// 	os.execute_or_panic('./temp rank -of vhammll/datasets/developer.tab')
// 	os.execute_or_panic('./temp rank -of -b 2,7 vhammll/datasets/iris.tab')
// 	os.execute_or_panic('./temp rank -of vhammll/datasets/anneal.tab')
// 	os.execute_or_panic('./temp rank -of -l 3 vhammll/datasets/anneal.tab')
// }

// fn test_plot_rank() {
// 	os.execute_or_panic('./temp rank -g vhammll/datasets/developer.tab')
// 	os.execute_or_panic('./temp rank -g -b 2,7 vhammll/datasets/iris.tab')
// 	os.execute_or_panic('./temp rank -g vhammll/datasets/anneal.tab')
// 	os.execute_or_panic('./temp rank -g -l 3 vhammll/datasets/anneal.tab')
// }

fn test_plot_explore() {
	os.execute_or_panic('./temp explore -g vhammll/datasets/iris.tab')
	os.execute_or_panic('./temp explore -g -a 2 -b 6  vhammll/datasets/leukemia34test.tab')
	os.execute_or_panic('./temp explore -g vhammll/datasets/breast-cancer-wisconsin-disc.tab')
}

fn test_area_under_curve() {
	mut x := []f64{}
	mut y := []f64{}
	x = [0.0, 1.0]
	y = [0.0, 1.0]
	assert area_under_curve(x, y) == 0.5
	x = [0.2, 0.4]
	y = [0.3, 0.4]
	assert area_under_curve(x, y) == 0.07
	x = [0.2, 0.3, 0.4]
	y = [0.5, 0.3, 0.1]
	assert area_under_curve(x, y) == 0.06
}

// fn test_plot_roc() {
// 	// generate a multiple classifier settings file from a 2-class dataset
// 	os.execute_or_panic('./temp explore -ms tempfolders/tempfolder_plot/bcw.opts -t vhammll/datasets/bcw174test vhammll/datasets/bcw350train')
// 	// display the ROC curve from the settings file (exercises plot_roc)
// 	os.execute_or_panic('./temp display -g tempfolders/tempfolder_plot/bcw.opts')
// }

// fn test_plot_multi_roc() {
// 	// generate multiple ROC curve traces from the settings file (exercises plot_mult_roc)
// 	os.execute_or_panic('./temp optimals -g tempfolders/tempfolder_plot/bcw.opts')
// }

// fn test_plot_roc_multiclass() {
// 	// generate a settings file from a multi-class dataset (iris: 3 classes)
// 	os.execute_or_panic('./temp explore -ms tempfolders/tempfolder_plot/iris.opts vhammll/datasets/iris.tab')
// 	// display -g with multi-class settings: the 2-class guard skips plot_roc but must not crash
// 	os.execute_or_panic('./temp display -g tempfolders/tempfolder_plot/iris.opts')
// 	// optimals -g with multi-class settings: exercises plot_mult_roc with multi-class sens/spec values
// 	os.execute_or_panic('./temp optimals -g tempfolders/tempfolder_plot/iris.opts')
// }
