#!/bin/bash

if (( $# != 1 )); then
  echo "Specify a test set as a parameter to this script (e.g. tst2010)"
  exit
fi

declare -a BPE_SIZES=("300" "10000")
BEST_SIZE="10000"

set=$1

if [ -z "$SLTKITDIR" ]; then
    SLTKITDIR=/opt/SLT.KIT
fi
if [ -z "$BASEDIR" ]; then
    BASEDIR=/
fi

if [ -z "$BASEDIR" ]; then
    CTCISL=/opt/CTC.ISL
fi

if [ -z "$PYTHON3" ]; then
    PYTHON3=/root/anaconda3/bin/python
fi

#Download Data - if not there
if [ ! -e $BASEDIR/data/orig/eval/$set ]; then
    mkdir -p $BASEDIR/data/orig/eval/$set
    cd $BASEDIR/data/orig/eval/$set
    wget http://i13pc106.ira.uka.de/~jniehues/IWSLT-SLT/data/eval/en-de/IWSLT-SLT.$set.en-de.tgz
    tar -xzvf IWSLT-SLT.$set.en-de.tgz
fi

DATA_PATH=$BASEDIR/data/orig/eval/${set}/IWSLT.${set}
# Preprocess Data - if not there
if [ ! -e ${DATA_PATH}/test-db.h5 ]; then
    $SLTKITDIR/scripts/xnmt/make-test-db.sh $BASEDIR/data/orig/eval/${set}/IWSLT.${set}/
fi

for BPE_SIZE in "${BPE_SIZES[@]}"
do

  # Download model if is not there yet
  if [ ! -e $BASEDIR/model/ctc/bpe${BPE_SIZE}.mdl ]; then
    $SLTKITDIR/systems/ctc-tedlium2/Download.sh    
  fi

  # Test
  CTC_OUTPUT=$BASEDIR/data/ctc/eval/
  mkdir -p ${CTC_OUTPUT}
  sed -e "s|#BASEDIR#|$BASEDIR|g" $SLTKITDIR/scripts/ctc/bpe${BPE_SIZE}.yaml >  $BASEDIR/model/ctc/bpe${BPE_SIZE}.yaml
  $PYTHON3 $CTCISL/test.py $BASEDIR/model/ctc/bpe${BPE_SIZE}.yaml --logits_file ${CTC_OUTPUT}/${set}-${BPE_SIZE}.logits --hyp_file ${CTC_OUTPUT}/${set}-${BPE_SIZE}.s --model $BASEDIR/model/ctc/bpe${BPE_SIZE}.mdl --audio_features ${DATA_PATH}/test-db.h5

  # normalize output inplace
  sed -i "s/ '/'/g" ${CTC_OUTPUT}/${set}-${BPE_SIZE}.s

  mkdir -p ${CTC_OUTPUT}/${set}
  $SLTKITDIR/scripts/evaluate/Eval.asr.sh $set ${CTC_OUTPUT}/${set}.s ${CTC_OUTPUT}/${set}
done

ln -s ${CTC_OUTPUT}/${set}-${BEST_SIZE}.s ${CTC_OUTPUT}/${set}.s

