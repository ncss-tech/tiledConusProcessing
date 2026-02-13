##
## Draft workflow for creating thematic maps from CONUS gNATSGO mukey grid + SDA
##

## TODO:
# * use fSSURGO instead of gSTATSGO
# * profile CPU, RAM, disk, network resources
# * finish categorical variable handling
# * better selection of aggregation type
# * add depth interval to file name



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

# 2024-03-26:
#
# gNATSGO 30m:
#  * 68 seconds / tile (6 hz level properties)
#  * 1 hour for 6 hz level properties (SDA / slow internet)

# STATSGO 300m:
# * 74 seconds for 6 hz level properties (SDA / slow internet)
# * 

# gSSURGO 30m (SoilWeb 4-1)
#  * 43 minutes for 6 hz level properties (SDA)
#

# 2025-12-17
#
#


## create tile systems
## these are already in place
# source('tiling-grid-A.R')

## tile CONUS mukey grid
# only need to do this once per FY snapshot
# synced with other operations via config.R
#
# gSSURGO/gNATSGO 30m : ~ 10 minutes
# STATSGO 300m : ~ 2 minutes
system.time(
  source('tile-mukey-grid.R')
)


## collect unique map unit keys
# only need to do this once per FY / source grid
#
# GFE fSSURGO 30m: 2.7 minutes
source('prepare-unique-mukey.R')


## prepare LUT for unique mukey and all variables
# do this each time config.R changes
#
# GFE fSSURGO 30m: 95 seconds (parallel) | 17 minutes (serial)
source('prepare-LUT.R')




## process tiles, create thematic grid tiles
# variables stored in config.R
# 
# 2026-02-13
# terra terra_1.8-97
# GFE fSSURGO 30m: 13 minutes !!!  (6 properties)
system.time(
  source('process-tiles.R')
)

## mosaic / re-sample tiles

# 2025-12-19
# fSSURGO 30m:        21 minutes (6 properties)

# 2026-02-13
# fSSURGO 30m:        19.5 minutes (6 properties)



# gSSURGO 30m:        10 minutes (1 property)
# gNATSGO 30m:        36 minutes (6 properties)
# STATSGO 300m:       32 seconds (6 properties)
#
# gSSURGO (SoilWeb):  10 minutes (6 properties)
#
# variables stored in config.R
system.time(
  source('mosaic-tiles.R')
)






