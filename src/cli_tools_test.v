// cli_tools_test.v
module vhammll

import os

fn test_flag() {
	mut args := ['rank', '-h']
	assert flag(args, ['-h', '--help', 'help']) == true
	assert flag(args, ['']) == false
	assert flag(args, []) == false
	assert flag(args, ['rank']) == true
	assert flag([], ['-h', '--help', 'help']) == false
}

fn test_option() {
	assert option(['--bins', '2,6', '-x', 'true', 'datasets/iris.tab'], ['-x', '--exclude']) == 'true'
	assert option(['--bins', '2,6', '--exclude', 'false', 'datasets/iris.tab'], ['-x', '--exclude']) == 'false'
	assert option(['-b', '2,6', '-x', 'true', 'datasets/iris.tab'], ['-b', '--bins']) == '2,6'
	assert option(['--bins', '2,6', '-x', 'true', 'datasets/iris.tab'], ['-b', '--bins']) == '2,6'
}

fn test_get_options() ? {
	mut opts := get_options(['garbage', 'more garbage'])
	assert opts.args == ['garbage', 'more garbage']

	assert !opts.show_flag
	assert !opts.expanded_flag
	assert !opts.graph_flag
	assert !opts.verbose_flag

	opts = get_options(['explore', '-h'])
	assert opts.command == 'explore'
	opts = get_options(['--bins', '4,6'])
	assert opts.bins == [4, 6]
	opts = get_options(['-v', '-e'])
	assert opts.verbose_flag
	assert opts.expanded_flag
	assert !opts.graph_flag
	assert !opts.show_flag
}

fn test_opts_function() {
	assert opts('').args == ['']
	assert opts('cross').command == 'cross'
	mut result := Options{}
	result = opts('-g -e -b 2,7 -pos Met src/testdata/ox1metstrainb2-4a2-25purged.opts')
	assert result.args == ['-g', '-e', '-b', '2,7', '-pos', 'Met',
		'src/testdata/ox1metstrainb2-4a2-25purged.opts']
	assert result.graph_flag && result.expanded_flag && result.bins == [2, 7]
		&& result.positive_class == 'Met'
		&& result.datafile_path == 'src/testdata/ox1metstrainb2-4a2-25purged.opts'
	assert result.command == ''
	result = opts('-e -pos Met -m src/testdata/ox1metstrainb2-4a2-25purged.opts -m# 0,20,40 ${os.home_dir()}/metabolomics/ox1_mets-train.tab')
	assert result.args == ['-e', '-pos', 'Met', '-m', 'src/testdata/ox1metstrainb2-4a2-25purged.opts',
		'-m#', '0,20,40', '${os.home_dir()}/metabolomics/ox1_mets-train.tab']
	assert result.command == ''
	assert result.expanded_flag && result.positive_class == 'Met'
		&& result.multiple_classify_options_file_path == 'src/testdata/ox1metstrainb2-4a2-25purged.opts'
		&& result.classifiers == [0, 20, 40]
		&& result.datafile_path == '${os.home_dir()}/metabolomics/ox1_mets-train.tab'

	assert opts('-e -pos Met -a 4 -b 1,4 -t ${os.home_dir()}/metabolomics/ox1_mets-test.tab ${os.home_dir()}/metabolomics/ox1_mets-train.tab').args == [
		'-e',
		'-pos',
		'Met',
		'-a',
		'4',
		'-b',
		'1,4',
		'-t',
		'${os.home_dir()}/metabolomics/ox1_mets-test.tab',
		'${os.home_dir()}/metabolomics/ox1_mets-train.tab',
	]

	result = opts('-e -pos Met -m src/testdata/ox1metstrainb2-4a2-25purged.opts -m# 0,10 -t ${os.home_dir()}/metabolomics/ox1_mets-test.tab ${os.home_dir()}/metabolomics/ox1_mets-train.tab')
	assert result.args == ['-e', '-pos', 'Met', '-m', 'src/testdata/ox1metstrainb2-4a2-25purged.opts',
		'-m#', '0,10', '-t', '${os.home_dir()}/metabolomics/ox1_mets-test.tab',
		'${os.home_dir()}/metabolomics/ox1_mets-train.tab']
	assert result.expanded_flag && result.positive_class == 'Met' && result.classifiers == [0, 10]
		&& result.testfile_path == '${os.home_dir()}/metabolomics/ox1_mets-test.tab'
}

fn test_show_help() ? {
	mut opts := Options{
		command: 'orange'
	}
	assert show_help(opts) == orange_help
	opts.command = ''
	assert show_help(opts) == vhammll_help
	opts.command = 'nonsense'
	assert show_help(opts) == vhammll_help
}

fn test_last() ? {
	mut array := ['abc', 'defg', 'xyz']
	assert array.last() == 'xyz'
	array = ['abc']
	assert array.last() == 'abc'
}

fn test_print_array() ? {
	mut array := ['first line', 'second line']
	print_array(array)
	array = ['single line']
	print_array(array)
	array = ['']
	print_array(array)
	array = []
	print_array(array)
}
