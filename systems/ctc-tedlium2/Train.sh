#!/bin/bash

BPE_STEPS=300
mkdir -p /data/tedlium2-xnmt/bpe${BPE_STEPS}

# learn bpe
/opt/subword-nmt/learn_bpe.py --input /data/tedlium2-xnmt/transcript/train.words --output /data/tedlium2-xnmt/bpe${BPE_STEPS}/bpe.rules --symbols ${BPE_STEPS}

# apply bpe
for data in "test" "dev" "train"
do
  /opt/subword-nmt/apply_bpe.py -c /data/tedlium2-xnmt/bpe${BPE_STEPS}/bpe.rules < /data/tedlium2-xnmt/transcript/${data}.words > /data/tedlium2-xnmt/bpe${BPE_STEPS}/${data}.units
done

# write mapping of units to ids
/opt/SLT.KIT/scripts/ctc/create_unit_dict.py --text /data/tedlium2-xnmt/bpe${BPE_STEPS}/train.units --output /data/tedlium2-xnmt/bpe${BPE_STEPS}/units.json

