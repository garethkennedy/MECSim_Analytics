#!/bin/bash

# synchronize volumes between local directory and "external" part of the docker image
# 1: copy externally mapped directory contents over local directories
#    note that these changes are ephemeral and will only last while the docker container is being run


# copy the users versions of the codes (if any) to the temp dir inside the container
# these directories will always have contents - even if just the defaults - backup regardless
dir_ext_list="input
input_templates
docs
python
script
output"
for dir_name in $dir_ext_list;
do
  [ -d external/$dir_name ] && ls -1 external/$dir_name | wc -l > temp.txt || echo 0 > temp.txt
  [ $(awk '{print $1}' temp.txt) != "0" ] && cp -p external/$dir_name/* $dir_name/
done

# value > 0 if files exist - in which case try the copy - else ignore
# do as part of a for loop - for all external directories


# 2: copy back to the mapped directories. Thus they will have the most up to date versions AND any gaps filled in with default files stored in the docker image
# only done in jupyter mode - note that this could cause unexpected behaviour if user was using incorrect dir to update and use script mode?
#echo "Status after copy"
#ls -lrt *
#echo "Copy status above"
#date

# Entry point script for MECSim docker. 

if [ "$1" == "--script" ]; then
  echo "Running scripting mode on script/run_mecsim_script.sh:"
  dos2unix script/*.sh
  chmod +x script/*.sh
  
  # convert all ipynb to py
  jupyter nbconvert --to python --template=python.tpl python/*.ipynb

  ./script/run_mecsim_script.sh
elif [ "$1" == "--single" ]; then
  echo "Running a single MECSim experiment:"

  # copy in input file
  cp -p input/Master.inp ./
  ./MECSim.exe 2> err.txt
  # copy out result files
  [[ -e EC_Model.* ]] && cp -p EC_Model.* external/output/
  [[ -e log.txt ]] && cp -p log.txt external/output/
  [[ -e MECSimOutput_Pot.txt ]] && cp -p MECSimOutput_Pot.txt external/output/
elif [ "$1" == "--jupyter" ]; then
  echo "Running a jupyter notebook env:"
  # 2: copy back to the mapped directories (from above) 
  for dir_name in $dir_ext_list;
  do
    [ -d $dir_name ] && ls -1 $dir_name | wc -l > temp.txt || echo 0 > temp.txt
    [ $(awk '{print $1}' temp.txt) != "0" ] && cp -p $dir_name/* external/$dir_name/
  done

  # convert all ipynb to py
  jupyter nbconvert --to python --template=python.tpl python/*.ipynb
  
  dos2unix script/*.sh
  chmod +x script/*.sh
  ./script/run_jupyter_script.sh
elif [ "$1" == "--update" ]; then
  echo "Updating all python and jupyter notebooks in your local python directory using latest versions from the github repository ( https://github.com/garethkennedy/MECSim_Analytics/tree/master/python ). CAUTION this will overwrite any notebooks with the same names in your local python directory. As a failsafe the existing contents of python/ are copied to python/backup"
  # 2: copy back to the mapped directories (from above) 
  for dir_name in $dir_ext_list;
  do
    [ -d $dir_name ] && ls -1 $dir_name | wc -l > temp.txt || echo 0 > temp.txt
    [ $(awk '{print $1}' temp.txt) != "0" ] && cp -p $dir_name/* external/$dir_name/
  done
  
  # backup and download update from github one directory at a time
  for this_dir in $dir_ext_list;
  do
    cd $this_dir
    mkdir backup
    cp -p * backup
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
