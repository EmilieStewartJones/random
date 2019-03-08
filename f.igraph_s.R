#################### Function to create spatially refrenced igraph object #####################

#=================================== Version 2.0 =============================================#

f.igraph_s <- function(df) {
  require(igraph)
  require(sp)
  require(rgeos)
  require(plyr)
  source('new_f.spatial_point.R')

  
  # Make edgelist 
    edgelist <- data.frame(df$lineage, df$inst) 
    colnames(edgelist) <- c("lineage", "inst")
    edgelist <- as.data.frame(edgelist[edgelist$lineage %in% edgelist$inst,])
  
  # Creating attribute table for vertices
    vattrib_df <- cbind(df$inst, df[,names(df)!='inst'], stringsAsFactors =F)  # make a dataframe that starts with the vertex name and matches the inst in edgelist
    names(vattrib_df)[1] <- 'inst'
  
  # Creating object of class igraph
    g <- graph_from_data_frame(edgelist, vertices = vattrib_df) #igraph function to make a graph using edges and assign attribs to vertices
  
  # Make spatial points dataframe 
    df_spoint <- f.spatial_point(df)
  
  # Add spatial points df to igraph
    V(g)$x=df_spoint@data$lon[match(V(g)$name, df_spoint@data$inst)]
    V(g)$y=df_spoint@data$lat[match(V(g)$name, df_spoint@data$inst)]
  
  return(g)
}



