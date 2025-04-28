library(tools)
library(sf)
library(terra)

## FY25

## Notes:
#  * gSSURGO is Int32 | gNATSGO is UInt32
#  * gSSURGO and gNATSGO grids are slightly different
#  * sf::gdal_utils() seems partially broken by latest OCIO policy





# gNATSGO: 932606178562f712231ce5b82cd8fbc0
gNATSGO <- 'e:/gis_data/mukey-grids/gNATSGO-mukey.tif'
md5sum(gNATSGO)

# gSSURGO: 224858ba41afcaed4d73e3192e18ffa5
gSSURGO <- 'e:/gis_data/mukey-grids/gSSURGO-mukey.tif'
md5sum(gSSURGO)

# gSTATSGO: 2a9be180d7f203e066faf1308c914f5e
gSTATSGO <- 'e:/gis_data/mukey-grids/gSTATSGO-mukey.tif'
md5sum(gSTATSGO)

# gSTATSGO-300m: d7d739a38718b8fed5cde01d6a9d26f5
gSTATSGO.300 <- 'e:/gis_data/mukey-grids/gSTATSGO-mukey-300m.tif'
md5sum(gSTATSGO.300)

# fSSURGO: 3df5eba3eb6bae2181ceabcdb05a3465
fSSURGO <- 'e:/gis_data/mukey-grids/fSSURGO-mukey.tif'
md5sum(fSSURGO)


gdal_utils(util = 'info', fSSURGO)
gdal_utils(util = 'info', gSTATSGO)


rast(gNATSGO)
rast(gSSURGO)
rast(gSTATSGO)
rast(gSTATSGO.300)
rast(fSSURGO)



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
# dimensions  : 96751, 153996, 1  (nrow, ncol, nlyr)
# resolution  : 30, 30  (x, y)
# extent      : -2356125, 2263755, 270045, 3172575  (xmin, xmax, ymin, ymax)
# coord. ref. : NAD83 / Conus Albers (EPSG:5070) 
# source      : gSTATSGO-mukey.tif 


# class       : SpatRaster 
# dimensions  : 9676, 15400, 1  (nrow, ncol, nlyr)
# resolution  : 300, 300  (x, y)
# extent      : -2356125, 2263875, 269775, 3172575  (xmin, xmax, ymin, ymax)
# coord. ref. : NAD83 / Conus Albers (EPSG:5070) 
# source      : gSTATSGO-mukey-300m.tif 


# class       : SpatRaster 
# dimensions  : 96751, 153996, 1  (nrow, ncol, nlyr)
# resolution  : 30, 30  (x, y)
# extent      : -2356125, 2263755, 270045, 3172575  (xmin, xmax, ymin, ymax)
# coord. ref. : NAD83 / Conus Albers (EPSG:5070) 
# source      : fSSURGO-mukey.tif 
