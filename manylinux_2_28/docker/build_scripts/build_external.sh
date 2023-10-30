#!/bin/bash
set -eux

NPROC=$((8 > $(nproc) ? $(nproc) : 8))

# curl command
CURL="curl -fsSL" # silent and follow redirects

function boost {
    local basename=boost_${1//\./_}
    local src_url=http://parrot.cs.wisc.edu/externals/${basename}.tar.gz

    $CURL -o ${basename}.tar.gz ${src_url}

    tar -xf ${basename}.tar.gz && (
        pushd ${basename}
        ./bootstrap.sh

        # build non-python boost libraries
        ./b2 install --prefix=/usr/local -j$NPROC --with-thread --with-test --with-filesystem --with-regex --with-program_options --with-date_time

        # build boost for every version of python by adding to user-config.jam
        local pythons=""
        echo "{" > tools/build/src/user-config.jam
        for i in /opt/python/cp*; do
            local full_ver=$(basename $i | grep -oP '(?<=^cp)[0-9]+')
            local majv=${full_ver:0:1}
            local minv=${full_ver:1}
            local incv=$(ls -1d ${i}/include/python* | head -1) # include dir
            echo "using python : ${majv}.${minv} : \"${i}/bin/python\" : \"${incv}\" : \"${i}/lib\" ;" >> tools/build/src/user-config.jam
            pythons="${pythons},${majv}.${minv}"
        done
        echo "}" >> tools/build/src/user-config.jam
        ./b2 install --prefix=/usr/local --layout=system -j$NPROC variant=release define=BOOST_HAS_THREADS cxxflags=-fPIC linkflags=-fPIC --with-python python=${pythons:1} # strip the leftmost comma
        popd
    )
}

cd "$(dirname "$0")"
echo "Writing stdout to ${PWD}/${1}.out"
$@ > build_${1}.out
