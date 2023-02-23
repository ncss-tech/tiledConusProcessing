## TODO
# * think about other resolutions that make sense here


library(terra)

.path <- 'e:/gis_data/mukey-grids'

x <- rast(file.path(.path, 'gNATSGO-mukey.tif'))

# ~ 15 minutes
system.time(
  a <- aggregate(
    x, 
    fact = 15, 
    fun = 'modal', 
    filename = file.path(.path, 'gNATSGO-mukey-ML-450m.tif'), 
    overwrite = TRUE
  )
)


