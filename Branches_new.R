
# Function for creating -list of drift paths
#                       -list of subgraphs of drift paths 
f.drift <- function(calvingloc = 'PG', calvingyr = '2008', attributes = c('calvingyr', 'poly_area')){
  source('f.igraph.R')
  
  
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
      drift <- unlist(which(lapply(branches, function(l) l[[1]] == i) ==TRUE))   # finds lists in branches that strt with i value
      drift <- branches[drift[which.min(lengths(branches[drift]))]]                                 # finds 
      drifts_g <- append(drifts_g, list(induced.subgraph(g,as.character(unlist(drift)))))
      drifts <- append(drifts, drift)
    }
    return(list("drifts_list" = drifts, "drifts_igraph" = drifts_g))
  } # Create lists of lists of vertices between fracture
  
    
    
    
  ## Prepare DB queries ##
    sub_query <- paste0("calvingloc = '", calvingloc, "' AND calvingyr = '", calvingyr, "'")
    atr_query <- paste(attributes, collapse=", ")
  
  ## Query main table and create igraph object ##
    query <- paste0("SELECT inst, motherinst, ", atr_query, " FROM shapefiles_qc WHERE ", sub_query)
    table <- dbGetQuery(con, query)
    table$names <- gsub('^.{21}','',table$inst)
    g <- f.igraph(table)
  
  ## Find all combinations ##
    # 1: Origins and just after fracturing
      query <- paste0("SELECT inst FROM shapefiles_qc WHERE motherinst IN (SELECT motherinst FROM shapefiles_qc WHERE ", sub_query, 
                      " GROUP BY motherinst HAVING COUNT(*) > 1) OR ", sub_query, "AND motherinst IS NULL")
      fract1 <- dbGetQuery(con, query)
    # 2: Terminals and just before fracture 
      query = paste0("SELECT inst FROM shapefiles_qc WHERE inst NOT IN (SELECT inst FROM shapefiles_qc where inst IN (SELECT motherinst FROM shapefiles_qc))
                     AND ", sub_query," OR inst IN (SELECT motherinst FROM shapefiles_qc WHERE ", sub_query, 
                     " GROUP BY motherinst HAVING COUNT(*) > 1)")
      fract2 = dbGetQuery(con, query)
    # all combinations between 1 and 2
      comb <- expand.grid(fract1$inst, fract2$inst)
  
  ## Create lists and igraph objects ##
    drifts <- f.branch(comb, g)
  
  return(drifts)
}








