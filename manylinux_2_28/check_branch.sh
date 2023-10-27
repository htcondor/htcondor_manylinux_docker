#!/bin/bash

if curl -s "https://api.github.com/repos/htcondor/htcondor/branches/$1" | grep "Branch not found"; then
    exit 1
fi
