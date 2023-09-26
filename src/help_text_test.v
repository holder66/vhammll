// help_text_test.v

module main

import os

const (
	output_search_terms = [
		'Description:',
		'Usage:',
		'Options:',
	]
)

fn test_help() {
	flags := ['', '--help', '-h']

	for flag in flags {
		result := os.execute_or_panic('${os.quoted_path(@VEXE)} run . ${flag}')
		assert result.exit_code == 0
		// assert result.output.contains('-k --classifier:')
		for term in output_search_terms {
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
			result := os.execute_or_panic('${os.quoted_path(@VEXE)} run . ${command} ${flag}')
			assert result.exit_code == 0
			for term in output_search_terms {
				assert result.output.contains(term)
			}
		}
	}
}
