######################################### Plotting movement of ice islands ################################ 
f.plot <- function(con, df) {
  source('f.coast.R')
  source('f.igraph.R')
  
  row.names(df) -> df$gid
  # Transforming polygons in to SpatialPolygonsDataFrame
  df_sp <- lapply(seq(nrow(df)), FUN=function(x) readWKT(df$geom1[x], df$gid[x]))
  df_sp <- do.call(rbind, df_sp)
  df_sp <- SpatialPolygonsDataFrame(df_sp, df)
  # assining original proj (LCC)
  proj4string(df_sp) = CRS("+proj=lcc +lat_1=77 +lat_2=49 +lat_0=40 +lon_0=-100, ellps=WGS84")
  
  # make a point shapefile of ice island centroids
  points_c <- lapply(seq(length(df_sp)), FUN=function(x) gCentroid(df_sp[x,]))
  points_c <- do.call(rbind, points_c)
  
  # poly@data is the attribute table that belongs to the shapefile
  df_sh = data.frame(df_sp@data,coordinates(points_c))
  #df_sh <- na.omit(df_sh) # Remove NAs (there might actually never be any)
  
  df_g <- df_sp@data
  g <- f.igraph(df_g)
  V(g)$x=df_sh$x[match(V(g)$name, df_sh$inst)]
  V(g)$y=df_sh$y[match(V(g)$name, df_sh$inst)]
  
  # Prepare extent for coastline stuff
  map_extent <- c(min(df_sp@data$centroid_x), max(df_sp@data$centroid_x), min(df_sp@data$centroid_y), max(df_sp@data$centroid_y))
  map_extent <- map_extent + 2000
  
  coast <- f.coast(con, map_extent)
  
  ### PLOT
  
  plot(coast)
  plot(g, vertex.shape="none", vertex.label="",
       edge.arrow.width=0.01, edge.arrow.size = 0.01, rescale=FALSE, add=TRUE, edge.arrow.color = V(g)$calvingyr)
  plot(df_sp, add=TRUE, col = V(g)$calvingyr)
  plot <- plot(coast, add=TRUE, col="beige")
  return(plot)
}
