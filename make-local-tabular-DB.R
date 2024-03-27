
## need to run this a little at a time, or 

library(soilDB)
library(RSQLite)
library(DBI)

q <- "SELECT areasymbol, saverest FROM sacatalog WHERE areasymbol LIKE ('MXNL001');"
x <- SDA_query(q)
nrow(x)


## download

# SSURGO
system.time(
  downloadSSURGO(areasymbols = x$areasymbol, exdir = 'e:/temp/SSURGO-STATSGO', include_template = FALSE, remove_zip = TRUE, extract = TRUE, overwrite = TRUE, db = 'SSURGO')  
)


# STATSGO
system.time(
  downloadSSURGO(areasymbols = 'US', exdir = 'e:/temp/SSURGO-STATSGO', include_template = FALSE, remove_zip = TRUE, extract = TRUE, overwrite = TRUE, db = 'STATSGO')
)



## create database
createSSURGO(filename = 'e:/temp/ssurgo-combined.sqlite', exdir = 'e:/temp/SSURGO-STATSGO', include_spatial = FALSE, overwrite = TRUE)


## additional indexing


## check

# connect
db <- dbConnect(RSQLite::SQLite(), 'E:/temp/ssurgo-combined.sqlite')

# list tables
dbListTables(db)

dbDisconnect(db)
