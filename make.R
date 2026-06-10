## Get landscape variable per commune

## Make sure needed packages are installed ---------
# make sure all needed packages are installed
if (!requireNamespace("here", quietly = TRUE)) {
  # to avoid issues of relative file path
  install.packages("here")
}
if (!requireNamespace("sf", quietly = TRUE)) {
  # to handle spatial files
  install.packages("sf")
}
if (!requireNamespace("terra", quietly = TRUE)) {
  # to handle spatial rasters
  install.packages("terra")
}
if (!requireNamespace("exactextract", quietly = TRUE)) {
  # to efficiently extract values per polygons
  install.packages("exactextract")
}

if (!requireNamespace("happign", quietly = TRUE)) {
  # to download ign datasets
  install.packages("happign")
}


## Run Project --------------------------------------------

# 2 steps:

# 1. Get the raw data
source(here::here("analysis", "01_get_data.R"))

# 2. Get landscape variables per commune
source(here::here("analysis", "02_extract_commune.R"))
