##################### Make spatial points df from igraph object###################3
f.spatial_point_g <- function(g){
  df <- as_data_frame(g, what = c("vertices"))
  spoint <- f.spatial_point(df)
  return(spoint)
}