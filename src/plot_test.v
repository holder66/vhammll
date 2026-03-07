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
	mut output := os.execute_or_panic('./temp rank -of -l 2 -b 2,5 vhammll/datasets/developer.tab')
	assert output.output.contains('Listening on')
	output = os.execute_or_panic('./temp rank -of -b 2,7 vhammll/datasets/iris.tab')
	assert output.output.contains('Listening on')
	output = os.execute_or_panic('./temp rank -e -of -l 3 -b 3,6 vhammll/datasets/anneal.tab')
	assert output.output.contains('Listening on')
}

fn test_plot_rank() {
	mut output := os.execute_or_panic('./temp rank -g vhammll/datasets/developer.tab')
	assert output.output.contains('Listening on')
	output = os.execute_or_panic('./temp rank -g -b 2,7 vhammll/datasets/iris.tab')
	assert output.output.contains('Listening on')
	output = os.execute_or_panic('./temp rank -g vhammll/datasets/anneal.tab')
	assert output.output.contains('Listening on')
	output = os.execute_or_panic('./temp rank -g -l 3 vhammll/datasets/anneal.tab')
	assert output.output.contains('Listening on')
}

fn test_plot_explore() {
	mut output := os.execute_or_panic('./temp explore -g vhammll/datasets/iris.tab')
	assert output.output.contains('Listening on')
	output = os.execute_or_panic('./temp explore -g -a 2 -b 6  vhammll/datasets/leukemia34test.tab')
	assert output.output.contains('Listening on')
	output = os.execute_or_panic('./temp explore -g vhammll/datasets/breast-cancer-wisconsin-disc.tab')
	assert output.output.contains('Listening on')
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

fn test_plot_roc() {
	// generate a multiple classifier settings file from a 2-class dataset
	mut output := os.execute_or_panic('./temp explore -ms tempfolders/tempfolder_plot/bcw.opts -t vhammll/datasets/bcw174test vhammll/datasets/bcw350train')
	assert !output.output.contains('Listening on')
	// display the ROC curve from the settings file (exercises plot_roc)
	output = os.execute_or_panic('./temp display -g tempfolders/tempfolder_plot/bcw.opts')
	assert output.output.contains('Listening on')
}

fn test_plot_multi_roc() {
	// generate multiple ROC curve traces from the settings file (exercises plot_mult_roc)
	mut output := os.execute_or_panic('./temp optimals -g vhammll/src/testdata/bcw.opts')
	assert output.output.contains('Listening on')
	output = os.execute_or_panic('./temp optimals -g -cl 2,3 vhammll/src/testdata/bcw.opts')
	assert output.output.contains('Listening on')
}

fn test_plot_roc_multiclass() {
	// generate a settings file from a multi-class dataset (iris: 3 classes)
	mut output := os.execute_or_panic('./temp explore -ms tempfolders/tempfolder_plot/iris.opts vhammll/datasets/iris.tab')
	assert !output.output.contains('Listening on')
	// display -g with multi-class settings: the 2-class guard skips plot_roc but must not crash
	output = os.execute_or_panic('./temp display -g tempfolders/tempfolder_plot/iris.opts')
	assert !output.output.contains('Listening on')
	// optimals -g with multi-class settings: exercises plot_mult_roc with multi-class sens/spec values
	output = os.execute_or_panic('./temp optimals -g tempfolders/tempfolder_plot/iris.opts')
	assert !output.output.contains('Listening on')
}
