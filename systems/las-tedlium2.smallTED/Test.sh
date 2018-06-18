#!/bin/bash

if (( $# != 1 )); then
  echo "Specify a test set as a parameter to this script (e.g. tst2010)"
  exit
fi

set=$1

export systemName=las-tedlium2.smallTED


/opt/SLT.KIT/systems/las-tedlium2/Test.sh $set


#Add puncuation
/opt/SLT.KIT/scripts/monoTranslationData/TestASROutput.sh $set las monoTransPrepro monTrans

#Translate
/opt/SLT.KIT/scripts/openNMT-py/Translate.sh las.$set monoTransPrepro mt

#Eval
/opt/SLT.KIT/scripts/evaluate/Eval.sh las.$set mt $set
