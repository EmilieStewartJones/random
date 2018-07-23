################## Finds all terminal ice islands directly from DB ####################################################
## Input: - con: connection to database
##        - calvingyr: year of orginal calvinf event. Default is "2008"
##        - calvingloc: location of initial calving event default is "PG"
## Ouput: - A subsetted dataframe with only the terminal instances
#######################################################################################################################

f.terminal_db <- function(con, calvingyr = "2008", calvingloc = "PG") {
  require(RPostgreSQL)
  
  # Prepare DB queries
    sub_query <- paste0("calvingloc = '", calvingloc, "' AND calvingyr = '", calvingyr, "'")
    query <- paste0("SELECT * FROM shapefiles_qc_2013 WHERE inst NOT IN ",
                  "(SELECT inst FROM shapefiles_qc_2013 where inst IN (SELECT motherinst FROM shapefiles_qc_2013)) AND ",
                  sub_query)
  
  # Query db and create character list
    term <- dbGetQuery(con, query)
  
  return(term)
}
