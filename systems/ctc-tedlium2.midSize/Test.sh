#!/bin/bash

set=$1

export systemName=ctc-tedlium2.midSizeTED


/opt/SLT.KIT/systems/ctc-tedlium2/Test.sh $set


#Add puncuation
/opt/SLT.KIT/scripts/monoTranslationData/TestASROutput.sh $set ctc monoTransPrepro monTrans model.adapt.TED.pt

#Translate
/opt/SLT.KIT/scripts/openNMT-py/Translate.sh ctc.$set monoTransPrepro mt model.adapt.TED.pt

#Eval
/opt/SLT.KIT/scripts/evaluate/Eval.sh ctc.$set mt $set
