#!/bin/bash

htcondor_branch="master" # default to master branch
wheel_version_identifier="" # no version identifier by default
if [ $# -gt 0 ]; then
    htcondor_branch="$1"
    wheel_version_identifier="$2"
fi
dagfile=${htcondor_branch}${wheel_version_identifier}.dag

echo "JOB check_branch dummy.sub NOOP" > $dagfile
echo "SCRIPT PRE check_branch check_branch.sh $htcondor_branch" >> $dagfile # check branch exists

while read cpu_architecture; do

# Point to the latest docker image
docker_image="htcondor/htcondor_manylinux_2_28_${cpu_architecture}:$(head -n 1 latest_tag)"

    # Create a temporary directory and node for each Python version in abi_tags.txt
    while read python_version_tag; do
        nodename="${htcondor_branch}${wheel_version_identifier}_${cpu_architecture}_${python_version_tag}"

        # Set up the temp directories
        tmpdir="tmp/$nodename"

        if [ -d "$tmpdir" ]; then
            # Start fresh if the directory exists
            rm -rf "$tmpdir"
        fi
        
        mkdir -p "$tmpdir"
        cp *_python_wheel.submit *_python_wheel.sh *_python_wheel.py "$tmpdir"

        # build the main dag
        echo
        echo "SUBDAG EXTERNAL $nodename $nodename.dag DIR $tmpdir"
        echo "PARENT check_branch CHILD $nodename"
        
        # build the subdags
        for jobtype in "build" "test"; do
            echo "JOB $jobtype ${jobtype}_python_wheel.submit"
            if [ "$jobtype" == "test" ]; then
                echo "VARS ALL_NODES manylinux_docker_image=\"$docker_image\""
                echo "VARS ALL_NODES htcondor_branch=\"$htcondor_branch\"" 
                echo "VARS ALL_NODES cpu_architecture=\"$cpu_architecture\""
                echo "VARS ALL_NODES python_version_tag=\"$python_version_tag\""
                echo "VARS ALL_NODES wheel_version_identifier=\"$wheel_version_identifier\""
                echo "PARENT build CHILD test"
                echo "SCRIPT POST test copy_python_wheel.sh"
            fi
        done > "$tmpdir/$nodename.dag"

    done < abi_tags.txt >> $dagfile

done < cpu_architectures.txt
