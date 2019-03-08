################## Finds all terminal ice islands of dataframe or igraph #####################################

#=================================== Version 2.0 ============================================================#

##############################################################################################################
## Input: - object: object of class igraph or dataframe
## Ouput: - For igraph: a character list of the terminal instances
##        - For dataframe: a dataframe subsetted to the terminal instances
#############################################################################################################

# From table or igraph
f.terminal <- function(object) {
  require(igraph)
  
  # For object of class dataframe
    if (class(object) == "data.frame") {
      term <- subset(object, !(object$inst %in% object$lineage))
    } 
  
  # For object of class igraph  
    else if (class(object) == "igraph") {
      # Finds outgoing vertices
      term <- as.data.frame(names(which(sapply(sapply(V(object), function(x) neighbors(object,x,mode='out')), 
                                               length) == 0)))
      term <- levels(term[,1])
      # Removes undescribed mothers (Original instances and mothers of orphans)
      term <- subset(term, !(term %in% grep("YYYYMMDD_HHMMSS_SN_#_|_P\\d|_S\\d", term, value = TRUE)))
    }
  
  # Error when neither dataframe or igraph
    else {stop("Object is not of class 'igraph' or 'data.frame'")}
  
  return(term)
}

