
## hmmm this isn't working
## * 0 should be NODATA
## * delete companion .xml file, if created
## * 

## consider gridding at a more appropriate cell size

library(terra)

# gNATSGO 30m mukey grid, used as template
x <- rast('e:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# latest STATSGO
s <- vect('e:/gis_data/STATSGO2/wss_gsmsoil_US_[2016-10-13]/spatial/gsmsoilmu_a_us.shp')

# transform to same CRS as gNATSGO
# AK, HI, PR not happy...
# we are only keeping CONUS anyway
s <- project(s, crs(x))

# store mukey as integer
options(scipen = 10000)
s$mukey.numeric <- as.numeric(s$MUKEY)

# rasterize to 30m grid
# save as UInt32
# will build overviews later
# ~ 20 minutes
system.time(
  g <- rasterize(
    s, x, 
    field = 'mukey.numeric', 
    filename = 'e:/gis_data/mukey-grids/gSTATSGO-mukey.tif', 
    overwrite = TRUE, 
    wopt = list(datatype = 'INT4U')
  )
)


## check
# should be UInt32
i <- sf::gdal_utils(util = 'info', source = 'e:/gis_data/mukey-grids/gSTATSGO-mukey.tif')
cat(i, file = 'junk.txt')


# sf::gdal_utils(util = 'info', source = 'e:/gis_data/mukey-grids/gNATSGO-mukey.tif')

z <- rast('e:/gis_data/mukey-grids/gSTATSGO-mukey.tif')

# takes a while
z[z == 0] <- NA

plot(z)

