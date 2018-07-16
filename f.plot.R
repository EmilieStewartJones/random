######################################### Plotting movement of ice islands ################################ 
## Input: - Connection to database
##        - Dataframe with at the least the inst, motherinst and geom1 columns
## Output: - A plot of ice islands and their edges with the coastline
###########################################################################################################
### Write seperate function that creates shapefiles

f.plot <- function(con, df) {
  source('f.coast.R')
  source('f.igraph_s.R')
  library(raster)
  library(sp)
  
  # Create spatially referenced igraph object
    g <- f.igraph_s(df)
  
  # Prepare map_extent for f.coast function
    map_extent <- c(min(df_sp@data$centroid_x) - 20000, max(df_sp@data$centroid_x) + 20000,
                  min(df_sp@data$centroid_y) - 20000, max(df_sp@data$centroid_y) + 20000)
  
  # Bring in cropped coastline
    coast <- f.coast(con, map_extent)
  
  # Create shapefiles
    #shapefile(coast, "coast.shp", overwrite = TRUE)
    #shapefile(df_sp, "polygons.shp", overwrite = TRUE)
  
  # plot
    par(mar=c(1,1,1,1))
    plot(coast) # plot coastline
    plot(g, vertex.shape="none", vertex.label="",
       edge.arrow.width=0.01, edge.arrow.size = 0.01, rescale=FALSE, add=TRUE) # plot igraph
    plot(df_sp, add=TRUE, col = "blue") # Plot ice island polygons 
    plot <- plot(coast, add=TRUE, col="beige")
  
  return(plot)
}
