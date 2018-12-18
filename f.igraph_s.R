#################### Function to create spatially refrenced igraph object #####################
## Input: - Dataframe queried from database with inst, motherinst and geom1 columns 
## Output:   - spatially referenced igraph object
##           - Spatial polygons dataframe
###############################################################################################
# TO DO: Find a way to return both the igraph and the spatial polygons dataframe
#              - Put spatial polygons dataframe into igraph object??
# Creating the spatial points shapefile of centroids is redundant because that info already exists in the dataframe

f.igraph_s <- function(df) {
  require(igraph)
  require(sp)
  require(rgeos)
  require(plyr)
  source('f.spatial_point.R')

  
  # Make edgelist 
    edgelist <- data.frame(df$motherinst, df$inst) 
    colnames(edgelist) <- c("motherinst", "inst")
    edgelist <- as.data.frame(edgelist[edgelist$motherinst %in% edgelist$inst,])
  
  # Creating attribute table for vertices
    undescribedmothers <- na.omit(data.frame(unique(df$motherinst[!(df$motherinst %in% df$inst)]),
                                           stringsAsFactors = F))  # these are the mothers that are referred to in the edgelist but have no inst
    vattrib_df <- cbind(df$inst, df[,names(df)!='inst'], stringsAsFactors =F)  # make a dataframe that starts with the vertex name and matches the inst in edgelist
    names(vattrib_df)[1] <- 'inst'
    names(undescribedmothers)[1] <- 'inst'
    vattrib_df <- rbind.fill(vattrib_df,undescribedmothers)  # Now the undescribed mothers are in the vertices attribute table without any attributes (because they don't have an inst)
  
  # Make spatial polygons dataframe 
    df_spoint <- f.spatial_point(df)
  
  # Creating object of class igraph
    g <- graph_from_data_frame(edgelist, vertices = vattrib_df) #igraph function to make a graph using edges and assign attribs to vertices
  
  # Add spatial points df to igraph
    V(g)$x=df_spoint@data$centroid_x[match(V(g)$name, df_spoint@data$inst)]
    V(g)$y=df_spoint@data$centroid_y[match(V(g)$name, df_spoint@data$inst)]
  
  return(g)
}



