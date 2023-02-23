## Approximate gNATSGO mukey grid with a 300m modal filter. This is not aggregation, only for rapid preview of thematic maps and testing.
## D.E Beaudette
## 2023-02-23


library(terra)

# local files
.path <- 'e:/gis_data/mukey-grids'

# current FY mukey grid, 30m res
x <- rast(file.path(.path, 'gNATSGO-mukey.tif'))

## 300m approximated gNATSGO grid
# ~ 15 minutes
system.time(
  a <- aggregate(
    x, 
    fact = 10, 
    fun = 'modal', 
    filename = file.path(.path, 'gNATSGO-mukey-ML-300m.tif'), 
    overwrite = TRUE
  )
)


