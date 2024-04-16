#!/bin/sh

path="$1"

mkdir -p $path/temp
cd $path/temp
rm -rf python
mkdir -p python
pip install -r ../requirements.txt -t python/
zip -r ../atlassian_layer.zip python/
