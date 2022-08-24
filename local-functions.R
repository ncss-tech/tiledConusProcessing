mosaicProperty <- function(i, input.dir, output.dir) {
  
  # current tile set
  fl <- list.files(path = input.dir, pattern = i, full.names = TRUE)
  
  # assemble pieces
  x <- vrt(fl)
  
  # output file name
  f <- file.path(output.dir, sprintf("%s-lowres.tif", i))
  f.highres <- file.path(output.dir, sprintf("%s.tif", i))
  
  # convert VRT -> single raster
  writeRaster(x, filename = f.highres, overwrite = TRUE)
  
  # optionally aggregate directly to file
  aggregate(x, fact = 9, fun = 'modal', na.rm = TRUE, filename = f, overwrite = TRUE)
  
  rm(x)
  gc(reset = TRUE)
  
  return(NULL)
}




## TODO: optionally wrap in safely() for simpler error reporting

makeThematicTileSDA <- function(i, tiles, vars, top, bottom, output.dir) {
  # current tile
  x <- rast(tiles[i])
  
  # init RAT
  # cannot contain NA or NaN
  uids <- terra::unique(x)[, 1]
  rat <- data.frame(value = uids, mukey = uids)
  rat <- na.omit(rat)
  levels(x)[[1]] <- rat
  
  # set layer name in object
  names(x) <- 'mukey'
  
  # extract RAT for thematic mapping
  rat <- cats(x)[[1]]
  
  # weighted mean over components to account for large misc. areas
  # depth-weighted average 0-25cm
  p <-  try(
    get_SDA_property(
      property = vars,
      method = "Weighted Average", 
      mukeys = as.integer(rat$mukey),
      top_depth = top,
      bottom_depth = bottom,
      include_minors = TRUE, 
      miscellaneous_areas = FALSE
    ), silent = TRUE
  )
  
  if (inherits(p, 'try-error')) {
    message('SDA query failed, likely hit resource constraint')
    
    # save tile ID + associated RAT
    error.log <- list(i = i, rat = rat)
    return(error.log)
  } else {
    error.log <- NULL
  }
  
  # just in case there were no valid mukeys
  if (is.null(p)) {
    return(NULL)
  }
  
  # ensure RAT only contains columns of interest
  p <- p[, c('mukey', vars)]
  
  # merge aggregate data into RAT
  rat <- merge(rat, p, by.x = 'mukey', by.y = 'mukey', sort = FALSE, all.x = TRUE)
  levels(x) <- rat
  
  # ~ 20 minutes per tile, when using 10x10 tiles
  # ~ 2 minutes per tile, when using 20x20 tiles
  
  ## TODO: possibly faster
  # iteratively:
  # as.numeric(x, index = match(.var, vars))
  
  # grid + RAT -> stack of numerical grids
  x.stack <- catalyze(x)
  
  ## TODO: consider aggregation at this step
  
  # continuous properties
  for (.var in vars) {
    # automatic use of LZW compression
    writeRaster(x.stack[[.var]], filename = file.path(output.dir, sprintf('%s_%03d.tif', .var, i)), overwrite = TRUE)
  }
  
  ## consider removing terra objects and garbage-collecting
  rm(x, x.stack)
  gc(reset = TRUE)
 
  # when SDA throws an error, tile ID + rat
  # otherwise NULL
  return(error.log)
   
}





#' @title Create temporary tiles of a mukey grid
#'
#' @param mu map unit key grid, `SpatRaster`
#' @param tg tile system, `sf` polygons
#' @param output.dir output directory path
#'
tileMukeyGrid <- function(mu, tg, output.dir) {
  
  # start fresh
  unlink(output.dir, recursive = TRUE)
  dir.create(output.dir)
  
  # iterate over vector tiles
  n <- nrow(tg)
  pb <- progress_bar$new(format = '[:bar] :percent (:eta)', total = n)
  
  # save -> mukey grid tiles
  for (i in 1:n) {
    # crop to current tile
    x <- crop(mu, tg[i, ])
    
    # save tile as UInt32
    fn <- file.path(output.dir, sprintf('tile-%03d.tif', i))
    writeRaster(x, filename = fn, overwrite = TRUE, datatype = 'INT4U')
    
    # double-check output is correct
    # gdal_utils(util = 'info', source = fn)
    
    # remove temporary terra objects and garbage-collecting
    rm(x)
    gc(reset = TRUE)
    
    pb$tick()
  }
  
  
  pb$terminate()
  
}
