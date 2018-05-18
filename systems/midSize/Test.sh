#!/bin/bash

set=$1

export systemName=midSize

#Download Data - if not there
if [ ! -e /data/orig/eval/$set ]; then
    mkdir -p /data/orig/eval/$set
    cd /data/orig/eval/$set
    wget http://i13pc106.ira.uka.de/~jniehues/IWSLT-SLT/data/eval/$sl-$tl/IWSLT-SLT.$set.$sl-$tl.tgz
    tar -xzvf IWSLT-SLT.$set.$sl-$tl.tgz

fi

#Add puncuation
/opt/SLT.KIT/scripts/monoTranslationData/Translate.sh $set orig monoTransPrepro monTrans model.adapt.TED.pt

#Translate
/opt/SLT.KIT/scripts/openNMT-py/Translate.sh $set monoTransPrepro mt model.adapt.TED.pt

#Eval
/opt/SLT.KIT/scripts/evaluate/Eval.sh $set mt

#Prepro manual transcript
/opt/SLT.KIT/scripts/defaultPreprocessor/Translate.sh $set prepro

#Translate manual transcript
/opt/SLT.KIT/scripts/openNMT-py/Translate.sh manualTranscript.$set prepro mt model.adapt.TED.pt

#Eval manual transcript
/opt/SLT.KIT/scripts/evaluate/Eval.manualTranscript.sh $set mt





