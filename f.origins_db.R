###################### Returns orginal ice islands ######################################################################

#=================================== Version 2.0 =======================================================================#

########################################################################################################################
## Input: - con: Connection to database
##        - calvingyr: A single or multiple years during which the instance originated. If none are specified, 
##                      all will be used
##        - calvingloc: A single or multiple orginal calving locations. If none are specified, all will be used
#########################################################################################################################

###### From database ######
f.origins_db <- function(con, calvingyr = NULL, calvingloc = NULL, orphans = FALSE) {
  require(RPostgreSQL)
  source('f.subquery.R')
  
  # Prepare DB query
    # Form subquery
      sub_query <<- f.subquery(calvingyr, calvingloc)
     
    # Prepare full query  
    if (orphans == FALSE){
      query <- paste0("SELECT *, ST_AsText(CI2D3.geometry) as geom1,", 
                      " DENSE_RANK() OVER(PARTITION BY calvingyr ORDER BY date_trunc('week', CI2D3.scenedate::timestamp))", 
                      " as wk_num FROM CI2D3",
                      " WHERE lineage", 
                      " SIMILAR TO '%(P|S)(0|1|2)(0|1|2|3|4|5|6|7|8|9)' ",
                      " AND lineage NOT LIKE 'YYYYMMDD!_HHMMSS!_SN!_#!____' ESCAPE '!'",
                      sub_query,  
                      " OR lineage IS NULL ", sub_query)
    }   
    else if (orphans == TRUE) {
      query <- paste0("SELECT *, ST_AsText(CI2D3.geometry) as geom1,", 
                      " DENSE_RANK() OVER(PARTITION BY calvingyr ORDER BY date_trunc('week', CI2D3.scenedate::timestamp))", 
                      " as wk_num FROM CI2D3",
                      " WHERE lineage",  
                      " SIMILAR TO '%(P|S)(0|1|2)(0|1|2|3|4|5|6|7|8|9)' ", sub_query,
                      "OR lineage LIKE 'YYYYMMDD!_HHMMSS!_SN!_#!____' ESCAPE '!'",
                      sub_query,  
                      " OR lineage IS NULL ", sub_query)
    }  
    
  # Query db
    orig <- dbGetQuery(con, query)
  
  return(orig)
}
