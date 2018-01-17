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
       -valid_tgt /tmp/${name}/valid.t \
       -save_data /tmp/${name}/train \
       -src_langs s \
       -tgt_langs t 


python -u /opt/OpenNMT-py/train.py  -data /tmp/${name}/train.train.pt \
       -save_model /tmp/${name}/model \
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

for f in /tmp/${name}/model_ppl_*.pt
do
    echo $f >> /tmp/${name}/list ;
done


best=`awk '{ppl=$0;gsub(/.tmp.*.model_ppl_/,"",ppl);gsub(/_e[0-9]*.pt/,"",ppl); if(NR==1 || 1.0*ppl < 1.0*min){min=ppl;f=$0}}END{print f}' /tmp/${name}/list`

python -u /opt/OpenNMT-py/train.py  -data /tmp/${name}/train.train.pt \
       -save_model /tmp/${name}/cont.model \
       -brnn \
       -rnn_size 512 \
       -word_vec_size 512 \
       -batch_size 128 \
       -max_generator_batches 16 \
       -optim adam \
       -dropout 0.2 \
       -epochs 5 \
       -learning_rate 0.000125 \
       -train_from_state_dict $best \
       -gpus 0
       

for f in /tmp/${name}/cont.model_ppl_*.pt
do
    echo $f >> /tmp/${name}/list.cont ;
done


best=`awk '{ppl=$0;gsub(/.tmp..*.cont.model_ppl_/,"",ppl);gsub(/_e[0-9]*.pt/,"",ppl); if(NR==1 || 1.0*ppl < 1.0*min){min=ppl;f=$0}}END{print f}' /tmp/${name}/list.cont`
echo $best

cp $best /model/$name/model.pt
cp /tmp/$name/train.dict.s /model/$name/
cp /tmp/$name/train.dict.t /model/$name/

rm -r /tmp/${name}/
