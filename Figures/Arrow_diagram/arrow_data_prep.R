## Load libraries
library(data.table)

print("reformatting data for arrow diagram...")
causes <- fread(causes_filepath)

## Select all level 3 causes along with other Covid related
cids <- causes[level == 3 | cause_id == 1058, cause_id]
causes[cause_outline %like% 'A', cause_type := 'A']
causes[cause_outline %like% 'B', cause_type := 'B']
causes[cause_outline %like% 'C', cause_type := 'C']
causes[cause_outline %like% 'D', cause_type := 'D']

lid <- unique(df$location_id)
meas_id <- unique(df$measure_id)
sid <- unique(df$sex_id)

## Make values into text
df[, text := paste0(trimws(format(round(val, digits = 1), big.mark = ',')), ' (',
                    trimws(format(round(lower, digits = 1), big.mark = ',')), ' to ',
                    trimws(format(round(upper, digits = 1), big.mark = ',')), ')')]

## Drop any not-estimated causes
df <- na.omit(df)

## Set order for ranking
setorder(df, -'val')

df[, rank := 1:.N, by = 'year']

df <- merge(df, causes[, .(cause_medium, cause_id, cause_type)], by = 'cause_id')

df[year == year1, year_nm := 'year1']
df[year == year2, year_nm := 'year2']
df[year == year3, year_nm := 'year3']


df_all <- as.data.table(df)
df <- as.data.table(df)

df <- data.table::dcast(df, rank ~ year_nm, 
                        value.var = c('cause_medium', 'cause_type', 'text', 'cause_id'))

df <- df[rank <= 25]

## Building out residuals
## Find top causes for residuals
top_cids <- unique(c(unique(df$cause_id_year1), unique(df$cause_id_year2), unique(df$cause_id_year3)))

resid <- df_all[cause_id %in% top_cids & rank > 25]

resid_year1 <- resid[year == year1]
resid_year2 <- resid[year == year2]
resid_year3 <- resid[year == year3]


## Set column names and subset to required columns
setnames(resid_year1, 
         c('cause_medium', 'cause_type', 'rank', 'text', 'year', 'cause_id'), 
         c('cause_medium_year1', 'cause_type_year1', 'rank_year1', 'text_year1', 'year1', 'cause_id_year1'))
setnames(resid_year2, 
         c('cause_medium', 'cause_type', 'rank', 'text', 'year', 'cause_id'), 
         c('cause_medium_year2', 'cause_type_year2', 'rank_year2', 'text_year2', 'year2', 'cause_id_year2'))
setnames(resid_year3, 
         c('cause_medium', 'cause_type', 'rank', 'text', 'year', 'cause_id'), 
         c('cause_medium_year3', 'cause_type_year3', 'rank_year3', 'text_year3', 'year3', 'cause_id_year3'))

resid_year1 = resid_year1[, c('cause_medium_year1', 'cause_type_year1', 'rank_year1', 
                              'text_year1', 'year1', 'cause_id_year1')]
resid_year2 = resid_year2[, c('cause_medium_year2', 'cause_type_year2', 'rank_year2', 
                              'text_year2', 'year2', 'cause_id_year2')]
resid_year3 = resid_year3[, c('cause_medium_year3', 'cause_type_year3', 'rank_year3', 
                              'text_year3', 'year3', 'cause_id_year3')]

## Order datasets and bind into single dataset
setorder(resid_year1, 'rank_year1')
setorder(resid_year2, 'rank_year2')
setorder(resid_year3, 'rank_year3')
resid <- cbind(resid_year1, resid_year2)
resid <- cbind(resid, resid_year3)

df[, rank_year1 := rank]
df[, rank_year2 := rank]
df[, rank_year3 := rank]

df[, year1 := year1]
df[, year2 := year2]
df[, year3 := year3]

df <- rbind(df, resid, fill= T)

df[, resid := 0]
df[rank_year1 > 25 | rank_year2 > 25 | rank_year3 > 25, resid := 1]

setorder(df, 'rank_year1')
df[, location_id := lid]
df[, measure_id := meas_id]
df[, sex_id := sid]
write.csv(df, output_filepath, row.names = F)

print("Creating arrow diagram from create_arrow_diagram.R")
source("launch_python_code.R")
