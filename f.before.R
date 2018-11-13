ng#### To get all instances before an instance ##############################
## Input: - g: object of class igraph 
##        - inst: ending instance (vertex) 
## Output: Object of class igraph 
##########################################################################


f.before <- function(g, inst) {
  library(igraph)
  v_before <- subcomponent(g, inst, mode = "in")
  g_before <- induced_subgraph(g, v_before)
  return(g_before)
}
