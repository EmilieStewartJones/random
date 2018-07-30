#################### Function to create spatially refrenced igraph object #####################
## Input: - Dataframe queried from database with inst, motherinst and geom1 columns 
## Output:   - spatially referenced igraph object
##           - Spatial polygons dataframe
###############################################################################################
# TO DO: Find a way to return both the igraph and the spatial polygons dataframe
#              - Put spatial polygons dataframe into igraph object??

f.igraph_s <- function(df) {
  require(igraph)
  require(sp)
  require(rgeos)
  require(plyr)
  source('f.Spatialdf.R')
  
  # Make spatial polygons dataframe 
   df_sp <<- f.Spatialdf(df)
   
  # Make edgelist 
    df_g <- df_sp@data
    edgelist <- data.frame(df_g$motherinst, df_g$inst) 
    colnames(edgelist) <- c("motherinst", "inst")
    edgelist <- as.data.frame(edgelist[edgelist$motherinst %in% edgelist$inst,])
  
  # Creating attribute table for vertices
    undescribedmothers <- na.omit(data.frame(unique(df_g$motherinst[!(df_g$motherinst %in% df_g$inst)]),
                                          stringsAsFactors = F))  # these are the mothers that are referred to in the edgelist but have no inst
    vattrib_df <- cbind(df_g$inst, df_g[,names(df_g)!='inst'], stringsAsFactors =F)  # make a dataframe that starts with the vertex name and matches the inst in edgelist
    names(vattrib_df)[1] <- 'inst'
    names(undescribedmothers)[1] <- 'inst'
    vattrib_df <- rbind.fill(vattrib_df,undescribedmothers)  # Now the undescribed mothers are in the vertices attribute table without any attributes (because they don't have an inst)
  
  # Make a point shapefile of ice island centroids
    points_c <- lapply(seq(length(df_sp)), FUN=function(x) gCentroid(df_sp[x,]))
    points_c <- do.call(rbind, points_c)
    df_sh <- data.frame(df_sp@data,coordinates(points_c))
   
  # Creating object of class igraph
    g <- graph_from_data_frame(edgelist, vertices = vattrib_df) #igraph function to make a graph using edges and assign attribs to vertices
    V(g)$x=df_sh$x[match(V(g)$name, df_sh$inst)]
    V(g)$y=df_sh$y[match(V(g)$name, df_sh$inst)]
  
  return(g)
}