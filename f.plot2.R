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
  
  # Define functions
    gClip <- function(shp, bb){
      if(class(bb) == "matrix") b_poly <- as(extent(as.vector(t(bb))), "SpatialPolygons")
      else b_poly <- as(extent(bb), "SpatialPolygons")
      shp <- gBuffer(shp, byid=TRUE, width=0)
      gIntersection(shp, b_poly, byid = TRUE)
    }
    
  # Subset the spatial polygons dataframe so that it only includes the islands of g
    df_sp <- df_sp[which(df_sp@data$inst %in% V(g)$name),]
  
  # Plotting with or without coastline
    # With coastline
      if (coastline == TRUE) {
        print("Preparing coastline data")
        # Bring in coastline data
          coast <- f.coast(con, coastm)
        
        # crop coastline map
          map_extent <- c(min(df_sp@data$centroid_x) - 25000, max(df_sp@data$centroid_x) + 25000,
                          min(df_sp@data$centroid_y) - 25000, max(df_sp@data$centroid_y) + 25000)
          print("-----> Clipping coastline map to map extent")
          if (is.null(map_extent)) crop <- extent(0, 2000000, 2800000, 5000000)
          else crop <- extent(map_extent[1], map_extent[2], map_extent[3], map_extent[4])
          
          coast <- gClip(coast, crop)
        
        # Plot
          print("Plotting")
          par(mar=c(1,1,1,1))
          plot(coast) # plot coastline
          plot(g, vertex.shape="none", vertex.label="",
               edge.arrow.width=0.4, edge.arrow.size = 0.3, rescale=FALSE, add=TRUE)#, vertex.label = V(g)$inst, vertex.label.cex = 0.5, vertex.label.color = 'black') # plot igraph
          plot(df_sp, add=TRUE, col = "blue", border= "black") # Plot ice island polygons 
          plot <- plot(coast, add=TRUE, col="beige")
      }
    
    # Without coastline 
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
