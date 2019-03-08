###################### Just before fracturing from dataframe ##################################

#=================================== Version 2.0 =============================================#

f.fract <- function(object, type="before") {
  if (type == "before"){
    # Before fracture
    fract <- subset(object, object$inst %in% count(object$lineage)$x[which(count(object$lineage)$freq >= 2)])
  }
  if (type == "after"){
    # After fracture
    fract <- subset(object, object$lineage %in% count(object$lineage)$x[which(count(object$lineage)$freq >= 2)] &
                         #!(object$lineage %in% grep("_P\\d|_S\\d", object$lineage, value = TRUE)) &
                         !(object$lineage %in% grep("YYYYMMDD_HHMMSS_SN_#_...", object$lineage, value = TRUE)))
  }
  return(fract)
}