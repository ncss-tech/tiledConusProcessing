


## query / aggregate each chunk
#' @param i integer vector of mukey
#' @param vars character vector of variable names
#' @param top top depth (cm)
#' @param bottom bottom depth (cm)
getDataByChunk <- function(i, vars, top, bottom) {
  
  p <-  try(
    suppressMessages(
      get_SDA_property(
        property = vars,
        method = "Weighted Average", 
        mukeys = as.integer(i),
        top_depth = top,
        bottom_depth = bottom,
        include_minors = TRUE, 
        miscellaneous_areas = FALSE,
        dsn = local.tabularDB
      )
    ), silent = TRUE
  )
  
  if (inherits(p, 'try-error')) {
    message('SDA query failed')
  }
  
  # TODO: any other error conditions?
  
  return(p)
}



getUniqueValues <- function(i, files) {
  r <- rast(files[i])
  v <- unique(values(r, mat = FALSE, dataframe = FALSE, na.rm = TRUE))
  v <- data.table(mukey = v)
  return(v)
}


## TODO: sync aggregation functions with output data type

mosaicProperty <- function(i, input.dir, output.dir, do.aggregate = TRUE, agg.fact = 9, agg.fun = c('modal', 'mean')) {
  
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
  if(do.aggregate) {
    aggregate(x, fact = agg.fact, fun = agg.fun, na.rm = TRUE, filename = f, overwrite = TRUE)
  }
  
  rm(x)
  gc(reset = TRUE)
  
  return(NULL)
}




## TODO: what do 0's in the grid represent?

makeThematicTile <- function(i, tiles, vars, output.dir) {
  
  # current tile
  x <- rast(tiles[i])
  
  # init grid of IDs + RAT
  x <- as.factor(x)
  
  # set layer name in object
  names(x) <- 'mukey'
  
  # extract RAT for thematic mapping
  # will be NULL if all cells are NA
  rat <- cats(x)[[1]]
  
  # check for an entirely NULL tile  (STATSGO 300m, tile 90)
  if(is.null(rat)) {
    # write blank tiles
    for (.var in vars) {
      # automatic use of LZW compression
      writeRaster(x, filename = file.path(output.dir, sprintf('%s_%03d.tif', .var, i)), overwrite = TRUE)
    }
    
    # next tile
    return(NULL)
  }
  
  # re-name mukey column for consistency across input grids
  names(rat)[2] <- 'mukey'
  
  # subset LUT to current set of mukey
  # ensure LUT only contains columns of interest
  p <- lut[which(lut$mukey %in% rat$mukey), c('mukey', vars)]
  
  # merge aggregate data into RAT
  rat <- merge(rat, p, by.x = 'mukey', by.y = 'mukey', sort = FALSE, all.x = TRUE)
  
  # re-pack RAT
  # `ID` must be the first column in the RAT
  levels(x) <- rat[, c('ID', 'mukey', vars)]
  
  # ~ 20 minutes per tile, when using 10x10 tiles
  # ~ 2 minutes per tile, when using 20x20 tiles
  
  # grid + RAT -> stack of numerical grids
  # 35 seconds
  # system.time(x.stack <- catalyze(x))
  
  # 4.8 seconds / variable
  # system.time(x.stack <- as.numeric(x, index = vars[1]))
  
  # 2025-12-20: as.numeric() is the slowest part of this function - why?
  #
  # as.numeric(): 9.24 seconds / variable
  # catalyze():   9.4 seconds / variable
  
  # continuous properties
  for (.var in vars) {
    # automatic use of LZW compression
    .x <- as.numeric(x, index = .var)
    writeRaster(.x, filename = file.path(output.dir, sprintf('%s_%03d.tif', .var, i)), overwrite = TRUE)
  }
  
  ## TODO: categorical properties
  
  ## consider removing terra objects and garbage-collecting
  rm(x, .x)
  gc(reset = TRUE)
 
  # TODO: trap and return errors?
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
    
    ## TODO: consider converting into a factor here
    
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

