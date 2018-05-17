#!/bin/bash

set=$1

BPE_STEPS=300

#Download Data - if not there
if [ ! -e /data/orig/eval/$set ]; then
    mkdir -p /data/orig/eval/$set
    cd /data/orig/eval/$set
    wget http://i13pc106.ira.uka.de/~jniehues/IWSLT-SLT/data/eval/en-de/IWSLT-SLT.$set.en-de.tgz
    tar -xzvf IWSLT-SLT.$set.en-de.tgz
fi

/opt/SLT.KIT/scripts/xnmt/make-test-db.sh /data/orig/eval/${set}/IWSLT.${set}/

# Test
mkdir -p /model/ctc/
/root/anaconda3/bin/python /opt/CTC.ISL/test.py /opt/SLT.KIT/scripts/ctc/bpe${BPE_STEPS}.yaml --logits_file logits.h5 --hyp_file greedy.txt --model /model/ctc/bpe300.mdl
# --audio_features /data/test/IWSLT.tst2015/test-db.h5

