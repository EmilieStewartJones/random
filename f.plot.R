######################################### Plotting movement of ice islands ################################ 
## Input: - con: connection to database
##        - df: dataframe with at the least the inst, motherinst and geom1 columns
##        - g: A spatially referenced igraph object 
##        - polygs: A spatial polygons dataframe that contains all the polygons of the igraph.
##                - It may contain other polygons too, but these will not appear in the plot
##        - coastline: 
##               - NULL: no coastline
##               - fine: fine scaled map (gshhs_f_l1_subset)
##               - low: low resolution map (gshhs_l_l1)
##               - object: a coastline map is provided 
## Output: - A plot of ice islands and their edges with or without the coastline
###########################################################################################################
## Now just need to add the non spatial plots and the possibility to plot polygons 
# Need to add to github

# Plot function combining 1, 2 and 3
f.plot <- function(con, object, polygs = NULL, coastline = NULL) {
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
  
  # Prepare igraph and SpatialPolygonsDataFrame
    if (class(object) == "data.frame") {
      # Create spatially referenced igraph object
      print("Creating Igraph object from dataframe")
      g <- f.igraph_s(object)
    }
    
    else if (class(object) == "igraph"){
      if (is.null(polygs)) {stop("Must provide SpatialPolygonsDataFrame of ice island polygons to polygs")}
      else {
        # Subset the spatial polygons dataframe so that it only includes the islands of g
        df_sp <- polygs[which(polygs@data$inst %in% V(g)$name),]
      }
    }
    
    else {stop("Object is not of class 'igraph' or 'data.frame'")}
    
  # Plotting with or without coastline
    # With coastline
    if (!is.null(coastline)){
      if (class(coastline) == "SpatialPolygons") {
        print("Preparing coastline data")
        
        # crop coastline map
        map_extent <- c(min(df_sp@data$centroid_x) - 25000, max(df_sp@data$centroid_x) + 25000,
                        min(df_sp@data$centroid_y) - 25000, max(df_sp@data$centroid_y) + 25000)
        print("-----> Clipping coastline map to map extent")
        if (is.null(map_extent)) crop <- extent(0, 2000000, 2800000, 5000000)
        else crop <- extent(map_extent[1], map_extent[2], map_extent[3], map_extent[4])
        
        coast <- gClip(coastline, crop)
      }
      
      else if (class(coastline) == "character"){
        print("Preparing coastline data")
        # Bring in coastline data
        coast <- f.coast(con, coastline)
        
        # crop map
        map_extent <- c(min(df_sp@data$centroid_x) - 25000, max(df_sp@data$centroid_x) + 25000,
                        min(df_sp@data$centroid_y) - 25000, max(df_sp@data$centroid_y) + 25000)
        print("-----> Clipping coastline map to map extent")
        if (is.null(map_extent)) crop <- extent(0, 2000000, 2800000, 5000000)
        else crop <- extent(map_extent[1], map_extent[2], map_extent[3], map_extent[4])
        
        coast <- gClip(coast, crop)
      }
      
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
    else if (is.null(coastline)) {
      # Plot
      print("Plotting")
      par(mar=c(1,1,1,1))
      plot(df_sp, col = "blue", border= "black")
      plot <- plot(g, add=TRUE, vertex.shape="none", vertex.label="",
                   edge.arrow.width=0.4, edge.arrow.size = 0.3, rescale=FALSE)#, vertex.label = V(g)$inst, vertex.label.cex = 0.5, vertex.label.color = 'black') # plot igraph
    }
    return(plot)
}



