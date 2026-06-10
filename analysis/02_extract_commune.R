## Script to extract average values per commune
# rely on data downloaded in 01_get_data.R

# 0. Set-up: libraries and working directory --------------------
library(sf)
library(terra)
library(exactextractr)

data_folder <- here::here("data", "raw-data")

# set directory where output data will be saved
out_folder <- here::here("data", "derived-data")
if (!dir.exists(out_folder)) {
  dir.create(
    path = out_folder,
    showWarnings = FALSE,
    recursive = TRUE
  )
}

# 1. Load commune definition ---------------------------------
commune <- sf::st_read(file.path(
  data_folder,
  "ADMINEXPRESS_COG_2025_commune.gpkg"
))

# select the columns to keep in the output dataset
select_col <- c(
  "code_insee",
  "nom_officiel",
  "code_postal",
  "population",
  "superficie_cadastrale"
)

# get coordinates of centroids
crds <- sf::st_coordinates(sf::st_centroid(commune))
colnames(crds) <- c("Longitude", "Latitude")

# select information per commune
out <- cbind(data.frame(commune[, select_col]), crds)

# 2. Extract values per commune ------------------------------
layers <- list.files(data_folder, "tif$", full.names = TRUE)
for (i in layers) {
  ri <- terra::rast(i)
  # all raster are projected in EPSG:4326, so no need of projections here
  #mean: the mean cell value, weighted by the fraction of each cell that is covered by the polygon
  exi <- exactextractr::exact_extract(ri, commune, fun = 'mean')
  out[, names(ri)] <- exi
}

#3. Export extracted information
# remove geometry information
out <- out[, !names(out) %in% "geom"]
# save the output as csv file
write.csv(
  data.frame(out),
  file.path(out_folder, "commune_gis.csv"),
  row.names = FALSE
)
