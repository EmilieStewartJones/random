##### Combine the 2 #####
# fract_bf + fract_af does not equal fract because of overlap.

f.fract <- function(con, type = "all", calvingyr = NULL, calvingloc = NULL, wk_num = NULL) {
  require(RPostgreSQL)
  #source('f.subquery.R')
  
  # Form subquery
    sub_query <- f.subquery(calvingyr, calvingloc)
  
  if (type == "all"){
    # Query db for all instances just after fracturing  
    query <- paste0("SELECT *, ST_AsText(shapefiles_qc_2013.wkb_geometry) as geom1,", 
                    " DENSE_RANK() OVER(PARTITION BY calvingyr ORDER BY date_trunc('week', shapefiles_qc_2013.scenedate::timestamp))", 
                    " as wk_num FROM shapefiles_qc_2013",
                    " WHERE motherinst IN (SELECT motherinst FROM shapefiles_qc_2013 WHERE",
                    " motherinst NOT LIKE 'YYYYMMDD!_HHMMSS!_SN!_#!____' ESCAPE '!'",
                    " AND motherinst NOT SIMILAR TO '%(P|S)(0|1|2)(0|1|2|3|4|5|6|7|8|9)'",
                    sub_query,
                    " GROUP BY motherinst HAVING COUNT(*) > 1)",
                    " OR inst IN (SELECT motherinst FROM shapefiles_qc_2013 ",
                    " GROUP BY motherinst HAVING COUNT(*) > 1)",
                    sub_query)
  }
    else if (type =="before") {
      # Query db for all instances just before fracturing  
      query <- paste0("SELECT *, ST_AsText(shapefiles_qc_2013.wkb_geometry) as geom1,", 
                      " DENSE_RANK() OVER(PARTITION BY calvingyr ORDER BY date_trunc('week', shapefiles_qc_2013.scenedate::timestamp))", 
                      " as wk_num FROM shapefiles_qc_2013",
                      " WHERE inst IN (SELECT motherinst FROM shapefiles_qc_2013 ",
                      " GROUP BY motherinst HAVING COUNT(*) > 1)", sub_query)
    }
    else if (type == "after") {
      # Query db for all instances just after fracturing  
      query <- paste0("SELECT *, ST_AsText(shapefiles_qc_2013.wkb_geometry) as geom1,", 
                      " DENSE_RANK() OVER(PARTITION BY calvingyr ORDER BY date_trunc('week', shapefiles_qc_2013.scenedate::timestamp))", 
                      " as wk_num FROM shapefiles_qc_2013",
                      " WHERE motherinst IN (SELECT motherinst FROM shapefiles_qc_2013 WHERE ",
                      " motherinst NOT LIKE 'YYYYMMDD!_HHMMSS!_SN!_#!____' ESCAPE '!'",
                      " AND motherinst NOT SIMILAR TO '%(P|S)(0|1|2)(0|1|2|3|4|5|6|7|8|9)'",
                      " GROUP BY motherinst HAVING COUNT(*) > 1)", sub_query)
    }

    fract <- dbGetQuery(con, query)
    
  # Subset weeks of interest from dataframe
    if (is.null(wk_num)){
      fract <- fract
    }
    else fract <- fract[fract$wk_num >= wk_num[1] & fract$wk_num <= wk_num[2], ]
  
  return(fract)
}

