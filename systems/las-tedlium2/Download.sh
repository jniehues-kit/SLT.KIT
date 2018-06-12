#!/bin/bash

# TODO: needed / correct?
#export systemName=las-tedlium2

cd /
wget http://i13pc106.ira.uka.de/~jniehues/SLT.KIT/en/las-pyramidal.mod.tgz
tar -xzvf las-pyramidal.mod.tgz
mv models/ /opt/SLT.KIT/scripts/xnmt/

