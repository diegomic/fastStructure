# fastStructure

## Introduction

*fastStructure* is a fast algorithm for inferring population structure from large SNP genotype data. 
It is based on a variational Bayesian framework for posterior inference and is written in `Python3.x` (thanks to the work of [@jashapiro](https://github.com/jashapiro)). 
Here, we summarize how to setup this software package, compile the C and Cython scripts and run 
the algorithm on a test simulated genotype dataset.

## Components of fastStructure 

This repo has two components: a library of C and Cython scripts in *vars* and
a set of Cython and pure Python scripts to load the data and run the algorithm.

## Dependencies

- [Numpy](http://www.numpy.org/)
- [Scipy](http://www.scipy.org/)
- [Cython](http://cython.org/)
- [GNU Scientific Library](http://www.gnu.org/software/gsl/)

Most python distributions have the first three modules packaged in them. It's also
straightforward to install these dependencies:
  1. using package managers for MACOSX and several Linux distributions,
  2. from platform-specific binary packages, and
  3. directly from source.

Below are detailed instructions for installing these dependencies, provided by
Thierry Gosselin from Université Laval, Québec. These instructions were 
tested on Mac OS 10.8 (Mountain Lion), 10.9 (Mavericks) and 10.10 (Yosemite). (Note that the latest
versions of Cython and GSL can be different from those below.)

### Installing wget

Most Linux distributions already come with wget; this is, however, not true for the Mac OS.

- [Mac OS Instructions](http://gbs-cloud-tutorial.readthedocs.org/en/latest/03_computer_setup.html)

### Installing git

Git is already pre-installed on Mac OS and is pretty easly to install on CentOS, Ubuntu, etc. if it is not already available on those systems using `yum` or `apt`.

- [Mac OS instructions](http://gbs-cloud-tutorial.readthedocs.org/en/latest/08_useful.html)

### Installing the GNU Scientific Library

```bash
cd tmp
wget http://gnu.mirror.vexxhost.com/gsl/gsl-latest.tar.gz
tar -zxvf gsl-latest.tar.gz -C /install/directory
cd /install/directory/gsl-1.16
./configure --prefix=/install/directory/gsl-1.16
make
make install
```

### Installing `numpy`, `scipy`, `cython`

It is easiest to install these 3 packages once you have cloned this repository using the below command:

```bash
cd fastStructure/
pip install -r requirements.txt
```

## Building fastStructure

`fastStructure` is not currently available on PyPi so in order to install/use it, you must clone this repository.

To obtain the source code from github, clone this repo into the desired directory:

```bash
git clone https://github.com/rajanil/fastStructure
```

To retrieve the latest code updates, you can do the following:

```bash
cd fastStructure
git fetch
git merge origin/master
```

## Building Python extensions

Before building python extensions, it is important to identify the path to the library
files libgsl.so and libgslcblas.so, and header file
gsl/gsl_sf_psi.h that are part of your GSL installation. For a default
installation of GSL, the libraries (.so files) are usually found in /usr/local/lib
and the header files (.h files) in /usr/local/include. In this case, you can add these
lines to your `.bash_profile` or `.profile` file on your home directory.

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export CFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
```

Then, run `source ~/.bash_profile` to set these environment variables.

#### Build Library Extensions

To build library extensions, run the following:

```bash
cd fastStructure/vars/
python setup.py build_ext --inplace
```

#### Compile Cython Scripts

To compile the main cython scripts, run the following:

```bash
cd fastStructure/
python setup.py build_ext --inplace
```

Each setup will create some `.c` and `.so` (shared object) files.
The setup may give some warnings, which are OK. If you get errors that indicate the 
build failed, this might be because the wrong compiler is being used or 
environment variables (like LD_LIBRARY_PATH) are set incorrectly. To use a specific
gcc compiler, try the following:

```bash
CC=</path/to/compiler> python setup.py build_ext --inplace
```

## Using fastStructure

The main script you will need to execute is `structure.py`. To see command-line 
options that need to be passed to the script, you can do the following:

```console
user@host [~] python structure.py

Here is how you can use this script

Usage: python structure.py
        -K <int>  (number of populations)
        --input=<file>  (/path/to/input/file)
        --output=<file>  (/path/to/output/file)
        --tol=<float>   (convergence criterion; default: 10e-6)
        --prior={simple,logistic}   (choice of prior; default: simple)
        --cv=<int>   (number of test sets for cross-validation, 0 implies no CV step; default: 0)
        --format={bed,str} (format of input file; default: bed)
        --full   (to output all variational parameters; optional)
        --seed=<int> (manually specify seed for random number generator; optional)
```

fastStructure performs inference for the simplest, independent-loci, admixture model, with two choices of priors
that can be specified using the `--prior` flag. Thus, unlike Structure, fastStructure does not require the
mainparams and extraparam files. The inference algorithm used by fastStructure is fundamentally different from
that of Structure and requires the setting of far fewer options. All options for fastStructure can be passed
via the flags listed above.

### Main options

The key options to pass to the scripts are the input file, the output file and the number of populations.
Assuming the input file is named `genotypes.bed` (with corresponding `genotypes.fam` and `genotypes.bim`),
the output file is named `genotypes_output` and the number of populations you would like is 3, 
you can run the algorithm as follows:

```console
user@host [~] python structure.py -K 3 --input=genotypes --output=genotypes_output
```

This generates a `genotypes_output.3.log` file that tracks how the algorithm proceeds, and files
`genotypes_output.3.meanQ` and `genotypes_output.3.meanP` containing the posterior mean of
admixture proportions and allele frequencies, respectively. The orders of samples and
SNPs in the output files
match those in the `.fam` file and `.bim` file, respectively. Note that input file names should
not include suffixes (e.g., .bed) and are relative to the main project directory (unless a full
path is provided).

### Input data format

The current implementation can import data from [plink bed](http://pngu.mgh.harvard.edu/~purcell/plink/data.shtml#bed)
format and the original Structure format. If the data are in plink format, ensure that
bed, bim and fam files for the dataset are all present in the same path.

While the original Structure program allowed for a more flexible input format, fastStructure expects a more
specific Structure-like input format. Specifically, rows in the data file correspond to samples, with two rows per sample
(note that only diploids are handled by this software), and columns correspond to SNPs. The first 6 columns
of the file will be ignored; these typically would include IDs, metadata, etc. This software only
handles bi-allelic loci. The two alleles at each locus can be encoded as desired; however, missing data
should be encoded as -9.

## Tests

A test simulated dataset is provided in `tests/data/testdata.bed` with genotypes sampled for
200 individuals at 500 SNP loci. The output files in `test/` were generated using the `run_tests.sh` script in the `tests` folder.

To rerun the tests, follow the below instructions:

```console
user@host [~] cd fastStructure/tests/
user@host [~] chmod +x run_tests.sh
user@host [~] ./ run_tests.sh
```

Executing the code with the provided test data should generate a log file identical to the ones in `tests/`, 
as a final check that the source code has been downloaded and compiled correctly. The algorithm scales
linearly with number of samples, number of loci and value of K; the expected runtime for a new dataset can be
computed from the runtime in the above log file.

## Choosing model complexity

In order to choose the appropriate number of model components that explain structure in the dataset,
we recommend running the algorithm for multiple choices of K. We have provided a utility tool to parse
through the output of these runs and provide a reasonable range of values for the model complexity
appropriate for this dataset.

Assuming the algorithm was run on the test dataset for choices of K ranging from 1 to 10, and
the output flag was --output=test/testoutput_simple, you can obtain the model complexity
by doing the following:

```console
user@host [~] python chooseK.py --input=test/testoutput_simple
Model complexity that maximizes marginal likelihood = 2
Model components used to explain structure in data = 4
```

## Visualizing admixture proportions

In order to visualize the expected admixture proportions inferred by fastStructure, we have
provided a simple tool to generate [Distruct](https://web.stanford.edu/group/rosenberglab/distruct.html)
plots using the mean of the variational
posterior distribution over admixture proportions. The samples in the plot will be grouped
according to population labels inferred by fastStructure. However, if the user would like to
group the samples according to some other categorical label (e.g., geographic location), these labels
can be provided as a separate file using the flag --popfile. The order of labels in this file (one label per row)
should match the order of samples in the input data files.

```console
user@host [~] python distruct.py

Here is how you can use this script

Usage: python distruct.py
        -K <int>  (number of populations)
        --input=<file>  (/path/to/input/file; same as output flag passed to structure.py)
        --output=<file>   (/path/to/output/file)
        --popfile=<file>  (file with known categorical labels; optional)
        --title=<figure title>  (a title for the figure; optional)
```

Assuming the algorithm was run on the test dataset for `K=5`, and
the output flag was `--output=test/testoutput_simple`, you can generate a Distruct plot
by doing the following:

```console
user@host [~] python distruct.py -K 5 --input=test/testoutput_simple --output=test/testoutput_simple_distruct.svg
```

## Citation

Anil Raj, Matthew Stephens, and Jonathan K. Pritchard. *fastSTRUCTURE: Variational Inference of 
Population Structure in Large SNP Data Sets*, (Genetics) June 2014 197:573-589
[[Genetics](www.genetics.org/content/197/2/573.full),
[Biorxiv](biorxiv.org/content/early/2013/12/02/001073)]