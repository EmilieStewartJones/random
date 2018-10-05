###################### Returns orginal ice islands ##########################################################################
## Input: Object of class 'dataframe' or 'igraph'
## Ouput: - For igraph: a character list of the origins
##        - For dataframe: a dataframe subsetted to the origins
#############################################################################################################################
# Includes orphans and instances with motherinst like _P08, _P12, _P13, _S12...

#### From Igraph or table ###########
f.origins <- function(object) {
  require(igraph)
  
  # For object of class dataframe
    if (class(object) == "data.frame") {
      orig <- subset(object, (is.na(object$motherinst) | (object$motherinst %in% grep("_P\\d|_S\\d", object$motherinst, value = TRUE))| 
                                (object$motherinst %in% grep("YYYYMMDD_HHMMSS_SN_#_...", object$motherinst, value = TRUE))))
    }
    
  # For object of class igraph
    else if (class(object) == "igraph") {
    # Make list of original instances
      orig <- c(names(which(sapply(sapply(V(object), function(x) neighbors(object,x,mode='in')), length) == 0)))
    # Removes undescribed mothers (Original instances and mothers of orphans).Do I keep this?
      orig <- subset(orig, !(orig %in% grep("YYYYMMDD_HHMMSS_SN_#_|_P\\d|_S\\d", orig, value = TRUE)))
  }
  
  # Error when neither dataframe or igraph
    else {stop("Object is not of class 'igraph' or 'data.frame'")}
  
  return(orig)
}














