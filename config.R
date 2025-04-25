##
##
##

## database selector

# local SQLite tabular database
# local.tabularDB <- 'e:/gis_data/SSURGO-STATSGO-tabular/ssurgo-combined.sqlite'

# SDA
local.tabularDB <- NULL


## grid system

# gNATSGO
grid.system <- 'E:/gis_data/mukey-grids/gNATSGO-mukey.tif'

# gSSURGO
# grid.system <- 'E:/gis_data/mukey-grids/gSSURGO-mukey.tif'

# STATSGO
# grid.system <- 'E:/gis_data/mukey-grids/gSTATSGO-mukey.tif'

# gSSURGO SoilWeb
# grid.system <- '/data1/website/wcs-files/gSSURGO-mukey.tif'


## variables
v <- c("sandtotal_r", "silttotal_r", "claytotal_r", "ph1to1h2o_r", "wthirdbar_r", "wfifteenbar_r")

# v <- c('wei')
# v <- c("om_r", "cec7_r", "ecec_r")

v <- 'om_r'


## depth interval
depth.interval <- c(0, 30)



