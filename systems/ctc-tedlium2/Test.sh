#!/bin/bash

set=$1

#Download Data - if not there
if [ ! -e /data/orig/eval/$set ]; then
    mkdir -p /data/orig/eval/$set
    cd /data/orig/eval/$set
    wget http://i13pc106.ira.uka.de/~jniehues/IWSLT-SLT/data/eval/en-de/IWSLT-SLT.$set.en-de.tgz
    tar -xzvf IWSLT-SLT.$set.en-de.tgz
fi

DATA_PATH=/data/orig/eval/${set}/IWSLT.${set}
# Preprocess Data - if not there
if [ ! -e ${DATA_PATH}/test-db.h5 ]; then
    /opt/SLT.KIT/scripts/xnmt/make-test-db.sh /data/orig/eval/${set}/IWSLT.${set}/
fi

# Download model if is not there yet
if [ ! -e /model/ctc/bpe300.mdl ]; then
    /opt/SLT.KIT/systems/ctc-tedlium2/Download.sh    
fi

# Test
CTC_OUTPUT=${DATA_PATH}/CTC
mkdir -p ${CTC_OUTPUT}
/root/anaconda3/bin/python /opt/CTC.ISL/test.py /opt/SLT.KIT/scripts/ctc/bpe300.yaml --logits_file ${CTC_OUTPUT}/logits.h5 --hyp_file ${CTC_OUTPUT}/greedy.txt --model /model/ctc/bpe300.mdl --audio_features ${DATA_PATH}/test-db.h5


