# Ci2D3 functions

## f.origins
Returns original ice islands, that is, ice island instances that calved directly off the ice sheet.
#### Input: 
* object: Object of class 'dataframe' or 'igraph'
* orphans (TRUE does not yet work with igraph objects): 
  * TRUE: includes ice island instances that have no lineage (lineage is: YYYYMMDD_HHMMSS_SN_#_---)
  * FALSE: Does not inlcude orphans
#### Ouput: 
* For igraph: a character list of the origins
* For dataframe: a dataframe subsetted to the origins

## f.origins_db
Returns original ice islands, that is, ice island instances that calved directly off the ice sheet.
#### Input: 
* con: Connection to database
* calvingyr: A single or multiple years during which the instance originated. If none are specified, all will be used
* calvingloc: A single or multiple original calving locations. If none are specified, all will be used
* orphans: 
  * TRUE: includes ice island instances that have no lineage (lineage is: YYYYMMDD_HHMMSS_SN_#_---)
  * FALSE: Does not inlcude orphans
#### Output:
A dataframe subsetted to the original ice islands.

## f.terminal
Returns terminal ice islands, that is, ice island instances that are not the lineage of any other ice island.
#### Input: 
bject: Object of class 'dataframe' or 'igraph'
#### Ouput: 
* For igraph: a character list of the terminal ice islands
* For dataframe: a dataframe subsetted to the terminal ice islands

## f.terminal_db
Returns terminal ice islands, that is, ice island instances that are not the lineage of any other ice island. Queries directly from the database and returns a dataframe of the terminal instances with their attributes. The function uses the f.subquery function, allowing it to take the calvingyr and calvingloc arguments to narrow the instances of interest.
#### Input: 
* con: Connection to database
* calvingyr: A single or multiple years during which the terminals' lineage originated. If none are specified, all will be used
* calvingloc: A single or multiple original locations of the terminals' lineage. If none are specified, all will be used
#### Output:
A dataframe subsetted to the terminal ice islands.

## f.fract_bf/f.fract_af
Finds ice island instances just before/after fracturing from table. Takes a dataframe queried from the database as input and outputs a subsetted dataframe.

## f.fract_bf_db/f.fract_af_db
Finds ice island instances just before/after fracturing from database. 
#### Input:
* con: connection to database
* calvingyr: A single or multiple years during which the original calving event occured. If none are specified, all will be used  
* calvingloc: A single or multiple orginal calving locations. If none are specified, all will be used
#### Output:
* A dataframe from the database with a subset of rows and all columns.

## f.fract
Finds ice island instances just before and just after fracturing.
#### Input:
* con: connection to database
* calvingyr: A single or multiple years during which the original calving event occured. If none are specified, all will be used  
* calvingloc: A single or multiple orginal calving locations. If none are specified, all will be used
* wk_num: Requires a vector of 2, where the 1st element is the earliest desired week number since original calving and the 2nd is the last
#### Output:
A dataframe queried from the database with the rows of ice islands instances just before and after fracturing and with all columns.

## f.after
Generates a branch of ice island observations following a given instance.
#### Input:
* g: object of class igraph
* inst: starting instance (vertex)
#### Output:
Object of class igraph.

## f.before
Generates a branch of ice island observations that preceded a given instance.
#### Input:
* g: object of class igraph
* inst: ending instance (vertex)
#### Output:
Object of class igraph.

## f.subset 
This function queries a subset of the database and creates a dataframe. Time, location and size of ice islands may be specified. This function must be used when querying a table to be used in f.Spatialdf and by extension f.igraph_s because it creates the geom1 column.
 #### Input:
 - calvingyr: A single or multiple years during which the original calving event occured. If none are specified, all will be used  
 - calvingloc: A single or multiple orginal calving locations. If none are specified, all will be used
 - wk_num: Requires a vector of 2, where the 1st element is the earliest desired week number since original calving and the 2nd is the last. If nothing is given, all weeks will be taken 
 - size: Requires a vector of 2, where the 1st element is the smallest area (Km2) and the 2nd is the latest area (km2). If nothing is given, all sizes will be taken 
 - loc_x: Requires a vector of 2, where the 1st element is the min x coord (UTM) and the 2nd is the max x coord (UTM). If nothing is given, all islands will be taken 
 - loc_y: Requires a vector of 2, where the 1st element is the min y coord (UTM) and the 2nd is the max y coord (UTM). If nothing is given, all islands will be taken 
 #### Output: 
 - A dataframe with all columns and a subset of rows    
 #### TO DO:   
 - [ ] Try to get f.drift to use this function 

## f.igraph
Creates an igraph object from a table with at the least motherinst and inst columns. Any other columns will be included in the igraph object as attributes. This function is not used by any other function at the moment as it has mostly been replaced by f.igraph_s. 

## f.Spatialdf
Creates an object of the class SpatialPolygonsDataframe of ice islands. An object of this class can be easily exported as a shapefile. This function is used by f.igraph_s. 
#### Input: 
- Dataframe with inst, motherinst and geom1 columns. The geom1 field is the Well-known Text representation of the geometry of the ice islands. This column is created when f.subset is used to query the database.  
#### Output: 
- A SpatialPolygonsDataFrame of ice islands. This object may be easily exported as a shapefile.

## f.igraph_s
Same as f.igraph, but outputs an igraph object with spatially referenced centroids for all islands. It also creates a spatial polygons dataframe of the ice islands. However, this is simply outputted into the environment using <<- symbol. This should probably be changed. Could possibly just create a list of the igraph and df. This function is used by f.drift and f.plot. It uses f.Spatialdf to create the spatial polygons dataframe.
#### Input: 
- Dataframe queried from database with inst, motherinst and geom1 columns 
#### Output:   
- Spatially referenced igraph object
- It will also create a SpatialPolygonsDataframe object in the glocal environment under tha name df_sp.
#### TO DO:   
 - [ ] Find a way to return both the igraph and the spatial polygons dataframe

## f.coast
This function brings in and prepares coastline data for plotting a map of ice islands. It can be used with the gshhs_l_l1 and gshhs_f_l1_subset table in the database. The map will be clipped if the map_extent argument is included. This function is used by f.plot and f.plot2 which both automatically create a map_extent argument based on the coordinates of the ice islands.
#### Input: 
* con: connection to database
* coastm: map to be used for coastline. Options are: 
  * fine: fine scaled map (gshhs_f_l1_subset)
  * low: low resolution map (gshhs_l_l1)
#### Output: 
- An object of class SpatialPolygons of the cropped coastal map

## f.plot
This function plots the movement of ice islands from a table queried from the database or an igraph object. It uses the f.igraph_s and f.coast functions. 
#### Input: 
* con: connection to database
* object: options are:
  * df: dataframe with at the least the inst, motherinst and geom1 columns
  * g: A spatially referenced igraph object 
* polygs: A spatial polygons dataframe that contains all the polygons of the igraph. Must be provided if object is of class igraph. It may contain other polygons too, but these will not appear in the plot.
* coastline: 
  * NULL: no coastline
  * fine: fine scaled map (gshhs_f_l1_subset)
  * low: low resolution map (gshhs_l_l1)
  * object: a coastline map is provided 
#### Output: 
- A plot of ice islands and their edges with or without the coastline
#### To do:
[] Option to plot in grid or tree form
[] Option to plot ice islands as polygons or points instead of an an igraph object

## f.plot2
This function takes a spatially referenced igraph object and a spatial polygons dataframe that contains all the polygons of the igraph object. The function uses the f.coast function. Is not used anymore as f.plot can do what it does.

## f.drift
This function isolates branches of drifting ice islands before and after fractures, essentially repeat observations of the same ice island. 
#### Input
* Input: 
  * calving location (PG, CG, NG, RG, SG)
  * calving year (2008, 2010, 2011, 2012 and NA)
  * week number
#### Output: 
A list with 2 items, a dataframe and an igraph object
#### Notes
This function needs some improvements. Could possibly use f. subset and maybe other smaller functions to reduce its length.

## f.subquery
A function exclusively used in other functions that query from the database. Creates a 'subquery' that may be included in a database query 
to specify calving year and calving location.

