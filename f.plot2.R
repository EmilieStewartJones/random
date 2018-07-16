######################################### Plotting movement of ice islands ################################ 
# Takes a spatially referenced igraph object and a spatial polygons dataframe that contains all the polygons of the igraph

f.plot2 <- function(con, g, df_sp) {
  source('f.coast.R')
  library(raster)
  library(sp)
  
  
  df_sp <- df_sp[which(df_sp@data$inst %in% V(g)$name),]
  
  # Prepare extent for coastline stuff
  map_extent <- c(min(df_sp@data$centroid_x) - 20000, max(df_sp@data$centroid_x) + 20000,
                  min(df_sp@data$centroid_y) - 20000, max(df_sp@data$centroid_y) + 20000)
  
  # Bring in coastline
  coast <- f.coast(con, map_extent)
  
  ### PLOT ##########
  par(mar=c(1,1,1,1))
  plot(coast)
  plot(g, vertex.shape="none", vertex.label="",
       edge.arrow.width=0.01, edge.arrow.size = 0.01, rescale=FALSE, add=TRUE)
  plot(df_sp, add=TRUE, col = "blue")
  plot <- plot(coast, add=TRUE, col="beige")
  
  return(plot)
}
