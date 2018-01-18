#!/bin/bash

export systemName=smallTED
rm -r /model/
cd /
wget http://i13pc106.ira.uka.de/~jniehues/SLT.KIT/$sl-$tl/SmallTED.tgz
tar -xzvf SmallTED.tgz
