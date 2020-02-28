#!/bin/bash
set -eux

# curl command
CURL="curl -fsSL" # silent and follow redirects

function pcre {
    local basename=pcre-${1}
    local src_url=https://ftp.pcre.org/pub/pcre/${basename}.tar.gz

    $CURL -o ${basename}.tar.gz ${src_url}

    tar -xf ${basename}.tar.gz && (
	pushd ${basename}
	./configure --prefix=/usr/local
	make
	make install
	popd
    )
}

function openssl {
    local basename=openssl-${1}
    local src_url=https://www.openssl.org/source/${basename}.tar.gz

    $CURL -o ${basename}.tar.gz ${src_url}

    tar -xf ${basename}.tar.gz && (
        pushd ${basename}
        ./config no-asm no-ssl2 -fPIC
        make
        make install_sw
        popd
    )
}

function voms {
    local basename=voms-${1}
    local src_url=https://github.com/italiangrid/voms/archive/v${1}.tar.gz

    $CURL -o ${basename}.tar.gz ${src_url}

    tar -xf ${basename}.tar.gz && \
	git apply voms-openssl.patch && (
        pushd ${basename}

        # remove gsoap
        sed -i 's/PKG_CHECK_MODULES(\[GSOAP/#PKG_CHECK_MODULES(\[GSOAP/g' configure.ac
        sed -i 's/AC_WSDL2H/#AC_WSDL2H/' configure.ac

        ./autogen.sh
        ./configure --with-api-only --disable-docs --prefix=/usr/local
        make
        make install
        popd
    )
}

function gct {
    local basename=gct-${1}
    local src_url=https://repo.gridcf.org/gct6/sources/${basename}.tar.gz

    $CURL -o ${basename}.tar.gz ${src_url}

    tar -xf ${basename}.tar.gz && (
	pushd ${basename}

	# remove register keyword
	sed -i 's/register //g' common/source/library/globus_libc.h
	sed -i 's/register //g' gsi_openssh/source/openbsd-compat/openbsd-compat.h

	./configure --prefix=/usr/local
	make
	make install
	popd
    )
}

function munge {
    local basename=munge-${1}
    local src_url=https://github.com/dun/munge/archive/${basename}.tar.gz

    $CURL -o ${basename}.tar.gz ${src_url}

    tar -xf ${basename}.tar.gz && (
	pushd munge-${basename}
	./configure --prefix=/usr/local
	make
	make install
	popd
    )
}

function boost {
    local basename=boost_${1//\./_}
    local src_url=https://dl.bintray.com/boostorg/release/${1}/source/${basename}.tar.gz

    $CURL -o ${basename}.tar.gz ${src_url}

    tar -xf ${basename}.tar.gz && (
	pushd ${basename}
	./bootstrap.sh

	# build non-python boost libraries
	./b2 install --prefix=/usr/local --with-thread --with-test --with-filesystem --with-regex --with-program_options --with-date_time

	# build boost for every version of python by adding to user-config.jam
	local pythons=""
	echo "{" > tools/build/src/user-config.jam
	for i in /opt/python/*; do
	    # skip the python 2 "m" versions, don't need extra builds for those
	    if [[ ! "$i" =~ cp2.m$ ]]; then
		local majv=${i:14:1}
		local minv=${i:15:1}
		local incv=$(ls -1d ${i}/include/python* | head -1) # include dir
		echo "using python : ${majv}.${minv} : \"${i}/bin/python\" : \"${incv}\" : \"${i}/lib\" ;" >> tools/build/src/user-config.jam
		pythons="${pythons},${majv}.${minv}"
	    fi
	done
	echo "}" >> tools/build/src/user-config.jam
	./b2 install --prefix=/usr/local --layout=system variant=release link=static define=BOOST_HAS_THREADS cxxflags=-fPIC linkflags=-fPIC --with-python python=${pythons:1} # strip the leftmost comma
	rm -rf /usr/local/lib/cmake
	popd
    )
}

cd "$(dirname "$0")"
echo "Writing stdout to ${PWD}/${1}.out"
$@ > build_${1}.out
