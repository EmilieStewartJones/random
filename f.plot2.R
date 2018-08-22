######################################### Plotting movement of ice islands ################################ 
## Input: - Connection to database
##        - A spatially referenced igraph object 
##        - A spatial polygons dataframe that contains all the polygons of the igraph.
##               - It may contain other polygons too, but these will not appear in the plot
## Output: - A plot of ice islands and their edges with the coastline
###########################################################################################################
### TO DO: - Write seperate function that creates shapefiles
#          - Make prettier

f.plot2 <- function(con, g, df_sp, coastline = FALSE, coastm = "fine") {
  source('f.coast.R')
  library(raster)
  library(sp)
  
  # Subset the spatial polygons dataframe so that it only includes the islands of g
    df_sp <- df_sp[which(df_sp@data$inst %in% V(g)$name),]
  
  # Bring in cropped coastline and plot
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
    
  return(plot)
}
