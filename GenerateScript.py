
# coding: utf-8

# # Generate script
# 
# Input parameters and simulation parameters
# 
# ## Parameters
# 

# In[5]:

import numpy as np


# ### Set variable ranges
# 
# Name mappings for "master.sk" and the ranges

# In[6]:

x_name = '$kzero'
x_min = 0.0e-4
x_max = 2.0e-2
del_x = 1.0e-2

y_name = '$Ezero'
y_min = 0.20
y_max = 0.25
del_y = 1.0e-2


# ### File names
# 
# Results name - and if it is pre-existing

# In[7]:

results_name = 'results.txt'
results_exists = False
script_name = 'script.sh'


# ### Settings

# In[8]:

# raw data files (sim/experiment)
raw_data_sim = 'MECSimOutput_Pot.txt'
raw_data_exp = 'ExperimentalOut.txt'
# preform harmonic splitter analysis on the experimental data
harmonic_analysis_exp = True
# number of harmonics
number_harmonics = 6
# only 1 needed for simulations (Hz)
frequency_bandwidth = 1.

# filename for smoothed experimental output
filename_exp = 'ExpSmoothed.txt'
# filename for smoothed simulation output
filename_sim = 'Smoothed.txt'
# results file to append to
results_name = 'results.txt'


# ### Script method

# In[9]:

method_type = 'grid'


# ## Statistics

# In[10]:

n_runs_x = int(round((x_max-x_min)/del_x) + 1)
n_runs_y = int(round((y_max-y_min)/del_y) + 1)

number_of_runs = int(round(n_runs_x * n_runs_y))
print "Number in x range: ", n_runs_x
print "Number in y range: ", n_runs_y
print "Total number of runs: ", number_of_runs


# ## Output settings file
# 

# In[11]:

f = open('Settings.inp', 'w')
f.write(str(raw_data_exp) + "\t# experiment raw data filename\n")
f.write(str(raw_data_sim) + "\t# simulation output filename\n")
f.write(str(number_harmonics) + "\t# number of harmonics\n")
f.write(str(frequency_bandwidth) + "\t# bandwidth frequency (Hz)\n")
f.write(str(filename_exp) + "\t# filename for smoothed experimental output\n")
f.write(str(filename_sim) + "\t# filename for smoothed simulation output\n")
f.write(str(results_name) + "\t# results file to append to\n")
f.close()


# ## Prepare script
# 

# In[12]:

def ConvertXToXExpForm(x_min, x_max, del_x):
    """
    Convert min/max/delta into a minimum common exponential form
    e.g. 1.4e-4, 1.0e-5 have 1e-5 as the minimum. 
    So the first becomes 14e-5 while the second remains as it is.
    
    Everything must be integer
    """
    if(del_x>0):
        x_min_unit = del_x
        if(x_min>0):
            x_min_unit = min(del_x, x_min)
    else:
        x_min_unit = x_min
    x_exp = np.floor(np.log10(np.abs(x_min_unit))).astype(int)
    x_exp_unit = 10**x_exp
    x_min_exp = x_min / x_exp_unit
    x_max_exp = x_max / x_exp_unit
    del_x_exp = del_x / x_exp_unit
    return x_min_exp.astype(int), x_max_exp.astype(int), del_x_exp.astype(int), x_exp.astype(int)


# ### Common exp form
# 
# If more dimensions then add more here (and to parameters above)

# In[13]:

x_min_exp, x_max_exp, del_x_exp, x_exp = ConvertXToXExpForm(x_min, x_max, del_x)
y_min_exp, y_max_exp, del_y_exp, y_exp = ConvertXToXExpForm(y_min, y_max, del_y)


# ### Output script to file
# 
# Depending on the method type selected then output a text file in bash script format for running MECSim with the analysis tools.
# 
# First set any by hand parameters. For example if you have a constant e0val=0.2 but want to keep the skeleton file general with $e0val in there. 
# 
# Note that you'll need to be careful to integrate these into the script generation yourself.

# In[17]:

#with open(script_name, "w") as text_file:
#    text_file.write("#!/bin/bash\n")
#    text_file.write("Ru=0.0\n")
#    text_file.write("CapA0=22.5e-6\n")


# Method dependent writing

# In[15]:

if(method_type=='grid'):
    print 'Using grid method'
#    with open(script_name, "a") as text_file:
    with open(script_name, "w") as text_file:
        text_file.write("#!/bin/bash\n")
        text_file.write("xmin={0}\n".format(x_min_exp))
        text_file.write("xmax={0}\n".format(x_max_exp))
        text_file.write("xdel={0}\n".format(del_x_exp))
        text_file.write("xext=e{0}\n".format(x_exp))
        text_file.write("ymin={0}\n".format(y_min_exp))
        text_file.write("ymax={0}\n".format(y_max_exp))
        text_file.write("ydel={0}\n".format(del_y_exp))
        text_file.write("yext=e{0}\n".format(y_exp))
        text_file.write("x=$xmin\n")
        # also use the harmonic splitter on exp raw data
        if(harmonic_analysis_exp):
            text_file.write("    python HarmonicSplitter.py -script -exp\n")
        # only put this in if there is no results file existing
        # WARNING: be careful not to overwrite pre-existing files
        if(not results_exists):
            text_file.write("> {0}\n".format(results_name))
        text_file.write("while [ $x -le $xmax ]\n")
        text_file.write("do\n")
        text_file.write("  y=$ymin\n")
        text_file.write("  while [ $y -le $ymax ]\n")
        text_file.write("  do\n")
        text_file.write("    cp Master.sk Master.inp\n")
        text_file.write("    sed -i 's/{0}/'$x$xext'/g' Master.inp\n".format(x_name))
        text_file.write("    sed -i 's/{0}/'$y$yext'/g' Master.inp\n".format(y_name))
        # run MECSim with text output redirected to a file "log.txt"
        text_file.write("    ./MECSim > log.txt\n")
        text_file.write("    python HarmonicSplitter.py -script\n")
        text_file.write("    python CompareSmoothed.py -script $x$xext $y$yext")

        text_file.write("    y=$((y+ydel))\n")
        text_file.write("  done\n")
        text_file.write("  x=$((x+xdel))\n")
        text_file.write("done\n")

