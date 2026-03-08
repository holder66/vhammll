module vhammll

fn test_make_rocpoint() {
	settings := ClassifierSettings{
		BinaryMetrics: BinaryMetrics{
			sens: 0.8
			spec: 0.6
		}
	}
	rp := make_rocpoint(settings, 7)
	assert rp.classifier_ids == [7]
	assert rp.Point == Point{fpr: 0.4, sens: 0.8} // fpr = 1.0 - spec
	// perfect classifier: fpr = 0, sens = 1
	perfect := ClassifierSettings{
		BinaryMetrics: BinaryMetrics{
			sens: 1.0
			spec: 1.0
		}
	}
	rp_perfect := make_rocpoint(perfect, 0)
	assert rp_perfect.Point == Point{fpr: 0.0, sens: 1.0}
	assert rp_perfect.classifier_ids == [0]
	// worst case: fpr = 1, sens = 0
	worst := ClassifierSettings{
		BinaryMetrics: BinaryMetrics{
			sens: 0.0
			spec: 0.0
		}
	}
	rp_worst := make_rocpoint(worst, 99)
	assert rp_worst.Point == Point{fpr: 1.0, sens: 0.0}
	assert rp_worst.classifier_ids == [99]
}

fn test_extend_rocpoints() {
	// single interior point: [0,0] is prepended and [1,1] is appended
	mut rp := RocPoints{
		roc_points: [RocPoint{Point{0.3, 0.7}, [1]}]
	}
	result := rp.extend_rocpoints()
	assert result.roc_points.len == 3
	assert result.roc_points[0].Point == Point{0.0, 0.0}
	assert result.roc_points[0].classifier_ids == []
	assert result.roc_points[1] == RocPoint{Point{0.3, 0.7}, [1]}
	assert result.roc_points[2].Point == Point{1.0, 1.0}
	assert result.roc_points[2].classifier_ids == []
	// empty roc_points: only the two boundary points remain
	mut rp2 := RocPoints{}
	result2 := rp2.extend_rocpoints()
	assert result2.roc_points.len == 2
	assert result2.roc_points[0].Point == Point{0.0, 0.0}
	assert result2.roc_points[1].Point == Point{1.0, 1.0}
	// multiple points: boundaries are added around all of them
	mut rp3 := RocPoints{
		roc_points: [RocPoint{Point{0.2, 0.4}, [2]}, RocPoint{Point{0.5, 0.8}, [3]}]
	}
	result3 := rp3.extend_rocpoints()
	assert result3.roc_points.len == 4
	assert result3.roc_points[0].Point == Point{0.0, 0.0}
	assert result3.roc_points[3].Point == Point{1.0, 1.0}
}

fn test_roc_values() {
	mut pairs := [[0.857, 0.671], [0.857, 0.612], [0.857, 0.682],
		[0.286, 0.824], [0.714, 0.824], [0.286, 0.800], [0.857, 0.706]]
	mut classifiers := [[5, 113, 118], [120, 113, 118], [120, 113, 118],
		[70, 5, 120, 14, 113, 118], [70, 118, 113, 135, 14], [70, 5, 120, 14, 113, 118],
		[120, 113, 118]]
	mut result := roc_values(pairs, classifiers)
	assert result[6] == RocPoint{
		Point:          Point{
			fpr:  0.388
			sens: 0.857
		}
		classifier_ids: [120, 113, 118]
	}
	assert result[0].Point == Point{}
	assert result[7].Point == Point{1, 1}
	assert result[7].classifier_ids == []
}

fn test_auc_roc() {
	rp00 := RocPoint{Point{0, 0}, []int{}}
	rp01 := RocPoint{Point{0, 1}, []int{}}
	rp10 := RocPoint{Point{1, 0}, []int{}}
	rp11 := RocPoint{Point{1, 1}, []int{}}
	assert auc_roc([rp00, rp11]) == 0.5
	assert auc_roc([rp00, rp01]) == 0.0
	assert auc_roc([rp00, rp10]) == 0.0
	assert auc_roc([rp01, rp11]) == 1.0
	rp29 := RocPoint{Point{0.2, 0.9}, []int{}}
	rp58 := RocPoint{Point{0.5, 0.8}, []int{}}
	rp76 := RocPoint{Point{0.7, 0.6}, []int{}}
	assert auc_roc([rp00, rp29, rp58, rp76, rp11]) == 0.7250000000000001
}

fn test_round_two_decimals() {
	assert round_two_decimals(0.0) == 0.0
	assert round_two_decimals(1.0) == 1.0
	assert round_two_decimals(3.14159) == 3.14
	assert round_two_decimals(2.71828) == 2.72
	assert round_two_decimals(-3.14159) == -3.14
	// eliminates floating-point residue beyond two decimal places
	assert round_two_decimals(0.1 + 0.2) == 0.3
}

fn test_filter() {
	labels := ['a', 'b', 'a', 'c', 'a']
	values := [1.0, 2.0, 3.0, 4.0, 5.0]
	assert filter('a', labels, values) == [1.0, 3.0, 5.0]
	assert filter('b', labels, values) == [2.0]
	assert filter('c', labels, values) == [4.0]
	assert filter('z', labels, values) == [] // no match returns empty
	// works with string values
	keys := ['x', 'y', 'x']
	words := ['hello', 'world', 'foo']
	assert filter('x', keys, words) == ['hello', 'foo']
	assert filter('y', keys, words) == ['world']
	assert filter('z', keys, words) == []
}

fn test_filter_int() {
	keys := [1, 2, 1, 3, 1]
	values := [10.0, 20.0, 30.0, 40.0, 50.0]
	assert filter_int(1, keys, values) == [10.0, 30.0, 50.0]
	assert filter_int(2, keys, values) == [20.0]
	assert filter_int(3, keys, values) == [40.0]
	assert filter_int(99, keys, values) == [] // no match returns empty
	// works with int values
	k2 := [0, 1, 0]
	v2 := [100, 200, 300]
	assert filter_int(0, k2, v2) == [100, 300]
	assert filter_int(1, k2, v2) == [200]
}

fn test_area_under_curve() {
	mut x := []f64{}
	mut y := []f64{}
	x = [0.0, 1.0]
	y = [0.0, 1.0]
	assert area_under_curve(x, y) == 0.5
	x = [0.2, 0.4]
	y = [0.3, 0.4]
	assert area_under_curve(x, y) == 0.07
	x = [0.2, 0.3, 0.4]
	y = [0.5, 0.3, 0.1]
	assert area_under_curve(x, y) == 0.06
}


