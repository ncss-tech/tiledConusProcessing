##
## Draft workflow for creating thematic maps from CONUS gNATSGO mukey grid + SDA
##

## Notes:
# processing tiles: 
#  * 26 minutes for a single component level property
#  * XX minutes for mosaic/re-sample of single property


## create tile systems
## these are already in place
# source('tiling-grid-A.R')

## tile CONUS mukey grid
## only need to do this once
# source('tile-mukey-grid.R')


## process tiles, create thematic grid tiles
# variables stored in config.R
source('process-tiles.R')


## mosaic / re-sample tiles
# variables stored in config.R
source('mosaic-tiles.R')






