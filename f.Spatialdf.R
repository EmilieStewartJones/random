################ Function that creates spatial polygons dataframe from queried table ######################
## Input: - Dataframe with inst, motherinst and geom1 columns  
## Output: - A SpatialPolygonsDataFrame of ice islands
###########################################################################################################

f.spatial_pol <- function(df) {
  # Add a column with an id number
    row.names(df) -> df$gid

  # Transforming polygons in to SpatialPolygonsDataFrame
    df_sp <- lapply(seq(nrow(df)), FUN=function(x) readWKT(df$geom1[x], df$gid[x]))
    df_sp <- do.call(rbind, df_sp)
    df_sp <- SpatialPolygonsDataFrame(df_sp, df)
    
  # assining original proj (LCC)
    proj4string(df_sp) = CRS("+proj=lcc +lat_1=77 +lat_2=49 +lat_0=40 +lon_0=-100, ellps=WGS84")
  
  return(df_sp)
}

