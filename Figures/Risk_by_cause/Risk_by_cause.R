rm(list = ls())

## Load libraries
library(tidyverse)
library(reshape2)
library(writexl)
library(RColorBrewer)
library(scales)
library(ggplot2)
library(extrafont)
loadfonts()
options(scipen = 999)

## Define fonts
f1 <- "Times"
f2 <- "ScalaLancetPro"
f3 <- "Shaker 2 Lancet Regular"

## -----------------------------------------------------------------------------
## Directories and file paths

## CODE DIRECTORY
## Update with path to code directory
user_repo <- "path/to/code/directory/"

## INPUT DATA
## Sample data can be downloaded from GBD Results Tool
# https://vizhub.healthdata.org/gbd-results?params=gbd-api-2021-permalink/75e5a860bf697d674cb368a220496492

## Path to sample data
input_data <- fread(paste0(user_repo, "external_publications/Figures/Risk_by_cause/input/sample_data.csv"))
## OR 
## Update with path to your input data
input_data <- fread("path/to/input/data.csv")

## OUTPUT DIRECTORY
## Update with path to output directory for final figure
out_dir <- "path/to/output/directory/"
output_filepath <- paste0(out_dir, "Level_2_risks_by_cause.pdf")

## -----------------------------------------------------------------------------

## Hierarchies
risks <- fread(paste0(user_repo, "/external_publications/hierarchies/risk_GBD2021.csv"))
causes <- fread(paste0(user_repo, "/external_publications/hierarchies/cause_GBD2021.csv"))
hist_colors <- fread(paste0(user_repo, "/external_publications/Figures/Risk_by_cause/input/hist_colors.csv"))

## Select level 2 causes and match to their GBD colors
lvl <- 2
causes <- causes[level == lvl]

cause_color <- merge(causes, hist_colors, by.x = "cause_name", by.y = "cause")

setorder(cause_color, 'sort_order')
colors <- unique(cause_color$hex)

## Risks for analysis
## At lower level risk, we need to be sure to include most_detailed

lvl2_risks <- risks[level == 2 | (level < 2 & most_detailed == 1), rei_id]
lvl3_risks <- risks[level == 3 | (level < 3 & most_detailed == 1), rei_id]

## Create sorting by total risk attributable
df = input_data

df[, sum := sum(val), by = c('rei_id', 'age_id', 'year', 'measure_id', 'metric_id', 'sex_id')]

### Create sorting for causes
df <- merge(df, cause_color[, .(cause_id, cause_medium, sort_order, hex)], by = 'cause_id')
setorder(df, 'sort_order')

## Level 2 Plot
df_lvl2 <- df[rei_id %in% lvl2_risks]
colors <- unique(df_lvl2$hex)


## Create figure
lvl2_plot <- ggplot(df_lvl2, 
                    aes(
                    x = reorder(rei_name, sum), # sort on the total attributable
                    y = val, # the height of each cause/risk pair
                    fill = reorder(cause_name, sort_order)), # sort causes according to the cause_hierarchy
                    color = "black") +
  geom_bar(stat = "identity", width = .6) + coord_flip()   +
  scale_fill_manual(values = colors) + # build colors according to causes
  xlab(NULL) + # remove labels for risks
  ylab("DALY Numbers") + # label for your measure and metric
  ggtitle(paste0("Global Risk Attibutable Deaths, Both sexes, All ages, 2021")) +
  
  theme_bw()+
  
  scale_y_continuous(expand = c(0, 0)) +
  geom_hline(yintercept = 0, linewidth = .1) +
  
  guides(fill = guide_legend(ncol = 6)) +
  ### additional formatting
  theme(axis.title.x = element_text(face = "bold", color = "black", size = 7),
        axis.title.y = element_text(face = "bold", color = "black", size = 7),
        axis.text.x = element_text(color = "black", size = 7),
        axis.text.y = element_text(color = "black", size = 6),
        plot.title = element_text(face = "bold", color = "black", size = 7, hjust = 0.5),
        legend.position = "bottom",
        strip.text = element_text(size = 6, face = "bold"),
        legend.background = element_blank(),
        legend.key = element_blank(),
        legend.text = element_text(size = 5),
        legend.title = element_blank(),
        legend.key.size = unit(0.3, "cm"),
        plot.margin = unit(c(0.1, 0.1, 0.1, 0.1), "inch"),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black")
  )

## Save as pdf
pdf(file = output_filepath, height = 6, width = 10)
plot(lvl2_plot)
dev.off()
