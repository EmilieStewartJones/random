######################################### Plotting movement of ice islands ################################ 
## Input: - con: connection to database
##        - df: dataframe with at the least the inst, motherinst and geom1 columns
##        - coastline: if TRUE, ice islands will be plotted with coastline (default FALSE)
## Output: - A plot of ice islands and their edges with or without the coastline
###########################################################################################################
### Could Write seperate function that creates shapefiles

f.plot <- function(con, df, coastline = FALSE, coastm = "fine") {
  source('f.coast.R')
  source('f.igraph_s.R')
  library(raster)
  library(sp)
  
  # Create spatially referenced igraph object
    print("Creating Igraph object from dataframe")
    g <- f.igraph_s(df)
  
  # Bring in cropped coastline
    if (coastline == TRUE) {
      print("Preparing coastline data")
      # Prepare map_extent for f.coast function
        map_extent <- c(min(df_sp@data$centroid_x) - 25000, max(df_sp@data$centroid_x) + 25000,
                        min(df_sp@data$centroid_y) - 25000, max(df_sp@data$centroid_y) + 25000)
        coast <- f.coast(con, map_extent, coastm)
      # Plot
        print("Plotting")
        par(mar=c(1,1,1,1))
        plot(coast) # plot coastline
        plot(g, vertex.shape="none", vertex.label="",
             edge.arrow.width=0.4, edge.arrow.size = 0.3, rescale=FALSE, add=TRUE)#, vertex.label = V(g)$inst, vertex.label.cex = 0.5, vertex.label.color = 'black') # plot igraph
        plot(df_sp, add=TRUE, col = "blue", border= "black") # Plot ice island polygons 
        plot <- plot(coast, add=TRUE, col="beige")
    }
    else if (coastline == FALSE) {
      # Plot
        print("Plotting")
        par(mar=c(1,1,1,1))
        plot(df_sp, col = "blue", border= "black")
        plot <- plot(g, add=TRUE, vertex.shape="none", vertex.label="",
                edge.arrow.width=0.4, edge.arrow.size = 0.3, rescale=FALSE)#, vertex.label = V(g)$inst, vertex.label.cex = 0.5, vertex.label.color = 'black') # plot igraph
    }

  # Create shapefiles
    #shapefile(coast, "coast.shp", overwrite = TRUE)
    #shapefile(df_sp, "polygons.shp", overwrite = TRUE)

  return(plot)
}
