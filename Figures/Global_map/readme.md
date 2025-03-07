[LINK TO FIGURE ON GBD COMPARE](http://ihmeuw.org/6us4)
![screenshot](Inputs/map.png)
# Global Map
GBD uses a GBD Shapefile for mapping in analysis and in figure creation.
Two shapefiles are included. `GBD_shapefile` for all GBD national and territorially locations and `disputed` for the mapping of disputed boundaries
## Mapping
GBD mapping uses the R package `sf` and `ggplot` this makes mapping easier that relying on ArcGIS and other tools. Final maps are outputed as PDFs
Data used for Mapping can be found by using the GBD Results Tool. Sample data is included hear of Global DALYs, 2021.