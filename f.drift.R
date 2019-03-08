#################### Script to isolate branches before and after fracture #####################

#=================================== Version 2.0 =============================================#

##############################################################################################
#### Function f.drift:
####       - Input: calving location (PG, CG, NG, RG, SG)
####                calving year (2008, 2010, 2011, 2012 and NA)
####                week number
####       - Output: A list with 2 items, a dataframe and an igraph object
##############################################################################################



f.drift <- function(con, calvingloc = NULL, calvingyr = NULL, wk_num = NULL) {
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
  sub_query <- f.subquery(calvingyr = calvingyr, calvingloc = calvingloc)

  ## Query main table and create igraph object ##
    #query <- paste0("SELECT inst, lineage, ", atr_query, " FROM CI2D3 WHERE ", sub_query)
    query <- paste0("SELECT *, ST_AsText(CI2D3.geometry) as geom1, ",
                    "DENSE_RANK() OVER(PARTITION BY calvingyr ORDER BY date_trunc('week', CI2D3.scenedate::timestamp)) ",
                    "as wk_num FROM CI2D3 WHERE inst IS NOT NULL ", sub_query)
    table <- dbGetQuery(con, query)
    # Subset weeks of interest from dataframe
    if (is.null(wk_num)){
      table <- table
    }
    else table <- table[table$wk_num >= wk_num[1] & table$wk_num <= wk_num[2], ]
    
    table$names <- gsub('^.{21}','',table$inst)
    g <- f.igraph_s(table)
  
  ## Find all combinations ##
    # 1: Origins and just after fracturing
      query <- paste0("SELECT inst FROM CI2D3 WHERE lineage IN (SELECT lineage FROM CI2D3",
                      " WHERE inst IS NOT NULL ", sub_query, 
                      " GROUP BY lineage HAVING COUNT(*) > 1) OR inst IS NOT NULL ", sub_query, "AND lineage IS NULL")
      fract1 <- dbGetQuery(con, query)
    # 2: Terminals and just before fracture 
      query = paste0("SELECT inst FROM CI2D3 WHERE inst NOT IN (SELECT inst FROM CI2D3 where inst",
                     " IN (SELECT lineage FROM CI2D3))"
                     , sub_query," OR inst IN (SELECT lineage FROM CI2D3 WHERE inst IS NOT NULL ", sub_query, 
                     " GROUP BY lineage HAVING COUNT(*) > 1)")
      fract2 = dbGetQuery(con, query)
    # all combinations between 1 and 2
      comb <<- expand.grid(fract1$inst, fract2$inst)
      
  ## Create lists and igraph objects ##
    drifts <- f.branch(comb, g)
  
  return(drifts)
}








