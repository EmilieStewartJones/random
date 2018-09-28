#### To get all instances after an instance ##############################
## Input: - g: object of class igraph 
##        - inst: starting instance (vertex) 
## Output: Object of class igraph 
##########################################################################


f.after <- function(g, inst) {
  library(igraph)
  v_after <- subcomponent(g, inst, mode = "out")
  g_after <- induced_subgraph(g, v_after)
  return(g_after)
}
