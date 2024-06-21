library(terra)


x <- rast('results/om_r_0-30cm.tif')
issr <- rast('e:/gis_data/FY2024-800m-rasters/rasters/cec.tif')


# take the min value within ISSR-800 grid cells
# 3 minutes
system.time(
  a <- resample(
    x, 
    issr, 
    method = 'min', 
    threads = 8, 
    filename = 'results/min-SOM-ISSR800-grid_0-30cm.tif', 
    overwrite = TRUE
  )
)

plot(a, col = hcl.colors(100), breaks = 10, breakby = 'cases', axes = FALSE, maxcell = 1e6)
