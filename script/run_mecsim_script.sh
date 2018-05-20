#!/bin/bash

PYTHON_CODE_DIR='python/'

# Script to run a single MECSim execution. Working directory of wherever this script is called (/ in docker)
echo "In sample customizable MECSim script..."
echo "Any python codes to be put in $PYTHON_CODE_DIR"
cp script/Settings.inp ./
./script/script.sh
cp results.txt output/