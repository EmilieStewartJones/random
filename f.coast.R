############### Function to bring in and prepare coastline data #######################################
#### Can be used with gshhs_l_l1 or gshhs_f_l1_subset dataframes
## Input: - Connection to database
##        - coastm: map to be used for coastline. 
##            Options are: - fine: fine scaled map (gshhs_f_l1_subset)
##                         - low: low resolution map (gshhs_l_l1)
## Output: - An object of class SpatialPolygons of the cropped coastal map
#######################################################################################################
# TO DO: - make compatable with more of the gshhs maps


f.coast <- function(conn, coastm = "fine") {
  library(sp)
  
  # Get from db
    if (coastm == "fine") {
      query <- "SELECT ST_AsText(gshhs_f_l1_subset.geom) AS geom1 FROM gshhs_f_l1_subset"
    }
    else if (coastm == "low") query <- "SELECT ST_AsText(gshhs_l_l1.wkb_geometry) AS geom1 FROM gshhs_l_l1"
    
    coast <- dbGetQuery(conn, query)
    row.names(coast) -> coast$gid
  
  # Make into SpatialPolygonDataFrame (Most time consuming part of function)
    print("-----> Making into SpatialPolygonDataFrame")
    coast <- lapply(seq(nrow(coast)), FUN=function(x) readWKT(coast$geom1[x], coast$gid[x]))
    coast <- do.call(rbind, coast)
  
  # Assining original proj (WGS84)
    print("-----> Assigning original pojection")
    proj4string(coast) = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
    
  # Reassign LCC
    print("-----> Reassigning projection")
    coast <- spTransform(coast, CRS("+proj=lcc +lat_1=77 +lat_2=49 +lat_0=40 +lon_0=-100, ellps=WGS84"))
    
  return(coast)
}
