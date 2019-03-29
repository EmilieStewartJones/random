#### For cleaning up the database ##
library(rgdal)

table <- f.subset(con, calvingyr = NULL, calvingloc = NULL, wk_num = NULL, size = NULL,
                  loc_x = NULL, loc_y = NULL) 

#### --------------------------------- WIRL VERSION (1.0)----------------------------------####
### Removing fields ##
  table <- table[, c("inst", "motherinst", "calvingyr","calvingloc", "poly_area", 
                     "perimeter", "length", "centroid_x", "centroid_y", 
                     "wkb_geometry", "scenedate", "imgref1", "iicert", "mothercert", 
                     "shpcert", "georef", "ddinfo", "sensor", "beam_mode", "polarizati", 
                     "alias", "operator", "traceback", "debrisfld",
                     "surf_feat", "aoi", "datepoly", "comments", "geom1")] 

### Renaming fields ##
  colnames(table)[colnames(table)=="wkb_geometry"] <- "geometry"
  colnames(table)[colnames(table)=="imgref1"] <- "imgref"
  colnames(table)[colnames(table)=="poly_area"] <- "area"
  colnames(table)[colnames(table)=="polarizati"] <- "pol"
  colnames(table)[colnames(table)=="centroid_x"] <- "lon"
  colnames(table)[colnames(table)=="centroid_y"] <- "lat"

### Cleaning up ddinfo ##
  table$ddinfo[table$ddinfo == "grounded ?"] <- "grounded?"
  table$ddinfo[table$ddinfo == "grounded."] <- "grounded"
  table$ddinfo[table$ddinfo == "trapped."] <- "trapped"

### Cleaning up georef ##
  table$georef[table$georef == ">400 m"] <- ">400m"

### Convert coordinates to lat long ##
  coordinates(table) <- ~lon+lat
  # Assining original proj (LCC)
  proj4string(table) = CRS("+proj=lcc +lat_1=77 +lat_2=49 +lat_0=40 +lon_0=-100, ellps=WGS84")
  # Reassign WGS
  table <- spTransform(table, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))
  table <- as.data.frame(table)

### Replace missing motherinst of 20080716_153449_es_0_SMD with 20080710_234704_es_0_P08 ##
  table$motherinst[is.na(table$motherinst)] <- "20080710_234704_es_0_P08"

### Fix beam_mode column
  ## Remove underscores
  table$beam_mode <- gsub(pattern = "_", replacement = "", table$beam_mode)
  ## Replace fine with f and wide with w
  table$beam_mode[table$beam_mode == "fine"] <- "f"
  table$beam_mode[table$beam_mode == "wide"] <- "w"
  
  
  
  #### --------------------------------- PUBLIC VERSION (1.1) ----------------------------------####
  ### Create a dataframe from entire db ###
  table <- f.subset(con, calvingyr = NULL, calvingloc = NULL, wk_num = NULL, size = NULL,
                    loc_x = NULL, loc_y = NULL) 
  ### Removing fields ##
  table <- table[, c("inst", "motherinst", "calvingyr","calvingloc", "poly_area", 
                     "perimeter", "length", "centroid_x", "centroid_y", "wkb_geometry",
                     "scenedate", "imgref1", "mothercert", "shpcert", "georef",
                     "ddinfo", "sensor", "beam_mode", "polarizati", "geom1")] 
  
  ### Renaming fields ##
  colnames(table)[colnames(table)=="wkb_geometry"] <- "geometry"
  colnames(table)[colnames(table)=="imgref1"] <- "imgref"
  colnames(table)[colnames(table)=="poly_area"] <- "area"
  colnames(table)[colnames(table)=="polarizati"] <- "pol"
  colnames(table)[colnames(table)=="centroid_x"] <- "lon"
  colnames(table)[colnames(table)=="centroid_y"] <- "lat"
  
  ### Cleaning up ddinfo ##
  table$ddinfo[table$ddinfo == "grounded ?"] <- "grounded?"
  table$ddinfo[table$ddinfo == "grounded."] <- "grounded"
  table$ddinfo[table$ddinfo == "trapped."] <- "trapped"
  
  ### Cleaning up georef ##
  table$georef[table$georef == ">400 m"] <- ">400m"  
  
  ### Convert coordinates to lat long ##
  coordinates(table) <- ~lon+lat
  # Assining original proj (LCC)
  proj4string(table) = CRS("+proj=lcc +lat_1=77 +lat_2=49 +lat_0=40 +lon_0=-100, ellps=WGS84")
  # Reassign WGS
  table <- spTransform(table, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))
  table <- as.data.frame(table)
  
  ### Fixing motherinst 
  # Replace missing motherinst of 20080716_153449_es_0_SMD with 20080710_234704_es_0_P08 ##
  table$motherinst[is.na(table$motherinst)] <- "20080710_234704_es_0_P08"
  
  ### Fix beam_mode column ##
  ## Remove underscores
  table$beam_mode <- gsub(pattern = "_", replacement = "", table$beam_mode)
  ## Replace fine with f and wide with w
  table$beam_mode[table$beam_mode == "fine"] <- "f"
  table$beam_mode[table$beam_mode == "wide"] <- "w"
  
  ### Making motherinst --> lineage and adding mother field
  colnames(table)[colnames(table)=="motherinst"] <- "lineage"
  
  ### Reorder fields ##
  table <- table[, c("inst", "lineage", "calvingyr","calvingloc", "area", 
                     "perimeter", "length", "lon", "lat", "geometry",
                     "scenedate", "imgref", "mothercert", "shpcert", "georef",
                     "ddinfo", "sensor", "beam_mode", "pol", "geom1")] 
  
  
  ### Output files ##
  ## csv
  table_csv <- table
  table_csv$geometry <- NULL
  table_csv$geom1 <- NULL
  write.csv(table_csv, file = "CI2D3_public_01.csv")
  ## shapefile
  # Make a polygon shapefile of ice island
  table_shp <- f.Spatialdf(table)
  # Removing excess columns
  table_shp$geom1 <- NULL
  table_shp$gid <- NULL
  # Make spatial points datframe into shapefile
  # Need different way to do this that does not truncate the column names
  writeOGR(table_shp, dsn = "Shapefile", layer = "CI2D3_public_01", driver="ESRI Shapefile")
  
 
#### --------------------------------- PUBLIC VERSION (1.2) ----------------------------------####
### Create a dataframe from entire db ###
  table <- f.subset(con, calvingyr = NULL, calvingloc = NULL, wk_num = NULL, size = NULL,
                    loc_x = NULL, loc_y = NULL) 
### Removing fields ##
  table <- table[, c("inst", "motherinst", "calvingyr","calvingloc", "poly_area", 
                     "perimeter", "length", "centroid_x", "centroid_y", "wkb_geometry",
                     "scenedate", "imgref1", "mothercert", "shpcert", "georef",
                     "ddinfo", "sensor", "beam_mode", "polarizati", "geom1")] 

### Renaming fields ##
  colnames(table)[colnames(table)=="wkb_geometry"] <- "geometry"
  colnames(table)[colnames(table)=="imgref1"] <- "imgref"
  colnames(table)[colnames(table)=="poly_area"] <- "area"
  colnames(table)[colnames(table)=="polarizati"] <- "pol"
  colnames(table)[colnames(table)=="centroid_x"] <- "lon"
  colnames(table)[colnames(table)=="centroid_y"] <- "lat"

### Cleaning up ddinfo ##
  table$ddinfo[table$ddinfo == "grounded ?"] <- "grounded?"
  table$ddinfo[table$ddinfo == "grounded."] <- "grounded"
  table$ddinfo[table$ddinfo == "trapped."] <- "trapped"

### Cleaning up georef ##
  table$georef[table$georef == ">400 m"] <- ">400m"  

### Convert coordinates to lat long ##
  coordinates(table) <- ~lon+lat
  # Assining original proj (LCC)
  proj4string(table) = CRS("+proj=lcc +lat_1=77 +lat_2=49 +lat_0=40 +lon_0=-100, ellps=WGS84")
  # Reassign WGS
  table <- spTransform(table, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))
  table <- as.data.frame(table)

### Fixing motherinst 
  # Replace missing motherinst of 20080716_153449_es_0_SMD with 20080710_234704_es_0_P08 ##
    table$motherinst[is.na(table$motherinst)] <- "20080710_234704_es_0_P08"
  # Replace 20101113_113437_r2_9_SJO, motherinst of 20101120_113131_r2_3_CJD with 20101107_224624_r2_3_FZI
    table$motherinst[table$inst == "20101120_113131_r2_3_CJD"] <- "20101107_224624_r2_3_FZI"
  # Replace 20121004_122025_r2_13_WZD, motherinst of 20121004_212457_r1_7_ROU with 20120930_214216_r1_13_JCQ
    table$motherinst[table$inst == "20121004_212457_r1_7_ROU"] <- "20120930_214216_r1_13_JCQ"

### Remove rows with inst = 20130728_193609_r2_55_BRM and 20130728_211614_r2_2_SRX
  table <-  table[!table$inst == "20130728_193609_r2_55_BRM",]
  table <- table[!table$inst == "20130728_211614_r2_2_SRX",]

### Fix beam_mode column ##
 ## Remove underscores
  table$beam_mode <- gsub(pattern = "_", replacement = "", table$beam_mode)
 ## Replace fine with f and wide with w
  table$beam_mode[table$beam_mode == "fine"] <- "f"
  table$beam_mode[table$beam_mode == "wide"] <- "w"
  
### Making motherinst --> lineage and adding mother field
  colnames(table)[colnames(table)=="motherinst"] <- "lineage"
  
  table <- f.mother(table)
  
### Adding name field
  table <- f.NamingSystem(table)
  
### Reorder fields ##
  table <- table[, c("inst", "test", "lineage", "mother", "calvingyr","calvingloc", "area", 
                     "perimeter", "length", "lon", "lat", "geometry",
                     "scenedate", "imgref", "mothercert", "shpcert", "georef",
                     "ddinfo", "sensor", "beam_mode", "pol", "geom1")] 
  
  
### Output files ##
  ## csv
    table_csv <- table
    table_csv$geometry <- NULL
    table_csv$geom1 <- NULL
    write.csv(table_csv, file = "CI2D3_public_02.csv")
  ## shapefile
    # Make a polygon shapefile of ice island
      table_shp <- f.Spatialdf(table)
    # Removing excess columns
      table_shp$geom1 <- NULL
      table_shp$gid <- NULL
    # Make spatial points datframe into shapefile
      # Need different way to do this that does not truncate the column names
      writeOGR(table_shp, dsn = "Shapefile", layer = "CI2D3_public_01", driver="ESRI Shapefile")

  

  
  
