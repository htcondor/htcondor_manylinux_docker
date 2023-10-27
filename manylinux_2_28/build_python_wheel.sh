#!/bin/bash
set -ex

# disable proxies
unset http_proxy
unset HTTPS_PROXY
unset FTP_PROXY

# get procs
NPROC=$((8 > $(nproc) ? $(nproc) : 8))

# arguments
HTCONDOR_BRANCH=$1
FULL_PYTHON_VERSION_TAG=$2
WHEEL_VERSION_IDENTIFIER=$3

# directories
SOURCE_DIR=$_CONDOR_SCRATCH_DIR/htcondor_source
BUILD_DIR=$_CONDOR_SCRATCH_DIR/htcondor_pypi_build

# derive tags & paths from python version tag
PYTHON_TAG=$(echo $FULL_PYTHON_VERSION_TAG | grep -oP 'cp[0-9]+')
PYTHON_VERSION_MAJOR=${PYTHON_TAG:2:1}
PYTHON_VERSION_MINOR=${PYTHON_TAG:3}
PYTHON_BASE_DIR=/opt/python/$PYTHON_TAG-$FULL_PYTHON_VERSION_TAG

# get the htcondor source tarball from github
curl -k -L https://api.github.com/repos/htcondor/htcondor/tarball/$HTCONDOR_BRANCH > $HTCONDOR_BRANCH.tar.gz

# untar to source directory
mkdir -p $SOURCE_DIR
tar -xf $HTCONDOR_BRANCH.tar.gz --strip-components=1 -C $SOURCE_DIR
rm -f $HTCONDOR_BRANCH.tar.gz

# set up build environment
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
make -j$NPROC python3_bindings wheel_classad_module wheel_htcondor

# put boost external libraries into path
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/src/condor_utils
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/src/python-bindings
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/src/classad/lib
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/src/classad
export LD_LIBRARY_PATH

# build wheel
cd bindings/python
python setup.py bdist_wheel

# repair wheel
auditwheel repair dist/*.whl

# save result
cp wheelhouse/*.whl $_CONDOR_SCRATCH_DIR
