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

fi

