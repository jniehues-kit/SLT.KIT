#!/bin/bash

set=$1
input=$2
name=$3

model=model.pt
if [ $# -ne 3 ]; then
    model=$4
fi


mkdir -p /data/$name/eval/

python -u /opt/OpenNMT-py/translate.py -gpu 0 \
       -model /model/$name/$model \
       -src /data/$input/eval/$set.s \
       -batch_size 1 \
       -beam_size 16 \
       -src_lang s \
       -tgt_lang t \
       -normalize \
       -output /data/$name/eval/$set.t
