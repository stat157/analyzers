# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

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

# <codecell>

catalog = read_csv("https://stat157.github.io/analyzers/data_from_curators/2012.catalog.csv")
clean_catalog = catalog.dropna(axis=0, how='any')
MAG = clean_catalog.MAG

# <codecell>

test_catalog = clean_catalog[0:20]

# <codecell>

test_date = test_catalog['YYYY/MM/DD']
test_time = test_catalog['HH:mm:SS.ss']

# <codecell>

test_dt = [parser.parse(date + " " + time) for date, time in zip(test_date, test_time)]

# <codecell>

test_catalog['DATETIME'] = test_dt
test_catalog[0:20]

# <codecell>

type(test_catalog['DATETIME'])
type(test_catalog['DATETIME'][0])
type(test_catalog.MAG[0])

# <codecell>

bins = numpy.arange(0, 5.5, 0.5)
freq, bins = numpy.histogram(MAG, bins)
print freq
print bins

# <codecell>

test_mag = test_catalog.MAG
test_dt = test_catalog.DATETIME
test_mag

# <codecell>

mags = [mag for mag in test_mag for rep in range(5)]
mags = mags[:-25]

# <codecell>

points = []
for i in range(len(test_dt) - 5):
    current = test_dt[i]
    for j in range(1, 6):
        points.append(test_dt[i+j] - current)

# <codecell>

assert len(points) == len(mags)

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

