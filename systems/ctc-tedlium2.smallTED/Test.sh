#!/bin/bash

if (( $# != 1 )); then
  echo "Specify a test set as a parameter to this script (e.g. tst2010)"
  exit
fi

if [ -z "$SLTKITDIR" ]; then
    SLTKITDIR=/opt/SLT.KIT
fi


set=$1

export systemName=ctc-tedlium2.smallTED


$SLTKITDIR/systems/ctc-tedlium2/Test.sh $set


#Add puncuation
$SLTKITDIR/scripts/monoTranslationData/TestASROutput.sh $set ctc monoTransPrepro monTrans

#Translate
$SLTKITDIR/scripts/openNMT-py/Translate.sh ctc.$set monoTransPrepro mt

#Eval
$SLTKITDIR/scripts/evaluate/Eval.sh ctc.$set mt $set
