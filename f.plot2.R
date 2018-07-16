######################################### Plotting movement of ice islands ################################ 
## Input: - Connection to database
##        - A spatially referenced igraph object 
##        - A spatial polygons dataframe that contains all the polygons of the igraph.
##               - It may contain other polygons too, but these will not appear in the plot
## Output: - A plot of ice islands and their edges with the coastline
###########################################################################################################
### TO DO: Write seperate function that creates shapefiles

f.plot2 <- function(con, g, df_sp) {
  source('f.coast.R')
  library(raster)
  library(sp)
  
  # Subset the spatial polygons dataframe so that it only includes the islands of g
    df_sp <- df_sp[which(df_sp@data$inst %in% V(g)$name),]
  
  # Prepare extent for coastline stuff
    map_extent <- c(min(df_sp@data$centroid_x) - 20000, max(df_sp@data$centroid_x) + 20000,
                  min(df_sp@data$centroid_y) - 20000, max(df_sp@data$centroid_y) + 20000)
  
  # Bring in coastline
    coast <- f.coast(con, map_extent)
  
  # Plot
    par(mar=c(1,1,1,1))
    plot(coast)  # Plot coastline
    plot(g, vertex.shape="none", vertex.label="",
       edge.arrow.width=0.01, edge.arrow.size = 0.01, rescale=FALSE, add=TRUE)  # Plot edges
    plot(df_sp, add=TRUE, col = "blue")  # Plot the polygons of the ice islands
    plot <- plot(coast, add=TRUE, col="beige")   
  
  return(plot)
}
