
# coding: utf-8

# # Compare smoothed waveforms
# 
# This script compares two smoothed data files and outputs the sum of squares comparison, either as a single metric or separately for each harmonic.
# 
# Requires: 
# 1. Experimental and simulation data have already been processed into time series of smoothed harmonics.
# 2. ``Settings.inp`` exists in the same directory as this python script
# 
# The file ``Settings.inp`` constains parameters for this script as well as the for the harmonic splitter used to create the smoothed harmonics (``HarmonicSplitter.py``). The parameters include the number of harmonics, frequency bandwidth and the weights for each harmonic if a single metric is requested. These settings as well as the script that automates the running of this and ``HarmonicSplitter.py`` are both made by ``GenerateScript.ipynb``.
# 
# ### Caution
# 
# **This script should not need to be modified by general users.**
# 
# All parameters for running this comparison, as well as ``HarmonicSplitter.py`` which creates the smoothed data files, is setup via the ``Settings.inp`` file which is created by the ``GenerateScript.ipynb`` python notebook which is the primary point of contact for users.
# 
# Note that there is a plotting option at the bottom of this script that can be activated manually for customizing this script - typically this should be turned off for running with the bash script.

# ### Load packages

# In[14]:

# import required python packages
import numpy as np
import pandas as pd
import sys


# ## Read settings
# 
# Read parameters from the text file ``Settings.inp`` created by ``GenerateScript.ipynb``
# 

# In[15]:

lines = [line.rstrip('\n') for line in open('Settings.inp')]
filename = lines[0].strip().split()[0]
number_harmonics = int(lines[1].strip().split()[0])
frequency_bandwidth = float(lines[2].strip().split()[0])
iUseSingleMetric = int(lines[3].strip().split()[0]) # =0 or =1
i_use_weights = int(lines[4].strip().split()[0])
weights = np.fromstring(lines[5].strip(), dtype=float, sep=',')


# ## Set filenames
# 
# Be default the filenames specifying the smoothed experimental and simulated data used for this comparison are hard wired. Changing these also requires them to be changed in ``HarmonicSplitter.py`` for consistency.

# In[16]:

# input the total number of frequencies to check; i.e. all frequencies, harmonics, cross harmonics etc
# specified in harmonic splitter when this was created
n_freq = number_harmonics

# experimental and simulated data file names
filename_exp = 'ExpSmoothed.txt'
filename_sim = 'Smoothed.txt'

# interactive
plotInteractive = False

# weights file (made by generate script?)


# Double check that interactive plotting mode is disabled if running this in script mode

# In[17]:

thisCodeName = 'CompareSmoothed.py'
nLength = len(thisCodeName)
tailString = sys.argv[0]
tailString = tailString[-nLength:]
if(tailString==thisCodeName):
    plotInteractive = False


# ## Define functions
# 
# ### Data read function
# 
# Read smoothed time series data. Generalise to take any number of harmonics and weights.
# For example we have 2 input frequencies and the 2nd harmonic of the 1st input frequency is more important.
# 
# First is time, second is dc, after that there are N harmonics

# In[18]:

def ReadSmoothed(filename):
    f = open(filename, 'r')
    input_data = []
    for line in f:
        input_data.append(line.split())
    input_array = np.array(input_data, dtype=float)
    return input_array


# <a id="ref_weights"></a>
# ### Sum of squares comparison function
# 
# Metric used in ``CompareSmoothed.py`` is to take the smoothed harmonics from ``HarmonicSplitter.py`` for both the experimental and simulated data (a function of parameters run by ``MECSim``), calculated the sum of squares difference for each harmonic and combine them to a single metric $S_m$ via
# $$
# S_m = \sum_{j=0}^{n_{harm}} w_j S_j
# $$
# where $n_{harm}$ is the number of harmonics, $j=0$ is the dc component, $w_j$ is the weight given to harmonic $j$ specified in the ``Settings.inp`` file and $S_j$ is the relative sum of squares difference given by
# $$
# S_j = \frac{ \sum_k^n \left( i^{exp}_k - i^{sim}_k \right)^2 }{ \sum_k^n \left( i^{exp}_k \right)^2 }
# $$
# where $n$ is the total number of current ($i$), time and voltage points in the smoothed experiemental ($exp$) and simiulated ($sim$) data. The weights ($w_j$) for each harmonic (and dc component) are set as a vector of any sum, or left as the unweighted default of $w_j = 1$.
# 
# These relative sums of squares are combined using the weights to calculate the final metric denoted as $S$ below. Note that the raw sum of squares values are output as a comma separated string if ``i_use_weights=0``.
# 
# Notes:
# 1. The sum of squares function is scaled by the sum of squares of the first input data 
# 2. Input data must perfectly align in that they should have the same number of data rows in each file
# 

# In[19]:

def ScaledSumOfSquares(y1, y2): # first is the basis for comparision
    S = 0.0
    X = 0.0
    for i in range(len(y1)):
        S += (y1[i]-y2[i])**2.
        X += y1[i]**2.
    if(X!=0.0):
        return S/X
    else:
        return 0.0


# ## Read files
# 
# Read experimental and simulation data files using defined function

# In[20]:

smoothed_exp = ReadSmoothed(filename_exp)
smoothed_sim = ReadSmoothed(filename_sim)


# ### Check data file consistency
# 
# Check file structure of both files for the correct number of harmonics as set in ``Settings.inp``.
# 
# Smoothed.txt file strucure is $t$, $E_{dc}$, $E_{app}$, $i_{dc}$, $i_{harmonics}$ ($*n$)

# In[21]:

n_found_harm_exp = len(smoothed_exp[0, :]) - 4
n_found_harm_sim = len(smoothed_sim[0, :]) - 4
if(number_harmonics!=n_found_harm_sim) or (number_harmonics!=n_found_harm_exp):
    print "WARNING: inconsistent number of harmonics (excluding dc)"
    print "Settings n_harm=", number_harmonics
    print "Experimental data n_harm=", n_found_harm_exp
    print "Simulation data n_harm=", n_found_harm_sim


# ## Calculate metric
# 
# Calculate the combined metric $S$ accounting for all harmonics with dc first (so +1 for range). We start at column 1 rather than 0 as we do not need to compare the time column (index=0).

# In[23]:

Smetric = 0.0
S = []
for i in range(number_harmonics+1):
    # raw sum of squares comparison (skip t, e_dc, e_app)
    Sharm = ScaledSumOfSquares(smoothed_sim[:, i+3], smoothed_exp[:, i+3])
    S.append(Sharm)
    Smetric+=Sharm*weights[i]


# ## Write to single metric to output
# 
# Depending on the selection in ``Settings.inp`` this file either outputs (to screen via print) a single number (the $S$ metric) or the full list of sum of squares values for each harmonic separated by commas. 
# 
# This is output via a print statement so it can be picked up by an echo command in the looping bash script (created by ``GenerateScript.ipynb``). There it is combined with the input parameters and appended to the ``Results.txt`` output file from the whole loop.

# In[24]:

if(iUseSingleMetric==1): # use total metric
    print Smetric
else: # use each harmonic split by commas
    SHText = ','.join(map(str, S))
    print SHText


# ## Use interactive plotter
# 
# ONLY if not using this in bash script.
# 
# Simulation in red, experimental data in black. Harmonic 0 is dc and this example goes up to the 5th harmonic.

# In[25]:

if(plotInteractive):
    import matplotlib.pyplot as plt
    get_ipython().magic(u'matplotlib inline')
    plt.figure(figsize=(20,10))
    plt.subplot(231)
    i_harm = 0
    plt.plot(smoothed_exp[:, 0], smoothed_exp[:, i_harm+1], c='k')
    plt.plot(smoothed_sim[:, 0], smoothed_sim[:, i_harm+1], c='r')
    plt.subplot(232)
    i_harm = 1
    plt.plot(smoothed_exp[:, 0], smoothed_exp[:, i_harm+1], c='k')
    plt.plot(smoothed_sim[:, 0], smoothed_sim[:, i_harm+1], c='r')
    plt.subplot(233)
    i_harm = 2
    plt.plot(smoothed_exp[:, 0], smoothed_exp[:, i_harm+1], c='k')
    plt.plot(smoothed_sim[:, 0], smoothed_sim[:, i_harm+1], c='r')
    plt.subplot(234)
    i_harm = 3
    plt.plot(smoothed_exp[:, 0], smoothed_exp[:, i_harm+1], c='k')
    plt.plot(smoothed_sim[:, 0], smoothed_sim[:, i_harm+1], c='r')
    plt.subplot(235)
    i_harm = 4
    plt.plot(smoothed_exp[:, 0], smoothed_exp[:, i_harm+1], c='k')
    plt.plot(smoothed_sim[:, 0], smoothed_sim[:, i_harm+1], c='r')
    plt.subplot(236)
    i_harm = 5
    plt.plot(smoothed_exp[:, 0], smoothed_exp[:, i_harm+1], c='k')
    plt.plot(smoothed_sim[:, 0], smoothed_sim[:, i_harm+1], c='r')
    plt.show()

