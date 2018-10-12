##### Just after fracturing #####

f.fract_af_db <- function(con, calvingyr = NULL, calvingloc = NULL) {
  require(RPostgreSQL)
  source('f.subquery.R')
  
  # Form subquery
  sub_query <- f.subquery(calvingyr, calvingloc)
  
  # Query db for all instances just after fracturing  
  query <- paste0("SELECT *, ST_AsText(shapefiles_qc_2013.wkb_geometry) as geom1,", 
                  " DENSE_RANK() OVER(PARTITION BY calvingyr ORDER BY date_trunc('week', shapefiles_qc_2013.scenedate::timestamp))", 
                  " as wk_num FROM shapefiles_qc_2013",
                  " WHERE motherinst IN (SELECT motherinst FROM shapefiles_qc_2013 WHERE ",
                  " motherinst NOT LIKE 'YYYYMMDD!_HHMMSS!_SN!_#!____' ESCAPE '!'",
                  " AND motherinst NOT SIMILAR TO '%(P|S)(0|1|2)(0|1|2|3|4|5|6|7|8|9)'",
                  " GROUP BY motherinst HAVING COUNT(*) > 1)", sub_query)
  fract_af <- dbGetQuery(con, query)
  
  return(fract_af)
}




