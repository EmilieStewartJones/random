# Just before fracturing from dataframe #

f.fract_bf <- function(object, type="before") {
  if (type = "before"){
    # Before fracture
    fract <- subset(object, object$inst %in% count(object$motherinst)$x[which(count(object$motherinst)$freq >= 2)])
  }
  if (type = "after"){
    # After fracture
    fract <- subset(object, object$motherinst %in% count(object$motherinst)$x[which(count(object$motherinst)$freq >= 2)] &
                         !(object$motherinst %in% grep("_P\\d|_S\\d", object$motherinst, value = TRUE)) &
                         !(object$motherinst %in% grep("YYYYMMDD_HHMMSS_SN_#_...", object$motherinst, value = TRUE)))
  }
  return(fract)
}