#!/bin/bash

#Download Data
/opt/SLT.KIT/scripts/dataCollection/IWSLT.2017.sh
/opt/SLT.KIT/scripts/dataCollection/EPPS.sh


#Preprocess Data
/opt/SLT.KIT/scripts/defaultPreprocessor/Train.sh orig prepro


#Train NMT
/opt/SLT.KIT/scripts/openNMT-py/Train.sh prepro mt 1024
/opt/SLT.KIT/scripts/openNMT-py/Adapt.sh prepro mt TED 1024


#Preprocess for Puncutation
/opt/SLT.KIT/scripts/monoTranslationData/Train.sh prepro monoTransPrepro

#monTranslationSystem
/opt/SLT.KIT/scripts/openNMT-py/Train.sh monoTransPrepro monTrans 1024
/opt/SLT.KIT/scripts/openNMT-py/Adapt.sh monoTransPrepro monTrans TED 1024
