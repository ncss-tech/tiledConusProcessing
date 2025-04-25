## Wt. Mean component surface fragments estimation within each 30m gNATSGO grid cell
##
##

library(soilDB)
library(purrr)
library(furrr)
library(terra)

sql <- sprintf(
  "WITH compdata AS (
  SELECT
  co.mukey, co.cokey, comppct_r,
  COALESCE(SUM(sfragcov_r), 0) AS surf_frag_vol
  FROM legend AS leg 
  INNER JOIN mapunit AS mu ON leg.lkey = mu.lkey
  INNER JOIN component AS co ON mu.mukey = co.cokey
  LEFT JOIN cosurffrags AS cf ON co.cokey = cf.cokey
  WHERE comppct_r IS NOT NULL
  AND compkind != 'Miscellaneous area'
  AND mu.mukey IN ('1865928', '2441798', '3295885', '462373')
  GROUP BY co.mukey, co.cokey, co.comppct_r
)
SELECT mukey,
ROUND(SUM(surf_frag_vol * comppct_r) / SUM(comppct_r), 0) AS wtmean_surf_frags,
SUM(comppct_r/100.0) AS soil_data_fraction
FROM compdata
GROUP by mukey;"
)

SDA_query(sql)




getCoSurfaceFrags <- function(ssa) {
  
  # mineralogy class by SSA
  sql <- sprintf("
          -- first aggregation step
          WITH a AS (
            SELECT m.mukey, c.cokey,
            -- no aggregation
            MIN(comppct_r) AS pct, 
            -- string concatenation over rows
            STRING_AGG(CASE WHEN taxminalogy IS NULL THEN 'not used' ELSE taxminalogy END, ' over ') AS txmn
            FROM 
            legend AS l
            INNER JOIN mapunit AS m ON l.lkey = m.lkey
            INNER JOIN component AS c ON m.mukey = c.mukey 
            LEFT JOIN cotaxfmmin AS ct ON c.cokey = ct.cokey
            WHERE majcompflag = 'Yes' 
            -- single SSA
            AND l.areasymbol = '%s'
            GROUP BY m.mukey, c.cokey 
          ), 
          -- second aggregation step
          b AS (
            SELECT mukey, SUM(pct) AS pct, txmn, 
            ROW_NUMBER() OVER (PARTITION BY mukey ORDER BY SUM(pct) DESC) AS ro
            FROM a
            GROUP BY mukey, txmn
          )
          -- filtering most common tax min class
          SELECT mukey, pct, txmn
          FROM b
          WHERE ro = 1 ;", ssa
  )
  
  
  # fails with all of SSURGO
  res <- suppressMessages(SDA_query(sql))
  
  return(res)
  
}

