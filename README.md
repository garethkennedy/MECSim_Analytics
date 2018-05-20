# MECSim_Analytics

Suite of python codes to preform analysis of MECSim results and automated scripting of MECSim runs (./MECSim_win7.exe)

Note that you should always run a single MECSim on a roughly correct value set to ensure that the curve looks correct. For example too low resolution may lead to spurious spikes in the current. There are warnings in the MECSim output that guide the user to finding these or that abort when criteria for numerical stability are not met. Best to go through this before automation - machines can not do everything... yet.


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


## Known issues

### Docker for windows 10


	run_docker_win_cmd_jupyter.bat

	docker run -v C:\Repos\MECSim_Analytics/input:/usr/local/input -v C:\Repos\MECSim_Analytics/output:/usr/local/output -v C:\Repos\MECSim_Analytics/python:/usr/local/python -v C:\Repos\MECSim_Analytics/script:/usr/local/script --rm --name mecsim_container -p 8888:8888 -it mecsim --jupyter

	docker: Error response from daemon: driver failed programming external connectivity on endpoint mecsim_container (6bd515b1957924776f7bb96a77ae31ba4c1f61486ae8c7b1e404701dc2778e02): Error starting userland proxy: mkdir /port/tcp:0.0.0.0:8888:tcp:172.17.0.2:8888: input/output error.


## Disclaimer

At present the MECSim source code itself is not available. Included here is a pre-compiled version MECSim that will run on Git Bash and Ubuntu. A docker version of MECSim is under development.