# Create spatial points dataframe from queried table


f.Spatialdf <- function(df) {
  row.names(df) -> df$gid
  # Transforming polygons in to SpatialPolygonsDataFrame
  df_sp <- lapply(seq(nrow(df)), FUN=function(x) readWKT(df$geom1[x], df$gid[x]))
  df_sp <- do.call(rbind, df_sp)
  df_sp <- SpatialPolygonsDataFrame(df_sp, df)
  # assining original proj (LCC)
  proj4string(df_sp) = CRS("+proj=lcc +lat_1=77 +lat_2=49 +lat_0=40 +lon_0=-100, ellps=WGS84")
  return(df_sp)
}

