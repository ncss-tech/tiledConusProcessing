library(tools)
library(sf)
library(terra)

## FY25

# gNATSGO: 932606178562f712231ce5b82cd8fbc0
gNATSGO <- 'e:/gis_data/mukey-grids/gNATSGO-mukey.tif'
md5sum(gNATSGO)

# gSSURGO: 224858ba41afcaed4d73e3192e18ffa5
gSSURGO <- 'e:/gis_data/mukey-grids/gSSURGO-mukey.tif'
md5sum(gSSURGO)

# gSTATSGO: 29c18a172f57c1c15e818300fdbf0eab
gSTATSGO <- 'e:/gis_data/mukey-grids/gSTATSGO-mukey.tif'
md5sum(gSTATSGO)


# gSTATSGO-300m: 125e876eaa4ef3f0f53531bead44371f
gSTATSGO.300 <- 'e:/gis_data/mukey-grids/gSTATSGO-mukey-300m.tif'
md5sum(gSTATSGO.300)





gdal_utils(util = 'info', gSTATSGO)


rast(gNATSGO)
rast(gSSURGO)
rast(gSTATSGO)
rast(gSTATSGO.300)


# 
# class       : SpatRaster 
# dimensions  : 96538, 153996, 1  (nrow, ncol, nlyr)
# resolution  : 30, 30  (x, y)
# extent      : -2356125, 2263755, 276435, 3172575  (xmin, xmax, ymin, ymax)
# coord. ref. : NAD83 / Conus Albers (EPSG:5070) 
# source      : gNATSGO-mukey.tif 
# name        : gNATSGO-mukey 

# class       : SpatRaster 
# dimensions  : 96751, 153996, 1  (nrow, ncol, nlyr)
# resolution  : 30, 30  (x, y)
# extent      : -2356125, 2263755, 270045, 3172575  (xmin, xmax, ymin, ymax)
# coord. ref. : NAD83 / Conus Albers (EPSG:5070) 
# source      : gSSURGO-mukey.tif 
# name        : gSSURGO-mukey
# 

# class       : SpatRaster 
# dimensions  : 96538, 153996, 1  (nrow, ncol, nlyr)
# resolution  : 30, 30  (x, y)
# extent      : -2356125, 2263755, 276435, 3172575  (xmin, xmax, ymin, ymax)
# coord. ref. : NAD83 / Conus Albers (EPSG:5070) 
# source      : gSTATSGO-mukey.tif 


# class       : SpatRaster 
# dimensions  : 9654, 15400, 1  (nrow, ncol, nlyr)
# resolution  : 300, 300  (x, y)
# extent      : -2356125, 2263875, 276375, 3172575  (xmin, xmax, ymin, ymax)
# coord. ref. : NAD83 / Conus Albers (EPSG:5070) 
# source      : gSTATSGO-mukey-300m.tif

