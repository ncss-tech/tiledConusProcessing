##
## mapping intensity by mukey
##

library(soilDB)
library(terra)
library(sf)
library(rasterVis)



# "one or more major components have NULL ST edition"
# too many records for regular SDA_query()
sql <- "SELECT
    mapunit.mukey, CASE WHEN invesintens IS NULL THEN 'missing' ELSE invesintens END AS invesintens
    FROM legend
    INNER JOIN mapunit ON mapunit.lkey = legend.lkey
    -- exclude STATSGO
    WHERE legend.areasymbol != 'US' "

# secret hack to make it work
# no semi-colons allowed in the SQL
x <- soilDB:::.SDA_query_FOR_JSON_AUTO(sql)

# 320032
nrow(x)

table(x$invesintens, useNA = 'always')

# TODO: proper encoding of NODATA

# this approach works with match() because all factor levels are present
# in the source LUT
x$invesintens <- factor(x$invesintens, levels = c('missing', 'Order 1', 'Order 2', 'Order 3', 'Order 4', 'Order 5'))
x$i <- as.numeric(x$invesintens)

head(x)

# lookup integer-coded survey order or, 'missing'
.f <- function(i) {

  .idx <- match(i, x$mukey)
  .res <- x$i[.idx]
  
  return(.res)
}

# # testing
# x[c(1, 100, 300), ]
# .f(x$mukey[c(1, 100, 300)])
# .f(c(NA, 50227, NA))


# CONUS gNATSGO 30m grid
g <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# ~ 17 minutes
system.time(r <- app(g, fun = .f, filename = 'examples/invesintens.tif', overwrite = TRUE))

# 10x aggregation
# ~ 6 minutes
system.time(a <- aggregate(r, fact = 10, fun = 'modal', filename = 'examples/invesintens.tif-300m.tif', overwrite = TRUE))

# mask?



## check within AOI


# make a bounding box and assign a CRS (4326: GCS, WGS84)
a <- vect('POLYGON((-118.6848 36.7983,-118.6848 36.9223,-118.4306 36.9223,-118.4306 36.7983,-118.6848 36.7983))', crs = 'epsg:4326')

# fetch gSSURGO map unit keys at native resolution (30m)
mu <- mukey.wcs(aoi = a, db = 'gssurgo')

# extract RAT for thematic mapping
rat <- cats(mu)[[1]]

rat <- merge(rat, x, by = 'mukey', all.x = TRUE, sort = FALSE)

table(rat$invesintens)

# re-pack rat
levels(mu) <- rat

activeCat(mu) <- 'invesintens'
plot(mu, axes = FALSE, col = hcl.colors(n = 4, palette = 'spectral'))

# use integer coding of factor
invesintens <- as.numeric(mu, index = 'i')
plot(invesintens, axes = FALSE, maxcell = 1e5, col = hcl.colors(10, 'mako'))



