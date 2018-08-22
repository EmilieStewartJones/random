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
  
  # Define functions
    gClip <- function(shp, bb){
      if(class(bb) == "matrix") b_poly <- as(extent(as.vector(t(bb))), "SpatialPolygons")
      else b_poly <- as(extent(bb), "SpatialPolygons")
      shp <- gBuffer(shp, byid=TRUE, width=0)
      gIntersection(shp, b_poly, byid = TRUE)
    }
  
  # Create spatially referenced igraph object
    print("Creating Igraph object from dataframe")
    g <- f.igraph_s(df)
  
  # Plotting with or without coastline
    # With coastline
      if (coastline == TRUE) {
        print("Preparing coastline data")
        # Bring in coastline data
          coast <- f.coast(con, coastm)
          
        # crop map
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

  # Create shapefiles
    #shapefile(coast, "coast.shp", overwrite = TRUE)
    #shapefile(df_sp, "polygons.shp", overwrite = TRUE)

  return(plot)
}
