[LINK TO FIGURE ON GBD COMPARE](http://ihmeuw.org/6us5)
# Arrow diagrams are built in R and in Python.
![screenshot](inputs/arrow.png)
## R is used to transform the data into the correct structure used by the python script. 

### Steps
#### Run 0_launch_arrow_diagram.R 
1. Change `user_repo` to your directory
2. Update input data. Data can be downloaded from GBD Results Tool. 
    - link in code set up for Global level 3 deaths
    - update lines 15 and 18 so that `df` reads in the correct filepath for your data
3. (Optional) Update the years for the arrow diagram columns in lines 34, 35, and 36. 
4. Run `0_launch_arrow_diagram.R` script. 
    - Data will be outputted as arrow_prep.csv
    - Figure will be outputted as arrow_{measure}_{location}.pdf


#### What is 0_launch_arrow_diagram.R doing?
1. It reformats your input data using `arrow_data_prep.R`
2. It runs `launch_python_code.R`, which installs reticulate and miniconda if needed, any required packages, and then...
3. It runs python script `arrow_chart_gen.py` from within RStudio. 

All packages should install automatically if required.
 
required packages in Rstudio:
- data.table
- reticulate: https://rstudio.github.io/reticulate/

required packages in your Python Environment:
- pandas
- reportlab



