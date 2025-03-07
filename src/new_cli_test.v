// new_cli_test.v
module vhammll

import os

fn test_ranking_via_cli() {
	path_to_vhammll := os.join_path(os.home_dir(), '.vmodules/holder66/vhammll')
	mut file_path := os.join_path(path_to_vhammll, 'datasets/UCI/diabetes.arff')
	mut opts := CliOptions{
		args: ['rank', '-b', '3,3', '-l', '20', '--explore-rank', '12', '-ov', '${file_path}']
	}
	cli(opts)!
}
