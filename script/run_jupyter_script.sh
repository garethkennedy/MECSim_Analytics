#!/bin/bash

PYTHON_CODE_DIR='python/'

# Script to run a single MECSim execution. Working directory of wherever this script is called (/ in docker)
echo "In sample customizable MECSim script..."
echo "Any python codes to be put in $PYTHON_CODE_DIR"
echo "jupyter notebook test"
#jupyter notebook --port=80 --no-browser --ip=0.0.0.0 --allow-root
jupyter notebook --port=8888 --no-browser --allow-root
