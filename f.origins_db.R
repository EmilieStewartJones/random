###################### Returns orginal ice islands ############################################################################
## Input: - con: Connection to database
##        - calvingyr: A single or multiple years during which the instance originated. If none are specified, all will be used
##        - calvingloc: A single or multiple orginal calving locations. If none are specified, all will be used
################################################################################################################################
# Includes orphans and instances with motherinst like _P08, _P12, _P13, _S12...

###### From database####
f.origins_db <- function(con, calvingyr = NULL, calvingloc = NULL) {
  require(RPostgreSQL)
  
  # Prepare DB query
    # Prepare calvingyr query
      if (is.null(calvingyr)) {
        yr_query <- NULL
      }
      else yr_query <- paste0("AND calvingyr = ANY (SELECT calvingyr WHERE calvingyr = '",
                              paste0(calvingyr, collapse = "' OR calvingyr = '"), "')")
      
    # Prepare calvingloc query
      if (is.null(calvingloc)) {
        loc_query <- NULL
      }
      else loc_query <- paste0("AND calvingloc = ANY (SELECT calvingloc WHERE calvingloc = '",
                               paste0(calvingloc, collapse = "' OR calvingloc = '"), "')")
      
    # Prepare total subquery
      sub_query <- paste0(yr_query, loc_query)
    
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
