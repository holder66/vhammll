// load_csv_test.v

module vhammll

import os

fn test_load_csv_file() {
	mut ds := load_csv_file('datasets/play_tennis.csv')
	println(ds)
}
