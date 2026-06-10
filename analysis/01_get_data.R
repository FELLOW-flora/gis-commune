## Script to get spatial data in France, including:
# French municipalities from https://cartes.gouv.fr/rechercher-une-donnee/dataset/IGNF_ADMIN-EXPRESS
# CHELSA Climate data from ttps://www.chelsa-climate.org/
# SoilGrids data from www.isric.org/explore/soilgrids

# 0. Set-up: libraries and working directory --------------------

library(happign)
library(sf)
library(terra)

# set directory where data is saved
datadir <- here::here("data", "raw-data")
if (!dir.exists(datadir)) {
  dir.create(
    path = datadir,
    showWarnings = FALSE,
    recursive = TRUE
  )
}

# Set French boundaries
fr_box <- sf::st_bbox(
  c(xmin = -5, xmax = 10, ymax = 55, ymin = 40),
  crs = 4326
) |>
  sf::st_as_sfc() |>
  sf::st_as_sf()

# 1. IGN data and ADMINEXPRESS (470Mb) --------------------

# check out all available information in ign servers
# meta_vect <- get_layers_metadata("wfs") # all layers for altimetrie wms
# look_up <- "ADMINEXPRESS"
#fmt: skip
# found <- grepl(tolower(look_up), tolower(meta_vect$Name)) | grepl(tolower(look_up), tolower(meta_vect$Name))
# meta_vect$Name[found]

# Download commune from 2025
adm_2025 <- get_wfs(fr_box, layer = "ADMINEXPRESS-COG.2025:commune")

# export as geopackage
st_write(
  adm_2025,
  file.path(datadir, "ADMINEXPRESS_COG_2025_commune.gpkg")
)


# 2. Chelsa climate data (23Mb) ------------------------
# https://www.chelsa-climate.org/datasets/chelsa_bioclim
# you can click and download individual files
# e.g. "https://os.unil.cloud.switch.ch/chelsa02/chelsa/global/bioclim/bio01/1981-2010/CHELSA_bio01_1981-2010_V.2.1.tif"
# or automate it and crop the region of interest

url_bioclim <- "https://os.unil.cloud.switch.ch/chelsa02/chelsa/global/bioclim/bioXX/1981-2010/CHELSA_bioXX_1981-2010_V.2.1.tif"
biomclim_select <- c("01", "04", "12", "15")

for (i in biomclim_select) {
  # add vsicurl to download only subset
  urli <- paste0("/vsicurl/", gsub("XX", i, url_bioclim))
  # is much faster with 'vsicurl' (no need to download all data)
  chelsa_i <- terra::rast(urli)
  # crop to the extent of intest
  crop_i <- terra::crop(chelsa_i, fr_box)
  # export
  file_i <- paste0("CHELSA_bioclim_", i, "_1981-2010_Fr.tif")
  writeRaster(crop_i, file.path(datadir, file_i))
}

# 3. Soil grid data (30Mb) --------------------------------
# same here you can click and download file online: https://soilgrids.org/
# but you can also automate it
soilgrid_select <- c("phh2o", "wv0033")
depth <- "0-5cm_mean"
sg_url <- "https://maps.isric.org/mapserv?map=/map/VV.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=VV_DD&FORMAT=image/tiff&SUBSET=long(-5,10)&SUBSET=lat(40,55)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
for (i in soilgrid_select) {
  # add vsicurl to download only subset
  urli <- gsub("VV", i, gsub("DD", depth, sg_url))

  file_i <- paste0("SOILGRID_", i, "_Fr.tif")
  download.file(urli, file.path(datadir, file_i), mode = "wb")
}
