################## Finds all terminal ice islands directly from DB ###########################

#=================================== Version 2.0 =============================================#

##############################################################################################
## Input: - con: connection to database
##        - calvingyr: year of orginal calvinf event. Default is "2008"
##        - calvingloc: location of initial calving event default is "PG"
## Ouput: - A subsetted dataframe with only the terminal instances
###############################################################################################

f.terminal_db <- function(con, calvingyr = NULL, calvingloc = NULL) {
  require(RPostgreSQL)
  source('f.subquery.R')
  
  # Prepare DB queries
    # Form subquery
      sub_query <- f.subquery(calvingyr, calvingloc)
      
    # Main query  
      query <- paste0("SELECT * FROM CI2D3 WHERE inst NOT IN ",
                    "(SELECT inst FROM CI2D3 where inst IN (SELECT lineage FROM CI2D3)) ",
                     sub_query)
  
  # Query db and create character list
    term <- dbGetQuery(con, query)
  
  return(term)
}


