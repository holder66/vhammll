// cli_functions_test.v
module vhammll

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
	mut opts, mut disp := get_options(['garbage', 'more garbage'])
	assert opts.args == ['garbage', 'more garbage']
	assert disp == DisplaySettings{
		show_flag: false
		expanded_flag: false
		graph_flag: false
		verbose_flag: false
	}
	opts, disp = get_options(['explore', '-h'])
	assert opts.command == 'explore'
	opts, disp = get_options(['--bins', '4,6'])
	assert opts.bins == [4, 6]
	opts, disp = get_options(['-v', '-e'])
	assert disp.verbose_flag
	assert disp.expanded_flag
	assert !disp.graph_flag
	assert !disp.show_flag
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
	assert last(array) == 'xyz'
	array = ['abc']
	assert last(array) == 'abc'
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
