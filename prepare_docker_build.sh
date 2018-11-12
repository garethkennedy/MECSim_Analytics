#!/bin/bash
docker='/c/gfk/EChem/StatisticalAnalysis/Docker_build/MECSim'

# copy docker build instructions file
cp -p Dockerfile $docker
# scripts includes running jupyter (run_jupyter_script.sh) and a default run_mecsim_script.sh
# also a sample skeleton file (Master.sk)
mkdir $docker/script
cp -p script/* $docker/script
# sample skeleton files for different mechanisms (copy over Master.sk)
mkdir $docker/input_templates
cp -p input_templates/* $docker/input_templates
# documentation (updatable via github via docker)
mkdir $docker/docs
cp -p docs/* $docker/docs
# sample single run MECSim input file (Master.inp)
mkdir $docker/input
cp -p input/* $docker/input
# MECSim source code for build (removed from docker container post-compile)
mkdir $docker/src
cp -p src/* $docker/src
# script to specify docker container functionality at run time
mkdir $docker/entry_script
cp -p entry_script/* $docker/entry_script
# python scripts that can be editted by user or updated from git
mkdir $docker/python
cp -p python/*.ipynb $docker/python

# what about the scripts to run the docker container correctly?
