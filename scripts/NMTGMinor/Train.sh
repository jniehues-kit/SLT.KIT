#!/bin/bash

input=$1
name=$2

size=512
if [ $# -ne 2 ]; then
    size=$3
fi
layer=8
innersize=`expr $layer * 4`

if [ -z "$BASEDIR" ]; then
    BASEDIR=/
fi

if [ -z "$NMTDIR" ]; then
    NMTDIR=/opt/NMTGMinor/
fi

if [ -z "$GPU" ]; then
    GPU=0
fi

mkdir -p $BASEDIR/tmp/${name}/
mkdir -p $BASEDIR/model/${name}/
mkdir -p $BASEDIR/model/${name}/checkpoints/




for l in s t
do
    for set in train valid
    do
	echo "" > $BASEDIR/tmp/${name}/$set.$l
	for f in $BASEDIR/data/${input}/${set}/*\.${l}
	do
    
		 cat $f >> $BASEDIR/tmp/${name}/$set.$l
	done
   done
done



python $NMTDIR/preprocess.py \
       -train_src $BASEDIR/tmp/${name}/train.s \
       -train_tgt $BASEDIR/tmp/${name}/train.t \
       -valid_src $BASEDIR/tmp/${name}/valid.s \
       -valid_tgt $BASEDIR/tmp/${name}/valid.t \
       -save_data $BASEDIR/model/${name}/train \
       -src_langs s \
       -tgt_langs t 


python -u $NMTDIR/train.py  -data $BASEDIR/tmp/${name}/train -data_format bin \
       -save_model $BASEDIR/model/${name}/checkpoints/model \
       -model transformer \
       -batch_size_words 3584 \
       -batch_size_update 24568 \
       -batch_size_sents 9999 \
       -batch_size_multiplier 8 \
       -checkpointing 0 \
       -layers $lazer \
       -model_size $size \
       -inner_size $innersize \
       -n_heads 8 \
       -dropout 0.2 \
       -attn_dropout 0.2 \
       -word_dropout 0.1 \
       -emb_dropout 0.2 \
       -residual_dropout 0.2 \
       -label_smoothing 0.1 \
       -epochs 64 \
       -learning_rate 2 \
       -optim 'adam' \
       -update_method 'noam' \
       -normalize_gradient \
       -warmup_steps 8000 \
       -max_generator_batches 8192 \
       -tie_weights \
       -seed 8877 \
       -log_interval 1000 \
       -gpus $GPU 2>&1 $BASEDIR/model/${name}/train.log

checkpoints=""

for f in $BASEDIR/model/${name}/checkpoint/model_ppl_*
do
    checkpoints=$checkpoints"$BASEDIR/model/${name}/checkpoint/${f}|"
done



python -u $NMTDIR/average_checkpoints.py -gpu $GPU \
                                    -models $checkpoints \
                                    -output $MODELDIR/model.pt

#rm -r /tmp/${name}/
