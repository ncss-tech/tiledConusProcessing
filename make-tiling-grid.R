library(terra)
library(sf)
library(progress)

## ~ 20 minutes


# mukey grid
mu <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# bbox
bb <- st_as_sfc(st_bbox(mu))

## TODO: think about other reasonable tiling systems


# tiling grid "A"
g <- st_make_grid(bb, n = c(20, 20))
g <- st_as_sf(g)

# grid cell ID
# starts from lower-left corner
# progresses left -> right, bottom -> top
g$id <- 1:nrow(g)


# # check: ok
# plot(mu, maxcell = 1e4)
# plot(bb, add = TRUE)
# plot(st_geometry(g), add = TRUE, border = 2)

## TODO: do this in parallel

# iterate over tile grid, test for all nodata
# remove those tiles
# save for later use
n <- nrow(g)
pb <- progress_bar$new(total = n)
nd.idx <- list()
for(i in 1:n) {
  # current tile
  x <- crop(mu, g[i, ])
  
  # test for all NA
  if(all(is.na(values(x)))) {
    nd.idx[i] <- TRUE
  } else {
    nd.idx[i] <- FALSE
  }
  pb$tick()
}
pb$terminate()

# indices of tiles to remove
idx <- which(unlist(nd.idx))
g.new <- g[-idx, ]

# check:
plot(g.new, pal = viridis::viridis, nbreaks = 50, key.pos = 1, main = '')

# save tile grid
saveRDS(g.new, file = 'A_grid.rds')

# also a shp for easy viz
st_write(g.new, dsn = 'tile-grid-SHP/A_grid.shp', append = FALSE)


