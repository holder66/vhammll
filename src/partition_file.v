// partition_file.v

module vhammll

import os
import arrays
import rand

// take a data file and partition it by random picking, into two or three partitions

fn partition_file(partition_sizes []int, in_file string, out_files []string, random_flag bool)! {
	mut header_lines := []string{}
	mut data_lines := []string{}
	// get file type, so we know how to home in on the data rows
	f_type := file_type(in_file)
	dump(f_type)
	mut lines := os.read_lines(in_file)!
	header_lines, data_lines = match f_type {
		'orange_newer' {partition_orange_newer_file(lines)}
		else {panic('file type of file "in_file" was not recognized')}
	}
	dump(header_lines)
	dump(data_lines.len)
	dump(arrays.sum(partition_sizes)!)
	mut partition_size := data_lines.len / arrays.sum(partition_sizes)!
	dump(partition_size)
	mut partition_lengths := []int{}
	for size in partition_sizes#[..-1] {
		partition_lengths << size * partition_size
	}
	partition_lengths << data_lines.len - arrays.sum(partition_lengths)!
	dump(partition_lengths)
	mut partition_indices := [][]int{}
	for length in partition_lengths {

	partition_indices << generate_pick_list(length, data_lines.len, partition_indices, random_flag)!
}
dump(partition_indices)
}

fn partition_orange_newer_file(lines []string) ([]string, []string) {
	return lines[..1], lines[1..]
}

// generate a pick list of indices
fn generate_pick_list(list_size int, max_index int, already_picked [][]int, random_flag bool) ![]int {
		mut pick_list := []int{}
		if random_flag {
			mut n := 0
			for pick_list.len < list_size {
				n = rand.int_in_range(0, max_index) or { 0 }
				if n in pick_list || n in arrays.flatten(already_picked) {
					continue
				}
				pick_list << n
			}
			return pick_list
		} else {
			next := if already_picked.len == 0 {0} else {already_picked.last().last() + 1}
			return []int{len: list_size, init:index+next}
	}
}