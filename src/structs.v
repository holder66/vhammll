// structs.v
module vhammll

// pub const missings = ['?', '', 'NA', ' ']
// pub const integer_range_for_discrete = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

// DefaultVals holds configurable default values used during dataset loading:
// the string tokens recognised as missing values, and the integer range
// treated as discrete rather than continuous.
pub struct DefaultVals {
pub mut:
	missings                   []string = ['?', '', 'NA', ' ']
	integer_range_for_discrete []int    = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
}

// RocPoint is a point on a Receiver Operating Characteristic curve,
// extending Point with the classifier identifier string that produced it.
pub struct RocPoint {
	Point
pub mut:
	classifiers    string
	classifier_ids []int
}

// Point is a 2D coordinate used for ROC plots:
// fpr is 1 − specificity (false positive rate); sens is sensitivity.
pub struct Point {
pub mut:
	fpr  f64 // 1 - specificity
	sens f64 // sensitivity
}

// Class holds all class-attribute metadata for a dataset:
// the class attribute name and index, the unique class labels,
// per-class instance counts, and pre/post-purge statistics.
pub struct Class {
pub mut:
	class_name  string // the attribute which holds the class
	class_index int
	classes     []string // to ensure that the ordering remains the same
	// positive_class string
	class_values                         []string
	missing_class_values                 []int // these are the indices of the original class values array
	class_counts                         map[string]int
	pre_balance_prevalences_class_counts map[string]int
	lcm_class_counts                     i64
	prepurge_class_values_len            int
	postpurge_class_counts               map[string]int
	postpurge_lcm_class_counts           i64
}

struct ContinuousAttribute {
	values  []f32
	minimum f32
	maximum f32
}

// Dataset is the primary data structure produced by load_file().
// It holds all attribute data and types, class information, and
// pre-computed maps of useful continuous and discrete attributes
// ready for training a classifier.
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

// RankedAttribute represents a single attribute together with its
// computed rank value, optimal bin count, and supporting hit arrays.
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

// Binning specifies the lower bound, upper bound, and step interval
// for binning (discretising) continuous attribute values.
pub struct Binning {
mut:
	lower    int
	upper    int
	interval int
}

// RankingResult is returned by rank_attributes() and rank_one_vs_rest();
// it contains the ordered list of ranked attributes and the options
// used to produce the ranking.
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

// TrainedAttribute holds the training-time representation of a single
// attribute: its type, the value-to-integer translation table (discrete)
// or range and bin count (continuous), rank value, and fold-usage counter.
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

// Classifier is a fully trained classifier produced by make_classifier().
// It contains the trained attribute maps, encoded instance byte arrays,
// class information, and the creation history needed to reproduce or
// extend the classifier.
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

// ParametersForShow is a lightweight struct combining Parameters,
// LoadOptions, and Class, used solely for formatted console display
// of classifier or result settings.
struct ParametersForShow {
	Parameters
	LoadOptions
	Class
}

// History wraps the ordered list of HistoryEvent records that track
// how a Classifier was created and subsequently extended.
pub struct History {
pub mut:
	history_events []HistoryEvent
}

struct TotalNnParams {
mut:
	maximum_hamming_distance_array []int
	total_max_ham_dist             int
	lcm_max_ham_dist               i64
}

// HistoryEvent records a single event (create or append) in a
// classifier's lifecycle, capturing the date, instance counts before
// and after any purging, and the source file path.
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

// Parameters holds the core training and cross-validation settings
// shared across many operations: binning range, number of attributes,
// purge/weighting/one-vs-rest flags, fold and repetition counts, and
// the maximum Hamming distance.
pub struct Parameters {
pub mut:
	binning              Binning
	number_of_attributes []int = [0]
	uniform_bins         bool
	exclude_flag         bool
	purge_flag           bool
	weighting_flag       bool
	weight_ranking_flag  bool
	one_vs_rest_flag     bool
	multiple_flag        bool
	folds                int
	repetitions          int
	random_pick          bool
	// balance_prevalences_flag bool
	maximum_hamming_distance int
}

// CombinationSizeLimits controls the minimum and maximum number of
// classifiers to combine when generating multi-classifier combinations.
// Setting min/max also activates the generate_combinations_flag.
@[params]
pub struct CombinationSizeLimits {
pub mut:
	generate_combinations_flag bool
	min                        int = 2
	max                        int
}

// DisplaySettings aggregates all flags and limits that control what
// is printed to the console or generated as plots: show, expand,
// graph, verbose, ROC, overfitting, output limits, and combination
// size limits.
@[params]
pub struct DisplaySettings {
	CombinationSizeLimits
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
	all_attributes_flag  bool
}

// LoadOptions are passed to load_file() to control dataset loading:
// the positive class label, whether to purge instances with a missing
// class value, and whether to balance class prevalences.
@[params]
pub struct LoadOptions {
	DefaultVals
pub mut:
	positive_class                string
	class_missing_purge_flag      bool
	balance_prevalences_flag      bool
	balance_prevalences_threshold f64 = 0.9
}

// Options is the main all-in-one options struct used throughout the
// library. It embeds Parameters, LoadOptions, DisplaySettings, and
// MultipleOptions, and adds file paths (data, test, classifier,
// output, settings) and runtime flags such as concurrency and
// traverse_all_flags. It can be used as the last parameter of a
// function to pass named options with defaults.
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
	datafile_path                       string
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

// MultipleClassifierSettingsFileStruct is a thin wrapper used when
// deserialising a multiple-classifier settings file in which each
// line holds one ClassifierSettings JSON object.
struct MultipleClassifierSettingsFileStruct {
pub mut:
	multiple_classifier_settings []ClassifierSettings
}

// AucClassifiers associates a set of classifier IDs with the
// Area Under the ROC Curve (AUC) value they jointly achieved.
pub struct AucClassifiers {
pub mut:
	classifier_ids []int
	auc            f64
}

// OptimalsResult is returned by optimals(); it identifies which
// classifier combinations achieve the best balanced accuracy,
// highest Matthews Correlation Coefficient (MCC), highest total
// correct inferences, and highest per-class correct inferences.
pub struct OptimalsResult {
	RocData
	RocFiles
pub mut:
	settings_length                                     int
	settings_purged                                     int
	all_attributes_flag                                 bool
	settingsfile_path                                   string
	datafile_path                                       string
	class_counts                                        []int
	best_balanced_accuracies                            []f64
	best_balanced_accuracies_classifiers_all            [][]int // refers to an array of classsifier ID values
	best_balanced_accuracies_classifiers                [][]int
	mcc_max                                             f64
	mcc_max_classifiers_all                             []int // refers to an array of classsifier ID values
	mcc_max_classifiers                                 []int
	correct_inferences_total_max                        int
	correct_inferences_total_max_classifiers_all        []int // refers to an array of classsifier ID values
	correct_inferences_total_max_classifiers            []int
	classes                                             []string
	correct_inferences_by_class_max                     []int
	correct_inferences_by_class_max_classifiers_all     [][]int // refers to an array of classsifier ID values
	correct_inferences_by_class_max_classifiers         [][]int
	receiver_operating_characteristic_settings          []int
	reversed_receiver_operating_characteristic_settings []int
	all_optimals                                        []int
	all_optimals_unique_attributes                      []int
	multi_classifier_combinations_for_auc               []AucClassifiers
}

// ClassifierSettings bundles all parameters needed to recreate a
// single classifier, together with the binary and multi-class
// performance metrics recorded when it was evaluated.
pub struct ClassifierSettings {
	Parameters
	BinaryMetrics
	Metrics
	LoadOptions
	ClassifierID
}

// ClassifierID links a numeric classifier identifier to the datafile
// path from which the classifier was trained.
pub struct ClassifierID {
pub mut:
	classifier_id int
	datafile_path string
}

// MultipleOptions holds settings that govern how multiple classifiers
// are combined: whether to stop as soon as all classifiers agree
// (break_on_all_flag), which combination strategy to use
// (multi_strategy: '', 'combined', or 'totalnn'), and which
// classifier IDs to include.
pub struct MultipleOptions {
	TotalNnParams
pub mut:
	break_on_all_flag bool
	multi_strategy    string // '', 'combined', or 'totalnn'
	classifiers       []int  // refers to an array of classsifier ID values
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

// Environment captures a snapshot of the runtime environment
// (OS kind and details, architecture, V executable mtime and version,
// and VFLAGS) recorded in classifier history events.
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

// Attribute holds descriptive statistics and metadata for a single
// attribute in a dataset, as produced by analyze_dataset(): name,
// type, unique-value count, missing-value count, and (for continuous
// attributes) min, max, mean, and median.
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

// AnalyzeResult is returned by analyze_dataset(); it contains
// per-attribute statistics, dataset-level metadata (path, type,
// class breakdown), and overall min/max values.
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

// ClassifyResult holds the outcome of classifying a single instance:
// the inferred class, nearest-neighbor counts by class, the labeled
// class (if known), Hamming distance, and sphere index reached.
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

pub type StringFloatMap = map[string]f64

// CrossVerifyResult is returned by cross_validate() and verify().
// It contains the inferred and actual class arrays, a full confusion
// matrix, per-class inference counts, accuracy metrics, and
// provenance information (file paths, classifier settings).
pub struct CrossVerifyResult {
	Parameters
	LoadOptions
	DisplaySettings
	Metrics
	BinaryMetrics
	MultipleOptions // MultipleClassifierSettingsArray
	Class
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
	// classes                              []string
	// class_counts                         map[string]int
	// pre_balance_prevalences_class_counts map[string]int
	train_dataset_class_counts map[string]int
	labeled_instances          map[string]int
	correct_inferences         map[string]int
	incorrect_inferences       map[string]int
	wrong_inferences           map[string]int
	true_positives             map[string]int
	false_positives            map[string]int
	true_negatives             map[string]int
	false_negatives            map[string]int
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

// ExploreResult is returned by explore(); it holds the array of
// CrossVerifyResults produced over a parameter sweep, together with
// the attribute range, binning, and display settings used.
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

// ValidateResult is returned by validate(); it contains the inferred
// classes for an unlabeled dataset, the encoded instance arrays, and
// provenance metadata. The result can be saved and later used to
// extend a classifier via append_instances().
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

// Metrics holds multi-class accuracy metrics computed for a
// verification or cross-validation: precision, recall, and F1 per
// class; their averages; balanced accuracy; and per-class instance,
// correct, and incorrect counts.
pub struct Metrics {
pub mut:
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

// BinaryMetrics holds performance metrics for a binary classifier:
// TP, FP, TN, FN counts; raw and balanced accuracy; sensitivity;
// specificity; PPV; NPV; F1 score; and the Matthews Correlation
// Coefficient (MCC).
pub struct BinaryMetrics {
pub mut:
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
