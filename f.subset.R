######## Query subsetted dataframe ########
# calvingyr: the year of calving event. If none are specified, all will be used
# wk_num: - requires a vector of 2, where the 1st element is the earliest week and the 2nd is the latest week
#         - If nothing is given, all weeks will be taken 

f.subset <- function(con, calvingyr = NULL, wk_num = NULL) {
  if (is.null(calvingyr)) {
    yr_query <- NULL
  }
  else yr_query <- paste0("WHERE calvingyr = '", paste0(calvingyr, collapse = "' OR calvingyr = '"), "'")
  
  query <- paste0("SELECT *, ST_AsText(shapefiles_qc_2013.wkb_geometry) as geom1, ",
                  "DENSE_RANK() OVER(PARTITION BY calvingyr ORDER BY date_trunc('week', shapefiles_qc_2013.scenedate::timestamp)) ",
                  "as wk_num FROM shapefiles_qc_2013 ", yr_query) 
  table <- dbGetQuery(con, query)
  if (is.null(wk_num)){
    table <- table
  }
  else table <- table[table$wk_num >= wk_num[1] & table$wk_num <= wk_num[2], ]
  return(table)
}
