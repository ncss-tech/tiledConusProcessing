## Use an externally-created mukey--value LUT for the creation of thematic soil property grids
## 2025-04-25
## D.E. Beaudette

library(terra)

# gNATSGO mukey--property LUT from Chad
x <- read.csv('e:/gis_data/mukey-grids/a_allstates_svi.csv')
head(x)

# function applied at each pixel
# lookup column value for each mukey
.f <- function(i, v) {
  
  .idx <- match(i, x$mukey)
  .res <- x[[v]][.idx]
  
  return(.res)
}

## test: ok
# .f(122685, 'sandvf_r')
# .f(122685, 'gypsum_r')


## checking grid topology
# 
# # w,s,e,n
# 
# # source
# Extent	-2356125,276435 : 2263755,3172575
# Dimensions	X: 153996 Y: 96538 Bands: 1
# Origin	-2356125,3172575
# Pixel Size	30,-30
# 
# 
# # terra::aggregate()
# Extent	-2356125,276375 : 2264475,3172575
# Dimensions	X: 5134 Y: 3218 Bands: 1
# Origin	-2356125,3172575
# Pixel Size	900,-900
# 
# 
# # GRASS, g.region res=900 w=-2356125 s=276375 e=2264475 n=3172575
# Extent	-2356125,276375 : 2264475,3172575
# Dimensions	X: 5134 Y: 3218 Bands: 1
# Origin	-2356125,3172575
# 
# 
# 
# # GRASS, import of 30m gNATSGO
# north:      3172575
# south:      276435
# west:       -2356125
# east:       2263755
# nsres:      30
# ewres:      30
# 
# 
# ## does not match terra::aggregate(), grids do not nest
# # GRASS, g.region -a res=900
# north:      3173400
# south:      276300
# west:       -2356200
# east:       2264400
# nsres:      900
# ewres:      900
# 
# 
# ## matches terra::aggregate(), grids nest
# # GRASS, g.region res=900 w=-2356125 s=276375 e=2264475 n=3172575
# north:      3172575
# south:      276375
# west:       -2356125
# east:       2264475
# nsres:      900
# ewres:      900
# 
# 






# FY25 CONUS gNATSGO 30m grid
# md5sum
# dylan: 932606178562f712231ce5b82cd8fbc0
# chad:  932606178562f712231ce5b82cd8fbc0
g <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# GFE: 11.3 minutes
system.time(
  r <- app(g, fun = .f, v = 'sandvf_r', filename = 'sandvfs_r_surface.tif', overwrite = TRUE)
)

system.time(
  r <- app(g, fun = .f, v = 'gypsum_r', filename = 'gypsum_r_surface.tif', overwrite = TRUE)
)

# check: strange NODATA value
# read fine by QGIS
sf::gdal_utils('info', 'sandvfs_r_surface.tif')


rm(r)
gc(reset = TRUE)


## aggregation to 900m
# GFE: 2.8 minutes

r <- rast('sandvfs_r_surface.tif')

system.time(
  a <- aggregate(r, fact = 30, fun = 'mean', na.rm = TRUE, filename = 'sandvfs_r_surface.tif-900m.tif', overwrite = TRUE)
)


rm(r, a)
gc(reset = TRUE)

r <- rast('gypsum_r_surface.tif')

system.time(
  a <- aggregate(r, fact = 30, fun = 'mean', na.rm = TRUE, filename = 'gypsum_r_surface.tif-900m.tif', overwrite = TRUE)
)

