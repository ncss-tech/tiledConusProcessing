##
## Draft workflow for creating thematic maps from CONUS gNATSGO mukey grid + SDA
##

## TODO:
# * profile CPU, RAM, disk, network resources
# * 



## Notes:
# * be sure to disable VPN and free as much RAM as possible
#
# government machine, at the office
#  * 26 minutes for a single component level property
#  * 37 minutes for 2 hz level properties
#  * 45 minutes for 3 hz level properties
#
#  * 25 minutes for mosaic/re-sample of single property
#  * 30 minutes for 3 hz level properties
#


## create tile systems
## these are already in place
# source('tiling-grid-A.R')

## tile CONUS mukey grid
## only need to do this once per FY snapshot
# ~ 10 minutes
# source('tile-mukey-grid.R')


## process tiles, create thematic grid tiles
# variables stored in config.R
source('process-tiles.R')


## mosaic / re-sample tiles
# variables stored in config.R
source('mosaic-tiles.R')






