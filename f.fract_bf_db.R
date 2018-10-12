##### Just before fracturing #####

f.fract_bf_db <- function(con, calvingyr = NULL, calvingloc = NULL) {
  require(RPostgreSQL)
  source('f.subquery.R')
  
  # Form subquery
  sub_query <- f.subquery(calvingyr, calvingloc)
  
  # Query db for all instances just before fracturing  
  query <- paste0("SELECT *, ST_AsText(shapefiles_qc_2013.wkb_geometry) as geom1,", 
                  " DENSE_RANK() OVER(PARTITION BY calvingyr ORDER BY date_trunc('week', shapefiles_qc_2013.scenedate::timestamp))", 
                  " as wk_num FROM shapefiles_qc_2013",
                  " WHERE inst IN (SELECT motherinst FROM shapefiles_qc_2013 ",
                  " GROUP BY motherinst HAVING COUNT(*) > 1)", sub_query)
  
  fract_bf <- dbGetQuery(con, query)
  
  return(fract_bf)
}
