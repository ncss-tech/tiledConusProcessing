## make tiling grid A


library(terra)
library(sf)
library(progress)

## TODO: think about other tiling systems


## ~ 15 minutes

# mukey grid
mu <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# bbox
bb <- st_as_sfc(st_bbox(mu))


# tiling grid "A"
g <- st_make_grid(bb, n = c(20, 20))
g <- st_as_sf(g)

# grid cell ID, for testing only
# starts from lower-left corner
# progresses left -> right, bottom -> top
g$id <- 1:nrow(g)

# # check: ok
# plot(mu, maxcell = 1e4)
# plot(bb, add = TRUE)
# plot(st_geometry(g), add = TRUE, border = 2)
# plot(g['id'])

# iterate over tile grid, test for all NA
# remove those tiles
# save for later use
n <- nrow(g)
pb <- progress_bar$new(format = '[:bar] :percent (:eta)', total = n)
nd.idx <- list()
for (i in 1:n) {
  # current tile
  x <- crop(mu, g[i, ])
  
  # test for all NA
  if (all(is.na(values(x)))) {
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

# updated grid cell ID
# starts from top-left corner
# progresses left -> right, top -> bottom
g.new <- g.new[rev(1:nrow(g.new)), ]
g.new$id <- 1:nrow(g.new)
diff(g.new$id)

# check: OK
plot(g.new, pal = viridis::viridis, nbreaks = 50, key.pos = 1, main = '')

# save tile grid
saveRDS(g.new, file = 'A_grid.rds')

# also a shp for easy viz
st_write(g.new, dsn = 'tile-grid-SHP/A_grid.shp', append = FALSE)


