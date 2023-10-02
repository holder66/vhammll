![VHamMLLL Continuous Integration](https://github.com/holder66/vhammll/actions/workflows/main.yml/badge.svg)
![GitHub](https://img.shields.io/github/license/holder66/VHamMLL)
# VHamMLL
A machine learning (ML) library for classification using a nearest neighbor algorithm based on Hamming distances.

You can incorporate the `VHamMLL` functions into your own code, or use the included Command Line Interface app (`cli.v`).

[Link to html documentation for the library functions and structs](https://holder66.github.io/vhammll.html)

You can use `VHamMLL` with your own datasets, or with a selection of publicly available datasets that are widely used for demonstrating and testing ML classifiers, in the `datasets` directory. These files are mostly in [Orange file format](https://orange3.readthedocs.io/projects/orange-data-mining-library/en/latest/reference/data.io.html); there are also datasets in [ARFF (Attribute-Relation File Format)](https://waikato.github.io/weka-wiki/formats_and_processing/arff_stable/) or in comma-separated-values (CSV) as used in [Kaggle](https://www.kaggle.com).

Classification accuracy with datasets in the `datasets` directory:
See this [table](https://henry.olders.ca/wordpress/?p=1885). Please note that these results were generated using an earlier version, with separate HamNN and VHamNN modules.

What, another AI package? [Is that necessary?](https://github.com/holder66/vhamml/blob/master/docs/AI_for_rest_of_us.md)
And have a look here for a more complete [description and potential use cases](https://github.com/holder66/vhamml/blob/master/docs/description.md). 

[Glossary of terms](https://github.com/holder66/vhamml/blob/master/docs/glossary.md)

## Usage:
### To use the VHamMLL library in an existing Vlang project:
`v install holder66.vhammll`

You may also need to install its dependencies, if not automatically installed:
```sh
v install vsl
v install Mewzax.chalk
```

In your v code, add:
`import holder66.vhammll`

### To use the library with the Command Line Interface (CLI):
First, install V, if not already installed. On MacOS, Linux etc. you need `git` and a C compiler (For windows or android environments, see the [v lang documentation](https://github.com/vlang/v/blob/master/doc/docs.md#windows)).

In a terminal:
```sh
git clone https://github.com/vlang/v
cd v
make
sudo ./v symlink	# add v to your PATH
v install holder66.vhammll
```
See above re needed dependencies.

In a folder or directory that you want to use for your project, you will need to create a file with module `main`, and a function `main()`.
You can do this in the terminal, or with a text editor. The file should contain:
```v
module main
import holder66.vhammll

fn main() {
    vhammll.cli()!
}
```
Assuming you've named the directory or folder `vhamml` and the file within `main.v`, in the terminal:
`v run .` followed by the command line arguments, eg
`v run . --help` or `v run . analyze <path_to_dataset_file>`
Command-specific help is available, like so:
`v run . explore --help` or `v run . explore -h`

Note that the publicly available datasets included with the VHamMLL distribution can be found at `~/.vmodules/holder66/vhammll/datasets`.

That's it!

## Tutorial:
```sh
v run . examples go
```

## Updating:
```sh
v up        # installs the latest release of V
v update    # get the latest version of the libraries, including holder66.vhammll
v .         # recompile
```


## Getting help:
The V lang community meets on [Discord](https://discord.gg/vlang)


For bug reports, feature requests, etc., please raise an issue on [github](https://github.com/holder66/vhammll/issues)


## Speed things up:

Use the -c (--concurrent) argument (in the CLI) to make use of available CPU cores for
some vhammll functions; this may speed things up (timings are on a MacBook Pro 2019)
```sh
v main.v
./main explore ~/.vmodules/holder66/vhammll/datasets/iris.tab  # 10.157 sec
./main explore -c  ~/.vmodules/holder66/vhammll/datasets/iris.tab   # 4.910 sec
```
A huge speedup usually happens if you compile using the -prod (for production) option. The compilation itself takes longer, but the resulting code is highly optimized.
```sh
v -prod main.v
./main explore ~/.vmodules/holder66/vhammll/datasets/iris.tab  # 3.899 sec
./main explore -c  ~/.vmodules/holder66/vhammll/datasets/iris.tab   # 4.849 sec!!
```
Note that in this case, there is no speedup for `-prod` when the `-c` argument is used.


## Examples showing use of the Command Line Interface
Please see [examples_of_command_line_usage.md](https://github.com/holder66/vhammll/blob/master/docs/examples_of_command_line_usage.md)


## Example: typical use case, a clinical risk calculator

Health care professionals frequently make use of calculators to inform clinical decision-making. Data regarding symptoms, findings on physical examination, laboratory and imaging results, and outcome information such as diagnosis, risk for developing a condition, or response to specific treatments, is collected for a sample of patients, and then used to form the basis of a formula that can be used to predict the outcome information of interest for a new patient, based on how their symptoms and findings, etc. compare to those in the dataset.

Please see [clinical_calculator_example.md](https://github.com/holder66/vhammll/blob/master/docs/clinical_calculator_example.md).

## Example: finding useful information embedded in noise

Please see a worked example here: [noisy_data.md](https://github.com/holder66/vhammll/blob/master/docs/noisy_data.md)


## MNIST dataset
The mnist_train.tab file is too large to keep in the repository. If you wish to experiment with it, it can be downloaded by right-clicking on [this link](https://henry.olders.ca/datasets/mnist_train.tab) in a web browser, or downloaded via the command line:
```
wget https://henry.olders.ca/datasets/mnist_train.tab
```

The process of development in its early stages is described in [this essay](https://henry.olders.ca/wordpress/?p=731) written in 1989.



Copyright (c) 2017, 2023: Henry Olders.
