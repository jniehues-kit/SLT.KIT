#!/bin/bash

input=$1
name=$2


mkdir -p /tmp/${name}/
mkdir -p /model/${name}/




for l in s t
do
    for set in train valid
    do
	echo "" > /tmp/${name}/$set.$l
	for f in /data/${input}/${set}/*\.${l}
	do
	    
		 cat $f >> /tmp/${name}/$set.$l
	done
    done
done



python /opt/OpenNMT-py/preprocess.py \
       -train_src /tmp/${name}/train.s \
       -train_tgt /tmp/${name}/train.t \
       -valid_src /tmp/${name}/valid.s \
       -valid_tgt /tmp/${name}/vaild.t \
       -save_data /tmp/${name}/train \
       -src_langs s \
       -tgt_langs t 


python -u /opt/OpenNMT-py/train.py  -data /tmp/${name}/train.train.pt \
       -save_model /model/${name}/model \
       -brnn \
       -rnn_size 512 \
       -word_vec_size 512 \
       -batch_size 128 \
       -max_generator_batches 16 \
       -optim adam \
       -dropout 0.2 \
       -epochs 10 \
       -learning_rate 0.001 \
       -gpus 0
