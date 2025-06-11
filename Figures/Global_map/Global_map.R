rm(list = ls())

## Load in Packages
library(data.table)
library(ggplot2)
library(stringr)
library(sf)
library(RJSONIO)
library(RColorBrewer)
library(stringi)
options(scipen = 999)

## ---------------------------------------------------------------------------------------------------------
## Directories and file paths

## CODE DIRECTORY
## Update with path to code directory
user_dir <- "path/to/code/directory/"

## INPUT DATA
## Download data from GBD Results Tool
## https://vizhub.healthdata.org/gbd-results?params=gbd-api-2021-permalink/3a9fb42b9a77ef72640999e89dc23771

## Path to sample data
input_data <- fread(paste0(user_dir, "external_publications/Figures/Global_map/Inputs/sample_data.csv"))
##OR
## Update with path to your input data
#input_data <- fread("path/to/input/data.csv")

## OUTPUT DIRECTORY
## Update with path to output directory for final figure
out_dir <- "path/to/output/directory/"
output_filepath <- paste0(out_dir, "Global_map.pdf")

## ---------------------------------------------------------------------------------------------------------

## Shapefiles
map1 <- st_read(paste0(user_dir, "/external_publications/Figures/Global_map/Shapefile/GBD_shapefile.shp"))
disputed = st_read(paste0(user_dir, "/external_publications/Figures/Global_map/Shapefile/disputed.shp"))

## LOAD DATA
df <- input_data

## Create color palette
colors <- brewer.pal(11, 'RdYlBu')

## Merge data with shapefile
map <- merge(df, map1, by.x = 'location_id', by.y = 'loc_id', all.y = T)

## Convert to sf type file for plotting  
map <- st_as_sf(map, crs = 4326)

## Create map
plot <- ggplot(map) +
    geom_sf(aes(fill = val), 
            color = 'black', linewidth = .05) +
    geom_sf(data = disputed, linetype = 2, fill = NA, show.legend = F) +
    theme_void() +
      scale_fill_distiller('', palette = "RdYlBu") +
    ggtitle('All-cause DALYs per 100,000, Both sexes, All ages, 2021') + # Update figure name as needed
    theme(  legend.position = 'bottom',
            legend.text = element_text(size = 12),
            legend.key.width = unit(3, 'cm'))

  
## Save map
  pdf(file = output_filepath, height = 6, width = 14)
  plot(plot)
  dev.off()

