############## Create mother field #########################

f.mother <- function(table) {
  ### Step 1: add mother field
    table$mother <- NA
  
  ### Step 2: find all inst who's lineage is also their mother
    # Find originals and orphans and give mother
    orig.orph <- f.origins(table, orphans = TRUE)
    table[table$inst %in% orig.orph$inst, ]$mother <- table[table$inst %in% orig.orph$inst, ]$lineage
    # Find the just after fracturing and give mother
    afract <- f.fract(table, type="after")
    table[table$inst %in% afract$inst, ]$mother <- table[table$inst %in% afract$inst, ]$lineage
    # Create list of the inst that keep their lineage for their mother
    list <- table[!is.na(table$mother),]$inst 
  
  ### Step 3: Fill in the rest
    # loop that finds inst with a lineage that already has a mother and give it that mother.
    # does this over and over again until all inst have a mother.
    while (anyNA(table$mother) == TRUE) {
      # Try by picking random, not with for loop
      # iir <- sample(table[table$lineage %in% list & is.na(table$mother), ]$inst, 1)
      # print(paste(iir))
      # table[table$inst == iir,]$mother <- table[table$inst %in% table[table$inst == iir,]$lineage,]$mother
      # list <- table[!is.na(table$mother),]$inst 
      
      # find inst with lineage that has a mother and give it that mother
      for (i in table[table$lineage %in% list & is.na(table$mother), ]$inst){
        print(paste(i))
        table[table$inst == i,]$mother <- table[table$inst %in% table[table$inst == i,]$lineage,]$mother
      }

      list <- table[!is.na(table$mother),]$inst
    }
    return(table)
}
