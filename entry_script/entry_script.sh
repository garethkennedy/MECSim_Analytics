#!/bin/bash

echo ""
echo "MECSim Docker build date: 30/11/2018 16:00"
echo ""

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

# version without output
dir_noout_list="input
input_templates
docs
python
script"

# common notes/warnings to users
echo
echo "Common usage notes"
echo "  * if script fails ensure docker is running, restart if needed"
echo "    Example of an error message from a fail is:"
echo "      docker: Error response from daemon ... input/output error"
echo "  * for aborting any run press ctrl+c"

# Entry point script for MECSim docker. 

if [ "$1" == "--script" ]; then
  echo
  echo
  echo "Running scripting mode on script/run_mecsim_script.sh:"
  echo
  dos2unix script/*.sh
  chmod +x script/*.sh
  
  # convert all ipynb to py
  jupyter nbconvert --to python --template=python.tpl python/*.ipynb

  ./script/run_mecsim_script.sh
elif [ "$1" == "--single" ]; then
  echo
  echo
  echo "Running a single MECSim experiment:"
  echo

  # copy in input file
  [[ -e input/Master.inp ]] && cp -p input/Master.inp external/input/
  # rum single instance of mecsim
  ./MECSim.exe 2> err.txt
  # copy out result files
#  [[ -e err.txt ]] && cp -p err.txt external/output/
  dir_name="output"
  [ -d $dir_name ] && ls -1 $dir_name | wc -l > temp.txt || echo 0 > temp.txt
  [ $(awk '{print $1}' temp.txt) != "0" ] && cp -p $dir_name/* external/$dir_name/
elif [ "$1" == "--jupyter" ]; then
  echo "  * copy/paste the URL at the end into your browser"
  echo "      http://localhost:8888/?token=901..."
  echo "  * for docker toolkit for older windows versions you may need to replace localhost "
  echo "      with the docker ip (top of docker quickstart terminal)"
  echo
  echo
  echo "Running a jupyter notebook env:"
  echo
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
  echo
  echo "Updating all python and jupyter notebooks in your local python directory using latest versions from the github repository ( https://github.com/garethkennedy/MECSim_Analytics/tree/master/python ). CAUTION this will overwrite any notebooks with the same names in your local python directory. As a failsafe the existing contents of blah/ are copied to blah/backup"
  echo
  # 2: copy back to the mapped directories (from above) 
#  for dir_name in $dir_ext_list;
#  do
#    [ -d $dir_name ] && ls -1 $dir_name | wc -l > temp.txt || echo 0 > temp.txt
#    [ $(awk '{print $1}' temp.txt) != "0" ] && cp -p $dir_name/* external/$dir_name/
#  done
  
  # backup and download update from github one directory at a time
  for this_dir in $dir_noout_list;
  do
    cd external/$this_dir
    [ $(ls -1 | wc -l) != "0" ] && mkdir backup
    [ $(ls -1 | wc -l) != "0" ] && cp -p * backup
    curl -L https://codeload.github.com/garethkennedy/MECSim_Analytics/tar.gz/master | tar -xz --strip=2 MECSim_Analytics-master/$this_dir
    cd ../..
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
