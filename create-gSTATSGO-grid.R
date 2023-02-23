
## TODO:
# * think about the most efficient grid cell size, likely 300m

library(terra)

.path <- 'e:/gis_data/mukey-grids'

# gNATSGO 450m mukey grid, used as template
x <- rast(file.path(.path, 'gNATSGO-mukey-ML-450m.tif'))

# latest STATSGO
s <- vect('e:/gis_data/STATSGO2/wss_gsmsoil_US_[2016-10-13]/spatial/gsmsoilmu_a_us.shp')

# transform to same CRS as gNATSGO
# AK, HI, PR not happy...
# we are only keeping CONUS anyway
s <- project(s, crs(x))

# store mukey as integer
options(scipen = 10000)
s$mukey.numeric <- as.numeric(s$MUKEY)

# rasterize to 450m grid
# ~ 20 seconds
system.time(
  g <- rasterize(
    s, x, 
    field = 'mukey.numeric'
  )
)


# save as UInt32
# NODATA encoded as 4294967295
# will build overviews later
writeRaster(
  g, filename = file.path(.path, 'gSTATSGO-mukey.tif'), 
  overwrite = TRUE,
  datatype = 'INT4U'
)






## check: ok
# should be UInt32
# NODATA 4294967295
i <- sf::gdal_utils(util = 'info', source = file.path(.path, 'gSTATSGO-mukey.tif'))


# sf::gdal_utils(util = 'info', source = 'e:/gis_data/mukey-grids/gNATSGO-mukey.tif')


