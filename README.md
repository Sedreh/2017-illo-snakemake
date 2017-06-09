# 2017 Snakemake ILLO

- June 10th, 2017
- Video: **TO BE ADDED**

- (Previously: doit ILLO https://www.youtube.com/watch?v=TMxUmuKtqNI)

## Installation

We'll use conda to manage our installation today.

```
curl -O https://repo.continuum.io/miniconda/Miniconda3-4.3.21-Linux-x86_64.sh
# curl -O https://repo.continuum.io/miniconda/Miniconda3-4.2.11-MacOSX-x86_64.sh
bash Miniconda3-4.3.21-Linux-x86_64.sh
export PATH="${HOME}/miniconda/bin:$PATH"
conda create -n illo python=3.6.1
source activate illo

conda config --add channels conda-forge
conda config --add channels defaults
conda config --add channels r
conda config --add channels bioconda

conda install khmer snakemake bwa samtools bcftools trimmomatic
```
