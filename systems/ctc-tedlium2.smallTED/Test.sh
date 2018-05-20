#!/bin/bash

if (( $# != 1 )); then
  echo "Specify a test set as a parameter to this script (e.g. tst2010)"
  exit
fi

set=$1

export systemName=ctc-tedlium2.smallTED


/opt/SLT.KIT/systems/ctc-tedlium2/Test.sh $set


#Add puncuation
/opt/SLT.KIT/scripts/monoTranslationData/TestASROutput.sh $set ctc monoTransPrepro monTrans

#Translate
/opt/SLT.KIT/scripts/openNMT-py/Translate.sh ctc.$set monoTransPrepro mt

#Eval
/opt/SLT.KIT/scripts/evaluate/Eval.sh ctc.$set mt $set
