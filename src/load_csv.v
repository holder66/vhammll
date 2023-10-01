// load_csv.v
module vhammll

import os

// load_csv_file loads a comma-separated file (as used by Kaggle) into a
// Dataset struct. It sets the attribute type for the first column as 
// metadata, and the last column as the class attribute.
fn load_csv_file(path string) Dataset {
	mut content_csv := os.read_lines(path.trim_space()) or { panic('failed to open ${path}')}
	mut content := content_csv.map(it.split(','))
	mut attr_names := content[0]
	
	println(content)
	mut ds := Dataset{
		path: path
		data: content
		attribute_names: content[0]

	}
	return ds
}