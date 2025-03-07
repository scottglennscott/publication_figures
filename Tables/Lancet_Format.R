###########################################
## Purpose: Function to apply Lancet style to tables
##
##
##
## REQUIREMENTS:
## df: (data.table) This corresponds to a datatable with the following columns:
#         "label"- this is what the table will be sorted on
#       (if non.numeric = F)
#         val.'variables' - a column beginning with "val." for every variable you are measuring
#           'variables' should correspond to final title: i.e. for a column named "Prevalence (Males)"
#         val.'variables' would be "val.Prevalence (Males)"
#       (if with.ui = T)
#         upper.'variables' - the upper confidence interval with variable names corresponding to those following "val."
#         lower.'variables' - the lower confidence interval with variable names corresponding to those following "val."
#       (if hierarchy = T)
#         sort_order - from get_'topic'_metadata (where topic = location, cause, rei)
#         level - from get_'topic'_metadata (where topic = location, cause, rei)
# 
# label: (string) the name of the column that the table will be sorted on
# hierarchy: (boolean) TRUE if labels under column "label" are hierarchical and come with a sort order and levels
# sdi: (boolean) TRUE if using location and low, low-middle, middle, high-middle, and high SDI are among the locations
# rounded: (boolean) default TRUE, will round to 3 sig figs (NOTE this does not reflect differing rounding standards for rates vs pcts vs counts,
## currently working on fix to round to correct sig fig/dec places depending on metric)
##   If FALSE will take in whatever values provided.
# alternate: (boolean) TRUE if format desired is alternating pink-white, often seen in appendices. Note, this is NOT a formal Lancet format. 
# with.ui: (boolean) TRUE if including columns upper.'variable' and lower.'variable'
# non.numeric: (boolean) TRUE if no numeric data is include (i.e. no val.'variable')
# title: (string) title for alternate = T tables, otherwise NULL
# lancet_font: (boolean) default FALSE, if TRUE you MUST HAVE LANCET FONT FILE ON YOUR LOCAL COMPUTER
# outfile: (string) complete filepath for output including 'filename'.xlsx
#################################################
#################################################

as_lancet_table <- function(df, label, hierarchy = T, sdi = T, alternate = F, rounded = T,
                            with.ui = T, non.numeric = F, title = NULL, lancet_font = F, outfile){
  
  library(openxlsx)
  library(dplyr)
  
  #--------- Set up Lancet fonts --------------
  # Defines the font families
  library(extrafont)
  loadfonts()
  if (lancet_font == T){
    f3 <- "Shaker 2 Lancet Regular"
  } else {
    f3 <- "Times"
  }
  
  specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall=k))
  specify_sigfig <- function(x, k){
    return(gsub("\\.$", "", formatC(signif(x,digits=k), digits=k, format="fg", flag="#")))
  }
  #----------------- Preliminary table formatting ----------------------------
  df <- as.data.table(df)
  max_length_label <- max(unlist(lapply(df[, label, with = F], nchar)))
  
  if(non.numeric == F){
    if (with.ui == T){
      upper_cols <- grep("upper.", names(df), fixed = T, value = T)
      lower_cols <- grep("lower.", names(df), fixed = T, value = T)
      val_cols <- grep("val.", names(df), fixed = T, value = T)
      data_cols <- c(val_cols, upper_cols, lower_cols)
    } else {
      data_cols <- grep("val.", names(df), value = T)
    }
    
    ## Change decimal to midline (interpunct) decimal 
    options(OutDec="\u0B7")
    
    if (rounded){
      df[, (data_cols) := lapply(df[,data_cols, with = F], specify_sigfig, k = 3)]
    }
    df[, (data_cols) := lapply(.SD, function(x) prettyNum(x, big.mark = ',')), .SDcols = data_cols]
    df[, (data_cols) := lapply(.SD, as.character), .SDcols = data_cols]
    df[, (data_cols) := lapply(.SD, function(x) trimws(x)), .SDcols = data_cols]
    max_length <- max(unlist(lapply(df[, data_cols, with = F], nchar)))
    
    if (with.ui == T){
      for (val in val_cols){
        base_name <- gsub("val.", "", val, fixed = T)
        lower <- paste0("lower.", base_name)
        upper <- paste0("upper.", base_name)
        
        
        df[(grepl("NA", df[, get(val)]) | is.na(df[, get(val)])), (val):='--']
        df[!grepl("--", df[, get(val)]), new :=do.call(paste, c(.SD, sep =as.character("\u2013"))), .SDcols=c(lower, upper)]
        df[!grepl("--", df[, get(val)]), new := paste0("(", new, ")")]
        df[!grepl("--", df[, get(val)]), (val) := do.call(paste, c(.SD, sep ="\n")), .SDcols=c(val, "new")]
        df <- df[, -c("new")] 
        
      }
      
      df <- df[, !upper_cols, with = F]
      df <- df[, !lower_cols, with = F]
    } else {
      val_cols <- data_cols
    }
  } else {
    max_length <- max(unlist(lapply(df[, !label, with = F], nchar)))
  }
  
  #----------------- Create Lancet styles to be applied to a worksheet -------
  ## Create header style
  header_style <- createStyle(fontName = f3, fontSize = 8, border = c("top", "left", "right","bottom"), fgFill = "#000000", textDecoration = "bold",
                              fontColour = "#ffffff",borderStyle = "medium", halign = "left", wrapText = F)
  title_pink <- createStyle(fontName = f3, fontSize = 8, textDecoration = "bold",
                            fgFill = "#F2DCDB", halign = "left", valign = "center", wrapText = T)
  
  ## CREATE STYLE OBJECTS FOR ALTERNATE METHOD
  if (alternate == T){
    alt_pink <- createStyle(fontName = f3, fontSize = 8, border = c("left", "right"),
                            borderStyle = "medium", fgFill = "#F2DCDB", halign = "center", wrapText = T)
    alt_main <- createStyle(fontName = f3, fontSize = 8, border = c("left", "right"),
                            borderStyle = "medium", halign = "center", wrapText = T)
    alt_title <- createStyle(fontName = f3, fontSize = 8, border = c("left", "right", "bottom", "top"),
                             borderStyle = "medium", fgFill = "#F2DCDB", textDecoration = "bold", halign = "left", valign = "center", wrapText = T)
    alt_last_pink <- createStyle(fontName = f3, fontSize = 8, border = c("left", "right", "bottom"),
                                 borderStyle = "medium", fgFill = "#F2DCDB", halign = "center", wrapText = T)
    alt_last_main <- createStyle(fontName = f3, fontSize = 8, border = c("left", "right", "bottom"),
                                 borderStyle = "medium", halign = "center", wrapText = T)
    alt_last_for_border <- createStyle(fontName = f3, fontSize = 8, border = "top",
                                       borderStyle = "medium", halign = "center", wrapText = T)
    
    ## FOR HIERARCHICAL DATA, CREATES A LIST OF STYLE OBJECTS PER EACH LEVEL
    if (hierarchy == T){
      style_white <- list()
      style_pink <- list()
      count <- 0
      indent <- 0
      lvls <- sort(unique(df$level))
      for(lvl in lvls){
        count <- count + 1
        if (lvl == 0 | lvl == 1){
          style_pink[[count]] <- createStyle(fontName = f3, fontSize = 8, fgFill = "#F2DCDB", border = c("left", "right"), borderStyle = "medium", wrapText = T)
          style_white[[count]] <- createStyle(fontName = f3, fontSize = 8, border = c("left", "right"), borderStyle = "medium", wrapText = T)
        } else {
          indent <- indent + 1
          style_pink[[count]] <- createStyle(fontName = f3, fontSize = 8, fgFill = "#F2DCDB", indent = indent, border = c("left", "right"), borderStyle = "medium", wrapText = T)
          style_white[[count]] <- createStyle(fontName = f3, fontSize = 8, indent = indent, border = c("left", "right"), borderStyle = "medium", wrapText = T)
        }
      }    
      
    }
    
    ## CREATE STYLE OBJECTS FOR LANCET METHOD
  } else {
    lancet_main_pink <- createStyle(fontName = f3, fontSize = 8, textDecoration = "bold",
                                    fgFill = "#F2DCDB", halign = "center", wrapText = T)
    lancet_main <- createStyle(fontName = f3, fontSize = 8, halign = "center", wrapText = T)
    
    ## FOR HIERARCHICAL DATA, CREATES A LIST OF STYLE OBJECTS PER EACH LEVEL
    if(hierarchy == T){
      style <- list()
      count <- 0
      indent <- 0
      lvls <- sort(unique(df$level))
      for(lvl in lvls){
        count <- count + 1
        if (lvl == 0 | lvl == 1){
          style[[count]] <- createStyle(fontName = f3, fontSize = 8, textDecoration = "bold", fgFill = "#F2DCDB", wrapText = T)
        } else {
          indent <- indent + 1
          style[[count]] <- createStyle(fontName = f3, fontSize = 8, indent = indent, wrapText = T)
        }
      }    
    }
  }
  
  #----------------- Select rows to apply different styles to for hierarchical data ----------------
  
  if (hierarchy == T){
    df <- df[order(sort_order),]
    header <- list()
    count <- 0
    for(lvl in lvls){
      count <- count + 1
      header[count] <- as.data.table(which(df$level %in% lvl) + 2)
      if (sdi == T){
        sdi_rows <- grep("SDI", df[[label]]) + 2
        if (lvl == 1){
          temp <- as.data.table(header[count])
          header[count] <- temp[!(temp$V1 %in% sdi_rows),]
        } else if (lvl == 2){
          temp <- unlist(header[count])
          header[count] <- as.data.table(c(temp, sdi_rows))
        }
      }
    }
    
    last_row_level <- df[nrow(df)]$level
    df <- df[, -c("sort_order", "level")]
  }
  
  # Ensure that label is always first column
  names <- names(df)
  names_order <- names[!(names == label)]
  names_order <- c(label, names_order)
  df <- df[, names_order, with = F]
  
  
  #----------------- Create, write to, and save excel book----------------------
  
  names(df) <- gsub("val.", "",names(df), fixed = T)
  
  wb <- createWorkbook()
  addWorksheet(wb, "sheet1")
  pageSetup(wb, 1, orientation = "portrait", scale = 100, left = 0.25,
            right = 0.25, top = 0.75, bottom = 0.75, header = 0.3, footer = 0.3,
            fitToWidth = T)
  if (alternate == T){
    sCol = 1
  } else {
    sCol = 2
  }
  writeData(wb, 1, df, startCol = sCol, startRow = 2)
  
  ## APPLIES STYLE OBJECTS TO DATA FOR LANCET STYLE
  if (alternate == F){
    if (!(is.null(title))){
      writeData(wb, 1, title, startCol = sCol, startRow = 1) 
      addStyle(wb, 1, style = header_style, rows = 1, cols = 1:(ncol(df)+2), gridExpand = T)
      addStyle(wb, 1, style = title_pink, rows = 2, cols = 1:(ncol(df)+1), gridExpand = T)
    } else {
      addStyle(wb, 1, style = title_pink, rows = 2, cols = 1:(ncol(df)+1), gridExpand = T)
    }
    
    # Creates pink borders
    addStyle(wb, 1, style = lancet_main_pink, rows = 2:(nrow(df) + 2), cols = 1, gridExpand = T)
    addStyle(wb, 1, style = lancet_main_pink , rows = nrow(df) + 3, cols = 1:(ncol(df)+1), gridExpand = T)
    addStyle(wb, 1, style = lancet_main_pink, rows = 2:(nrow(df) + 3), cols = (ncol(df)+2) , gridExpand = T)
    
    # Styles row names
    if (hierarchy == T){
      for (j in 1:length(lvls)){
        addStyle(wb, 1, style = style[[j]], rows = header[[j]], cols = 2, gridExpand = T)
        if (lvls[j] == 0 | lvls[j] == 1){
          addStyle(wb, 1, style = lancet_main_pink, rows = header[[j]], cols = 3:(ncol(df)+1), gridExpand = T)
        } else {
          addStyle(wb, 1, style = lancet_main, rows = header[[j]], cols = 3:(ncol(df)+1), gridExpand = T)
        }
      }
    } else {
      addStyle(wb, 1, style = lancet_main, rows = 3:(nrow(df)+2), cols = 2:(ncol(df)+1), gridExpand = T)
    }
    
    
    ## APPLIES STYLE OBJECTS TO DATA FOR ALTERNATE STYLE
  }  else {
    if (!(is.null(title))){
      writeData(wb, 1, title, startCol = sCol, startRow = 1) 
      addStyle(wb, 1, style = header_style, rows = 1, cols = 1:(ncol(df)), gridExpand = T)
      addStyle(wb, 1, style = alt_title, rows = 2, cols = 1:(ncol(df)), gridExpand = T)
    } else {
      addStyle(wb, 1, style = alt_title, rows = 2, cols = 1:(ncol(df)), gridExpand = T)
    }
    
    addStyle(wb, 1, style = alt_pink, rows = seq(3,(nrow(df)+2), 2), cols = 1:(ncol(df)), gridExpand = T)
    addStyle(wb, 1, style = alt_main, rows = seq(4, (nrow(df)+2), 2), cols = 1:(ncol(df)), gridExpand = T)
    
    if (hierarchy == T){
      for (j in 1:length(lvls)){
        temp <- unlist(header[j])
        pink_h <-  temp[lapply(temp, "%%", 2) == 1]
        white_h <- temp[lapply(temp, "%%", 2) == 0]
        
        addStyle(wb, 1, style = style_pink[[j]], rows = pink_h, cols = 1, gridExpand = T)
        addStyle(wb, 1, style = style_white[[j]], rows = white_h, cols = 1, gridExpand = T)
      }
    }
    if (((nrow(df) + 1) %% 2) == 0){
      addStyle(wb, 1, style = alt_last_pink, rows = (nrow(df)+2), cols = 2:(ncol(df)), gridExpand = T)
    } else {
      addStyle(wb, 1, style = alt_last_main, rows = (nrow(df)+2), cols = 2:(ncol(df)), gridExpand = T)
    }
    addStyle(wb, 1, style = alt_last_for_border, rows = (nrow(df) + 3), cols = 1, gridExpand = T)
  }
  
  # Sets colwidth / rowheight
  setColWidths(wb, 1, cols = 2, widths = max_length_label - (max_length_label * 0.33))
  if(alternate == F){
    setColWidths(wb, 1, cols = 1, widths = 2)
    setColWidths(wb, 1, cols = ncol(df)+2, widths = 2)
  } else {
    setColWidths(wb, 1, cols = 1, widths = 40)
  }
  setColWidths(wb, 1, cols = (sCol + 1):(ncol(df) + (2 - 1)), widths = "auto")
  setRowHeights(wb, 1, rows = nrow(df) +3, heights = 40)
  if (with.ui == T){
    setRowHeights(wb, 1, rows = 1:(nrow(df)+2), heights = 24)
  } else {
    setRowHeights(wb, 1, rows = 1:(nrow(df)+2), heights = "auto")  
  }
  saveWorkbook(wb, paste0(outfile), overwrite = TRUE)
  options(OutDec=".")
}