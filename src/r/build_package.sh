#!/usr/bin/env bash
set -ex

# Creates the PsychroLib package repository to deploy locally or on CRAN.
# Usage: build_package.sh

if [ ! -d R ]; then
    echo "Please run this script from r project folder"
    exit 1
fi

R -e 'library(devtools);document()'
cp ../../LICENSE.txt .
