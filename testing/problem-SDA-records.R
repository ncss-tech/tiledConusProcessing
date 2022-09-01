
## note: mukey values like 600000 are silently converted to 6e+05
# ---> use as.integer(mukey)



library(soilDB)
library(pbapply)

x <- readRDS('errors.rds')
m <- x$`188`$rat$mukey

length(m)

z <- pblapply(m, FUN = function(i) {
  
  p <- try( 
    get_SDA_property(
      property = 'ph1to1h2o_r',
      method = "Weighted Average", 
      mukeys = i,
      top_depth = 0,
      bottom_depth = 25,
      include_minors = TRUE, 
      miscellaneous_areas = FALSE
    ), silent = TRUE
  )
  
  return(data.frame(mukey = i, result = inherits(p, 'try-error')))
  
})


idx <- which(sapply(z, function(i) {i[, 2]}))

z[[idx]]

str(z)

m[idx]

as.integer(m[idx])

