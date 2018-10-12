# Just after fracturing from dataframe #

f.fract_af <- function(con, object) {
  # From table
  # After fracture
  fract_af <- subset(object, object$motherinst %in% count(object$motherinst)$x[which(count(object$motherinst)$freq >= 2)] &
                       !(object$motherinst %in% grep("_P\\d|_S\\d", object$motherinst, value = TRUE)) &
                       !(object$motherinst %in% grep("YYYYMMDD_HHMMSS_SN_#_...", object$motherinst, value = TRUE)))
  
  return(fract_af)
}