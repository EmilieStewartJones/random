####################### THE plotting function #################################################

#=================================== Version 2.0 =============================================#

##############################################################################################
# Grid and tree require igraph and not igraph_s
# Tree does not work

f.plot_igraph <- function(g, type, coastline = NULL, col = "blue", size = 1, coords, title = ""){
  ############################ Functions ##############################
  ### Plotting spatial igraph
  plot_g <- function(g){
    plot(g, add=TRUE, vertex.shape="none", vertex.label="",
         edge.arrow.width=1, edge.arrow.size = 0.3, rescale=FALSE, 
         vertex.label = V(g)$inst, vertex.label.cex = 1, vertex.label.color = 'black')
  }
  ### Plotting spatial points
  plot_pnt <- function(coords, add, size){
    plot(coords, col= col, pch = 21, add=add, cex=size, main=title)
  }
  
  ### Plotting spatial polygons
  plot_pol <- function(coords, add){
    plot(coords, col = "blue", border= "black", add=add, main = title)
  }
  
  ############################ Coastline ##############################
if (!is.null(coastline)){
  print("Preparing coastline data")
  
  # crop coastline map
  map_extent <- c(min(coords@data$lon) - 25000, max(coords@data$lon) + 25000,
                  min(coords@data$lat) - 25000, max(coords@data$lat) + 25000)
  print("-----> Clipping coastline map to map extent")
  if (is.null(map_extent)) crop <- extent(0, 2000000, 2800000, 5000000)
  else crop <- extent(map_extent[1], map_extent[2], map_extent[3], map_extent[4])
  
  coast <- gClip(coastline, crop)
}
  
  ############################ Type ###################################  
  if (type == "tree"){
    print("Plotting")
    plot(g, edge.arrow.size=0.3, vertex.frame.color = "white", 
         vertex.color=rbPal(10)[as.numeric(cut(sqrt(V(g)$area),breaks = 10))], 
         vertex.size= degree(g)*2,
         #vertex.color=rbPal(10)[as.numeric(cut(degree(g)*2,breaks = 10))], vertex.size= sqrt(V(g)$area)*1.5, 
         edge.curved = 0.1, vertex.label.cex = 0.5, layout = layout_as_tree, main=title)
  }
  else if (type == "grid"){
    print("Plotting")
    plot(g, layout_on_grid(g, width = 0, height = 0, dim = 2), edge.arrow.size=0.3,
         vertex.frame.color = "white", 
         vertex.color=rbPal(10)[as.numeric(cut(sqrt(V(g)$area),breaks = 10))], 
         vertex.size= degree(g)*2,
         #vertex.color=rbPal(10)[as.numeric(cut(degree(g)*2,breaks = 10))], vertex.size= sqrt(V(g)$area)*1.5, 
         edge.curved = 0.1, vertex.label=NA, vertex.label.cex = 0.5, main = title)
  }
  else if (type == "spatial"){
    if (!is.null(coastline)){
      
      if (class(coords) == "SpatialPolygonsDataFrame"){
        ## PLOT ##
        print("Plotting")
        par(mar=c(1,1,1,1))
        plot(coast) # plot coastline
        plot_pol(coords, add=TRUE)
        plot_g(g)
        plot <- plot(coast, add=TRUE, col="beige")
      }
      else if (class(coords)== "SpatialPointsDataFrame"){
        print("Plotting")
        par(mar=c(1,1,1,1))
        plot(coast) # plot coastline
        plot_pnt(coords, add=TRUE, size) 
        plot_g(g)
        #legend("bottomleft", legend=as.factor(unique(object$calvingyr)), col= as.factor(unique(object$calvingyr)), pch = 19, title="Year")
        plot <- plot(coast, add=TRUE, col="beige")
      }
    }
    else {
      if (class(coords) == "SpatialPolygonsDataFrame"){
        ## PLOT ##
        print("Plotting")
        par(mar=c(1,1,1,1))
        plot_pol(coords, add=FALSE)
        plot <- plot_g(g)
      }
      else if (class(coords)== "SpatialPointsDataFrame"){
        print("Plotting")
        plot_pnt(coords, add=FALSE, size) 
        plot <- plot_g(g)
        #legend("bottomleft", legend=as.factor(unique(object$calvingyr)), col= as.factor(unique(object$calvingyr)), pch = 19, title="Year")
      }
    }
  }
}