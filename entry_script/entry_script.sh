#!/bin/bash

# synchronize volumes between local directory and "external" part of the docker image
# 1: copy externally mapped directory contents over local directories
#    note that these changes are ephemeral and will only last while the docker container is being run
echo $PWD

echo "User prompting? Changes saved?"

ls -lrt external/*

# copy the users versions of the codes (if any) to the temp dir inside the container
[ -f external/input/* ] && cp external/input/* input/
[ -f external/input_templates/* ] && cp external/input_templates/* input_templates/
[ -f external/docs/* ] && cp external/docs/* docs/
[ -f external/python/* ] && cp external/python/* python/
[ -f external/script/* ] && cp external/script/* script/
[ -f external/output/* ] && cp external/output/* output/

# 2: copy back to the mapped directories. Thus they will have the most up to date versions AND any gaps filled in with default files stored in the docker image
# only done in jupyter mode - note that this could cause unexpected behaviour if user was using incorrect dir to update and use script mode?
ls -lrt input/*

# Entry point script for MECSim docker. 

if [ "$1" == "--script" ]; then
  echo "Running scripting mode on script/run_mecsim_script.sh:"
  ls -lrt script/*
  dos2unix script/*.sh
  chmod +x script/*.sh
  
  # convert all ipynb to py
  jupyter nbconvert --to python --template=python.tpl python/*.ipynb

  ./script/run_mecsim_script.sh
elif [ "$1" == "--single" ]; then
  echo "Running a single MECSim experiment:"
  # 2: copy back to the mapped directories (from above) 
  cp input/* external/input/
  [ -f output/* ] && cp output/* external/output/

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
  [ -f output/* ] && cp output/* external/output/

  # convert all ipynb to py
  jupyter nbconvert --to python --template=python.tpl python/*.ipynb
  
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
  [ -f output/* ] && cp output/* external/output/

  # these directories will always have contents - even if just the defaults - backup regardless
  backup_dirs='python
  input_templates
  docs
  script'
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
