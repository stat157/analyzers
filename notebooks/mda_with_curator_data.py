# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <markdowncell>

# **Imports the necessary packages**

# <codecell>

import datetime
import time
import urllib
import numpy as np
import pandas as pd
from pandas import read_csv
from dateutil import parser
from pprint import pprint

# <markdowncell>

# **Use the data from the curators, populate a Pandas dataframe**

# <codecell>

# This is the 2013 data from the curators
# Thanks Piazza for the free hosting :p

# We'll probably have to setup a github page for this project, or find a more 
# reliable way to host our csv file later
data = read_csv("https://piazza.com/class_profile/get_resource/hkyfvggfat84vl/hnnxl94gqitqb")
clean_data = data.dropna(axis=0, how='any')
p

# <markdowncell>

# **Get some relevant data using the first two columns (date and time), and the 'MAG' column (Magnitude)**

# <codecell>

test_mag = test_data['MAG']
test_mag = test_mag.tolist()
test_mag

# <codecell>

test_date = test_data['YYYY/MM/DD']
test_time = test_data['HH:mm:SS.ss']

test_dt = [parser.parse(date + " " + time) for date, time in zip(test_date, test_time)]
test_dt

# <markdowncell>

# **Extracts the alarm length for each possible quake**

# <codecell>

def basic_mda(tau, u, mag):
    return tau * (u ** mag)

# <codecell>

def mda(mag, dt, tau=0.7, funct=basic_mda):
    """
    Uses basic MDA model (tau*u^mag) to predict earthquakes.
    Returns tuple of (start, end) representing date range when alarm should be on.
    MAG: list of earthquake magnitudes
    DT: list of earthquake datetimes in python datetime format
    (MAG and DT have the same length and come from earthquakes data frame)
    """
    assert len(mag) == len(dt), "Dude are you mad?"
    
    tau = 0.7 # we will figure out what tau is later
    u = 4 # we will add fancy tuning functionality later
    alarms = []
    
    for i in range(0, len(mag)):
        alarm_length = funct(tau, u, mag[i])
        val = datetime.timedelta(seconds=alarm_length)
        rng = (dt[i] + datetime.timedelta(seconds=1), 
               dt[i] + val)
        alarms.append(rng)
    return alarms

# <codecell>

alarm_ranges = mda(test_mag, test_dt)
alarm_ranges

# <codecell>

data_we_need = {'Latitude': test_data['LAT'], 'Longitude': test_data['LON'], 
                'Alarm Begins': [alarm[0] for alarm in alarm_ranges], 
                'Alarm Ends': [alarm[1] for alarm in alarm_ranges]}
dframe = pd.DataFrame(data_we_need)
dframe

# <codecell>


