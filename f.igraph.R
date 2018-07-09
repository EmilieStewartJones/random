######################## Function that creates an igraph object ##############################
##### Input: 'table' with motherinst, inst and any other attributes ####
##### Output: igraph object that includes all attributes ####
##############################################################################################

f.igraph <- function(table){
  library(igraph)
  edgelist <- data.frame(table$motherinst, table$inst) 
  colnames(edgelist) <- c("motherinst", "inst")
  edgelist <- as.data.frame(edgelist[edgelist$motherinst %in% edgelist$inst,])
  
  # Creating attribute table for vertices
  undescribedmothers = na.omit(data.frame(unique(table$motherinst[!(table$motherinst %in% table$inst)]),
                                          stringsAsFactors = F))  # these are the mothers that are referred to in the edgelist but have no inst
  vattrib_df = cbind(table$inst, table[,names(table)!='inst'], stringsAsFactors =F)  # make a dataframe that starts with the vertex name and matches the inst in edgelist
  names(vattrib_df)[1] = 'inst'
  names(undescribedmothers)[1] = 'inst'
  vattrib_df = rbind.fill(vattrib_df,undescribedmothers)  # Now the undescribed mothers are in the vertices attribute table without any attributes (because they don't have an inst)
  
  # Creating object of class igraph
  g <- graph_from_data_frame(edgelist, vertices = vattrib_df) #igraph function to make a graph using edges and assign attribs to vertices
  return(g)
}