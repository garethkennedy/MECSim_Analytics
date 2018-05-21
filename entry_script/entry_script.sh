#!/bin/bash

# synchronize volumes between local directory and "external" part of the docker image
# 1: copy externally mapped directory contents over local directories
#    note that these changes are ephemeral and will only last while the docker container is being run
echo $PWD

ls -lrt external/*

cp external/input/* input/
cp external/python/* python/
cp external/script/* script/
# 2: copy back to the mapped directories. Thus they will have the most up to date versions AND any gaps filled in with default files stored in the docker image
cp input/* external/input/
cp python/* external/python/
cp script/* external/script/

# convert all ipynb to py
jupyter nbconvert --to python --template=python.tpl python/*

# Entry point script for MECSim docker. 

if [ "$1" == "--script" ]; then
  echo "Running scripting mode on script/run_mecsim_script.sh:"
  ls -lrt script/*
  dos2unix script/*.sh
  chmod +x script/*.sh
  ./script/run_mecsim_script.sh
elif [ "$1" == "--single" ]; then
  echo "Running a single MECSim experiment:"
  # copy in input file
  cp input/Master.inp ./
  ./MECSim.exe 2> err.txt
  # copy out result files
  [[ -e EC_Model.* ]] && cp EC_Model.* output/
  [[ -e log.txt ]] && cp log.txt output/
  [[ -e MECSimOutput_Pot.txt ]] && cp MECSimOutput_Pot.txt output/
elif [ "$1" == "--jupyter" ]; then
  echo "Running a jupyter notebook env:"
  dos2unix script/*.sh
  chmod +x script/*.sh
  ./script/run_jupyter_script.sh
else
  echo "Welcome to MECSim docker"
  echo ""
  echo "The following options are available:"
  echo " --single   : run a single experiment using MECSim on parameters given in /input/Master.inp"
  echo " --script   : run a customizable script for multiple experiments given in /script/run_mecsim_script.sh"
  echo " --jupyter  : setup a script using jupyter notebooks via browser"
fi

#Try exposing volume with :z option in the end.
#
#volumes:
#    - host_folder:docker_folder:z
