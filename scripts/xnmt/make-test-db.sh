#!/bin/bash

if [ -z ${1} ]
then
  echo "must specify path of test set"
else

  echo "" > $1/test-db.yaml
  for f in `cat $1/FILE_ORDER`
  do
    java -jar /opt/tools/lium_spkdiarization-8.4.1.jar --fInputMask=$1/wavs/$f.wav --sOutputMask=$1/wavs/$f.seg $f
    cat $1/wavs/$f.seg | grep --invert-match ";;" | awk '{print "- {\"wav\": \"$1/wavs/" $1 ".wav\", \"offset\":" $3/100 ", \"duration\":" ($4)/100 "}"}' >> $1/test-db.yaml
  done
 
  cat /opt/SLT.KIT/scripts/xnmt/extract-test-db.yaml | sed "s|{IN}|$1/test-db.yaml|g" | sed "s|{OUT}|$1/test-db.h5|g" > $1/extract-test-db.yaml

  /root/anaconda3/bin/python -m xnmt.xnmt_run_experiments $1/extract-test-db.yaml

fi

