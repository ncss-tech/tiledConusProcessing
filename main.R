library(terra)
library(sf)
library(progress)

source('local-functions.R')

# CONUS gNATSGO 30m grid
# UInt32
mu <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# load optimized grid, with all-NA tiles removed
tg <- readRDS(file = 'A_grid.rds')

# tiles go here
output.dir <- 'temporary-mukey-tiles'

# tile names match tile ID
tileMukeyGrid(mu = mu, tg = tg, output.dir = output.dir)


