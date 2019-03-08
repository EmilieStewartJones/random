###################### Returns orginal ice islands ####################################################

#=================================== Version 2.0 =====================================================#

#######################################################################################################
## Input: Object of class 'dataframe' or 'igraph'
##             - If dataframe, you can specify if origins are included or not
##             - If igraph, it does not include orphans   
## Ouput: - For igraph: a character list of the origins
##        - For dataframe: a dataframe subsetted to the origins
#######################################################################################################

#### From Igraph or table ###########
f.origins <- function(object, orphans = TRUE) {
  require(igraph)
  
  # For object of class dataframe
    if (class(object) == "data.frame") {
      if (orphans == TRUE){
        orig <- subset(object, (is.na(object$lineage) |
                                  (object$lineage %in% grep("_P\\d|_S\\d", object$lineage, value = TRUE))| 
                                  (object$lineage %in% grep("YYYYMMDD_HHMMSS_SN_#_...",
                                                            object$lineage, value = TRUE))))
      }
      if (orphans == FALSE){
        orig <- subset(object, (is.na(object$lineage) | 
                                  (object$lineage %in% grep("_P\\d|_S\\d", object$lineage, value = TRUE)) 
                                 & !(object$lineage %in% grep("YYYYMMDD_HHMMSS_SN_#_...", 
                                                              object$lineage, value = TRUE))))
      }
    }
    
  # For object of class igraph
    else if (class(object) == "igraph") {
    # Make list of original instances (does not include orphans)
      orig <- c(names(which(sapply(sapply(V(object), function(x) neighbors(object,x,mode='in')),
                                   length) == 0)))
      orig <- subset(orig, !(orig %in% grep("YYYYMMDD_HHMMSS_SN_#_...", orig, value = TRUE)))
  }
  
  # Error when neither dataframe or igraph
    else {stop("Object is not of class 'igraph' or 'data.frame'")}
  
  return(orig)
}














