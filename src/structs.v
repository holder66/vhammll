// structs.v
module vhammll

// pub const missings = ['?', '', 'NA', ' ']
// pub const integer_range_for_discrete = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

pub struct DefaultVals {
pub mut:
	missings                   []string = ['?', '', 'NA', ' ']
	integer_range_for_discrete []int    = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
}

pub struct Class {
pub mut:
	class_name  string // the attribute which holds the class
	class_index int
	classes     []string // to ensure that the ordering remains the same
	// positive_class string
	class_values               []string
	missing_class_values       []int // these are the indices of the original class values array
	class_counts               map[string]int
	lcm_class_counts           i64
	prepurge_class_values_len  int
	postpurge_class_counts     map[string]int
	postpurge_lcm_class_counts i64
}

struct ContinuousAttribute {
	values  []f32
	minimum f32
	maximum f32
}

pub struct Dataset {
	Class // DataDict
	LoadOptions
pub mut:
	struct_type                  string = '.Dataset'
	path                         string
	attribute_names              []string
	attribute_flags              []string
	raw_attribute_types          []string
	attribute_types              []string
	inferred_attribute_types     []string
	data                         [][]string
	useful_continuous_attributes map[int][]f32
	useful_discrete_attributes   map[int][]string
	row_identifiers              []string
}

struct Fold {
	Class
mut:
	fold_number     int
	attribute_names []string
	indices         []int
	data            [][]string
}

pub struct RankedAttribute {
pub mut:
	attribute_index      int
	attribute_name       string
	attribute_type       string
	rank_value           f32
	rank_value_array     []f32
	bins                 int
	array_of_hits_arrays [][][]int
}

pub struct Binning {
mut:
	lower    int
	upper    int
	interval int
}

pub struct RankingResult {
	Class
	LoadOptions
	DisplaySettings
pub mut:
	struct_type                string = '.RankingResult'
	path                       string
	exclude_flag               bool
	weight_ranking_flag        bool
	binning                    Binning
	array_of_ranked_attributes []RankedAttribute
}

pub struct TrainedAttribute {
pub mut:
	attribute_type    string
	translation_table map[string]int
	minimum           f32
	maximum           f32
	bins              int
	rank_value        f32
	index             int
	folds_count       int // for cross-validations, this tracks how many folds use this attribute
}

pub struct Classifier {
	History
	Parameters
	LoadOptions
	Class
pub mut:
	struct_type        string = '.Classifier'
	datafile_path      string
	attribute_ordering []string
	trained_attributes map[string]TrainedAttribute
	// maximum_hamming_distance int
	indices   []int
	instances [][]u8
	// history   []HistoryEvent
}

pub struct History {
pub mut:
	history_events []HistoryEvent
}

pub struct OneVsRestClassifier {
	Parameters
	LoadOptions
	Class
	History
pub mut:
	struct_type   string = '.OneVsRestClassifier'
	datafile_path string
	// history       []HistoryEvent
}

struct TotalNnParams {
mut:
	maximum_hamming_distance_array []int
	total_max_ham_dist             int
	lcm_max_ham_dist               i64
}

pub struct HistoryEvent {
	Environment
pub mut:
	event_date               string
	instances_count          int
	prepurge_instances_count int
	// event_environment        Environment
	event     string
	file_path string
}

struct Parameters {
pub mut:
	binning                  Binning
	number_of_attributes     []int = [0]
	uniform_bins             bool
	exclude_flag             bool
	purge_flag               bool
	weighting_flag           bool
	weight_ranking_flag      bool
	one_vs_rest_flag         bool
	multiple_flag            bool
	folds                    int
	repetitions              int
	random_pick              bool
	balance_prevalences_flag bool
	maximum_hamming_distance int
}

@[params]
pub struct DisplaySettings {
pub mut:
	show_flag            bool
	expanded_flag        bool
	show_attributes_flag bool
	graph_flag           bool
	help_flag            bool
	verbose_flag         bool
	generate_roc_flag    bool
	limit_output         int
	overfitting_flag     bool
}

@[params]
pub struct LoadOptions {
	DefaultVals
pub mut:
	positive_class           string
	class_missing_purge_flag bool
}

// Options struct: can be used as the last parameter in a
// function's parameter list, to enable
// default values to be passed to functions.
@[params]
pub struct Options {
	Parameters
	LoadOptions
	DisplaySettings
	MultipleOptions // MultipleClassifierSettingsArray
pub mut:
	struct_type                         string = '.Options'
	non_options                         []string
	bins                                []int = [2, 16]
	explore_rank                        []int
	partition_sizes                     []int
	concurrency_flag                    bool
	datafile_path                       string = 'datasets/developer.tab'
	traverse_all_flags                  bool
	testfile_path                       string
	outputfile_path                     string
	classifierfile_path                 string
	instancesfile_path                  string
	multiple_classify_options_file_path string
	multiple_classifier_settings        []ClassifierSettings
	settingsfile_path                   string
	roc_settingsfile_path               string
	partitionfiles_paths                []string
	append_settings_flag                bool
	command                             string
	args                                []string
	kagglefile_path                     string
}

pub struct MultipleClassifierSettingsFileStruct {
pub mut:
	multiple_classifier_settings []ClassifierSettings
}

pub struct OptimalsResult {
pub mut:
	class_counts                                []int
	balanced_accuracy_max                       f64
	balanced_accuracy_max_classifiers           []int // refers to an array of classsifier ID values
	mcc_max                                     f64
	mcc_max_classifiers                         []int // refers to an array of classsifier ID values
	correct_inferences_total_max                int
	correct_inferences_total_max_classifiers    []int // refers to an array of classsifier ID values
	classes                                     []string
	correct_inferences_by_class_max             []int
	correct_inferences_by_class_max_classifiers [][]int // refers to an array of classsifier ID values
	receiver_operating_characteristic_settings  []int
}

pub struct ClassifierSettings {
	Parameters
	BinaryMetrics
	Metrics
	LoadOptions
	ClassifierID
}

pub struct ClassifierID {
pub mut:
	classifier_id int
	datafile_path string
}

pub struct MultipleOptions {
	TotalNnParams
pub mut:
	break_on_all_flag    bool
	combined_radii_flag  bool
	total_nn_counts_flag bool
	classifiers          []int // refers to an array of classsifier ID values
}

struct RadiusResults {
mut:
	sphere_index               int
	radius                     int
	nearest_neighbors_by_class []int
	inferred_class_found       bool
	inferred_class             string
}

struct IndividualClassifierResults {
mut:
	results_by_radius []RadiusResults
	inferred_class    string
	radii             []int
}

struct MultipleClassifierResults {
	MultipleOptions
mut:
	number_of_attributes         []int
	maximum_number_of_attributes int
	lcm_attributes               i64
	combined_radii               []int
	results_by_classifier        []IndividualClassifierResults
	max_sphere_index             int
}

pub struct Environment {
pub mut:
	vhammll_version string
	// cached_cpuinfo map[string]string
	os_kind        string
	os_details     string
	arch_details   []string
	vexe_mtime     string
	v_full_version string
	vflags         string
}

pub struct Attribute {
pub mut:
	id            int
	name          string
	count         int
	counts_map    map[string]int
	uniques       int
	missing       int
	raw_type      string
	att_type      string
	inferred_type string
	for_training  bool
	min           f32
	max           f32
	mean          f32
	median        f32
}

pub struct AnalyzeResult {
	LoadOptions
pub mut:
	struct_type             string = '.AnalyzeResult'
	environment             Environment
	datafile_path           string
	datafile_type           string
	class_name              string
	class_index             int
	class_counts            map[string]int
	attributes              []Attribute
	overall_min             f32
	overall_max             f32
	use_inferred_types_flag bool
}

pub struct ClassifyResult {
	LoadOptions
	Class
pub mut:
	struct_type                string = '.ClassifyResult'
	index                      int
	inferred_class             string
	inferred_class_array       []string
	labeled_class              string
	nearest_neighbors_by_class []int
	nearest_neighbors_array    [][]int
	classes                    []string
	class_counts               map[string]int
	weighting_flag             bool
	weighting_flag_array       []bool
	multiple_flag              bool
	hamming_distance           int
	sphere_index               int
}

pub struct ResultForClass {
pub mut:
	labeled_instances    int
	correct_inferences   int
	incorrect_inferences int
	wrong_inferences     int
	confusion_matrix_row map[string]int
}

pub type StringFloatMap = map[string]f64

// Returned by cross_validate() and verify()
pub struct CrossVerifyResult {
	Parameters
	LoadOptions
	DisplaySettings
	Metrics
	BinaryMetrics
	MultipleOptions // MultipleClassifierSettingsArray
pub mut:
	struct_type                         string = '.CrossVerifyResult'
	command                             string
	datafile_path                       string
	testfile_path                       string
	multiple_classify_options_file_path string
	multiple_classifier_settings        []ClassifierSettings
	labeled_classes                     []string
	actual_classes                      []string
	inferred_classes                    []string
	nearest_neighbors_by_class          [][]int
	instance_indices                    []int
	classes                             []string
	class_counts                        map[string]int
	labeled_instances                   map[string]int
	correct_inferences                  map[string]int
	incorrect_inferences                map[string]int
	wrong_inferences                    map[string]int
	true_positives                      map[string]int
	false_positives                     map[string]int
	true_negatives                      map[string]int
	false_negatives                     map[string]int
	// outer key: actual class; inner key: predicted class
	confusion_matrix_map            map[string]StringFloatMap
	pos_neg_classes                 []string
	correct_count                   int
	incorrects_count                int
	wrong_count                     int
	total_count                     int
	bin_values                      []int // used for displaying the binning range for explore
	attributes_used                 int
	prepurge_instances_counts_array []int
	classifier_instances_counts     []int
	repetitions                     int
	confusion_matrix                [][]string
	// trained_attribute_maps_array    []map[string]TrainedAttribute
	trained_attribute_maps_array []map[string]TrainedAttribute
}

struct AttributeRange {
mut:
	start        int
	end          int
	att_interval int
}

pub struct ExploreResult {
	Class
	Parameters
	LoadOptions
	AttributeRange
	DisplaySettings
pub mut:
	struct_type      string = '.ExploreResult'
	path             string
	testfile_path    string
	pos_neg_classes  []string
	array_of_results []CrossVerifyResult
	// accuracy_types   []string = ['raw accuracy', 'balanced accuracy', ' MCC (Matthews Correlation Coefficient)']
	// analytics        []MaxSettings
	// analytics map[string]Analytics
	args []string
}

//
pub struct SettingsForROC {
pub mut:
	master_class_index      int
	classifiers_for_roc     []ClassifierSettings
	array_of_correct_counts [][]int
}

pub struct PlotResult {
pub mut:
	bin             int
	attributes_used int
	correct_count   int
	total_count     int
}

pub struct ValidateResult {
	Class
	Parameters
	LoadOptions
pub mut:
	struct_type                     string = '.ValidateResult'
	datafile_path                   string
	validate_file_path              string
	row_identifiers                 []string
	inferred_classes                []string
	counts                          [][]int
	instances                       [][]u8
	attributes_used                 int
	prepurge_instances_counts_array []int
	classifier_instances_counts     []int
}

struct Metrics {
mut:
	precision         []f64
	recall            []f64
	f1_score          []f64
	avg_precision     []f64
	avg_recall        []f64
	avg_f1_score      []f64
	avg_type          []string
	balanced_accuracy f64
	class_counts_int  []int
	correct_counts    []int
	incorrect_counts  []int
}

struct BinaryMetrics {
mut:
	t_p             int
	f_n             int
	t_n             int
	f_p             int
	raw_acc         f64
	bal_acc         f64
	sens            f64
	spec            f64
	ppv             f64
	npv             f64
	f1_score_binary f64
	mcc             f64 // Matthews Correlation Coefficient
}

struct BinaryCounts {
mut:
	t_p int
	f_n int
	t_n int
	f_p int
}

type Val = f64 | int

struct Analytics {
mut:
	valeur                      Val
	idx                         int
	settings                    MaxSettings
	binary_counts               []int
	multiclass_correct_counts   []int
	multiclass_incorrect_counts []int
}

struct MaxSettings {
mut:
	attributes_used int
	binning         []int
	purged_percent  f64
}
