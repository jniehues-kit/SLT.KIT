#!/bin/bash

set=$1

#Download Data - if not there
if [ ! -e /data/orig/eval/$set ]; then
    mkdir -p /data/orig/eval/$set
    cd /data/orig/eval/$set
    wget http://i13pc106.ira.uka.de/~jniehues/IWSLT-SLT/data/eval/$sl-$tl/IWSLT-SLT.$set.$sl-$tl.tgz
    tar -xzvf IWSLT-SLT.$set.$sl-$tl.tgz

fi

/opt/SLT.KIT/scripts/monoTranslationData/Translate.sh $set orig monoTransPrepro monTrans

#Preprocess Data
#/opt/SLT.KIT/scripts/defaultPreprocessor/Train.sh orig prepro


#Train NMT
#/opt/SLT.KIT/scripts/openNMT-py/Train.sh prepro mt


#Preprocess for Puncutation

#monTranslationSystem
#/opt/SLT.KIT/scripts/openNMT-py/Train.sh monoTransPrepro monTrans
