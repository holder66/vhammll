// cli_functions_test.v
module vhamml

// test_flag
fn test_flag() {
	mut args := ['rank', '-h']
	assert flag(args, ['-h', '--help', 'help']) == true
	assert flag(args, ['']) == false
	assert flag(args, []) == false
	assert flag(args, ['rank']) == true
	assert flag([], ['-h', '--help', 'help']) == false
}

// test_option
fn test_option() {
	assert option(['--bins', '2,6', '-x', 'true', 'datasets/iris.tab'], ['-x', '--exclude']) == 'true'
	assert option(['--bins', '2,6', '--exclude', 'false', 'datasets/iris.tab'], ['-x', '--exclude']) == 'false'
	assert option(['-b', '2,6', '-x', 'true', 'datasets/iris.tab'], ['-b', '--bins']) == '2,6'
	assert option(['--bins', '2,6', '-x', 'true', 'datasets/iris.tab'], ['-b', '--bins']) == '2,6'
}

// test_get_options
fn test_get_options() ? {
	// assert get_options(['']) == opts
	assert get_options(['garbage', 'more garbage']).args == ['garbage', 'more garbage']
	assert get_options(['explore', '-h']).command == 'explore'
	assert get_options(['orange']).command == 'orange'
	assert get_options(['--bins', '4,6']).bins == [4, 6]
}

// test_show_help
fn test_show_help() ? {
	// mut opts := Options{
	// 	command: 'orange'
	// }
	// assert show_help(opts) == orange_help
	// opts.command = ''
	// assert show_help(opts) == vhamml_help
	// opts.command = 'nonsense'
	// assert show_help(opts) == vhamml_help
}

// test_parse_range
fn test_parse_range() ? {
	mut arg := '1,2,3'
	assert parse_range(arg) == [1, 2, 3]
	arg = '2,3'
	assert parse_range(arg) == [2, 3]
	arg = '3'
	assert parse_range(arg) == [3]
	arg = ''
	assert parse_range(arg) == [0]
}

// test_last
fn test_last() ? {
	mut array := ['abc', 'defg', 'xyz']
	assert last(array) == 'xyz'
	array = ['abc']
	assert last(array) == 'abc'
}

// test_print_array
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
