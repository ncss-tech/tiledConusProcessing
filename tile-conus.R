library(terra)
library(sf)
library(soilDB)
library(progress)

## WCS demo (raster-based, needs an update)
# http://ncss-tech.github.io/AQP/soilDB/WCS-demonstration-01.html

## get the latest gNATSGO / gSSURGO grids here:
## these are CONUS (AEA) grids at 30m
# https://nrcs.app.box.com/v/soils/folder/149859400396

## TODO: make sure this works with latest terra

## TODO: does aggregation probably needs to happen after tile-based processing?
##       ---> seems to work fine (no aliasing)

## TODO: consider 2-passes: SDA aggregation, then raster creation / aggregation

## TODO: do we need to ensure each tile has an integer extent and resolution?

## ~ 3 minutes / tile / property -> 14.6 hours for the entire grid
## --> probably faster with a local DB, or if aggregation to mukey is done first
## --> parallelization over suites of properties


# mukey grid
mu <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# load optimized grid, with all-NA tiles removed
g <- readRDS(file = 'A_grid.rds')

# tiles go here
output.dir <- 'results'

# start fresh
unlink(output.dir, recursive = TRUE)
dir.create(output.dir)

# chorizon variables
vars <- c("sandtotal_r", "silttotal_r", "claytotal_r", "om_r", "cec7_r", "ph1to1h2o_r")


# keep track of errors
error.log <- list()

# process tiles
n <- nrow(g)
pb <- progress_bar$new(format = '[:bar] :percent (:eta)', total = n)
for(i in 1:n) {
  
  # current tile
  x <- crop(mu, g[i, ])
  
  ## TODO: double-check this for efficiency
  # ratify
  uids <- terra::unique(x)[,1]
  rat <- data.frame(value = uids, mukey = uids)
  x <- terra::categories(x, layer = 1, rat)
  
  # set layer name in object
  names(x) <- 'mukey'
  
  # extract RAT for thematic mapping
  rat <- cats(x)[[1]]
  
  ## note: mukey values like 600000 are silently converted to 6e+05
  # ---> use as.integer(mukey)
  
  
  # weighted mean over components to account for large misc. areas
  # depth-weighted average 0-25cm
  p <-  try(
    get_SDA_property(
      property = vars,
      method = "Weighted Average", 
      mukeys = as.integer(rat$mukey),
      top_depth = 0,
      bottom_depth = 25,
      include_minors = TRUE, 
      miscellaneous_areas = FALSE
    ), silent = TRUE
  )
  
  if(inherits(p, 'try-error')) {
    message('SDA query failed, not sure why')
    
    # save tile ID + associated RAT
    error.log[[as.character(i)]] <- list(
      i = i,
      rat = rat
    )
    next
  }
  
  # just in case there were no valid mukeys
  if(is.null(p)) {
    pb$tick()
    next
  }
  
  # merge aggregate data into RAT
  rat <- merge(rat, p, by.x = 'mukey', by.y = 'mukey', sort = FALSE, all.x = TRUE)
  levels(x) <- rat
  
  # ~ 20 minutes per tile, when using 10x10 tiles
  # ~ 2 minutes per tile, when using 20x20 tiles
  
  ## WTF: this occasionally happens 
  # Error in x@ptr$classify(as.vector(rcl), NCOL(rcl), right, include.lowest,  : 
  # std::bad_alloc
  
  ## .. could be memory leak or something related to overwritting previouslu created objects (pointers)
  
  # grid + RAT -> stack of numerical grids
  x.stack <- catalyze(x)
  
  # keep only properties / remove IDs
  x.stack.sub <- x.stack[[vars]]
  
  ## TODO: check for aliasing effects
  
  # aggregate to ~ 300m
  # terra progress bar interferes with for-loop bar
  a <- aggregate(x.stack.sub, fact = 10, fun = 'mean', na.rm = TRUE)

  # continuous properties
  for(v in vars) {
    # automatic use of LZW compression
    writeRaster(a[[v]], filename = file.path(output.dir, sprintf('%s_%s.tif', v, i)), overwrite = TRUE)
  }
  
  ## consider removing terra objects and garbage-collecting
  rm(x, x.stack, x.stack.sub, a)
  gc(reset = TRUE)
  
  pb$tick()
}

pb$terminate()

length(error.log)

sapply(error.log, '[', 'i')

# save error log
saveRDS(error.log, file = 'errors.rds')




