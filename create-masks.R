library(terra)
library(sf)

# use CONUS MLRA boundaries for reasonable outline
mlra <- st_read('e:/gis_data/MLRA/MLRA_52-conus.shp')

# use ISSR800 grid system for mask
# 800m EPSG:5070
issr800 <- rast('e:/gis_data/FY2023-800m-rasters/rasters/cec.tif')

# GCS -> PCS
x <- st_transform(mlra, crs = 5070)

# retain outer-most polygon
x <- st_union(x, by_feature = FALSE)

# convert sf -> spatVect
x <- vect(x)

# check: ok
plot(x)

# new field in attribute table for rasterization
x$constant <- 1

# rasterize CONUS polygon according to ISSR800 grid system
r <- rasterize(x, issr800, field = 'constant')

# check: ok
plot(r)
lines(x)

# save
# unsigned, 8-bit integer (BYTE)
writeRaster(r, filename = 'masks/CONUS-MLRA52-mask.tif', overwrite = TRUE, datatype = 'INT1U')

# check: ok
sf::gdal_utils('info', source = 'masks/CONUS-MLRA52-mask.tif')
