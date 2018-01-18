#!/bin/bash

set=$1

#Download Data - if not there
if [ ! -e /data/orig/eval/$set ]; then
    mkdir -p /data/orig/eval/$set
    cd /data/orig/eval/$set
    wget http://i13pc106.ira.uka.de/~jniehues/IWSLT-SLT/data/eval/$sl-$tl/IWSLT-SLT.$set.$sl-$tl.tgz
    tar -xzvf IWSLT-SLT.$set.$sl-$tl.tgz

fi

#Add puncuation
/opt/SLT.KIT/scripts/monoTranslationData/Translate.sh $set orig monoTransPrepro monTrans

#Translate
/opt/SLT.KIT/scripts/openNMT-py/Translate.sh $set monoTransPrepro mt


#Eval
/opt/SLT.KIT/scripts/evaluate/Eval.sh dev2010 mt
