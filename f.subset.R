################### Function for querying the database for a subsetted dataframe #######################################
## Input: - calvingyr: A single or multiple years during which the instance originated. If none are specified, all will be used
##        - calvingloc: A single or multiple orginal calving locations. If none are specified, all will be used
##        - wk_num: - requires a vector of 2, where the 1st element is the earliest week and the 2nd is the latest week
##                  - If nothing is given, all weeks will be taken 
##        - size: - requires a vector of 2, where the 1st element is the smallest area (Km2) and the 2nd is the latest area (km2)
##                - If nothing is given, all sizes will be taken 
##        - loc_x: - requires a vector of 2, where the 1st element is the min x coord (UTM) and the 2nd is the max x coord (UTM)
##                 - If nothing is given, all islands will be taken 
##        - loc_y: - requires a vector of 2, where the 1st element is the min y coord (UTM) and the 2nd is the max y coord (UTM)
##                 - If nothing is given, all islands will be taken 
## Output: - A dataframe with all columns and a subset of rows  
########################################################################################################################


f.subset <- function(con, calvingyr = NULL, calvingloc = NULL, wk_num = NULL, size = NULL, loc_x = NULL, loc_y = NULL) {
  
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
      
    # Prepare size query
      if (is.null(size)) {
        size_query <- NULL
      }
      else size_query <- paste0(" poly_area >= ", size[1], " AND poly_area <= ", size[2] )
      
    # Prepare loc_x query
      if (is.null(loc_x)) {
        loc_x_query <- NULL
      }
      else loc_x_query <- paste0(" centroid_x >= ", loc_x[1], " AND centroid_x <= ", loc_x[2] )
      
    # Prepare loc_y query
      if (is.null(loc_y)) {
        loc_y_query <- NULL
      }
      else loc_y_query <- paste0(" centroid_y >= ", loc_y[1], " AND centroid_y <= ", loc_y[2] )
      
    # Prepare total subquery
      if (is.null(calvingyr) & is.null(calvingloc) & is.null(size) & is.null(loc_x) & is.null(loc_y)){
        sub_query <- NULL
      }
      else sub_query <- paste0(" WHERE", paste0(c(yr_query, loc_query, size_query, loc_x_query, loc_y_query), collapse = " AND "))
    
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
