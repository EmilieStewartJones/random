######################################### Plotting movement of ice islands ################################ 

f.plot <- function(con, df) {
  source('f.coast.R')
  source('f.igraph_s.R')
  library(raster)
  library(sp)
  
  g <- f.igraph_s(df)
  
  # Prepare extent for coastline stuff
  map_extent <- c(min(df_sp@data$centroid_x) - 20000, max(df_sp@data$centroid_x) + 20000,
                  min(df_sp@data$centroid_y) - 20000, max(df_sp@data$centroid_y) + 20000)
  
  # Bring in coastline
  coast <- f.coast(con, map_extent)
  
  ### Create shapefiles
  shapefile(coast, "coast.shp", overwrite = TRUE)
  shapefile(df_sp, "polygons.shp", overwrite = TRUE)
  
  ### PLOT ##########
  par(mar=c(1,1,1,1))
  plot(coast)
  plot(g, vertex.shape="none", vertex.label="",
       edge.arrow.width=0.01, edge.arrow.size = 0.01, rescale=FALSE, add=TRUE)
  plot(df_sp, add=TRUE, col = "blue")
  plot <- plot(coast, add=TRUE, col="beige")
  
  return(plot)
}
