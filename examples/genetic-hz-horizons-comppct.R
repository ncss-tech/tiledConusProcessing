library(soilDB)
library(terra)
library(sf)
library(viridisLite)
library(rasterVis)

## "TODO: generalize to return summed component percent matching criteria

q <- "SELECT
    DISTINCT component.mukey
    FROM legend
    INNER JOIN mapunit ON mapunit.lkey = legend.lkey
    INNER JOIN component ON component.mukey = mapunit.mukey
    INNER JOIN chorizon ON component.cokey = chorizon.cokey
    WHERE legend.areasymbol != 'US' 
    AND majcompflag = 'Yes' 
    AND hzname LIKE 'E%';"

x <- SDA_query(q)
nrow(x)

# TODO: proper encoding of NODATA

# function applied to each pixel
# 2: TRUE
# 1: FALSE
# 0: NODATA
.f <- function(i) {
  ifelse(i %in% x$mukey, 2, 1)
}


# CONUS gNATSGO 30m grid
g <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# ~ 17 minutes
system.time(r <- app(g, fun = .f, filename = 'E-horizon.tif', overwrite = TRUE))

# 10x aggregation
# ~ 4.8 minutes
system.time(a <- aggregate(r, fact = 10, fun = 'modal', filename = 'E-horizon-300m.tif', overwrite = TRUE))




# make a bounding box and assign a CRS (4326: GCS, WGS84)
a <- st_bbox(
  c(xmin = -114, xmax = -114.4, ymin = 47, ymax = 47.4), 
  crs = st_crs(4326)
)

# convert bbox to sf geometry
a <- st_as_sfc(a)

# fetch gSSURGO map unit keys at native resolution (30m)
mu <- mukey.wcs(aoi = a, db = 'gssurgo')

# extract RAT for thematic mapping
rat <- cats(mu)[[1]]

rat$condition <- factor(as.integer(rat$mukey) %in% as.integer(x$mukey), levels = c('FALSE', 'TRUE'))

table(rat$condition)

levels(mu) <- rat

activeCat(mu) <- 'condition'
mu.stack <- catalyze(mu)[['condition']]
plot(mu.stack, axes = FALSE, maxcell = 1e5, col = mako(2))



