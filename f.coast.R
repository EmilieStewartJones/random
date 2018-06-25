# Function to bring in and prepare coastline data
# Can only be used with gshhs_l_l1 dataframe

f.coast <- function(con, map_extent = NULL) {
  # Define functions
    gClip <- function(shp, bb){
      if(class(bb) == "matrix") b_poly <- as(extent(as.vector(t(bb))), "SpatialPolygons")
      else b_poly <- as(extent(bb), "SpatialPolygons")
      gIntersection(shp, b_poly, byid = TRUE)
    }
  # Get from db
    query <- "SELECT ST_AsText(gshhs_l_l1.wkb_geometry) AS geom FROM gshhs_l_l1"
    coast <- dbGetQuery(con, query)
    row.names(coast) -> coast$gid
  
  # Make into SpatialPolygonDataFrame
    coast <- lapply(seq(nrow(coast)), FUN=function(x) readWKT(coast$geom[x], coast$gid[x]))
    coast <- do.call(rbind, coast)
    # assining original proj (WGS84)
    proj4string(coast) = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
    # reassign LCC
    coast <- spTransform(coast, CRS("+proj=lcc +lat_1=77 +lat_2=49 +lat_0=40 +lon_0=-100, ellps=WGS84"))
  
  # clip to same extent as site map
    if (is.null(map_extent)) crop <- extent(0, 2000000, 2800000, 5000000)
    else crop <- extent(map_extent[1], map_extent[2], map_extent[3], map_extent[4])
    coastcrop <- gClip(coast, crop)
}
