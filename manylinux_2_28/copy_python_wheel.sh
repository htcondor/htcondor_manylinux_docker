#!/bin/sh

set -ex

output_dir="../../wheels"
mkdir -p $output_dir
cp *.whl $output_dir
