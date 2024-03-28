##
## mineralogy class
##

library(soilDB)
library(terra)
library(purrr)
library(furrr)
library(lattice)
library(latticeExtra)
library(tactile)


getMinClass <- function(ssa) {
  
  # mineralogy class by SSA
  sql <- sprintf("
          -- first aggregation step
          WITH a AS (
            SELECT m.mukey, c.cokey,
            -- no aggregation
            MIN(comppct_r) AS pct, 
            -- string concatenation over rows
            STRING_AGG(CASE WHEN taxminalogy IS NULL THEN 'not used' ELSE taxminalogy END, ' over ') AS txmn
            FROM 
            legend AS l
            INNER JOIN mapunit AS m ON l.lkey = m.lkey
            INNER JOIN component AS c ON m.mukey = c.mukey 
            LEFT JOIN cotaxfmmin AS ct ON c.cokey = ct.cokey
            WHERE majcompflag = 'Yes' 
            -- single SSA
            AND l.areasymbol = '%s'
            GROUP BY m.mukey, c.cokey 
          ), 
          -- second aggregation step
          b AS (
            SELECT mukey, SUM(pct) AS pct, txmn, 
            ROW_NUMBER() OVER (PARTITION BY mukey ORDER BY SUM(pct) DESC) AS ro
            FROM a
            GROUP BY mukey, txmn
          )
          -- filtering most common tax min class
          SELECT mukey, pct, txmn
          FROM b
          WHERE ro = 1 ;", ssa
  )
  
  
  # fails with all of SSURGO
  res <- suppressMessages(SDA_query(sql))
  
  return(res)
  
}



# quick test
x <- getMinClass('CA630')
knitr::kable(head(x), row.names = FALSE)

x$txmn <- factor(x$txmn)
dotchart(sort(table(x$txmn), decreasing = FALSE))


## SSURGO, + STATSGO
# no AK, HI, PR
sql <- "
SELECT areasymbol, saverest 
FROM sacatalog 
WHERE areasymbol NOT LIKE 'AK%'
AND areasymbol NOT LIKE 'PR%' 
AND areasymbol NOT LIKE 'HI%' 
-- optionally filter STATSGO
-- AND areasymbol != 'US' 
;"

x <- SDA_query(sql)
head(x)

# FY24: 3226 rows
nrow(x)

## parallel processing
# init parallel processing, works on macos and windows
plan(multisession)

# ~ 93 seconds
system.time(m <- future_map(x$areasymbol, safely(getMinClass), .progress = TRUE))

# stop back-ends
plan(sequential)



## flatten

# results
m.res <- map(m, pluck, 'result')
m.res <- do.call('rbind', m.res)

# errors


str(m.res)

# FY24: 319326 rows
nrow(m.res)


## process raster

## TODO: think about levels / simplification
# factor
m.res$txmn <- factor(m.res$txmn)

# integer encoding
m.res$i <- as.numeric(m.res$txmn)


options(scipen = 20)
dotplot(
  sort(table(m.res$txmn), decreasing = FALSE), 
  cex = 0.66, 
  scales = list(x = list(log = 10)), 
  xscale.components = xscale.components.log10ticks
)


## TODO: encode / use factors here if possible
## TODO: account for NA
# lookup integer-coded factor
.f <- function(i) {
  
  .idx <- match(i, m.res$mukey)
  .res <- m.res$i[.idx]
  
  return(.res)
}

## testing
m.res[c(1, 100, 300), ]
.f(369778)

# grid system
g <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# STATSGO 300m: ~ 10 seconds
# gNATSGO 30m: ~ 10 minutes
system.time(r <- app(g, fun = .f, filename = 'examples/gNATSGO-minclass.tif', overwrite = TRUE))

# this takes a little while, not re
r <- as.factor(r)
rat <- levels(r)[[1]]
rat$txmn <- levels(m.res$txmn)[as.integer(rat$lyr.1)]
levels(r) <- rat

activeCat(r) <- 'txmn'
plot(r, col = hcl.colors(nrow(rat)), mar = c(1, 1, 1, 10), axes = FALSE)




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





########################### tinkering #################################


# secret hack to make it work
# TODO: seems to break with CTE?
# # no semi-colons allowed in the SQL
# x <- soilDB:::.SDA_query_FOR_JSON_AUTO(sql)



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

