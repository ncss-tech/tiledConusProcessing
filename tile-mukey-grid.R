library(terra)
library(sf)
library(progress)

source('config.R')
source('E:/working_copies/tiledConusProcessing/local-functions.R')

## grid system
# CONUS gNATSGO 30m grid
# UInt32
mu <- rast(grid.system)

# load optimized grid, with all-NA tiles removed
tg <- readRDS(file = 'E:/working_copies/tiledConusProcessing/A_grid.rds')

# tiles go here
output.dir <- 'temporary-mukey-tiles'

# tile names match tile ID
# gNATSGO: 7 minutes
# STATSGO: 2 minutes
tileMukeyGrid(mu = mu, tg = tg, output.dir = output.dir)


## cleanup
rm(list = ls())
gc(reset = TRUE)

