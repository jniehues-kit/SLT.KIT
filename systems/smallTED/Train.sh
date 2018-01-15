#!/bin/bash

#Download Data
/opt/SLT.KIT/scripts/dataCollection/IWSLT.2017.sh


#Preprocess Data
/opt/SLT.KIT/scripts/defaultPreprocessor/Train.sh orig prepro


#Train NMT
/opt/SLT.KIT/scripts/openNMT-py/Train.sh prepro mt


#Preprocess for Puncutation
/SLT.KIT/scripts/monoTranslationData/Train.sh prepro monoTransPrepro

#monTranslationSystem
/opt/SLT.KIT/scripts/openNMT-py/Train.sh monoTransPrepro monTrans
