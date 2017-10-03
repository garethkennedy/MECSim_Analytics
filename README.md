# MECSim_Analytics

Suite of python codes to preform analysis of MECSim results and automated scripting of MECSim runs (./MECSim_win7.exe)


## Analysis codes


Jupyter notebooks in python

    HarmonicSplitter.ipynb
    CompareSmoothed.ipynb
    MECSimPlotter.ipynb




## Scripting codes

The python script file "GenerateScript.ipynb" will create "Settings"

The two analysis codes are called in non-interactive mode inside the generated script.


## Steps

1. Edit Master.sk file to have variables (e.g. $Ru and $Cap0)
2. Edit GenerateScript to setup the range of variables by assigning x=$Ru and y=$Cap0 for example
3. Run GenerateScript to create the parameters file "Settings.inp" and bash script "script.sh"
4. Run the bash script which will do the following:
    * run all combinations of the variables through MECSim
    * run the MECSim output file "MECSimOutput\_Pot.txt" through the "HarmonicSplitter" code to split by harmonics and create smoothed currents against time
    * run the smoothed current file through "CompareSmoothed" code to generate a least squares comparison for each harmonic and output a single metric
    * the metric comparison value is added to the grid output file typically called "results.txt" which also contains the variable parameters
5. Run the "SurfacePlots" interactive script to examine or produce output images of the grid results



## Disclaimer

At present the MECSim source code itself is not available. Included here is a pre-compiled version MECSim that will run on Git Bash and Ubuntu. A docker version of MECSim is under development.