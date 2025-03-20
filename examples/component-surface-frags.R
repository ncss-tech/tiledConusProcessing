## Wt. Mean component surface fragments estimation within each 30m gNATSGO grid cell
##
##

library(soilDB)
library(terra)

# WITH compdata AS (
#   SELECT 
#   co.mukey, co.cokey, compname, comppct_r,
#   COALESCE(SUM(sfragcov_r), 0) AS surf_frag_vol 
#   FROM ssurgo.component AS co 
#   LEFT JOIN ssurgo.cosurffrags AS cf USING (cokey)
#   WHERE comppct_r IS NOT NULL
#   AND compkind != 'Miscellaneous area'
#   AND co.mukey IN ('1865928', '2441798', '3295885', '462373') 
#   GROUP BY co.cokey
# )
# SELECT mukey, 
# ROUND(SUM(surf_frag_vol * comppct_r) / SUM(comppct_r)) AS wtmean_surf_frags,
# SUM(comppct_r/100.0) AS soil_data_fraction
# FROM compdata
# GROUP by mukey;




