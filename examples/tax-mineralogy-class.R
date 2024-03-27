##
## mineralogy class
##

library(soilDB)
library(terra)

# ## testing multiple min classes
# x <- SDA_query("SELECT 
#           m.mukey, c.cokey, compname, comppct_r, CASE WHEN taxminalogy IS NULL THEN 'not-used' ELSE taxminalogy END as taxminalogy
#           FROM mapunit AS m 
#           INNER JOIN component AS c ON m.mukey = c.mukey 
#           LEFT JOIN cotaxfmmin AS ct ON c.cokey = ct.cokey
#           WHERE majcompflag = 'Yes' 
#           AND m.mukey = '75414'; "
# )
# 
# knitr::kable(x, row.names = FALSE)
# 
# 
# x <- SDA_query("SELECT 
#           m.mukey, c.cokey,
#           -- no aggregation
#           MIN(comppct_r) AS pct, 
#           -- string concatenation over rows
#           STRING_AGG(CASE WHEN taxminalogy IS NULL THEN 'not-used' ELSE taxminalogy END, ' over ') AS txmn
#           FROM mapunit AS m 
#           INNER JOIN component AS c ON m.mukey = c.mukey 
#           LEFT JOIN cotaxfmmin AS ct ON c.cokey = ct.cokey
#           WHERE majcompflag = 'Yes' 
#           AND m.mukey = '75414'
#           GROUP BY m.mukey, c.cokey ; "
# )
# 
# knitr::kable(x, row.names = FALSE)
# 
# 
# x <- SDA_query("SELECT mukey, SUM(pct) AS pct, FIRST(txmn) WITHIN GROUP (ORDER BY pct ASC) AS txmn
#                FROM (
#                SELECT m.mukey, c.cokey,
#           -- no aggregation
#           MIN(comppct_r) AS pct, 
#           -- string concatenation over rows
#           STRING_AGG(CASE WHEN taxminalogy IS NULL THEN 'not-used' ELSE taxminalogy END, ' over ') AS txmn
#           FROM mapunit AS m 
#           INNER JOIN component AS c ON m.mukey = c.mukey 
#           LEFT JOIN cotaxfmmin AS ct ON c.cokey = ct.cokey
#           WHERE majcompflag = 'Yes' 
#           AND m.mukey = '75414'
#           GROUP BY m.mukey, c.cokey 
#                ) AS a
#           GROUP BY mukey, txmn
#           ORDER BY pct DESC;
#            "
# )


## TODO: more testing with SSURGO BBOX
## ALSO: this syntax sucks

## toggle STATSGO | SSURGO | both
sql <- "WITH a AS (
          SELECT m.mukey, c.cokey,
          -- no aggregation
          MIN(comppct_r) AS pct, 
          -- string concatenation over rows
          STRING_AGG(CASE WHEN taxminalogy IS NULL THEN 'not used' ELSE taxminalogy END, ' over ') AS txmn
          FROM 
          legend AS l
          INNER JOIN mapunit AS m ON l.lkey = m.lkey AND l.areasymbol = 'US'
          INNER JOIN component AS c ON m.mukey = c.mukey 
          LEFT JOIN cotaxfmmin AS ct ON c.cokey = ct.cokey
          WHERE majcompflag = 'Yes' 
          -- AND m.mukey = '75414'
          GROUP BY m.mukey, c.cokey 
          ), 
          b AS (
          SELECT mukey, SUM(pct) AS pct, txmn, 
          ROW_NUMBER() OVER (PARTITION BY mukey ORDER BY SUM(pct) DESC) AS ro
          FROM a
          GROUP BY mukey, txmn
          )
          SELECT mukey, pct, txmn
          FROM b
          WHERE ro = 1 "


# fails with all of SSURGO
x <- SDA_query(sql)

## TODO: seems to break with CTE?

# secret hack to make it work
# # no semi-colons allowed in the SQL
# x <- soilDB:::.SDA_query_FOR_JSON_AUTO(sql)


## TODO: use local SQLite database



knitr::kable(head(x), row.names = FALSE)


x$txmn <- factor(x$txmn)
dotchart(sort(table(x$txmn), decreasing = FALSE))

head(x)

# integer encoding
x$i <- as.numeric(x$txmn)

# lookup integer-coded factor
.f <- function(i) {
  
  .idx <- match(i, x$mukey)
  .res <- x$i[.idx]
  
  return(.res)
}

## testing
x[c(1, 100, 300), ]
.f(657753)

# grid system
g <- rast('E:/gis_data/mukey-grids/gSTATSGO-mukey.tif')

# STATSGO 300m: ~ 10 seconds
system.time(r <- app(g, fun = .f, filename = 'examples/STATSGO-minclass.tif', overwrite = TRUE))

r <- as.factor(r)
rat <- levels(r)[[1]]
rat$txmn <- levels(x$txmn)[as.integer(rat$lyr.1)]
levels(r) <- rat

activeCat(r) <- 'txmn'
plot(r, col = hcl.colors(25), mar = c(1, 1, 1, 10), axes = FALSE)




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



