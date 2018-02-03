#!/bin/bash

export systemName=midSize
rm -r /model/
cd /
wget http://i13pc106.ira.uka.de/~jniehues/SLT.KIT/$sl-$tl/MidSize.tgz
tar -xzvf MidSize.tgz
