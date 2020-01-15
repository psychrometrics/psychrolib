#!/usr/bin/env bash
set -ex

# Creates the PsychroLib package repository to deploy locally.
# Usage: build_package.sh

if [ ! -d R ]; then
    echo "Please run this script from r project folder"
    exit 1
fi

R -e 'devtools::document()'
cp ../../LICENSE.txt .
R -e 'devtools::install()'
rm -rf man
