
# coding: utf-8

# # Return a random number in exp format
# 
# Called by random sample script

# In[1]:

def returnRandomExpNumber(x_min, x_max, log_uniform=False):
    """
    Return a random number from a range assuming uniform distribution (can be in log) in a specified range.
    
    Inputs: x_min, x_max as numeric
    Outputs: random number x in ExpForm as above
    """
    import random
    import numpy as np
    if(log_uniform):
        if(x_min<0):
            x_min = 1.0e-10
        x_min = np.log10(x_min)
        x_max = np.log10(x_max)
        x = random.uniform(x_min, x_max)
        x = 10.0**x
    else:
        x = random.uniform(x_min, x_max)
    return x

#returnRandomExpNumber(0.001, 1.0e7, log_uniform=True)


# In[5]:

import sys
thisCodeName = 'ReturnRandomExpFormat.py'
nLength = len(thisCodeName)
tailString = sys.argv[0]
tailString = tailString[-nLength:]
if(tailString==thisCodeName and len(sys.argv)>=3):
    # next should be the file name
    x_min = float(sys.argv[1])
    x_max = float(sys.argv[2])
    log_uniform = False
    if(len(sys.argv)>=4 and sys.argv[3]=="True"):
        log_uniform = True
    x = returnRandomExpNumber(x_min, x_max, log_uniform)
    print(x)
else:
    print('Error')

