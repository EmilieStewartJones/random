###################### Returns orginal ice islands ############################################################################
## Input: - con: Connection to database
##        - calvingyr: A single or multiple years during which the instance originated. If none are specified, all will be used
##        - calvingloc: A single or multiple orginal calving locations. If none are specified, all will be used
################################################################################################################################
# Includes orphans and instances with motherinst like _P08, _P12, _P13, _S12...

###### From database ######
f.origins_db <- function(con, calvingyr = NULL, calvingloc = NULL) {
  require(RPostgreSQL)
  source('f.subquery.R')
  
  # Prepare DB query
    # Form subquery
      sub_query <- f.subquery(calvingyr, calvingloc)

    # Prepare full query
      query <- paste0("SELECT inst, motherinst FROM shapefiles_qc_2013 WHERE motherinst", 
                      " SIMILAR TO '%(P|S)(0|1|2)(0|1|2|3|4|5|6|7|8|9)' ",
                      sub_query,  
                      # " motherinst NOT LIKE 'YYYYMMDD!_HHMMSS!_SN!_#!____' ESCAPE '!'AND ",
                      " OR motherinst IS NULL ", sub_query)
    
  # Query db
    orig <- dbGetQuery(con, query)
  
  return(orig)
}
