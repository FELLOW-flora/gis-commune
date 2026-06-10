# gis-commune : Research compendium for extracting landscape variables per commune in France 

Code and data used to extracting landscape variables in France 


## General

This repository is structured as follow:

- :file_folder: &nbsp;`analysis/`: contains R scripts to download and extract gis data;
- :file_folder: &nbsp;`data/`: contains raw and derived data;

## Usage

The analysis is divided in two sequential steps:  

1. Get the raw data (commune boundaries, climate and soil data)
2. Get the indicators per commune 

These two steps will be run automatically when run this command in R/RStudio: 

```r
source("make.R")
```

The file `make.R` can be run to recompute all indicators. 

