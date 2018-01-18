#!/bin/bash


set=$1
name=$2

mkdir -p /data/${name}/eval
mkdir -p /data/${name}/valid

##TOKENIZE
##SMARTCASE
##BPE

cat /data/orig/eval/$set/IWSLT.$set/IWSLT.TED.$set.$sl-$tl.$sl.xml | \
    grep "<seg id" | sed -e "s/<[^>]*>//g" | \
    perl /opt/mosesdecoder/scripts/tokenizer/tokenizer.perl -l ${sl} | \
    /opt/mosesdecoder/scripts/recaser/truecase.perl --model /model/${name}/truecase-model.s | \
    /opt/subword-nmt/apply_bpe.py -c /model/${name}/codec --vocabulary /model/${name}/voc.s --vocabulary-threshold 50 \
				  > /data/${name}/eval/manualTranscript.$set.s


