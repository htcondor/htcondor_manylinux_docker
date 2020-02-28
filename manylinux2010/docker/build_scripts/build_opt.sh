#!/bin/bash
set -eux

# curl command
CURL="curl -fsSL" # silent and follow redirects

function perl {
    local basename=perl-${1}
    local src_url=https://www.cpan.org/src/5.0/${basename}.tar.gz

    $CURL -o ${basename}.tar.gz ${src_url}

    tar -xf ${basename}.tar.gz && (
        pushd ${basename}
        ./Configure -des -Dprefix=/opt/${basename}
        make
        make install
        popd
    )
}

function pkgconfig {
    local basename=pkg-config-${1}
    local src_url=https://pkg-config.freedesktop.org/releases/${basename}.tar.gz

    $CURL -o ${basename}.tar.gz ${src_url}

    tar -xf ${basename}.tar.gz && (
	pushd ${basename}
	./configure --prefix=/opt/${basename}
	make
	make install
    )
}

cd "$(dirname "$0")"
echo "Writing stdout to ${PWD}/${1}.out"
$@ > build_${1}.out
