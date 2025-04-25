library(tools)
library(sf)

# FY25
# gNATSGO: 932606178562f712231ce5b82cd8fbc0
gNATSGO <- 'e:/gis_data/mukey-grids/gNATSGO-mukey.tif'
md5sum(gNATSGO)

gdal_utils(util = 'info', gNATSGO)




