
## TODO: careful with NA handling
## TODO: catch failed SDA requests in a second pass
## -----> why does this happen?


library(purrr)
library(furrr)
library(terra)
library(sf)
library(soilDB)

source('local-functions.R')
source('config.R')

# mukey grid
mu <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# load optimized grid, with all-NA tiles removed
g <- readRDS(file = 'A_grid.rds')

# tiles go here
output.dir <- 'processed-tiles'

# start fresh
unlink(output.dir, recursive = TRUE)
dir.create(output.dir)

# pre-tiled mukey grids
# must exclude any other accessory files in this dir: e.g. .tif.aux.xml
g.files <- list.files(path = 'temporary-mukey-tiles', pattern = '\\.tif$', full.names = TRUE)

## iterate over tiles
.tileIndex <- seq_along(g.files)

# works as expected
# map(.x = 227, .f = makeThematicTileSDA, tiles = g.files, vars = v, top = 0, bottom = 25, output.dir = output.dir)
# map(.x = 9, .f = makeThematicTileSDA, tiles = g.files, vars = v, top = 0, bottom = 25, output.dir = output.dir)

# component-level data: top/bottom arguments are ignored
# map(.x = 9, .f = makeThematicTileSDA, tiles = g.files, vars = 'wei', top = 0, bottom = 25, output.dir = output.dir)


# init multiple cores
plan(multisession)

system.time(
  z <- future_map(
    .tileIndex, 
    .f = makeThematicTileSDA, 
    tiles = g.files, 
    vars = v, 
    top = depth.interval[1], 
    bottom = depth.interval[2], 
    output.dir = output.dir,
    .progress = TRUE
  )
)

# stop parallel back-ends
plan(sequential)

## check for errors or failed SDA requests 
idx <- which(!sapply(z, is.null))
zz <- z[idx]


if (length(zz) > 0) {
  
  ## TODO: check on these
  sapply(zz, function(i) {
    nrow(i$rat)
  })
  
  .secondPass <- sapply(zz, function(i) {
    i$i
  })
  
  plan(multisession)
  
  system.time(
    z <- future_map(
      .secondPass,
      .f = makeThematicTileSDA,
      tiles = g.files,
      vars = v,
      top = depth.interval[1],
      bottom = depth.interval[2],
      output.dir = output.dir,
      .progress = TRUE
    )
  )
  
  plan(sequential)
  
  
  ## TODO: find a more elegant solution
  
  ## check for errors or failed SDA requests 
  idx <- which(!sapply(z, is.null))
  zz <- z[idx]
  
  sapply(zz, function(i) {
    nrow(i$rat)
  })
  
  
  .thirdPass <- sapply(zz, function(i) {
    i$i
  })
  
}




## final check

n.expected <- length(v) * length(g.files)
n.output <- length(list.files(output.dir))

stopifnot(n.expected == n.output)


## cleanup
rm(list = ls())
gc(reset = TRUE)

