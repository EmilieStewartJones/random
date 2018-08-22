############### Function to bring in and prepare coastline data #######################################
#### Can only be used with gshhs_l_l1 dataframe
## Input: - Connection to database
##        - Map extent as a list of coordinates, in this order: min x, max x, min y, max y (optional)
## Output: - An object of class SpatialPolygons of the cropped coastal map
#######################################################################################################
# TO DO: - make compatable with any of the gshhs maps

f.coast <- function(conn, map_extent = NULL, coastm = "fine") {
  library(sp)
  
  # Define functions
    gClip <- function(shp, bb){
      if(class(bb) == "matrix") b_poly <- as(extent(as.vector(t(bb))), "SpatialPolygons")
      else b_poly <- as(extent(bb), "SpatialPolygons")
      gIntersection(shp, b_poly, byid = TRUE)
    }
    
  # Get from db
    if (coastm == "fine") {
      query <- "SELECT ST_AsText(gshhs_f_l1_subset.geom) as geom FROM gshhs_f_l1_subset"
    }
    else if (coastm == "low") query <- "SELECT ST_AsText(gshhs_l_l1.wkb_geometry) AS geom FROM gshhs_l_l1"
    
    coast <- dbGetQuery(conn, query)
    row.names(coast) -> coast$gid
  
  # Make into SpatialPolygonDataFrame (Most time consuming part of function)
    print("----- Making into SpatialPolygonDataFrame")
    coast <- lapply(seq(nrow(coast)), FUN=function(x) readWKT(coast$geom[x], coast$gid[x]))
    coast <- do.call(rbind, coast)
    
    # assining original proj (WGS84)
      print("----- Assigning original pojection")
      proj4string(coast) = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
    
    # reassign LCC
      print("----- Reassigning projection")
      coast <- spTransform(coast, CRS("+proj=lcc +lat_1=77 +lat_2=49 +lat_0=40 +lon_0=-100, ellps=WGS84"))
  
  # crop map
    if (is.null(map_extent)) crop <- extent(0, 2000000, 2800000, 5000000)
    else crop <- extent(map_extent[1], map_extent[2], map_extent[3], map_extent[4])
    print("----- Clipping coastline map to map extent")
    coastcrop <- gClip(coast, crop)
    
    return(coastcrop)
}
