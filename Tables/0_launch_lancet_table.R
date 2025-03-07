## Lancet Table Use Example Script
## Data needs to be restructured to align with needs of Lancet_table.R

library(data.table)

### Parameters

user_repo = '/PATH/TO/YOUR/DIRECTORY'
user_repo = '~/ext_pubs'
outdir = 'PATH/TO/WHERE/Table/SAVED'
outdir = '~/ext_pubs'
## LOAD PACKAGE

source(paste0(user_repo, '/external_publications/Tables/Lancet_Format.R'))


### Pull data from GBD Results Tool
##DATA
# https://vizhub.healthdata.org/gbd-results?params=gbd-api-2021-permalink/73ba5ad297422be521dde9246b8c7cf7
data = fread(paste0(user_repo, '/external_publications/Tables/Inputs/sample_data.csv'))

## We will be making a table of all locations


#Need to Reshape data.
## Data most be stored according to "val.'Variable Name', lower.'Variable Name', upper.'Variable Name'
# Data here is unique by Location. But we have two variables of interest. Metric by Number and by Rate

### We will use dcast to shape data from long to wide. 
# https://www.statology.org/long-vs-wide-data/


data = dcast(data, location_id+location_name~metric_name, value.var = c('val', 'lower', 'upper'), sep = '.')

# use setnames() to change variable to desired Column title if needed
setnames(data, c('val.Number', 'lower.Number', 'upper.Number'), c('val.Count', 'lower.Count', 'upper.Count'))

###### Building hierarchy
# The Lancet Table builds out based on a Hiearchy. With higher level locations/causes/risks 
# Being bolded and lower levels, indented

# Here we will be using the location hierarchy

locations = fread(paste0(user_repo, '/external_publications/hierarchies/location_GBD2021.csv'))

## Only keep the variables we need for our table from the hierarchy
locations = locations[,.(location_id, sort_order, level)]

data = merge(data, locations, by = 'location_id')

## Only keep variables needed to create table.

data = data[,.(location_name, level, sort_order, val.Count, lower.Count, upper.Count, val.Rate, lower.Rate, upper.Rate)]

# Change you label name to what you would want the column to be labeled as

setnames(data, 'location_name', 'Location')

## Make Table
# This table will use the location hierarchy
as_lancet_table(data, label = 'Location', hierarchy = T, title = 'All cause DALYs, 2021, both sexes All ages', outfile = paste0(outdir , '/external_publications/Tables/DALYs_table_example.xlsx'))


