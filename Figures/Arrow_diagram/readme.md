[LINK TO FIGURE ON GBD COMPARE](http://ihmeuw.org/6us5)
# Arrow diagrams are built in R and in Python.
![screenshot](inputs/arrow.png)
## R is used to transform the data into the correct structure used by the python script. 

### Steps
#### Run arrow_data_prep.R 
1. Install needed packages
2. Change `user_repo` to your directory
3. Data can be downloaded from GBD Results Tool 
    - (link in code set up for Global level 3 deaths)
4. Run script. Data will be outputted as arrow_prep.csv

#### Run arrow_chart_gen.py

required packages in your Python Environment:
- pandas
- reportlab

The python script `arrow_chart_py` will automatically read the file outputted through R

#### Run
run within directory where code is stored
run `python arrow_chart_gen.py`