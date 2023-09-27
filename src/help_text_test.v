// help_text_test.v

module vhammll

import os

const (
	output_search_terms = [
		'Description:',
		'Usage:',
		'Options:',
	]

	main_text           = '// temp.v
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

fn test_help() {
	flags := ['', '--help', '-h']

	for flag in flags {
		result := os.execute_or_panic('./temp ${flag}')
		assert result.exit_code == 0
		// assert result.output.contains('-k --classifier:')
		for term in vhammll.output_search_terms {
			assert result.output.contains(term)
		}
	}
}

fn test_command_help() {
	commands := ['analyze', 'append', 'cross', 'display', 'examples', 'explore', 'make', 'orange',
		'query', 'rank', 'validate', 'verify']
	flags := ['', '--help', '-h']
	for command in commands {
		for flag in flags {
			result := os.execute_or_panic('./temp ${command} ${flag}')
			assert result.exit_code == 0
			for term in vhammll.output_search_terms {
				assert result.output.contains(term)
			}
		}
	}
}
