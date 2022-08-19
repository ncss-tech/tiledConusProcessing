## Mosaic 30m tiles and save second version after aggregation to 270m or similar
## 2022-07-21
## D.E. Beaudette

library(purrr)
library(furrr)
library(terra)

## continuous variables
v <- c("sandtotal_r", "claytotal_r", "ph1to1h2o_r", "wthirdbar_r", "wfifteenbar_r")

input.dir <- 'processed-tiles'
output.dir <- 'results'
dir.create(output.dir)

# test: works
map('sandtotal_r', .f = mosaicProperty, input.dir = input.dir, output.dir = output.dir)

# init multiple cores
# aggregate seems to use multiple cores, so only start 4 concurrent operations
# 4 workers -> 28GB RAM required
plan(multisession, workers = 4)

system.time(z <- future_map(s, .mosaicSlices, .progress = TRUE))

# stop parallel back-ends
plan(sequential)

## cleanup
rm(list = ls())
gc(reset = TRUE)




for (i in v) {
  
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


## new version



# 0-pad
s <- sprintf("%03d", ..slices)





