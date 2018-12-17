#################### Create spatial points dataframe ################################

f.spatial_point <- function(df) {
  coordinates(df) <- ~centroid_x+centroid_y
  # Assining original proj (LCC)
  proj4string(df) = CRS("+proj=lcc +lat_1=77 +lat_2=49 +lat_0=40 +lon_0=-100, ellps=WGS84")
  return(df)
}



