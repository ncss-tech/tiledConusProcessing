## Wt. Mean component surface fragments estimation within each 30m gNATSGO grid cell
##
##

library(soilDB)
library(purrr)
library(furrr)
library(terra)

# aggregate component surface frags by SSA
getCoSurfaceFrags <- function(ssa) {
  
  sql <- sprintf("
WITH compdata AS (
  SELECT
  co.mukey, co.cokey, comppct_r,
  COALESCE(SUM(sfragcov_r), 0) AS surf_frag_vol
  FROM legend AS leg 
  INNER JOIN mapunit AS mu ON leg.lkey = mu.lkey
  LEFT JOIN component AS co ON mu.mukey = co.mukey
  LEFT JOIN cosurffrags AS cf ON co.cokey = cf.cokey
  WHERE comppct_r IS NOT NULL
  AND compkind != 'Miscellaneous area'
  AND leg.areasymbol = '%s'
  GROUP BY co.mukey, co.cokey, co.comppct_r
)
SELECT mukey,
ROUND(SUM(surf_frag_vol * comppct_r) / SUM(comppct_r), 0) AS wtmean_surf_frags,
SUM(comppct_r/100.0) AS soil_data_fraction
FROM compdata
GROUP by mukey;",
  ssa
  )

  res <- suppressMessages(SDA_query(sql))

  return(res)

}

# test: OK
# getCoSurfaceFrags('ca113')

# test hand-calculated value




## SSURGO + STATSGO mukey
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

# FY25: 3228 rows
nrow(x)


# keep track of STATSGO mukey
sql <- "SELECT mukey
FROM legend as l
JOIN mapunit as m ON l.lkey = m.lkey
WHERE areasymbol = 'US' ;"

statsgo.mukeys <- SDA_query(sql)

# FY25: 9562 rows
nrow(statsgo.mukeys)



# init parallel back-end for GFE / windows
plan(multisession)

# GFE: ~ 
system.time(m <- future_map(x$areasymbol, safely(getCoSurfaceFrags), .progress = TRUE))

# stop back-ends
plan(sequential)

# ensure all areasymbols were processed
stopifnot(length(m) == nrow(x))

# results
m.res <- map(m, pluck, 'result')
m.res <- do.call('rbind', m.res)

# FY25: 319,076 rows
str(m.res)

# mark SSURGO / STATSGO
m.res$source <- 'SSURGO'
m.res$source[which(m.res$mukey %in% statsgo.mukeys$mukey)] <- 'STATSGO'
table(m.res$source)

# FY25
# SSURGO STATSGO 
# 309523    9553


## fix any out of range values
summary(m.res$wtmean_surf_frags)


# TODO: >90% seems unusual
# >100
m.res$wtmean_surf_frags[m.res$wtmean_surf_frags > 100] <- 100

## function applied at each pixel
# lookup 'pct' for each mukey
.f <- function(i) {
  
  .idx <- match(i, m.res$mukey)
  .res <- m.res$wtmean_surf_frags[.idx]
  
  return(.res)
}

## test

# z <- SDA_query("
#           SELECT
#   co.mukey, co.cokey, comppct_r,
#   COALESCE(SUM(sfragcov_r), 0) AS surf_frag_vol
#   FROM legend AS leg 
#   INNER JOIN mapunit AS mu ON leg.lkey = mu.lkey
#   LEFT JOIN component AS co ON mu.mukey = co.mukey
#   LEFT JOIN cosurffrags AS cf ON co.cokey = cf.cokey
#   WHERE comppct_r IS NOT NULL
#   AND compkind != 'Miscellaneous area'
#   AND mu.mukey = '2766859'
#   GROUP BY co.mukey, co.cokey, co.comppct_r;
#           ")
# 
# z
# 
# sum(z$surf_frag_vol * z$comppct_r) / sum(z$comppct_r)


# OK: result is 0%
.f('488039')

# OK: result is 3%
.f('2924649')

# OK: result is 23%
.f('2766859')



# CONUS gNATSGO 30m grid
# using SDA as the source, RSS values will be missing
g <- rast('E:/gis_data/mukey-grids/gNATSGO-mukey.tif')

# GFE: ~ 8 minutes
system.time(
  r <- app(
    g, 
    fun = .f, 
    filename = 'examples/co-surface-frags-pct.tif', 
    overwrite = TRUE, 
    wopt = list(datatype = 'INT1U')
  )
)

# aggregate to 900m
# GFE ~ 1.7 minutes
system.time(
  a <- aggregate(
    r, 
    fact = 30, 
    fun = 'mean', na.rm = TRUE, 
    filename = 'examples/co-surface-frags-pct-900m.tif', 
    overwrite = TRUE,
    wopt = list(datatype = 'INT1U')
  )
)


# TODO: 900m grid should be:

# Origin = (-2356125.000000000000000,270045.000000000000000)
# Pixel Size = (900.000000000000000,900.000000000000000)
# 
# Corner Coordinates:
#   Upper Left  (-2356125.000,  270045.000) (118d44'15.75"W, 22d52'43.56"N)
# Lower Left  (-2356125.000, 3195045.000) (127d59' 9.66"W, 48d 9' 1.67"N)
# Upper Right ( 2278875.000,  270045.000) ( 73d58'51.50"W, 23d 2'40.72"N)
# Lower Right ( 2278875.000, 3195045.000) ( 64d59'19.43"W, 48d22'43.16"N)
# Center      (  -38625.000, 1732545.000) ( 96d26'52.21"W, 38d37'16.37"N)
# 


