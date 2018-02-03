#!/bin/bash

input=$1
name=$2
corpus=$3
mkdir -p /tmp/${name}/
mkdir -p /model/${name}/
size=512
if [ $# -ne 3 ]; then
    size=$4
fi




for l in s t
do
    for set in valid
    do
	echo "" > /tmp/${name}/$set.$l
	for f in /data/${input}/${set}/*\.${l}
	do
    
		 cat $f >> /tmp/${name}/$set.$l
	done
   done
done



python /opt/OpenNMT-py/preprocess.py \
       -train_src /data/${input}/train/${corpus}.s \
       -train_tgt /data/${input}/train/${corpus}.t \
       -valid_src /tmp/${name}/valid.s \
       -valid_tgt /tmp/${name}/valid.t \
       -save_data /tmp/${name}/train.${corpus} \
       -vocab /model/${name}/train.dict \
       -src_langs s \
       -tgt_langs t 


python -u /opt/OpenNMT-py/train.py  -data /tmp/${name}/train.${corpus}.train.pt \
       -save_model /tmp/${name}/adapt.${corpus}.model \
       -brnn \
       -rnn_size $size \
       -word_vec_size $size \
       -batch_size 128 \
       -max_generator_batches 16 \
       -optim adam \
       -dropout 0.2 \
       -epochs 5 \
       -learning_rate 0.000125 \
       -train_from_state_dict /model/${name}/model.pt \
       -gpus 0
       

echo -n "" > /tmp/${name}/list.adapt.${corpus}

for f in /tmp/${name}/adapt.${corpus}.model_ppl_*.pt
do
    echo $f >> /tmp/${name}/list.adapt.${corpus} ;
done

best=`awk '{ppl=$0;gsub(/.tmp..*.adapt.*.model_ppl_/,"",ppl);gsub(/_e[0-9]*.pt/,"",ppl); if(NR==1 || 1.0*ppl < 1.0*min){min=ppl;f=$0}}END{print f}' /tmp/${name}/list.adapt.${corpus}`
echo $best

cp $best /model/$name/model.adapt.${corpus}.pt

rm -r /tmp/${name}/
