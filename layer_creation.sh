#!/bin/sh

mkdir -p temp
cd temp
rm -rf python
mkdir -p python
pip install -r ../requirements.txt -t python/
zip -r ../atlassian_layer.zip python/
