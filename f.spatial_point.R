#################### Create spatial points dataframe #########################################

#=================================== Version 2.0 =============================================#

##############################################################################################

f.spatial_point <- function(df) {
  coordinates(df) <- ~lon+lat
  # Assining original proj (LCC)
  proj4string(df) = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")

  df@data$lon <- df@coords[,"lon"]
  df@data$lat <- df@coords[,"lat"]
  return(df)
}



