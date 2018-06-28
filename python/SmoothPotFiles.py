
# coding: utf-8

# In[1]:

# import required python packages
import numpy as np


# In[2]:

# load POT output file
# t_MS2, i_MS2, e_MS2 = ReadPOTFile('Raw/GC06_FeIII-1mM_1M-KCl_02_009Hz.txt', tmin, tmax)
def ReadPOTFile(filename, tmin, tmax):
    f = open(filename, 'r')
    time = []
    eapp = []
    current = []
    iCount = 0
    iAll = 0
    for line in f:
        columns = line.split()
        if(columns[0][3].isdigit()): # look at 2nd character in case Eapp is "-"
            thisTime = float(columns[2])
            if((thisTime>=tmin) and (thisTime<=tmax)):
                time.append(thisTime)
                eapp.append(float(columns[0]))
                current.append(float(columns[1]))
                iCount += 1
        iAll += 1
    return iCount, time, current, eapp

# load MECSim TVS output file
def ReadMECSimFile(filename, tmin, tmax):
    f = open(filename, 'r')
    time = []
    eapp = []
    current = []
    for line in f:
        columns = line.split()
        if(columns[0][0].isdigit()): # time is first so shouldn't have "-" numbers
            if((columns[0]>=tmin) and (columns[0]<=tmax)):
                time.append(float(columns[0]))
                eapp.append(float(columns[1]))
                current.append(float(columns[2]))
    return time, current, eapp

# load DigiElch 7 output file (need to give scan rate to get time)
#t_DE1, i_DE1, e_DE1 = ReadDE7File('DE7_surfconc_1e-12_kf1e5.txt', vscan, tmin, tmax)
def ReadDE7File(filename, vscan=1, tmin=0, tmax=1):
    f = open(filename, 'r')
    f.readline()
    f.readline()
    eapp = []
    current = []
    for line in f:
        columns = line.split()
        eapp.append(float(columns[0]))
        current.append(-float(columns[1])) # to fit with MECSim current convention
# make time based on delta E and vscan
    deltaE = abs(eapp[0]-eapp[1])
    deltat = deltaE/vscan
    time = []
    for i in range(1,len(eapp)+1):
        time.append(float(i)*deltat)
    return time, current, eapp


# In[3]:

def AveragedCurrent(t, i, e, tWindow):
    iSmooth = list(i)
    deltaT = t[1]-t[0] # assumes constant time steps
    tEnd = t[-1]
    tStart = t[0]
    iWindow = int(tWindow/deltaT)+1
    RunningTotal = 0.0
    iMax = len(t)
    iMinW = -iWindow/2
    iMaxW = iMinW+iWindow-1
    for j in range(0, iWindow):
        RunningTotal += i[j]

#    print deltaT, tEnd, iWindow
    for ii in range(iMax):
        iMinW += 1
        iMaxW += 1
        iSmooth[ii] = RunningTotal
        if((iMinW>0) and (iMaxW<iMax)): # shift running total across by one point
            RunningTotal += i[iMaxW]
            RunningTotal -= i[iMinW]
        iSmooth[ii] = RunningTotal/float(iWindow)
    return iSmooth


# In[4]:

def SmoothCurrent(t, i, e, tWindow):
    iSmooth = list(i)
    deltaT = t[1]-t[0] # assumes constant time steps
    tEnd = t[-1]
    tStart = t[0]
    iWindow = int(tWindow/deltaT)+1
    windowVal = []
    iMax = len(t)
    iMinW = -iWindow/2
    iMaxW = iMinW+iWindow-1
    for j in range(0, iWindow):
        windowVal.insert(0, i[j]) # insert at top/pop from bottom
    for ii in range(iMax):
        iMinW += 1
        iMaxW += 1
        if((iMinW>0) and (iMaxW<iMax)): # shift running total across by one point
            windowVal.pop()
            windowVal.insert(0, i[iMaxW])
        iSmooth[ii] = max(windowVal)
    return iSmooth


# In[5]:

tmin = 0.001
tmax = 13.4
tWindow = 1.0/9.0  # f_AC = 9Hz
filename = 'ExpRawData.txt'
# raw experimental data from Elton's potentiostat
#iCount, t_MS1, i_MS1, e_MS1 = ReadPOTFile(filename, tmin, tmax)
# data format from MECSim
t_MS1, i_MS1, e_MS1 = ReadMECSimFile(filename, tmin, tmax)
# apply smoothing function
i_Smooth = SmoothCurrent(t_MS1, i_MS1, e_MS1, tWindow)


# In[ ]:

np.savetxt( 'Smoothed.txt', np.c_[t_MS1, i_Smooth])


# In[ ]:

t_MS1

