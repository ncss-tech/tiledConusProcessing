##
##
##

library(soilDB)
library(purrr)
library(furrr)

source('config.R')
source('local-functions.R')

## unique mukey values for entire grid system
m <- readRDS('unique-mukey.rds')

## split into chunks small enough to run efficiently in SDA
# 2025-12-19: 1000 mukey seems about right, 1500 can lead to slowness / server errors
idx <- makeChunks(m$mukey, size = 1000)
m <- split(m$mukey, idx)

# ok
str(m, 1)

# 323 chunks
length(m)

# ok
# z <- getDataByChunk(i = m[[1]], vars = v, top = depth.interval[1], bottom = depth.interval[2])


## init multiple cores
# plan(multicore) # linux
plan(multisession) # windows

# GFE fSSURGO 30m: 95 seconds (parallel) | 17 minutes (serial)
system.time(
  z <- future_map(
    m, 
    .f = getDataByChunk, 
    vars = v, 
    top = depth.interval[1],
    bottom = depth.interval[2], 
    .progress = TRUE
  )
)

# stop parallel back-ends
plan(sequential)



# process errors:

table(sapply(z, class))


## flatten
z <- do.call('rbind', z)

## QC
table(is.na(z$mukey))


## save
saveRDS(z, file = 'LUT.rds')


## cleanup
rm(list = ls())
gc(reset = TRUE)

