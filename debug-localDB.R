

library(DBI)
library(RSQLite)
library(soilDB)


local.tabularDB <- 'e:/gis_data/SSURGO-STATSGO-tabular/ssurgo-combined.sqlite'


# SSURGO
get_SDA_property(
  property = 'claytotal_r', 
  dsn = local.tabularDB, 
  mukeys = 2600481, 
  method = "Weighted Average",  
  top_depth = 0, 
  bottom_depth = 25, 
  include_minors = TRUE, 
  miscellaneous_areas = FALSE
)


# STATSGO
get_SDA_property(
  property = 'claytotal_r', 
  dsn = local.tabularDB, 
  mukeys = 658083, 
  method = "Weighted Average",  
  top_depth = 0, 
  bottom_depth = 25, 
  include_minors = TRUE, 
  miscellaneous_areas = FALSE
)


