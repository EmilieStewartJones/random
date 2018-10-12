###################### Returns orginal ice islands ############################################################################
## Input: - con: Connection to database
##        - calvingyr: A single or multiple years during which the instance originated. If none are specified, all will be used
##        - calvingloc: A single or multiple orginal calving locations. If none are specified, all will be used
################################################################################################################################

###### From database ######
f.origins_db <- function(con, calvingyr = NULL, calvingloc = NULL, orphans = TRUE) {
  require(RPostgreSQL)
  source('f.subquery.R')
  
  # Prepare DB query
    # Form subquery
      sub_query <- f.subquery(calvingyr, calvingloc)
     
    # Prepare full query  
    if (orphans == FALSE){
      query <- paste0("SELECT *, ST_AsText(shapefiles_qc_2013.wkb_geometry) as geom1,", 
                      " DENSE_RANK() OVER(PARTITION BY calvingyr ORDER BY date_trunc('week', shapefiles_qc_2013.scenedate::timestamp))", 
                      " as wk_num FROM shapefiles_qc_2013",
                      " WHERE motherinst", 
                      " SIMILAR TO '%(P|S)(0|1|2)(0|1|2|3|4|5|6|7|8|9)' ",
                      " AND motherinst NOT LIKE 'YYYYMMDD!_HHMMSS!_SN!_#!____' ESCAPE '!'",
                      sub_query,  
                      " OR motherinst IS NULL ", sub_query)
    }   
    else if (orphans == TRUE) {
      query <- paste0("SELECT *, ST_AsText(shapefiles_qc_2013.wkb_geometry) as geom1,", 
                      " DENSE_RANK() OVER(PARTITION BY calvingyr ORDER BY date_trunc('week', shapefiles_qc_2013.scenedate::timestamp))", 
                      " as wk_num FROM shapefiles_qc_2013",
                      " WHERE motherinst",  
                      " SIMILAR TO '%(P|S)(0|1|2)(0|1|2|3|4|5|6|7|8|9)' ",
                      "OR motherinst LIKE 'YYYYMMDD!_HHMMSS!_SN!_#!____' ESCAPE '!'",
                      sub_query,  
                      " OR motherinst IS NULL ", sub_query)
    }  
    
  # Query db
    orig <- dbGetQuery(con, query)
  
  return(orig)
}
