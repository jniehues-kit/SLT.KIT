#!/bin/bash

if [ -z "$SLTKITDIR" ]; then
    SLTKITDIR=/opt/SLT.KIT
fi
if [ -z "$LIUMSPK" ]; then
    LIUMSPK=/opt/lium_spkdiarization-8.4.1.jar
fi

if [ -z "$PYTHON3" ]; then
    PYTHON3=/root/anaconda3/bin/python
fi

if [ -z ${1} ]
then
  echo "must specify path of test set"
else

  echo "" > $1/test-db.yaml
  for f in `cat $1/FILE_ORDER`
  do
    java -jar $LIUMSPK --fInputSpeechThr=0.0 --fInputMask=$1/wavs/$f.wav --sOutputMask=$1/wavs/$f.seg $f --saveAllStep
    # using *.s.seg for now, we live with possibly bad segmentation instead of throwing away to much stuff
    # also sort by start offset of utterance
    cat $1/wavs/$f.s.seg | grep --invert-match ";;" | sort -n -k3 | awk '{print "- {\"wav\": \"PATH/wavs/" $1 ".wav\", \"offset\":" $3/100 ", \"duration\":" ($4)/100 "}"}' >> $1/test-db.yaml
  done
  sed -i 's\PATH\'$1'\g' ${1}/test-db.yaml
 
  cat $SLTKITDIR/scripts/xnmt/extract-test-db.yaml | sed "s|{IN}|$1/test-db.yaml|g" | sed "s|{OUT}|$1/test-db.h5|g" > $1/extract-test-db.yaml

  $PYTHON3 -m xnmt.xnmt_run_experiments $1/extract-test-db.yaml

fi

