#!/bin/bash

BPE_STEPS=300

if (( $# == 1 )); then
  BPE_STEPS=$1
  echo "Setting BPE Steps to ${BPE_STEPS}"
fi

mkdir -p /data/tedlium2-xnmt/bpe${BPE_STEPS}
mkdir -p /model/ctc

if [ ! -f /data/tedlium2-xnmt/feat/train.h5 ]; then
  echo "No audio features found! Running xnmt preprocessing"
  /root/anaconda3/bin/python -m xnmt.xnmt_run_experiments /opt/SLT.KIT/scripts/xnmt/config.las-pyramidal-preproc.yaml  
fi

# remove junk that annoys python
for data in "test" "dev" "train"
do
  tr -cd "[:print:]\n" < /data/tedlium2-xnmt/transcript/${data}.words > /data/tedlium2-xnmt/transcript/${data}.words.printable
done
# learn bpe
subword-nmt learn-bpe --input /data/tedlium2-xnmt/transcript/train.words.printable --output /data/tedlium2-xnmt/bpe${BPE_STEPS}/bpe.rules --symbols ${BPE_STEPS}

# apply bpe
for data in "test" "dev" "train"
do
  subword-nmt apply-bpe -c /data/tedlium2-xnmt/bpe${BPE_STEPS}/bpe.rules < /data/tedlium2-xnmt/transcript/${data}.words.printable > /data/tedlium2-xnmt/bpe${BPE_STEPS}/${data}.units
done
rm /data/tedlium2-xnmt/transcript/*.words.printable

# create units for all characters, including base characters that are not necessarly used
cat /data/tedlium2-xnmt/bpe${BPE_STEPS}/*.units > /data/tedlium2-xnmt/bpe${BPE_STEPS}/all.units.tmp
characters="0123456789abcdefghijklmnopqrstuvwxyz'&-/"
for i in $(seq 1 ${#characters});
do
  echo "${characters:i-1:1}" >> /data/tedlium2-xnmt/bpe${BPE_STEPS}/all.units.tmp
  echo "${characters:i-1:1}@@" >> /data/tedlium2-xnmt/bpe${BPE_STEPS}/all.units.tmp
done

# write mapping of units to ids
/root/anaconda3/bin/python /opt/SLT.KIT/scripts/ctc/create_unit_dict.py --text /data/tedlium2-xnmt/bpe${BPE_STEPS}/all.units.tmp --output /model/ctc/units${BPE_STEPS}.json
rm /data/tedlium2-xnmt/bpe${BPE_STEPS}/all.units.tmp

# Train
/root/anaconda3/bin/python /opt/CTC.ISL/train.py --config /opt/SLT.KIT/scripts/ctc/bpe${BPE_STEPS}.yaml

