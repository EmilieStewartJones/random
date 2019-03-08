############################# Plotting of dataframe ##########################################

#=================================== Version 2.0 =============================================#

##############################################################################################

f.plot_df <- function(object, coastline = NULL, title = "", col = "blue", legend=FALSE, title_leg = ""){
  par(mar=c(1,1,1.5,1))
  ############################ Functions ##############################
  ### Plotting spatial points
  plot_pnt <- function(object, add, legend){
    plot(object, col= col, pch = 20, add=add, main=title)
    if (legend == TRUE){
      legend("bottomleft", legend=unique(col), col= unique(col), pch = 16, title=title_leg)
    }
    else if (legend == FALSE) {}
  }
  
  ### Plotting spatial polygons
  plot_pol <- function(object, add, legend){
    plot(object, col = col, border= "black", add=add, main=title)
    if (legend == TRUE){
      legend("topright", legend=unique(col), col= unique(col), pch = 16, title=title_leg)
    }
    else if (legend == FALSE) {}
  }
  ############################ Coastline ##############################
  if (!is.null(coastline)){
    print("Preparing coastline data")
    
    # crop coastline map
    map_extent <- c(min(object@data$lon) - 25000, max(object@data$lon) + 25000,
                    min(object@data$lat) - 25000, max(object@data$lat) + 25000)
    print("-----> Clipping coastline map to map extent")
    if (is.null(map_extent)) crop <- extent(0, 2000000, 2800000, 5000000)
    else crop <- extent(map_extent[1], map_extent[2], map_extent[3], map_extent[4])
    
    coast <- gClip(coastline, crop)
  }
  ############################ Type #######################################
  if (!is.null(coastline)){
    if (class(object) == "SpatialPolygonsDataFrame"){
      ## PLOT ##
      print("Plotting")
      plot(coast, col="beige") # plot coastline
      plot<- plot_pol(object, add=TRUE, legend)
      #plot <- plot(coast, add=TRUE, col="beige")
    }
    else if (class(object)== "SpatialPointsDataFrame"){
      print("Plotting")
      plot(coast, col = "beige", main = title) # plot coastline
      plot <- plot_pnt(object, add=TRUE, legend) 
    }
  }
  else {
    if (class(object) == "SpatialPolygonsDataFrame"){
      ## PLOT ##
      print("Plotting")
      plot <- plot_pol(object, add=FALSE, legend)
    }
    else if (class(object)== "SpatialPointsDataFrame"){
      print("Plotting")
      plot <- plot_pnt(object, add=FALSE, legend) 
    }
  }
}

# as.factor(object$calvingyr)