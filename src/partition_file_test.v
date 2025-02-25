module vhammll

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolders/tempfolder_partition_file') {
		os.rmdir_all('tempfolders/tempfolder_partition_file')!
	}
	os.mkdir_all('tempfolders/tempfolder_partition_file')!
}

fn testsuite_end() ? {
	os.rmdir_all('tempfolders/tempfolder_partition_file')!
}

fn test_partition_file()! {
	partition_file([2,1], 'datasets/developer.tab', [], true)!
	partition_file([2,1], 'datasets/developer.tab', ['tempfolders/tempfolder_partition_file/developer_bigtrain.tab','tempfolders/tempfolder_partition_file/developer_bigtest.tab'], false)!
	partition_file([2,2,1], 'datasets/developer.tab', ['tempfolders/tempfolder_partition_file/developer_train.tab','tempfolders/tempfolder_partition_file/developer_test.tab','tempfolders/tempfolder_partition_file/developer_validate.tab'], false)!
	partition_file([3,1], 'datasets/anneal.tab', ['tempfolders/tempfolder_partition_file/anneal_bigtrain.tab','tempfolders/tempfolder_partition_file/anneal_bigtest.tab'], true)!
	partition_file([2,1], '/Users/henryolders/mets/all_mets_v_other.tsv', ['tempfolders/tempfolder_partition_file/ox2_bigtrain.tab','tempfolders/tempfolder_partition_file/ox2_bigvalidate.tab'], true)!
	// verify that the generated files are usable
	mut result := CrossVerifyResult{}
	mut opts := Options{
		datafile_path: 'tempfolders/tempfolder_partition_file/developer_bigtrain.tab'
		testfile_path: 'tempfolders/tempfolder_partition_file/developer_bigtest.tab'
		command: 'verify'
		show_attributes_flag: true
		expanded_flag: true
	}
	result = verify(opts)
	opts.datafile_path = 'tempfolders/tempfolder_partition_file/anneal_bigtrain.tab'
	opts.testfile_path = 'tempfolders/tempfolder_partition_file/anneal_bigtest.tab'
	result = verify(opts)

	opts.datafile_path = 'tempfolders/tempfolder_partition_file/ox2_bigtrain.tab'
	opts.testfile_path = 'tempfolders/tempfolder_partition_file/ox2_bigvalidate.tab'
	opts.number_of_attributes = [2]
	opts.bins = [3,3]
	opts.balance_prevalences_flag = true
	opts.command = 'cross'
	result = cross_validate(load_file(opts.datafile_path) ,opts)
}