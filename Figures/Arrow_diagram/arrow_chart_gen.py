
# coding: utf-8

# In[35]:

from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import landscape, letter
import pandas as pd
import os
# add custom modules directory

dir = os.getcwd()
locs = pd.read_csv('inputs/location_GBD2021.csv')
loc_dict = dict(zip(locs.location_id.tolist(), locs.location_name.tolist()))
sex_dict = {1:'Males', 2:'Females', 3:'Both sexes'}
meas_dict = {1:'Deaths', 2:'DALYs', 3:'YLDs', 4:'YLLs'}

df = pd.read_csv('inputs/arrow_prep.csv')

lid = df.location_id.tolist()[0]
meas_id = df.measure_id.tolist()[0]
sid = df.sex_id.tolist()[0]
sex_name = sex_dict[sid]
loc_name = loc_dict[lid]
meas_name = meas_dict[meas_id]

year1 = str(df.year1.tolist()[0])
year2 = str(df.year2.tolist()[0])
year3 = str(df.year3.tolist()[0])


title = 'Leading 25 causes of ' + meas_name + ' in ' + loc_name + ' with percent change, both sexes ' + year1 + ', ' + year2 + ', and ' + year3
rank = 25

outfile = '/arrow_' +  meas_name + '_' + loc_name + '.pdf'
#### import datafrom

#### open file for writing
file = dir + outfile
c = canvas.Canvas(file, pagesize=(800, 650))

#### text size and style
titletextsize = 14
textsize = 7.5
textgap = textsize*1.5


#### write title
titley = 600
titlex = 370
row1 = titley-(2*textgap)
row2 = row1-(0.75*textgap)
row3 = row2-(0.75*textgap)
row4 = row3-(0.75*textgap)
row5 = row4-(0.75*textgap)
c.setFont("Helvetica-Bold",titletextsize)
c.drawString(titlex-(c.stringWidth(
        '{title}'.format(title=title))/2),
        titley,
        '{title}'.format(title=title))


#### write column headers
c.setFont("Helvetica-Bold",textsize)
columnwidth1 = 115
columnwidth2 = 90
columnwidth3 = 115
columnwidth4 = 90
columnwidth5 = 115
columnwidth6 = 90
gap = 65

# set columns widths (counting from left to right)
column1 = 30
column2 = column1 + columnwidth1 + 3
column3 = column2 + columnwidth2 + gap
column4 = column3 + columnwidth3 + 3
column5 = column4 + columnwidth4 + gap
column6 = column5 + columnwidth5 + 3

# name columns
c.drawString(column1,row5,'Leading causes {year1}'.format(year1=year1))
c.drawString(column2,row4,'Rate per 100,000'.format(meas_name = meas_name, year1=year1))
c.drawString(column2,row5,'{meas_name} {year1}'.format(meas_name = meas_name, year1=year1))

c.drawString(column3,row5,'Leading causes {year2}'.format(year2=year2))
c.drawString(column4,row4,'Rate per 100,000'.format(meas_name = meas_name, year2=year2))
c.drawString(column4,row5,'{meas_name} {year2}'.format(meas_name = meas_name, year2=year2))

c.drawString(column5,row5,'Leading causes {year3}'.format(year3=year3))
c.drawString(column6,row4,'Rate per 100,000'.format(meas_name = meas_name, year3=year3))
c.drawString(column6,row5,'{meas_name} {year3}'.format(meas_name = meas_name, year3=year3))


#### set dictionary for fill colors
fill = {
        'A':[.7490196,.2470588,.2470588],
        'B':[.2470588,.2470588,.7490196],
        'C':[.2470588,.7490196,.2470588],
        'D':[.2,.2,.2]
        }


#### loop through non residuals start year, middle year
# c.setFont("Helvetica",textsize)
iter = 1
for i in range(len(df[df.resid != 1])):
    # write text
    c.setStrokeColorRGB(0,0,0)
    c.setFillColorRGB(0,0,0)
    c.setStrokeAlpha(1)
    c.setFillAlpha(1)
    c.setFont("Helvetica",textsize)
    c.drawString(column1+1,row5-(iter*textgap),'{rank_year1} {cause_medium_year1}'.format(cause_medium_year1=df.cause_medium_year1[i],rank_year1=df.rank_year1[i]))
    c.drawString(column2+1,row5-(iter*textgap),'{text_year1}'.format(text_year1=df.text_year1[i]))

    c.drawString(column3+1,row5-(iter*textgap),'{rank_year2} {cause_medium_year2}'.format(cause_medium_year2=df.cause_medium_year2[i],rank_year2=df.rank_year2[i]))
    c.drawString(column4+1,row5-(iter*textgap),'{text_year2}'.format(text_year2=df.text_year2[i]))

    c.drawString(column5+1,row5-(iter*textgap),'{rank_year3} {cause_medium_year3}'.format(cause_medium_year3=df.cause_medium_year3[i],rank_year3=df.rank_year3[i]))
    c.drawString(column6+1,row5-(iter*textgap),'{text_year3}'.format(text_year3=df.text_year3[i]))

    # set color for start year based on cause_type
    c.setFillColorRGB(fill['{cause_type_year1}'.format(cause_type_year1 = df.cause_type_year1[i])][0],fill['{cause_type_year1}'.format(cause_type_year1 = df.cause_type_year1[i])][1],fill['{cause_type_year1}'.format(cause_type_year1 = df.cause_type_year1[i])][2])
    c.setFillAlpha(0.2)
    c.setStrokeColorRGB(fill['{cause_type_year1}'.format(cause_type_year1 = df.cause_type_year1[i])][0],fill['{cause_type_year1}'.format(cause_type_year1 = df.cause_type_year1[i])][1],fill['{cause_type_year1}'.format(cause_type_year1 = df.cause_type_year1[i])][2])
    c.setStrokeAlpha(0.7)

    # fill with color start year
    c.setDash(1,0)
    c.rect(column1,row5-(iter*textgap)-2.5,columnwidth1,textsize*1.3,stroke=1,fill=1)
    c.rect(column2,row5-(iter*textgap)-2.5,columnwidth2,textsize*1.3,stroke=1,fill=1)

    #determine rank change
    num_start = df[df.cause_medium_year1 == df.cause_medium_year1[i]].index.values[0]
    num_mid_start = df[df.cause_medium_year2 == df.cause_medium_year1[i]].index.values[0]
    num_end = df[df.cause_medium_year3 == df.cause_medium_year3[i]].index.values[0]
    num_mid_end = df[df.cause_medium_year2 == df.cause_medium_year3[i]].index.values[0]

    # detemine line type
    if num_start >= num_mid_start:
        c.setDash(1,0)
    else:
        c.setDash(3,1)

    #draw line
    c.line(column2+columnwidth2,row5-((num_start+1)*textgap)+(.33*textsize),column3,row5-((num_mid_start+1)*textgap)+(.33*textsize))



    # set color for middle year based on cause_type
    c.setFillColorRGB(fill['{cause_type_year2}'.format(cause_type_year2 = df.cause_type_year2[i])][0],fill['{cause_type_year2}'.format(cause_type_year2 = df.cause_type_year2[i])][1],fill['{cause_type_year2}'.format(cause_type_year2 = df.cause_type_year2[i])][2])
    c.setFillAlpha(0.2)
    c.setStrokeColorRGB(fill['{cause_type_year2}'.format(cause_type_year2 = df.cause_type_year2[i])][0],fill['{cause_type_year2}'.format(cause_type_year2 = df.cause_type_year2[i])][1],fill['{cause_type_year2}'.format(cause_type_year2 = df.cause_type_year2[i])][2])
    c.setStrokeAlpha(0.7)

    # fill with color middle year
    c.setDash(1,0)
    #c.rect(column2,row5-(iter*textgap)-2.5,columnwidth2,textsize*1.3,stroke=1,fill=1)
    c.rect(column3,row5-(iter*textgap)-2.5,columnwidth3,textsize*1.3,stroke=1,fill=1)
    c.rect(column4,row5-(iter*textgap)-2.5,columnwidth4,textsize*1.3,stroke=1,fill=1)

    # set color for middle year based on cause_type
    c.setFillColorRGB(fill['{cause_type_year3}'.format(cause_type_year3 = df.cause_type_year3[i])][0],fill['{cause_type_year3}'.format(cause_type_year3 = df.cause_type_year3[i])][1],fill['{cause_type_year3}'.format(cause_type_year3 = df.cause_type_year3[i])][2])
    c.setFillAlpha(0.2)
    c.setStrokeColorRGB(fill['{cause_type_year3}'.format(cause_type_year3 = df.cause_type_year3[i])][0],fill['{cause_type_year3}'.format(cause_type_year3 = df.cause_type_year3[i])][1],fill['{cause_type_year3}'.format(cause_type_year3 = df.cause_type_year3[i])][2])
    c.setStrokeAlpha(0.7)

    # fill with color middle year
    c.setDash(1,0)
    #c.rect(column2,row5-(iter*textgap)-2.5,columnwidth2,textsize*1.3,stroke=1,fill=1)
    c.rect(column5,row5-(iter*textgap)-2.5,columnwidth5,textsize*1.3,stroke=1,fill=1)
    c.rect(column6,row5-(iter*textgap)-2.5,columnwidth6,textsize*1.3,stroke=1,fill=1)
 
    if num_mid_end >= num_end:
        c.setDash(1,0)
    else:
        c.setDash(3,1)

    #draw line
    c.line(column4+columnwidth4,row5-((num_mid_end+1)*textgap)+(.33*textsize),column5,row5-((num_end+1)*textgap)+(.33*textsize))


    # iterate
    iter = iter + 1


# store column iterations
legend_iter = iter
resid_year1_iter = iter
resid_year2_iter = iter
resid_year3_iter = iter

c.setFont("Helvetica",textsize)
#### loop through resids
for i in range((iter-1),len(df)):

    num_start = df[df.cause_medium_year1 == df.cause_medium_year1[i]].index.values[0]
    num_mid_start = df[df.cause_medium_year2 == df.cause_medium_year1[i]].index.values[0]
    num_end = df[df.cause_medium_year3 == df.cause_medium_year3[i]].index.values[0]
    num_mid_end = df[df.cause_medium_year2 == df.cause_medium_year3[i]].index.values[0]

    # set text colors
    c.setStrokeColorRGB(0,0,0)
    c.setFillColorRGB(0,0,0)
    c.setStrokeAlpha(1)
    c.setFillAlpha(1)

    # write all resids for middle year
    c.drawString(column3,row5-(resid_year2_iter*textgap),'{rank_year2} {cause_medium_year2}'.format(cause_medium_year2=df.cause_medium_year2[i],rank_year2=df.rank_year2[i]))
    c.drawString(column5,row5-(resid_year3_iter*textgap),'{rank_year3} {cause_medium_year3}'.format(cause_medium_year3=df.cause_medium_year3[i],rank_year3=df.rank_year3[i]))
    resid_year2_iter = resid_year2_iter + 1
    resid_year3_iter = resid_year3_iter + 1


    c.setStrokeColorRGB(0,0,0)
    c.setFillColorRGB(0,0,0)
    c.setStrokeAlpha(1)
    c.setFillAlpha(1)

    #write text
    c.drawString(column1+1,row5-(resid_year1_iter*textgap),'{rank_year1} {cause_medium_year1}'.format(cause_medium_year1=df.cause_medium_year1[i],rank_year1=df.rank_year1[i]))

    # detemine line type
    if num_start >= num_mid_start:
        c.setDash(1,0)
    else:
        c.setDash(3,1)

    # set color for start year based on cause_type
    c.setFillColorRGB(fill['{cause_type_year1}'.format(cause_type_year1 = df.cause_type_year1[i])][0],fill['{cause_type_year1}'.format(cause_type_year1 = df.cause_type_year1[i])][1],fill['{cause_type_year1}'.format(cause_type_year1 = df.cause_type_year1[i])][2])
    c.setFillAlpha(0.2)
    c.setStrokeColorRGB(fill['{cause_type_year1}'.format(cause_type_year1 = df.cause_type_year1[i])][0],fill['{cause_type_year1}'.format(cause_type_year1 = df.cause_type_year1[i])][1],fill['{cause_type_year1}'.format(cause_type_year1 = df.cause_type_year1[i])][2])
    c.setStrokeAlpha(0.7)

    #draw line
    c.line(column2+columnwidth2,row5-((num_start+1)*textgap)+(.33*textsize),column3,row5-((num_mid_start+1)*textgap)+(.33*textsize))

    if num_end >= num_mid_end:
        c.setDash(1,0)
    else:
        c.setDash(3,1)

    # set color for start year based on cause_type
    c.setFillColorRGB(fill['{cause_type_year2}'.format(cause_type_year2 = df.cause_type_year2[i])][0],fill['{cause_type_year2}'.format(cause_type_year2 = df.cause_type_year2[i])][1],fill['{cause_type_year2}'.format(cause_type_year2 = df.cause_type_year2[i])][2])
    c.setFillAlpha(0.2)
    c.setStrokeColorRGB(fill['{cause_type_year2}'.format(cause_type_year2 = df.cause_type_year2[i])][0],fill['{cause_type_year2}'.format(cause_type_year2 = df.cause_type_year2[i])][1],fill['{cause_type_year2}'.format(cause_type_year2 = df.cause_type_year2[i])][2])
    c.setStrokeAlpha(0.7)

    #draw line
    c.line(column4+columnwidth4,row5-((num_mid_end+1)*textgap)+(.33*textsize),column5,row5-((num_end+1)*textgap)+(.33*textsize))



    #iterate
    resid_year1_iter = resid_year1_iter + 1

#### save
c.save()
