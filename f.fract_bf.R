# Just before fracturing from dataframe #

f.fract_bf <- function(con, object) {
  # From table
  # Before fracture
  fract_bf <- subset(object, object$inst %in% count(object$motherinst)$x[which(count(object$motherinst)$freq >= 2)])
  return(fract_bf)
}