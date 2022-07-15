library(terra)
library(sf)


## continuous variables
vars <- c("sandtotal_r", "silttotal_r", "claytotal_r", "om_r", "cec7_r", "ph1to1h2o_r")


for(i in vars) {
  
  print(i)
  
  # current tile set
  p <- sprintf('%s.*\\.tif$', i)
  fl <- list.files(path = 'results', pattern = p, full.names = TRUE)
  
  # assemble pieces
  # resolution may not be exactly the same
  x <- vrt(fl)
  
  # output file name
  f <- sprintf('%s_final.tif', gsub(pattern = '_r', '', x = i, fixed = TRUE))
  
  # convert VRT -> single raster
  writeRaster(x, filename = f, overwrite = TRUE)
  
}

