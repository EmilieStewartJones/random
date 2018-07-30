################### Function for querying the database for a subsetted dataframe #######################################
## Input: - calvingyr: A single or multiple years during which the instance originated. If none are specified, all will be used
##        - calvingloc: A single or multiple orginal calving locations. If none are specified, all will be used
##        - wk_num: - requires a vector of 2, where the 1st element is the earliest week and the 2nd is the latest week
##                  - If nothing is given, all weeks will be taken 
## Output: - A dataframe with all columns and a subset of rows  
########################################################################################################################
# TO DO: Add location subseting

f.subset <- function(con, calvingyr = NULL, calvingloc = NULL, wk_num = NULL) {
  
  # Prepare DB queries
    # Prepare calving year query
      if (is.null(calvingyr)) {
        yr_query <- NULL
      }
      else yr_query <- paste0(" calvingyr = ANY (SELECT calvingyr WHERE calvingyr = '", paste0(calvingyr, collapse = "' OR calvingyr = '"), "')")
      
    # Prepare calvingloc query
      if (is.null(calvingloc)) {
        loc_query <- NULL
      }
      else loc_query <- paste0(" calvingloc = ANY (SELECT calvingloc WHERE calvingloc = '", paste0(calvingloc, collapse = "' OR calvingloc = '"), "')")
      
    # Prepare total subquery
      sub_query <- paste0(" WHERE", paste0(c(yr_query, loc_query), collapse = " AND "))
    
    # Query from database
      query <- paste0("SELECT *, ST_AsText(shapefiles_qc_2013.wkb_geometry) as geom1, ",
                      "DENSE_RANK() OVER(PARTITION BY calvingyr ORDER BY date_trunc('week', shapefiles_qc_2013.scenedate::timestamp)) ",
                      "as wk_num FROM shapefiles_qc_2013", sub_query) 
  
  # Query DB    
    table <- dbGetQuery(con, query)
  
  # Subset weeks of interest from dataframe
    if (is.null(wk_num)){
      table <- table
    }
    else table <- table[table$wk_num >= wk_num[1] & table$wk_num <= wk_num[2], ]
    
  return(table)
}
