#!/bin/bash

BPE_STEPS=300
mkdir -p /data/tedlium2-xnmt/bpe${BPE_STEPS}
mkdir -p /model/ctc

if [ ! -f /data/tedlium2-xnmt/feat/train.h5 ]; then
  echo "No audio features found! Running xnmt preprocessing"
  /root/anaconda3/bin/python -m xnmt.xnmt_run_experiments /opt/SLT.KIT/scripts/xnmt/config.las-pyramidal-preproc.yaml  
fi

# learn bpe
/root/anaconda3/bin/python /opt/subword-nmt/subword_nmt/subword_nmt.py learn-bpe --input /data/tedlium2-xnmt/transcript/train.words --output /data/tedlium2-xnmt/bpe${BPE_STEPS}/bpe.rules --symbols ${BPE_STEPS}

# apply bpe
for data in "test" "dev" "train"
do
  /root/anaconda3/bin/python /opt/subword-nmt/subword_nmt/subword_nmt.py apply-bpe -c /data/tedlium2-xnmt/bpe${BPE_STEPS}/bpe.rules < /data/tedlium2-xnmt/transcript/${data}.words > /data/tedlium2-xnmt/bpe${BPE_STEPS}/${data}.units
done

# write mapping of units to ids
/root/anaconda3/bin/python /opt/SLT.KIT/scripts/ctc/create_unit_dict.py --text /data/tedlium2-xnmt/bpe${BPE_STEPS}/train.units --output /model/ctc/units${BPE_STEPS}.json

# Train
/root/anaconda3/bin/python /opt/CTC.ISL/train.py --config /opt/SLT.KIT/scripts/ctc/bpe${BPE_STEPS}.yaml

