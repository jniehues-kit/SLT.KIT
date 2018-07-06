#!/bin/bash

if (( $# != 1 )); then
  echo "Specify a test set as a parameter to this script (e.g. tst2010)"
  exit
fi

declare -a BPE_SIZES=("300" "10000")
BEST_SIZE="10000"

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

for BPE_SIZE in "${BPE_SIZES[@]}"
do

  # Download model if is not there yet
  if [ ! -e /model/ctc/bpe${BPE_SIZE}.mdl ]; then
    /opt/SLT.KIT/systems/ctc-tedlium2/Download.sh    
  fi

  # Test
  CTC_OUTPUT=/data/ctc/eval/
  mkdir -p ${CTC_OUTPUT}
  /root/anaconda3/bin/python /opt/CTC.ISL/test.py /opt/SLT.KIT/scripts/ctc/bpe${BPE_SIZE}.yaml --logits_file ${CTC_OUTPUT}/${set}-${BPE_SIZE}.logits --hyp_file ${CTC_OUTPUT}/${set}-${BPE_SIZE}.s --model /model/ctc/bpe${BPE_SIZE}.mdl --audio_features ${DATA_PATH}/test-db.h5

  # normalize output inplace
  sed -i "s/ '/'/g" ${CTC_OUTPUT}/${set}-${BPE_SIZE}.s

  mkdir -p ${CTC_OUTPUT}/${set}
  /opt/SLT.KIT/scripts/evaluate/Eval.asr.sh $set ${CTC_OUTPUT}/${set}.s ${CTC_OUTPUT}/${set}
done

ln -s ${CTC_OUTPUT}/${set}-${BEST_SIZE}.s ${CTC_OUTPUT}/${set}.s

