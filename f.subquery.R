# Subquery function #

f.subquery <- function(calvingyr = NULL, calvingloc = NULL) {
  
  # Prepare calvingyr query
    if (is.null(calvingyr)) {
      yr_query <- NULL
    }
    else yr_query <- paste0("AND calvingyr = ANY (SELECT calvingyr WHERE calvingyr = '",
                            paste0(calvingyr, collapse = "' OR calvingyr = '"), "')")
  
  # Prepare calvingloc query
    if (is.null(calvingloc)) {
      loc_query <- NULL
    }
    else loc_query <- paste0("AND calvingloc = ANY (SELECT calvingloc WHERE calvingloc = '",
                             paste0(calvingloc, collapse = "' OR calvingloc = '"), "')")
  
  # Prepare total subquery
    sub_query <- paste0(yr_query, loc_query)
    
    return(sub_query)
}