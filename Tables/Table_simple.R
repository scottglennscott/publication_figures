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

#################################################
#################################################

library(data.table)
library(openxlsx)

  library(extrafont)
loadfonts()
if (lancet_font == T){
  f3 <- "Shaker 2 Lancet Regular"
} else {
  f3 <- "Times"
}

  value_columns = c('val', 'upper', 'lower')

ui_formatting <- function(df, value_columns = c('val', 'lower', 'upper'), 
                          index_columns = c('cause_id', 'age_group_id', 'location_id', 'year_id', 'sex_id'), 
                          round = 1, bullet = F, 
                          seperator = ' - '){
  if(bullet){options(OutDec="\u0B7")}
     df = as.data.table(df)
    df = df[, round(.SD, round), by = index_columns, .SDcols = value_columns]
    df$text = paste0(df[[value_columns[1]]], '\n(', df[[value_columns[2]]], seperator, df[[value_columns[3]]], ')')
    df[, text := gsub("NA", '--', text)]
    df = data.frame(df)
    df = df[,c(index_columns, 'text')]
    
    return(df)
}


#----------------- Create Lancet styles to be applied to a worksheet -------

print_table = function(df)

## Create header style
header_style <- createStyle(fontName = f3, fontSize = 8, border = c("top", "left", "right","bottom"), fgFill = "#000000", textDecoration = "bold",
                            fontColour = "#ffffff",borderStyle = "medium", halign = "left", wrapText = F)
title_pink <- createStyle(fontName = f3, fontSize = 8, textDecoration = "bold",
                          fgFill = "#F2DCDB", halign = "left", valign = "center", wrapText = T)

## CREATE STYLE OBJECTS FOR ALTERNATE METHOD
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
  

#----------------- Create, write to, and save excel book----------------------


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




  