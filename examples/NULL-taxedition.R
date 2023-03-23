library(soilDB)
library(terra)
library(sf)
library(viridisLite)
library(rasterVis)

## TODO: make a thematic map of most-frequent tax edition

# "one or more major components have NULL ST edition"
# too many records for regular SDA_query()
sql <- "SELECT
    DISTINCT component.mukey
    FROM legend
    INNER JOIN mapunit ON mapunit.lkey = legend.lkey
    INNER JOIN component ON component.mukey = mapunit.mukey
    -- exclude STATSGO
    WHERE legend.areasymbol != 'US' 
    AND majcompflag = 'Yes'
    AND compkind != 'Miscellaneous area'
    AND soiltaxedition IS NULL"

# secret hack to make it work
# no semi-colons allowed in the SQL
x <- soilDB:::.SDA_query_FOR_JSON_AUTO(sql)

# 108081
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
system.time(r <- app(g, fun = .f, filename = 'examples/NULL-taxedition.tif', overwrite = TRUE))

# 10x aggregation
# ~ 6 minutes
system.time(a <- aggregate(r, fact = 10, fun = 'modal', filename = 'examples/NULL-taxedition-300m.tif', overwrite = TRUE))


## check within AOI


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



