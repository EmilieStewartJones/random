# Ci2D3 functions

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
Creates a spatial polygons dataframe of the ice islands of a querried table from the database. The table must contain the geom1 column, which is the Well-known Text representation of the geometry of the ice islands. This column is created when f.subset is used to query the database. This function is used by f.igraph_s. 
#### Input: 
- Dataframe with inst, motherinst and geom1 columns  
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

## f.terminal
Takes an object of class ‘igraph’ or of class ‘dataframe’ and finds its terminal ice island. A terminal ice island is the last observation of an ice ice island. 

#### Input:  
- object: object of class igraph or dataframe
#### Ouput:  
- For igraph: a character list of the terminal instances  
- For dataframe: a dataframe subsetted to the terminal instances

## f.terminal_db
Queries directly from the database and returns a dataframe of the terminal instances with their attributes. The function uses the f.subquery function, allowing it to take the calvingyr and calvingloc arguments to narrow the instances of interest.
#### Input: 
- con: connection to database
- calvingyr: year of orginal calvinf event. If none is given, all years will be taken.
- calvingloc: location of initial calving event. If none is given, all locations will be taken.
#### Ouput: 
- A subsetted dataframe with only the terminal ice islands

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

