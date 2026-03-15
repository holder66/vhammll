// performance_test.v tests that the various cli commands produce
// consistent results with the datasets in the datasets folder
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

	r := os.execute_or_panic('v temp.v')
	if os.is_dir('tempfolders/tempfolder_performance') {
		os.rmdir_all('tempfolders/tempfolder_performance')!
	}
	os.mkdir_all('tempfolders/tempfolder_performance')!
}

fn testsuite_end() ? {
	if os.exists('temp') {
		os.rm('temp')!
	}
	if os.exists('temp.v') {
		os.rm('temp.v')!
	}
	os.rmdir_all('tempfolders/tempfolder_performance')!
}

fn test_explore() {
	opts := CliOptions{}
	mut r := os.execute_or_panic('./temp explore --help')
	assert r.output.contains('-bpt --balance-prevalences-threshold: ratio threshold below which class')
	r = os.execute_or_panic('./temp explore -e vhammll/datasets/iris.tab')
	assert r.output.contains('Totals                      150     142 (accuracy: raw: 94.67% balanced: 94.67%)')
	r = os.execute_or_panic('./temp explore -e -a 2 -b 6  vhammll/datasets/leukemia34test.tab')
	assert r.output.contains('2  1 - 6      13     1    19     1   0.929  0.950  0.929  0.950     0.929         94.12%    93.93%   0.879')
	r = os.execute_or_panic('./temp explore  -e -o tempfolders/tempfolder_performance/breast.exr vhammll/datasets/breast-cancer-wisconsin-disc.tab')
	assert r.output.contains('MCC (Matthews Correlation Coefficient):   0.908 [225, 16, 445, 13] using 9 attribute')
	r = os.execute_or_panic('./temp cross  -w -e -a 13 vhammll/datasets/UCI/zoo.arff')
	assert r.output.contains('reptile                           5       4 ( 80.00%)        1.000     0.800       0.889')
}

fn test_verify() {
	mut r := os.execute_or_panic('./temp verify -h')
	assert r.output.contains('-bpt --balance-prevalences-threshold: ratio threshold below which class
    prevalences are considered imbalanced (default 0.9; range 0.0–1.0);')
	r = os.execute_or_panic('./temp verify -e -t vhammll/datasets/bcw174test vhammll/datasets/bcw350train')
	assert r.output.contains('Verification of "vhammll/datasets/bcw174test" using a classifier from "vhammll/datasets/bcw350train"')
	// save a classifier to a file
	r = os.execute_or_panic('./temp make -e -a 33 -b 2,16 -w -o tempfolders/tempfolder_performance/soybean.cl vhammll/datasets/soybean-large-train.tab')
	assert r.output.contains('Classifier from "vhammll/datasets/soybean-large-train.tab"')
	r = os.execute_or_panic('./temp verify -e -w -s -k tempfolders/tempfolder_performance/soybean.cl -t vhammll/datasets/soybean-large-test.tab')
	assert r.output.contains('Verification of "vhammll/datasets/soybean-large-test.tab" using a classifier from "vhammll/datasets/soybean-large-test.tab"')
}

// fn test_analyze() {
// 	mut r := os.execute_or_panic('./temp')
// 	r = os.execute_or_panic('./temp analyze vhammll/datasets/developer.tab')
// 	r = os.execute_or_panic('./temp analyze vhammll/datasets/bcw174test')
// 	r = os.execute_or_panic('./temp analyze vhammll/datasets/iris.tab')
// }

// fn test_make() {
// 	mut r := os.execute_or_panic('./temp make')
// 	r = os.execute_or_panic('./temp make -a 7 -b 3,7 vhammll/datasets/developer.tab')
// 	r = os.execute_or_panic('./temp make -a 7 -b 3,7 -x -e -o tempfolders/tempfolder_performance/dev.cl vhammll/datasets/developer.tab')
// }

// fn test_cross() {
// 	r = os.execute_or_panic('./temp cross --help')
// 	r = os.execute_or_panic('./temp cross vhammll/datasets/iris.tab')
// 	r = os.execute_or_panic('./temp cross -e -a 2 -b 3,6 vhammll/datasets/iris.tab')
// 	r = os.execute_or_panic('./temp cross -e -a 2 -b 3,6 -f 10 -w vhammll/datasets/iris.tab')
// 	r = os.execute_or_panic('./temp cross -e -a 6 -b 3,6 -f 20 -w vhammll/datasets/prostata.tab')
// 	r = os.execute_or_panic('./temp cross -w -e -a 13 vhammll/datasets/UCI/zoo.arff')
// }

// fn test_append() ? {
// 	// make a classifier
// 	mut r := os.execute_or_panic('./temp make -a 4 -o tempfolders/tempfolder_performance/bcw.cl vhammll/datasets/bcw350train')
// 	// make an instances file by doing a validation
// 	r = os.execute_or_panic('./temp validate -k tempfolders/tempfolder_performance/bcw.cl -o tempfolders/tempfolder_performance/bcw.inst -t vhammll/datasets/bcw174test')
// 	// use the instances file to append to the saved classifier
// 	r = os.execute_or_panic('./temp append -k tempfolders/tempfolder_performance/bcw.cl -o tempfolders/tempfolder_performance/bcw-ext.cl tempfolders/tempfolder_performance/bcw.inst')
// }

// fn test_rank_attributes() {
// 	mut r := os.execute_or_panic('./temp rank')
// 	assert r.output.contains('"rank" rank orders a dataset\'s attributes')
// 	r = os.execute_or_panic('./temp rank -e vhammll/datasets/developer.tab')
// 	assert r.output.contains('5   age                              2  C           84.62     12')
// 	r = os.execute_or_panic('./temp rank -e -x -b 3,3 vhammll/datasets/iris.tab')
// 	assert r.output.contains('4   sepal width                      1  C           34.67      3')
// 	r = os.execute_or_panic('./temp rank -e -b 2,6 -x -a 2 vhammll/datasets/iris.tab')
// 	assert r.output.contains('Bin range for continuous attributes: from 2 to 6 with interval 1')
// 	r = os.execute_or_panic('./temp rank -e -x vhammll/datasets/anneal.tab')
// 	assert r.output.contains('8   carbon                           3  C           78.90      7')
// }

// fn test_display() {
// 	mut r := os.execute_or_panic('./temp cross -c -b 2,4 -a 4 -o tempfolders/tempfolder_performance/cross_result.txt vhammll/datasets/developer.tab')
// 	r = os.execute_or_panic('./temp display -e tempfolders/tempfolder_performance/cross_result.txt')
// 	r = os.execute_or_panic('./temp rank -o tempfolders/tempfolder_performance/rank_result.txt vhammll/datasets/UCI/segment.arff')
// 	// r = os.execute_or_panic('./temp display tempfolders/tempfolder_performance/rank_result.txt'))
// }

fn test_purge_for_missing_class_values() {
	mut r := os.execute_or_panic('./temp analyze -s vhammll/datasets/class_missing_developer.tab')
	assert r.output.len == 2857
	assert r.output.contains('(5 classes)')
	assert r.output.contains('                          1')
	// the -pmc flag strips away cases where the class value is missing or is "?"
	r = os.execute_or_panic('./temp analyze -s -pmc vhammll/datasets/class_missing_developer.tab')
	assert r.output.len == 2865
	assert r.output.contains('Note: instances with missing class values were purged.')
	assert r.output.contains('(3 classes)')
	r = os.execute_or_panic('./temp rank -e -pmc vhammll/datasets/class_missing_developer.tab')
	assert r.output.contains('Purging of instances with missing class values: true')
	assert r.output.contains('5   age                              2  C           84.62     12')
	assert r.output.contains('2   negative                         9  C          100.00     12')
	r = os.execute_or_panic('./temp make -e -a 7 -b 3,7 -pmc vhammll/datasets/class_missing_developer.tab')
	assert r.output.contains('Purging of instances with missing class values: true')
	assert r.output.contains('4  height                      C         100.00              110.00     180.00     3')
}

fn test_partitioning() {
	path1 := 'tempfolders/tempfolder_performance/part1.tab'
	path2 := 'tempfolders/tempfolder_performance/part2.tab'
	path3 := 'tempfolders/tempfolder_performance/part3.tab'
	mut r := os.execute_or_panic('./temp partition')
	r = os.execute_or_panic('./temp partition -p# 3,2,1 -ps ${path1},${path2},${path3} -rand vhammll/datasets/developer.tab')
	assert os.exists(path1)
	assert os.exists(path2)
	assert os.exists(path3)
	assert os.read_lines(path3)!.len == 4
}
