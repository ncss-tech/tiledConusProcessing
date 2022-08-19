
## TODO: careful with NA handling

library(purrr)
library(furrr)
library(terra)
library(sf)
library(soilDB)

source('local-functions.R')

# mukey grid
mu <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# load optimized grid, with all-NA tiles removed
g <- readRDS(file = 'A_grid.rds')

# tiles go here
output.dir <- 'processed-tiles'

# start fresh
unlink(output.dir, recursive = TRUE)
dir.create(output.dir)

## chorizon variables

## TODO: asking for 'wtenthbar_r' results in mostly NA
# https://github.com/ncss-tech/soilDB/issues/261

# v <- c("sandtotal_r", "silttotal_r", "claytotal_r", "om_r", "cec7_r", "ph1to1h2o_r", "wthirdbar_r", "wtenthbar_r", "wfifteenbar_r")
v <- c("sandtotal_r", "claytotal_r", "ph1to1h2o_r", "wthirdbar_r", "wfifteenbar_r")

# pre-tiled mukey grids
g.files <- list.files(path = 'temporary-mukey-tiles', pattern = '\\.tif', full.names = TRUE)

## iterate over tiles
.tileIndex <- seq_along(g.files)

# works as expected
# map(.x = 10, .f = makeThematicTileSDA, tiles = g.files, vars = v, top = 0, bottom = 25, output.dir = output.dir)

# init multiple cores
plan(multisession)

system.time(
  z <- future_map(
    .tileIndex[1:20], 
    .f = makeThematicTileSDA, 
    tiles = g.files, 
    vars = v, 
    top = 0, 
    bottom = 25, 
    output.dir = output.dir,
    .progress = TRUE
  )
)

# stop parallel back-ends
plan(sequential)

## cleanup
rm(list = ls())
gc(reset = TRUE)

