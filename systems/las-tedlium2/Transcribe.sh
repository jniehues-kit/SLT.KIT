#!/bin/bash

set=$1

export systemName=las-tedlium2

#Download Data - if not there
if [ ! -e /data/orig/eval/$set ]; then
    mkdir -p /data/orig/eval/$set
    cd /data/orig/eval/$set
    wget http://i13pc106.ira.uka.de/~jniehues/IWSLT-SLT/data/eval/en-de/IWSLT-SLT.$set.en-de.tgz
    tar -xzvf IWSLT-SLT.$set.en-de.tgz

fi

cd /opt/SLT.KIT/scripts/xnmt
./make-test-db.sh /data/orig/eval/dev2010/IWSLT.$set
sed "s|REPLACE_WITH_TEST_DATA_DIR|/data/orig/eval/dev2010/IWSLT.$set|g" /opt/SLT.KIT/scripts/xnmt/config.las-pyramidal-test.yaml > /data/orig/eval/dev2010/IWSLT.$set/config.las-pyramidal-test.yaml
/root/anaconda3/bin/python -m xnmt.xnmt_run_experiments --dynet-gpu /data/orig/eval/dev2010/IWSLT.$set/config.las-pyramidal-test.yaml

# TODO: adjust the below
exit

#Add puncuation
/opt/SLT.KIT/scripts/monoTranslationData/Translate.sh $set orig monoTransPrepro monTrans

#Translate
/opt/SLT.KIT/scripts/openNMT-py/Translate.sh $set monoTransPrepro mt

#Eval
/opt/SLT.KIT/scripts/evaluate/Eval.sh $set mt

#Prepro manual transcript
/opt/SLT.KIT/scripts/defaultPreprocessor/Translate.sh $set prepro

#Translate manual transcript
/opt/SLT.KIT/scripts/openNMT-py/Translate.sh manualTranscript.$set prepro mt

#Eval manual transcript
/opt/SLT.KIT/scripts/evaluate/Eval.manualTranscript.sh $set mt





