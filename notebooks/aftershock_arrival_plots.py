# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <markdowncell>

# # Plotting Aftershock Arrival Times

# <markdowncell>

# ## Goal: Identify Functions to Fit for MDA Model
# 
# ### Method:
# 
# + Bin quakes by magnitude (arbitrary bin sizes for now)
# 
# + Plot timedeltas for the aftershocks of each quake (arbitrarily define aftershocks as the next 5 quakes, for now)
# 
# + Improve and smooth the plot to identify functions that might fit better than $$ \tau u^M $$

# <codecell>

from ggplot import *
import datetime
import time
import urllib
import numpy
import pandas as pd
from pandas import read_csv
from dateutil import parser
from pprint import pprint
from datetime import timedelta

# <markdowncell>

# ## Curation
# 
# Fetch 2012 Earthquake Catalog from curators

# <codecell>

catalog = read_csv("https://stat157.github.io/analyzers/data_from_curators/2012.catalog.csv")
clean_catalog = catalog.dropna(axis=0, how='any')

# <markdowncell>

# Use a small subset of data for prototyping the process

# <codecell>

test_catalog = clean_catalog[0:20]

# <markdowncell>

# Extract date and time, and combine them into python.datetime format

# <codecell>

test_date = test_catalog['YYYY/MM/DD']
test_time = test_catalog['HH:mm:SS.ss']

# <codecell>

test_dt = [parser.parse(date + " " + time) for date, time in zip(test_date, test_time)]

# <markdowncell>

# Add the reformatted datetimes as a column in the existing DataFrame

# <codecell>

test_catalog['DATETIME'] = test_dt
test_catalog[0:20]

# <markdowncell>

# Prints the data types of our variables.
# 
# Notice:
# 
# + the datetimes were converted by Pandas.DataFrame from python.datetime to python.timestamp format
# 
# + magnitude is stored as a float; this might make binning difficult (see [python's **round()** documentation](http://docs.python.org/2/library/functions.html#round)).

# <codecell>

print type(test_catalog['DATETIME'])
print type(test_catalog['DATETIME'][0])
print type(test_catalog.MAG[0])

# <markdowncell>

# ## Analysis
# 
# Create a histogram of the magnitudes from 0 to 5.5, in bin sizes 0.5

# <codecell>

bins = numpy.arange(0, 5.5, 0.5)
freq, bins = numpy.histogram(clean_catalog.MAG, bins)
print freq
print bins

# <codecell>

test_mag = test_catalog.MAG
test_dt = test_catalog.DATETIME
test_mag

# <markdowncell>

# #### Warning: Hacky Solutions Ahead
# 
# This code is sufficient to create an initial plot and allowed us to move forward when stuck, but needs to be refactored.
# 
# Idea: Create x and y columns to add to the data frame, so they can be plotted with ggplot.

# <markdowncell>

# Creates the x-coordinates: a list with each quake's magnitude repeated five times

# <codecell>

mags = [mag for mag in test_mag for rep in range(5)]
mags = mags[:-25]

# <markdowncell>

# Creates the y-coordinates: a list with the timedeltas of each quake's aftershocks (for now, the next five quakes)

# <codecell>

points = []
for i in range(len(test_dt) - 5):
    current = test_dt[i]
    for j in range(1, 6):
        points.append(test_dt[i+j] - current)

# <codecell>

assert len(points) == len(mags)

# <markdowncell>

# Converts the timedeltas into seconds so they can be plotted on an absolute time scale

# <codecell>

points_ts = [timedelta.total_seconds(point) for point in points]

type(points_ts)

# <markdowncell>

# Creates a DataFrame of the x- and y-coordinates, so ggplot can plot them.
# 
# TODO: Convert the existing columns in the catalog DF, instead of creating a new dataframe.
# TODO: Memory-management: only import the DF columns we want (mag, date, time)

# <codecell>

df = pd.DataFrame({'mags': mags, 'timedeltas': points_ts})

# <codecell>

from ggplot import *

print ggplot(df, aes('mags', 'timedeltas')) + \
  geom_point(colour='steelblue')

# <codecell>

import matplotlib.pyplot as plt
print freq
plt.bar([0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5], freq)
plt.show()

# <codecell>

# p = ggplot(aes(x='bins'), data = 

# <codecell>

test_catalog['DATETIME'][1] - test_catalog['DATETIME'][0]

# <codecell>

# myplot = ggplot(aes('MAG'), data = clean_catalog)
# myplot + geom_boxplot(aes(x=NGRM, y=MAG))

