#!/bin/bash
set -ex

# disable proxies
unset http_proxy
unset HTTPS_PROXY
unset FTP_PROXY

export HTCONDOR_BRANCH=V24_0-HTCONDOR-2737-branch
# Must match the version declared in `python-bindings/condor_python.h`.
export PYTHON_ABI_VERION=cp33
# The version of Python to build with.  Should be the oldest version
# we have/otherwise support that's not older than the ABI version.
export FULL_PYTHON_VERSION_TAG=cp37m
export WHEEL_VERSION_IDENTIFIER=

cd
mkdir scratch

cd scratch
export SOURCE_DIR=`pwd`/htcondor_source
export BUILD_DIR=`pwd`/htcondor_pypi_build

PYTHON_TAG=$(echo $FULL_PYTHON_VERSION_TAG | grep -oP 'cp[0-9]+')
PYTHON_VERSION_MAJOR=${PYTHON_TAG:2:1}
PYTHON_VERSION_MINOR=${PYTHON_TAG:3}
PYTHON_BASE_DIR=/opt/python/$PYTHON_TAG-$FULL_PYTHON_VERSION_TAG

# get the htcondor source tarball from github
curl -k -L https://api.github.com/repos/htcondor/htcondor/tarball/$HTCONDOR_BRANCH > $HTCONDOR_BRANCH.tar.gz

mkdir -p $SOURCE_DIR
tar -xf $HTCONDOR_BRANCH.tar.gz --strip-components=1 -C $SOURCE_DIR

export PATH=$PYTHON_BASE_DIR/bin:$PATH
export PKG_CONFIG_PATH=$PYTHON_BASE_DIR/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig
export USE_PYTHON3_INCLUDE_DIR=$(python -c "import sysconfig; print(sysconfig.get_paths()['include'])")
export USE_PYTHON3_EXT_SUFFIX=$(python -c "import sysconfig; print(sysconfig.get_config_var('EXT_SUFFIX'))")

# create build directory
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# cmake
cmake $SOURCE_DIR \
       -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
       -DPROPER:BOOL=ON \
       -DHAVE_BOINC:BOOL=OFF \
       -DENABLE_JAVA_TESTS:BOOL=OFF \
       -DWITH_BLAHP:BOOL=OFF \
       -DWITH_SCITOKENS:BOOL=ON \
       -DWANT_PYTHON_WHEELS:BOOL=ON \
       -DAPPEND_VERSION:STRING=$WHEEL_VERSION_IDENTIFIER \
       -DUSE_PYTHON3_INCLUDE_DIR:PATH=$USE_PYTHON3_INCLUDE_DIR \
       -DUSE_PYTHON3_EXT_SUFFIX:PATH=$USE_PYTHON3_EXT_SUFFIX \
       -DBUILDID:STRING=UW_Python_Wheel_Build

# build targets
make -j 8 python3_bindings

# put libraries into path
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/src/condor_utils
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/src/python-bindings
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/src/classad/lib
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/src/classad
export LD_LIBRARY_PATH

# build wheel
cd bindings/python
# The path probably means something missing in the source's CMake.
python3 ../../../htcondor_source/bindings/python/setup_mvi.py bdist_wheel

# Actually add all the necessary libaries...
auditwheel repair dist/*.whl

# Rename the wheel correctly
mv wheelhouse/htcondor2-2.0.0-py3-none-manylinux_2_28_x86_64.whl \
    wheelhouse/htcondor2-2.0.0-cp33-abi3-manylinux_2_28_x86_64.whl

