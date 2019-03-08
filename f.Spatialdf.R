####### Function that creates spatial polygons dataframe from queried table ###################

#=================================== Version 2.0 =============================================#

###############################################################################################
## Input: - Dataframe with inst, motherinst and geom1 columns  
## Output: - A SpatialPolygonsDataFrame of ice islands
###############################################################################################

f.Spatialdf <- function(df) {
  # Add a column with an id number
   df$gid <- row.names(df) 

  # Transforming polygons into SpatialPolygonsDataFrame
    df_sp <- lapply(seq(nrow(df)), FUN=function(x) readWKT(df$geom1[x], df$gid[x]))
    df_sp <- do.call(rbind, df_sp)
    df_sp <- SpatialPolygonsDataFrame(df_sp, df)
    
  # assining original proj 
    # WGS 
    proj4string(df_sp) = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
  
  return(df_sp)
}

