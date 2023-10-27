#!/bin/bash
set -ex

while read ARCH ; do
    DOCKERFILE_DIR=$(dirname "$(readlink -f "$0")")/docker/
    TAG="htcondor_manylinux_2_28_${ARCH}:$(head -n 1 latest_tag)"
    sed -i s+pypa.*+pypa/manylinux_2_28_${ARCH}+ ${DOCKERFILE_DIR}/Dockerfile

    docker pull quay.io/pypa/manylinux_2_28_${ARCH}
    docker build $DOCKERFILE_DIR -t $TAG
    docker tag $TAG htcondor/$TAG
    sed -i s/${ARCH}/x86_64/g ${DOCKERFILE_DIR}/Dockerfile
    #docker push htcondor/$TAG
done < arch.txt
