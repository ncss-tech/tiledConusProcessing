
## Notes:
# if working with a huge directory of .zip files
# ~ 7 minutes on 4-1
# time parallel --eta unzip ::: *.zip

# A lot of free space is required for all of SSURGO
# FY24 SSURGO (uncompressed): 217GB
# Latest STATSGO (uncompressed): 1GB

# Final SSURGO + STATSGO tabular database: 14GB (2.1GB gzip)


## will fail on a slow connection, WSS / SDA are shutdown most nights

library(soilDB)
library(RSQLite)
library(DBI)


## paths

# soilweb
.exdir1 <- 'statsgo'
.exdir2 <- 'ssurgo'
.dbfile <- 'ssurgo-combined.sqlite'

# local machine
.exdir1 <- 'e:/temp/statsgo'
.exdir2 <- 'e:/temp/ssurgo'
.dbfile <- 'e:/gis_data/SSURGO-STATSGO-tabular/ssurgo-combined.sqlite'


## SSAs to iterate over
q <- "SELECT areasymbol, saverest FROM sacatalog WHERE areasymbol NOT IN ('US', 'MXNL001');"
x <- SDA_query(q)
nrow(x)

## download

# notes:
# * all of SSURGO will never finish at home / Sonora MLRA office
# * must increase curl timeout on a slow connection (STATSGO will fail with defaults)
# * parallel downloads would be faster (1 hour on soilmap 2-1)

# STATSGO
#  * gov machine, Sonora MLRA office: 13 minutes
#  * soilmap 4-1: 11 minutes
options('soilDB.timeout' = 1e6)
system.time(
  downloadSSURGO(areasymbols = 'US', exdir = .exdir1, include_template = FALSE, remove_zip = TRUE, extract = TRUE, overwrite = TRUE, db = 'STATSGO')
)

# SSURGO
system.time(
  downloadSSURGO(areasymbols = x$areasymbol, exdir = .exdir2, include_template = FALSE, remove_zip = TRUE, extract = TRUE, overwrite = TRUE, db = 'SSURGO')  
)





## create database

# fresh start, remove whatever was left from last time
unlink(.dbfile)


# first pass, STATSGO
#  * gov machine: ~ 91 seconds
#  * soilweb 4-1: ~ 71 seconds
system.time(
  createSSURGO(filename = .dbfile, exdir = .exdir1, include_spatial = FALSE, overwrite = TRUE)
)


# second pass, SSURGO
#  * gov machine: (not possible yet)
#  * soilweb 4-1: 32 minutes
system.time(
  createSSURGO(filename = .dbfile, exdir = .exdir2, include_spatial = FALSE, overwrite = FALSE)
)



## connect to finish up
db <- dbConnect(RSQLite::SQLite(), .dbfile)

# cleanup
# ~ 5 minutes
dbExecute(db, 'VACUUM;')

# check indices
dbGetQuery(db, 'PRAGMA index_list(mapunit);')

dbGetQuery(db, "select type, name, tbl_name, sql
FROM sqlite_master
WHERE type = 'index' AND tbl_name = 'chorizon' ;")


## TODO additional or specialized indexing?


## check


# list tables
dbListTables(db)

# STATSGO
dbGetQuery(db, "SELECT mukey, muname, mukind FROM mapunit WHERE mukey  = '658083' ;")

# SSURGO
dbGetQuery(db, "SELECT mukey, muname, mukind FROM mapunit WHERE mukey  = '2600481' ;")

# simple query
dbGetQuery(db, 'SELECT cokey, compname, comppct_r, majcompflag FROM component LIMIT 5;')

# be sure to close connection / file
dbDisconnect(db)


## cleanup
rm(list = ls())
gc(reset = TRUE)



