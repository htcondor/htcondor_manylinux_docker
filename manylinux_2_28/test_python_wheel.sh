#!/bin/bash
set -e

# arguments
CPU_ARCHITECTURE=$1
FULL_PYTHON_VERSION_TAG=$2
WHEEL_FILE=$3
shift 3 # strip args for activate scripts

# derive tags & paths from python version tag
PYTHON_VERSION_MAJOR=${FULL_PYTHON_VERSION_TAG:2:1}
PYTHON_VERSION_MINOR=${PYTHON_TAG:3}

# install miniconda and create environment
export HOME=$_CONDOR_SCRATCH_DIR
bash Miniconda3-latest-Linux-${CPU_ARCHITECTURE}.sh -b -p $HOME/miniconda3
source $HOME/miniconda3/bin/activate
conda create -y -n wheeltest python=${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}
conda activate wheeltest

# install htcondor and run test script
pip install $WHEEL_FILE
(python test_python_wheel.py) || true
(python test_python_v2_wheel.py) || true
exit $?
