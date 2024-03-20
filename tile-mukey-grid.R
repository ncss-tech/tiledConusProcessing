library(terra)
library(sf)
library(progress)

source('E:/working_copies/tiledConusProcessing/local-functions.R')

# CONUS gNATSGO 30m grid
# UInt32
mu <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# load optimized grid, with all-NA tiles removed
tg <- readRDS(file = 'E:/working_copies/tiledConusProcessing/A_grid.rds')

# tiles go here
output.dir <- 'temporary-mukey-tiles'

# tile names match tile ID
# gNATSGO: 7 minutes
tileMukeyGrid(mu = mu, tg = tg, output.dir = output.dir)


## cleanup
rm(list = ls())
gc(reset = TRUE)

