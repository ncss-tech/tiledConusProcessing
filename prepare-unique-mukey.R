##
##
##

library(purrr)
library(furrr)
library(terra)
library(soilDB)
library(data.table)

source('local-functions.R')
source('config.R')

# mukey grid system
mu <- rast(grid.system)

# pre-tiled mukey grids
# must exclude any other accessory files in this dir: e.g. .tif.aux.xml
g.files <- list.files(path = 'temporary-mukey-tiles', pattern = '\\.tif$', full.names = TRUE)

## iterate over tiles
.tileIndex <- seq_along(g.files)


# # test
# x <- map(1:10, .f = getUniqueValues, files = g.files, .progress = TRUE)
# x <- rbindlist(x)
# # ok
# str(x)

## init multiple cores
# plan(multicore) # linux
plan(multisession) # windows

# GFE fSSURGO 30m: 2.7 minutes
system.time(
  x <- future_map(.tileIndex, .f = getUniqueValues, files = g.files, .progress = TRUE)  
)

# stop parallel back-ends
plan(sequential)

## flatten
x <- rbindlist(x)

## get unique values
x <- unique(x)

# FY26 fSSURGO: 322752
nrow(x)

## save for later
x <- as.data.frame(x)
saveRDS(x, file = 'unique-mukey.rds')


## cleanup
rm(list = ls())
gc(reset = TRUE)





