## Mosaic 30m tiles and save second version after aggregation to 270m or similar
## 2022-07-21
## D.E. Beaudette


## TODO:
#  * categorical variables

# ~ 1 hour for 7 properties

library(purrr)
library(furrr)
library(terra)

source('local-functions.R')
source('config.R')


input.dir <- 'processed-tiles'
output.dir <- 'results'
dir.create(output.dir)

# test: works
# map('sandtotal_r', .f = mosaicProperty, input.dir = input.dir, output.dir = output.dir)

# init multiple cores
# aggregate seems to use multiple cores, so only start 4 concurrent operations
# 4 workers -> 28GB RAM required
plan(multisession, workers = 4)

system.time(z <- future_map(v, .f = mosaicProperty, input.dir = input.dir, output.dir = output.dir, .progress = TRUE))

# stop parallel back-ends
plan(sequential)

## cleanup
rm(list = ls())
gc(reset = TRUE)






