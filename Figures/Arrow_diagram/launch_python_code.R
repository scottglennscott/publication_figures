## Run python script from R
## Update directory only if you need to
setwd(paste0(user_repo, "external_publications/Figures/Arrow_diagram"))

print("installing packages if needed...")
## install reticulate only if needed
if (!("reticulate" %in% installed.packages())) {
  install.packages("reticulate")
}

## install miniconda only if needed
if (!dir.exists(reticulate::miniconda_path())) {
  reticulate::install_miniconda()
}

## create conda environment only if needed
if (!("arrow_chart" %in% reticulate::conda_list()$name)) {
  reticulate::conda_create(envname = "arrow_chart", python_version = "3.9", packages = c("reportlab", "pandas"))
}
## Load python conda environment created above 
print("loading python environment...")
library(reticulate)
conda_location <- subset(reticulate::conda_list(), name == 'arrow_chart')$python
reticulate::use_python(conda_location)

## Create figure
print("creating figure...")
## Update filepath only if you need to
source_python(paste0(user_repo, "external_publications/Figures/Arrow_diagram/arrow_chart_gen.py"))
print(paste("Figure saved to", getwd()))
