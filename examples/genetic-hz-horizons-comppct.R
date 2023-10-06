library(soilDB)
library(terra)
library(sf)


## Notes:
# * this approach fails when components use old-style H1, H2, H3, etc. notation for horizon names
#

q <- "SELECT
    mapunit.mukey, SUM(comppct_r) AS pct
    FROM legend
    INNER JOIN mapunit ON mapunit.lkey = legend.lkey
    INNER JOIN component ON component.mukey = mapunit.mukey
    -- collect unique component keys where any horizon matches pattern
    -- inner join is an implicit filter
    INNER JOIN (
      SELECT DISTINCT component.cokey
      FROM 
      component INNER JOIN chorizon ON component.cokey = chorizon.cokey
      -- pattern matching on horizon name
      WHERE hzname LIKE 'E%'
    ) AS hz ON component.cokey = hz.cokey
    WHERE legend.areasymbol != 'US' 
    -- testing a single map unit
    -- AND mapunit.mukey = '295570'
    GROUP BY mapunit.mukey ;"

x <- SDA_query(q)

# 59696 rows
nrow(x)
head(x)


# TODO: proper encoding of NODATA

# function applied at each pixel
# lookup 'pct' for each mukey
.f <- function(i) {
  
  .idx <- match(i, x$mukey)
  .res <- x$pct[.idx]
  
  return(.res)
}

# CONUS gNATSGO 30m grid
g <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# ~ 17 minutes
system.time(r <- app(g, fun = .f, filename = 'E-horizon-pct.tif', overwrite = TRUE))

# 10x aggregation
# ~ 4.8 minutes
system.time(a <- aggregate(r, fact = 10, fun = 'modal', filename = 'E-horizon-pct-300m.tif', overwrite = TRUE))




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



