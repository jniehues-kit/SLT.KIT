#!/bin/bash

if [ -z "$BASEDIR" ]; then
    BASEDIR=/
fi

export systemName=smallTED
cd $BASEDIR
wget http://i13pc106.ira.uka.de/~jniehues/SLT.KIT/$sl-$tl/SmallTED.tgz
tar -xzvf SmallTED.tgz
