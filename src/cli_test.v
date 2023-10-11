// cli_test.v
module vhammll

import os

const (
	main_text = '// temp.v
module main
import vhammll

fn main() {
	vhammll.cli()!
}'
)

fn testsuite_begin() ? {
	os.chdir('..')!
	mut f := os.create(os.abs_path('') + '/temp.v')!
	f.write_string(vhammll.main_text)!
	f.close()

	os.execute_or_panic('v -keepc run temp.v')
	if os.is_dir('tempfolder_cli') {
		os.rmdir_all('tempfolder_cli')!
	}
	os.mkdir_all('tempfolder_cli')!
}

fn testsuite_end() ? {
	if os.exists('temp') {
		os.rm('temp')!
	}
	if os.exists('temp.v') {
		os.rm('temp.v')!
	}
	os.rmdir_all('tempfolder_cli')!
}



// test_explore
// fn test_explore() {
// 	println(os.execute_or_panic('v run . explore --help'))
// 	println(os.execute_or_panic('v run . explore -g datasets/iris.tab'))
// 	println(os.execute_or_panic('v run . explore -g -a 2 -b 6  -c datasets/leukemia34test.tab'))
// 	println(os.execute_or_panic('v run . explore -g -e -c -o tempfolder_cli/breast.exr datasets/breast-cancer-wisconsin-disc.tab'))
// 	println(os.execute_or_panic('v run . cross -c -w -e -a 13 datasets/UCI/zoo.arff'))
// }

// // test_verify
// fn test_verify() {
// 	println(os.execute_or_panic('v run . verify -h'))
// 	println(os.execute_or_panic('v run . verify -c -t datasets/bcw174test datasets/bcw350train'))
// 	// save a classifier to a file
// 	println(os.execute_or_panic('v run . make -a 33 -b 2,16 -w -o tempfolder_cli/soybean.cl datasets/soybean-large-train.tab'))
// 	println(os.execute_or_panic('v run . verify -c -w -s -k tempfolder_cli/soybean.cl -t datasets/soybean-large-test.tab'))
// }

// // test_analyze
// fn test_analyze() {
// 	println(os.execute_or_panic('v run .'))
// 	println(os.execute_or_panic('v run . analyze datasets/developer.tab'))
// 	// println(os.execute_or_panic('v run . analyze datasets/bcw174test'))
// 	// println(os.execute_or_panic('v run . analyze datasets/iris.tab'))
// }

// // test_make
// fn test_make() {
// 	println(os.execute_or_panic('v run . make'))
// 	println(os.execute_or_panic('v run . make -a 7 -b 3,7 datasets/developer.tab'))
// 	println(os.execute_or_panic('v run . make -a 7 -b 3,7 -x -e -o tempfolder_cli/dev.cl datasets/developer.tab'))
// }

// // test_cross
// fn test_cross() {
// 	println(os.execute_or_panic('v run . cross --help'))
// 	println(os.execute_or_panic('v run . cross -c datasets/iris.tab'))
// 	println(os.execute_or_panic('v run . cross -c -e -a 2 -b 3,6 datasets/iris.tab'))
// 	println(os.execute_or_panic('v run . cross -c -e -a 2 -b 3,6 -f 10 -w datasets/iris.tab'))
// 	println(os.execute_or_panic('v run . cross -c -e -a 6 -b 3,6 -f 20 -w datasets/prostata.tab'))
// 	println(os.execute_or_panic('v run . cross -c -w -e -a 13 datasets/UCI/zoo.arff'))
// }

// // test_append
// fn test_append() ? {
// 	// make a classifier
// 	println(os.execute_or_panic('v run . make -a 4 -o tempfolder_cli/bcw.cl datasets/bcw350train'))
// 	// make an instances file by doing a validation
// 	println(os.execute_or_panic('v run . validate -k tempfolder_cli/bcw.cl -o tempfolder_cli/bcw.inst -t datasets/bcw174test'))
// 	// use the instances file to append to the saved classifier
// 	println(os.execute_or_panic('v run . append -k tempfolder_cli/bcw.cl -o tempfolder_cli/bcw-ext.cl tempfolder_cli/bcw.inst'))
// }

fn test_rank_attributes() {
	mut r := os.execute_or_panic('./temp rank')
	// println(r.output)
	assert r.output.len == 558
	assert r.output.contains('"rank" rank orders a dataset\'s attributes')
	r = os.execute_or_panic('./temp rank vhammll/datasets/developer.tab')
	// println(r.output)
	assert r.output.len == 899
	assert r.output.contains('5   age                              2  C           84.62     12')
	r = os.execute_or_panic('./temp rank -x -b 3,3 vhammll/datasets/iris.tab')
	// println(r.output)
	assert r.output.len == 613
	assert r.output.contains('4   sepal width                      1  C           34.67      3')
	r = os.execute_or_panic('./temp rank -b 2,6 -x -a 2 vhammll/datasets/iris.tab')
	// println(r.output)
	assert r.output.len == 613
	assert r.output.contains('Bin range for continuous attributes: from 2 to 6 with interval 1')
	r = os.execute_or_panic('./temp rank -x -g vhammll/datasets/anneal.tab')
	// println(r.output)
	assert r.output.len == 2705
	assert r.output.contains('8   carbon                           3  C           78.90      7')
}

// fn test_display() {
// 	println(os.execute_or_panic('v run . cross -c -b 2,4 -a 4 -o tempfolder_cli/cross_result.txt datasets/developer.tab'))
// 	println(os.execute_or_panic('v run . display -e tempfolder_cli/cross_result.txt'))
// 	println(os.execute_or_panic('v run . rank -o tempfolder_cli/rank_result.txt datasets/UCI/segment.arff'))
// 	println(os.execute_or_panic('v run . display -g tempfolder_cli/rank_result.txt'))
// }

fn test_purge_for_missing_class_values() {
	mut r := os.execute_or_panic('./temp analyze -pmc vhammll/datasets/class_missing_developer.tab')
	// println(r.output)
	assert r.output.len == 2803
	assert r.output.contains('6  SEC                                         5        1    7.7')
	r = os.execute_or_panic('./temp rank -pmc vhammll/datasets/class_missing_developer.tab')
	// println(r.output)
	assert r.output.len == 913
	assert r.output.contains('2   negative                         9  C          100.00     12')
	r = os.execute_or_panic('./temp make -a 7 -b 3,7 - pmc vhammll/datasets/class_missing_developer.tab')
	// println(r.output)
	assert r.output.len == 1326
	assert r.output.contains('9  negative                    C          80.00              -90.00      80.00     7')
