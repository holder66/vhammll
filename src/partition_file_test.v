

module vhammll

fn test_rand_part()! {
	partition_file([2,1], 'datasets/developer.tab', [], true)!
	partition_file([2,2,1], 'datasets/developer.tab', [], true)!
	partition_file([2,1], 'datasets/developer.tab', [], false)!
	partition_file([2,2,1], 'datasets/developer.tab', [], false)!
	// random_partition([2,1], 'datasets/anneal.tab', [])
	// random_partition([2,1], 'datasets/arrhythmia.arff', [])
	// random_partition([2,1], 'datasets/covid_biochem.csv', [])
	// random_partition([2,1], '/Users/henryolders/mets/all_mets_v_other.tsv', [])

}