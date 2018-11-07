#!/bin/bash

# synchronize volumes between local directory and "external" part of the docker image
# 1: copy externally mapped directory contents over local directories
#    note that these changes are ephemeral and will only last while the docker container is being run
echo $PWD

ls -lrt external/*

echo "User prompting? Changes saved?"

cp external/input/* input/
cp external/input_templates/* input_templates/
cp external/docs/* docs/
cp external/python/* python/
cp external/script/* script/
# 2: copy back to the mapped directories. Thus they will have the most up to date versions AND any gaps filled in with default files stored in the docker image
# only done in jupyter mode - note that this could cause unexpected behaviour if user was using incorrect dir to update and use script mode?


# Entry point script for MECSim docker. 

if [ "$1" == "--script" ]; then
  echo "Running scripting mode on script/run_mecsim_script.sh:"
  ls -lrt script/*
  dos2unix script/*.sh
  chmod +x script/*.sh
  
  # convert all ipynb to py
  jupyter nbconvert --to python --template=python.tpl python/*

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
  # 2: copy back to the mapped directories (from above) 
  cp input/* external/input/
  cp input_templates/* external/input_templates/
  cp docs/* external/docs/
  cp python/* external/python/
  cp script/* external/script/

  # convert all ipynb to py
  jupyter nbconvert --to python --template=python.tpl python/*
  
  dos2unix script/*.sh
  chmod +x script/*.sh
  ./script/run_jupyter_script.sh
elif [ "$1" == "--update" ]; then
  echo "Updating all python and jupyter notebooks in your local python directory using latest versions from the github repository ( https://github.com/garethkennedy/MECSim_Analytics/tree/master/python ). CAUTION this will overwrite any notebooks with the same names in your local python directory. As a failsafe the existing contents of python/ are copied to python/backup"
  # 2: copy back to the mapped directories (from above) 
  cp input/* external/input/
  cp input_templates/* external/input_templates/
  cp docs/* external/docs/
  cp python/* external/python/
  cp script/* external/script/

  backup_dirs='python
  input_templates'
  for this_dir in $backup_dirs;
  do
    cd $this_dir
    mkdir backup
    cp * backup
    curl -L https://codeload.github.com/garethkennedy/MECSim_Analytics/tar.gz/master | tar -xz --strip=2 MECSim_Analytics-master/$this_dir
    cd ..
  done
else
  echo "Welcome to MECSim docker"
  echo ""
  echo "The following options are available:"
  echo " --single   : run a single experiment using MECSim on parameters given in /input/Master.inp"
  echo " --script   : run a customizable script for multiple experiments given in /script/run_mecsim_script.sh"
  echo " --jupyter  : setup a script using jupyter notebooks via browser"
  echo " --update   : download the latest python scripts and notebooks from the github repository ( https://github.com/garethkennedy/MECSim_Analytics/tree/master/python ). CAUTION this will overwrite any notebooks with the same names in your local python directory.  As a failsafe the existing contents of python/ are copied to python/backup"
fi

#Try exposing volume with :z option in the end.
#
#volumes:
#    - host_folder:docker_folder:z
