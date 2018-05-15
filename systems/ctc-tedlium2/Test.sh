#!/bin/bash

BPE_STEPS=300

# Test
mkdir -p /model/ctc/
/root/anaconda3/bin/python /opt/CTC.ISL/test.py /opt/SLT.KIT/scripts/ctc/bpe${BPE_STEPS}.yaml --logits_file logits.h5 --hyp_file greedy.txt --model /model/ctc/bpe300.mdl
# --audio_features /data/test/IWSLT.tst2015/test-db.h5

