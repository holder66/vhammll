[![VHamML Continuous Integration](https://github.com/holder66/VHamML/actions/workflows/VHamML%20Continuous%20Integration.yml/badge.svg)](https://github.com/holder66/VHamML/actions/workflows/VHamML%20Continuous%20Integration.yml)
![GitHub](https://img.shields.io/github/license/holder66/VHamML)
# VHamML
A machine learning (ML) library for classification using a nearest neighbor algorithm based on Hamming distances.

You can incorporate the `VHamML` functions into your own code, or use the included Command Line Interface app (`src/vhamml.v`).

You can use `VHamML` with your own datasets, or with a selection of publicly available datasets that are widely used for demonstrating and testing ML classifiers, in the `datasets` directory. These files are either in [ARFF (Attribute-Relation File Format)](https://waikato.github.io/weka-wiki/formats_and_processing/arff_stable/) or in [Orange file format](https://orange3.readthedocs.io/projects/orange-data-mining-library/en/latest/reference/data.io.html).

Classification accuracy with datasets in the `datasets` directory:
See this [table](https://henry.olders.ca/wordpress/?p=1885). Please note that these results were generated using an earlier version, with separate HamNN and VHamNN modules.

What, another AI package? [Is that necessary?](https://github.com/holder66/vhamml/blob/master/docs/AI_for_rest_of_us.md)
And have a look here for a more complete [description and potential use cases](https://github.com/holder66/vhamml/blob/master/docs/description.md). 

[Glossary of terms](https://github.com/holder66/vhamml/blob/master/docs/glossary.md)

## Installation:
First, install V, if not already installed. On MacOS, Linux etc. you need `git` and a C compiler (For windows or android environments, see the [v lang documentation](https://github.com/vlang/v/blob/master/doc/docs.md#windows)).

In a terminal:
```sh
git clone https://github.com/vlang/v
cd v
make
sudo ./v symlink	# add v to your PATH
```
Clone this github repository:
```sh
cd ~               # go back to your home directory
git clone https://github.com/holder66/vhamml
```
Install the needed dependencies:
```sh
v install vsl
v install Mewzax.chalk
```
Go into the vhamml directory, compile the app, and try it out:
```sh
cd vhamml
v .                # compiles all the files in the folder
./vhamml --help    # displays help information about the various commands
                   # and options available. More specific help information
                   # is available for each command.
```
That's it!

## Tutorial:
```
v run . examples go
```

## Updating:
```sh
v up        # installs the latest release of V
git pull    # When you're in the vhamml directory, this command pulls in the 
            # latest version of vhamml
v update    # get the latest version of the libraries, including holder66.vhamml
v .         # recompile
```

## Getting help:
The V lang community meets on [Discord](https://discord.gg/vlang)


For bug reports, feature requests, etc., please raise an issue on [github](https://github.com/holder66/vhamml/issues)


## Speed things up:

Using the -c (--concurrent) flag makes use of available CPU cores may speed things up.
A huge speedup happens if you compile using the -prod (for production) option. The compilation itself takes longer, but the resulting code is highly optimized.
```
v -prod .
```

And then run it, eg 
```
./vhamml explore -s -c datasets/iris.tab
```

## Examples showing use of the Command Line Interface
Please see [examples_of_command_line_usage.md](https://github.com/holder66/vhamml/blob/master/docs/examples_of_command_line_usage.md)

## Example: typical use case, a clinical risk calculator

Health care professionals frequently make use of calculators to inform clinical decision-making. Data regarding symptoms, findings on physical examination, laboratory and imaging results, and outcome information such as diagnosis, risk for developing a condition, or response to specific treatments, is collected for a sample of patients, and then used to form the basis of a formula that can be used to predict the outcome information of interest for a new patient, based on how their symptoms and findings, etc. compare to those in the dataset.

Please see [clinical_calculator_example.md](https://github.com/holder66/vhamml/blob/master/docs/clinical_calculator_example.md).

## Example: finding useful information embedded in noise

Please see a worked example here: [noisy_data.md](https://github.com/holder66/vhamml/blob/master/docs/noisy_data.md)


## MNIST dataset
The mnist_train.tab file is too large to keep in the repository. If you wish to experiment with it, it can be downloaded by right-clicking on [this link](http://henry.olders.ca/datasets/mnist_train.tab) in a web browser, or downloaded via the command line:
```
wget http://henry.olders.ca/datasets/mnist_train.tab
```

The process of development in its early stages is described in [this essay](https://henry.olders.ca/wordpress/?p=731) written in 1989.



Copyright (c) 2017, 2023: Henry Olders.
