############ Names ice islands according to CIS system #################

f.NamingSystem <- function(table){
  
  ##### Define FUNCTIONS #####
    # Function 1: Find 1st before fract (bfract) and name from larg to bfract
      f.next <- function(g, table, larg, name) {
        # Find all ii after largest daughter, larg
        aft <- f.after(g, inst = larg)
        # Create df from igraph
        df <- as_data_frame(aft, what = 'vertices')
        # Change to right col name
        colnames(df)[which(names(df) == "name")] <- "inst"
        # Find bfract of df 
        bfract <- f.fract(df, type='before')
        
        # Find first bf
        bfract <- bfract$inst[bfract$scenedate == min(bfract$scenedate)]
        # if no bf, find terminal and call bfract, set STOP to TRUE 
        if (length(bfract)==0) {
          STOP <<- TRUE
          bfract <- f.terminal(df)
          bfract <- bfract$inst[bfract$scenedate == min(bfract$scenedate)]
        }
        # Find all ii between larg and bfract
        p <- shortest_paths(g, from = larg, to = bfract, mode = "all",
                            weights = NULL, output = "vpath",
                            predecessors = FALSE, inbound.edges = FALSE)
        # Name p by c
        table$test[table$inst %in% p$vpath[[1]]$name] <- name
        
        table <<- table
        bfract <<- bfract
        #return(table)
      }
    
    # Function 2: Name daughters of 1st before fract, bfract 
      f.name2 <- function(ii, name, num) {
        # Find daughters of ii
        daught <- table[table$lineage == ii,]
        # Name all daughters by c
        table$test[table$inst %in% daught$inst] <- name
        # Find largest daughter
        larg <- daught$inst[daught$area == max(daught$area)]
        # Remove largest daughter from daughters to name
        daught <- daught[!daught$inst == larg,]
        # Set order of daughters
        ord <- order(order(-daught$area))
        ## Name daughters by order
        # split string of name and figure out new addition
        str <- unlist(strsplit(name, split='-'))
        # check length of str, if 2 or less, capital letter
        if (length(str) < 3) {
          sequ <- c(paste0(LETTERSs[seq( from = num, to = 104)]))
        }
        
        # check if numeric
        else if (!is.na(as.numeric(tail(str, n=1)))) {
          # check if upper case before numeric
          if (toupper(tail(str, n=2)[1]) == tail(str, n=2)[1]) {
            # if uppercase, make lower case
            sequ <- c(paste0(letterss[seq( from = num, to = 104)]))
          }
          # else, make upper case
          else {sequ <- c(paste0(LETTERSs[seq( from = num, to = 104)]))}
        }
        
        # if not numeric, make numeric
        else {sequ <- c(paste0(as.character(seq(from = num, 100))))}
        # name daughters
        table$test[table$inst %in% daught$inst] <- paste0(name, c(paste0("-", sequ))[ord])
        
        # remember letter of last daughter
        num <<- num + max(ord) 
        
        larg <<- larg
        return(table)
      }
    
  ################## Step 1 #################
    ## Name The originals. First one by size, others by date
    table$test <- NA
    # Create igraph
    g <- f.igraph(table)
    # Create LETTERSS and letterss
    LETTERSs <- c(LETTERS, paste0(LETTERS, LETTERS), paste0(LETTERS, LETTERS, LETTERS), paste0(LETTERS, LETTERS, LETTERS, LETTERS), 
                  paste0(LETTERS, LETTERS, LETTERS, LETTERS, LETTERS), paste0(LETTERS, LETTERS, LETTERS, LETTERS, LETTERS, LETTERS),
                  paste0(LETTERS, LETTERS, LETTERS, LETTERS, LETTERS, LETTERS, LETTERS))
    letterss <- c(letters, paste0(letters, letters), paste0(letters, letters, letters), paste0(letters, letters, letters, letters))
    # Find originals
    orig <- f.origins(object=table, orphans=FALSE)
    # Give all originals a name 
    # Name from calvingloc. PG->PII, SG->SII, CG->CII, NG->NII, NA->UNK and calvingyr
    table$test[table$inst %in% orig$inst] <- paste0(gsub("G", "II", table$calvingloc[table$inst %in% orig$inst]), 
                                                    "-", table$calvingyr[table$inst %in% orig$inst])
    # Find orphans
    orph <- f.orphan(table)
    # Name from calvingloc. PG->PII, SG->SII, CG->CII, NG->NII, NA->UNK and calvingyr
    table$test[table$inst %in% orph$inst] <- paste0(gsub("G", "II", table$calvingloc[table$inst %in% orph$inst]), 
                                                    "-", table$calvingyr[table$inst %in% orph$inst],
                                                    "-ORPH")
    # Fix Nas
    # Replace NA for location with UNK
    table$test <-as.character(gsub("NA-", "UNK-", table$test))
    # Replace Na for year with nothing 
    table$test <- gsub("-NA", "", table$test)
    # Get rid of spaces in name
    table$test <- gsub(" ", "", table$test)
  
  ################## Step 2 ##################  
    # Name the originals and immediate offshoots of the longest path like A,B, C...
    # For every unique name (year and calving loc), c
    for (c in unique(table$test)[!is.na(unique(table$test))]){
      
      ### Step 2.1: Name originals in order
      # Daughters: originals are the ii who's test is c
      orig_c <- table[table$test == c,]
      orig_c <- orig_c[rowSums(is.na(orig_c)) !=ncol(orig_c), ]
      # Find largest daughters, larg
      larg <- orig_c$inst[orig_c$area == max(orig_c$area)]
      # Remove larg from list to name
      orig_c <- orig_c$inst[!orig_c$inst ==larg]
      # rank in order of observation, if equal, in order of size
      ord <- rank(order(order(table$scenedate[table$inst %in% orig_c], -table$area[table$inst %in% orig_c])))
      # Add -A, -B, -C, in for order
      table$test[table$inst %in% orig_c] <- paste0(table$test[table$inst %in% orig_c],
                                                   c(paste0("-", LETTERSs[seq( from = 1, to = 160)]))[ord])
      # Remember letter of last ii
      if (length(ord)==0) {
        num <- 1
      } else {
        num <- max(ord) + 1
        }
      
      ### Step 2.1: Follow path of largest (larg)
      STOP <- FALSE
      while (STOP == FALSE){
        # 1: Find 1st before fract (bfract) and name from larg to bfract
        f.next(g, table, larg, name=c)
        if (STOP == TRUE) {break}
        # 2: Name daughters of 1st before fract, bfract 
        table <- f.name2(ii = bfract, c, num)
      }
    }
  
  ################## Step 3 ###################
    # Name remianing iis
    while(any(is.na(table$test)) == TRUE) {
      # Find any random unamed ii
      iir <- sample(table$inst[is.na(table$test)],1)
      # Move up branch until find named ii
      # - find before of ii
      bf <- f.before(g, inst = iir)
      # - find before of ii with a name and the latest date
      larg <- table[table$inst %in% V(bf)$name & !is.na(table$test),]
      larg <- larg$inst[larg$scenedate == max(larg$scenedate)]
      
      # name of larg
      d <- table$test[table$inst == larg]
      
      # reset num
      num <- 1
      # Follow largest path of this ii like previously done
      STOP <- FALSE
      while (STOP == FALSE){
        # 1: Find 1st before fract (bfract) and name from larg to bfract
        f.next(g, table, larg, name=d)
        if (STOP == TRUE) {break}
        # 2: Name daughters of 1st before fract, bfract 
        table <- f.name2(ii = bfract, d, num)
      }
    }
  return(table)
}



