#################### Script to isolate branches before and after fracture #####################
#### Function f.drift:
####       - Input: calving location (PG, CG, NG, RG, SG)
####                calving year (2008, 2010, 2011, 2012 and NA)
####                Attributes
####       - Output: A list with 2 items, a dataframe and an igraph object
###########################################################################
## Figure out how results may be plotted with f,plot function. It may work if f.igraph_s function is used when creating g instead of f.igraph function
#    - May have figured it out

# Function for creating -list of drift paths
#                       -list of subgraphs of drift paths 



f.drift <- function(con, calvingloc = 'PG', calvingyr = '2008') {#, attributes = c('calvingyr', 'poly_area')){
  source('f.igraph_s.R')
  require(igraph)
  require(RPostgreSQL)
  require(rgeos)
  require(sp)
  require(plyr)
  
  ## Define functions ##
  f.branch <- function(comb, g) {
    branches <- c()
    branches_g <- c()
    for (i in seq_len(nrow(comb))){
      tab <- suppressWarnings(get.shortest.paths(g, from = as.character(comb[i,1]), to = as.character(comb[i,2])))
      tab <- unlist(tab$vpath)
      if (is.null(names(tab))) next
      else if ((length(names(tab))) <= 1) next
      else {
        branches <- append(branches, list(names(tab)))
      }
    }
    uniques = unique(lapply(branches, function(l) l[[1]]))
    drifts <- c()
    drifts_g <- c()
    for (i in uniques) {
      drift <- unlist(which(lapply(branches, function(l) l[[1]] == i) ==TRUE))   # finds lists in branches that start with i value
      drift <- branches[drift[which.min(lengths(branches[drift]))]]                           # Finds shortest of these
      drifts_g <- append(drifts_g, list(induced.subgraph(g,as.character(unlist(drift)))))
      drifts <- append(drifts, drift)
    }
    return(list("drifts_list" = drifts, "drifts_igraph" = drifts_g))
  } # Create lists of lists of vertices between fracture
  
  ## Prepare DB queries ##
    sub_query <- paste0("calvingloc = '", calvingloc, "' AND calvingyr = '", calvingyr, "'")
    #atr_query <- paste(attributes, collapse=", ")
  
  ## Query main table and create igraph object ##
    #query <- paste0("SELECT inst, motherinst, ", atr_query, " FROM shapefiles_qc_2013 WHERE ", sub_query)
    query <- paste0("SELECT *, ST_AsText(shapefiles_qc_2013.wkb_geometry) as geom1 FROM shapefiles_qc_2013 WHERE ", sub_query)
    table <<- dbGetQuery(con, query)
    table$names <- gsub('^.{21}','',table$inst)
    g <- f.igraph_s(table)
  
  ## Find all combinations ##
    # 1: Origins and just after fracturing
      query <- paste0("SELECT inst FROM shapefiles_qc_2013 WHERE motherinst IN (SELECT motherinst FROM shapefiles_qc_2013 WHERE ", sub_query, 
                      " GROUP BY motherinst HAVING COUNT(*) > 1) OR ", sub_query, "AND motherinst IS NULL")
      fract1 <- dbGetQuery(con, query)
    # 2: Terminals and just before fracture 
      query = paste0("SELECT inst FROM shapefiles_qc_2013 WHERE inst NOT IN (SELECT inst FROM shapefiles_qc_2013 where inst IN (SELECT motherinst FROM shapefiles_qc_2013))
                     AND ", sub_query," OR inst IN (SELECT motherinst FROM shapefiles_qc_2013 WHERE ", sub_query, 
                     " GROUP BY motherinst HAVING COUNT(*) > 1)")
      fract2 = dbGetQuery(con, query)
    # all combinations between 1 and 2
      comb <- expand.grid(fract1$inst, fract2$inst)
      
  ## Create lists and igraph objects ##
    drifts <- f.branch(comb, g)
  
  return(drifts)
}








