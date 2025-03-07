![logo](ihme.png)
# Code Used for GBD Figures and Tables
## Context
GBD papers normally use a number of tools to produce figures and table to be used by journal. One major journal requirement is to have Vector Editable figures.
This means that figures pulled directly from GBD Compare cannot be used for Publications. We use the programming Language R, and Python to produce
our Figures and Tables. Figures are outputed in the form of Vector PDFs. Tables are exported as Excel Workbooks.

## [Figures](Figures)
Basic figures that can be found on GBD Compare or in previous Journal articles are found here.
### [Arrow Diagram](Figures/Arrow_diagram/)
This figure displays the ranking of causes between years. Included Percent Change and the "residual" causes (Causes that appeared in the top causes in one year but not in 
other years) Figure is produced using R to prepare the data for use and in Python to produce the figure
### [Global Map](Figures/Global_map/)
A global map using the same color pallette as GBD Compare. Included in this subfolder is a GBD Shapefile with location_ids so that the shapefile can be matched
to GBD data.
### [Risk by Cause](Figures/Risk_by_cause/)
Plot of risk attributable health loss and how risk/cause pairs contribute to health loss. Included the proper color hexes to match colors used to represent causes in GBD Compare 
and other GBD Publications
## [Tables](Tables)
#### Lancet Table
Function to produce full Lancet Tables with formatting for hierarchy, including indentation for different causes or locations on the hierarchy.

## Instructions
1. Clone or download this repository. 
2. Select Needed Data from GBD Results Tool (For example change location to location of interest, or age_group to needed age_group)
    - Each Figure Code contains a link to the data that was used in the creation of the sample Figure.
3. Replace Sample Data used in figure and Table production with downloaded data.
4. Replace `user_dir` with where you saved the code
5. Replace `out_dir` with where you would like the figure saved.
6. Run code!

## Resources
[GBD Results Tool](https://vizhub.healthdata.org/gbd-results/)

[GBD Compare](https://vizhub.healthdata.org/gbd-compare/)

[Download R](https://www.r-project.org/)

[Download Python](https://www.python.org/downloads/)

[Getting Started with R](https://rafalab.dfci.harvard.edu/dsbook/getting-started.html)
