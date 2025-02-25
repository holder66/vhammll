// cli_test.v
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
	if os.is_dir('tempfolders/tempfolder_cli') {
		os.rmdir_all('tempfolders/tempfolder_cli')!
	}
	os.mkdir_all('tempfolders/tempfolder_cli')!
}

fn testsuite_end() ? {
	if os.exists('temp') {
		os.rm('temp')!
	}
	if os.exists('temp.v') {
		os.rm('temp.v')!
	}
	os.rmdir_all('tempfolders/tempfolder_cli')!
}

fn test_explore() {
	println(os.execute_or_panic('./temp explore --help'))
	println(os.execute_or_panic('./temp explore  vhammll/datasets/iris.tab'))
	println(os.execute_or_panic('./temp explore  -a 2 -b 6  -c vhammll/datasets/leukemia34test.tab'))
	println(os.execute_or_panic('./temp explore  -e -c -o tempfolders/tempfolder_cli/breast.exr vhammll/datasets/breast-cancer-wisconsin-disc.tab'))
	println(os.execute_or_panic('./temp cross -c -w -e -a 13 vhammll/datasets/UCI/zoo.arff'))
}

fn test_verify() {
	println(os.execute_or_panic('./temp verify -h'))
	println(os.execute_or_panic('./temp verify -c -t vhammll/datasets/bcw174test vhammll/datasets/bcw350train'))
	// save a classifier to a file
	println(os.execute_or_panic('./temp make -a 33 -b 2,16 -w -o tempfolders/tempfolder_cli/soybean.cl vhammll/datasets/soybean-large-train.tab'))
	println(os.execute_or_panic('./temp verify -c -w -s -k tempfolders/tempfolder_cli/soybean.cl -t vhammll/datasets/soybean-large-test.tab'))
}

fn test_analyze() {
	println(os.execute_or_panic('./temp'))
	println(os.execute_or_panic('./temp analyze vhammll/datasets/developer.tab'))
	println(os.execute_or_panic('./temp analyze vhammll/datasets/bcw174test'))
	println(os.execute_or_panic('./temp analyze vhammll/datasets/iris.tab'))
}

fn test_make() {
	println(os.execute_or_panic('./temp make'))
	println(os.execute_or_panic('./temp make -a 7 -b 3,7 vhammll/datasets/developer.tab'))
	println(os.execute_or_panic('./temp make -a 7 -b 3,7 -x -e -o tempfolders/tempfolder_cli/dev.cl vhammll/datasets/developer.tab'))
}

fn test_cross() {
	println(os.execute_or_panic('./temp cross --help'))
	println(os.execute_or_panic('./temp cross -c vhammll/datasets/iris.tab'))
	println(os.execute_or_panic('./temp cross -c -e -a 2 -b 3,6 vhammll/datasets/iris.tab'))
	println(os.execute_or_panic('./temp cross -c -e -a 2 -b 3,6 -f 10 -w vhammll/datasets/iris.tab'))
	println(os.execute_or_panic('./temp cross -c -e -a 6 -b 3,6 -f 20 -w vhammll/datasets/prostata.tab'))
	println(os.execute_or_panic('./temp cross -c -w -e -a 13 vhammll/datasets/UCI/zoo.arff'))
}

fn test_append() ? {
	// make a classifier
	println(os.execute_or_panic('./temp make -a 4 -o tempfolders/tempfolder_cli/bcw.cl vhammll/datasets/bcw350train'))
	// make an instances file by doing a validation
	println(os.execute_or_panic('./temp validate -k tempfolders/tempfolder_cli/bcw.cl -o tempfolders/tempfolder_cli/bcw.inst -t vhammll/datasets/bcw174test'))
	// use the instances file to append to the saved classifier
	println(os.execute_or_panic('./temp append -k tempfolders/tempfolder_cli/bcw.cl -o tempfolders/tempfolder_cli/bcw-ext.cl tempfolders/tempfolder_cli/bcw.inst'))
}

fn test_rank_attributes() {
	mut r := os.execute_or_panic('./temp rank')
	// println(r.output)
	assert r.output.contains('"rank" rank orders a dataset\'s attributes')
	r = os.execute_or_panic('./temp rank vhammll/datasets/developer.tab')
	// println(r.output)
	assert r.output.contains('5   age                              2  C           84.62     12')
	r = os.execute_or_panic('./temp rank -x -b 3,3 vhammll/datasets/iris.tab')
	// println(r.output)
	assert r.output.contains('4   sepal width                      1  C           34.67      3')
	r = os.execute_or_panic('./temp rank -b 2,6 -x -a 2 vhammll/datasets/iris.tab')
	// println(r.output)
	assert r.output.contains('Bin range for continuous attributes: from 2 to 6 with interval 1')
	r = os.execute_or_panic('./temp rank -x vhammll/datasets/anneal.tab')
	// println(r.output)
	assert r.output.contains('8   carbon                           3  C           78.90      7')
}

fn test_display() {
	println(os.execute_or_panic('./temp cross -c -b 2,4 -a 4 -o tempfolders/tempfolder_cli/cross_result.txt vhammll/datasets/developer.tab'))
	println(os.execute_or_panic('./temp display -e tempfolders/tempfolder_cli/cross_result.txt'))
	println(os.execute_or_panic('./temp rank -o tempfolders/tempfolder_cli/rank_result.txt vhammll/datasets/UCI/segment.arff'))
	// println(os.execute_or_panic('./temp display -g tempfolders/tempfolder_cli/rank_result.txt'))
}

fn test_purge_for_missing_class_values() {
	mut r := os.execute_or_panic('./temp analyze -pmc vhammll/datasets/class_missing_developer.tab')
	println(r.output)
	// assert r.output.len == 2031
	// assert r.output.contains('6  SEC                                        13        5        1    7.7')
	r = os.execute_or_panic('./temp rank -pmc vhammll/datasets/class_missing_developer.tab')
	println(r.output)
	// assert r.output.len == 965
	// assert r.output.contains('2   negative                         9  C          100.00     12')
	r = os.execute_or_panic('./temp make -a 7 -b 3,7 - pmc vhammll/datasets/class_missing_developer.tab')
	println(r.output)
	// assert r.output.len == 1379
	// assert r.output.contains('9  negative                    C          80.00              -90.00      80.00     7')
}

fn test_partitioning() {
	path1 := 'tempfolders/tempfolder_cli/part1.tab'
	path2 := 'tempfolders/tempfolder_cli/part2.tab'
	path3 := 'tempfolders/tempfolder_cli/part3.tab'
	println(os.execute_or_panic('./temp partition'))
	println(os.execute_or_panic('./temp partition -p# 3,2,1 -ps ${path1},${path2},${path3} -rand vhammll/datasets/developer.tab'))
	assert os.exists(path1)
	assert os.exists(path2)
	assert os.exists(path3)
	assert os.read_lines(path3)!.len == 4
}

