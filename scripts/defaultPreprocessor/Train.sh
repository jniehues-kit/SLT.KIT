#!/bin/bash


mkdir -p /tmp/defaultPreprocessor/tok/train
mkdir -p /tmp/defaultPreprocessor/tok/valid
mkdir -p /tmp/defaultPreprocessor/sc/train
mkdir -p /tmp/defaultPreprocessor/sc/valid
mkdir -p /data/defaultPreprocessor/model


##TOKENIZE

echo "" > /tmp/defaultPreprocessor/corpus.tok.s
for f in /data/parallel/*\.s
do
cat $f | perl /opt/mosesdecoder/scripts/tokenizer/tokenizer.perl -l ${sl} > /tmp/defaultPreprocessor/tok/train/${f##*/}
cat /tmp/defaultPreprocessor/tok/train/${f##*/} >> /tmp/defaultPreprocessor/corpus.tok.s
done
for f in /data/valid/*\.s
do
cat $f | perl /opt/mosesdecoder/scripts/tokenizer/tokenizer.perl -l ${sl} > /tmp/defaultPreprocessor/tok/valid/${f##*/}
done



echo "" > /tmp/defaultPreprocessor/corpus.tok.t
for f in /data/parallel/*\.t
do
cat $f | perl /opt/mosesdecoder/scripts/tokenizer/tokenizer.perl -l ${sl} > /tmp/defaultPreprocessor/tok/train/${f##*/}
cat /tmp/defaultPreprocessor/tok/train/${f##*/} >> /tmp/defaultPreprocessor/corpus.tok.t
done
for f in /data/valid/*\.t
do
cat $f | perl /opt/mosesdecoder/scripts/tokenizer/tokenizer.perl -l ${sl} > /tmp/defaultPreprocessor/tok/valid/${f##*/}
done



##SMARTCASE


/opt/mosesdecoder/scripts/recaser/train-truecaser.perl --model /data/defaultPreprocessor/model/truecase-model.s --corpus /tmp/defaultPreprocessor/corpus.tok.s
/opt/mosesdecoder/scripts/recaser/train-truecaser.perl --model /data/defaultPreprocessor/model/truecase-model.t --corpus /tmp/defaultPreprocessor/corpus.tok.t

for set in dev train
do
for f in /tmp/defaultPreprocessor/tok/$set/*\.s
do
cat $f | /opt/mosesdecoder/scripts/recaser/truecase.perl --model /tmp/defaultPreprocessor/corpus.tok.s > /tmp/defaultPreprocessor/sc/$set/${f##*/}
done
done

for set in dev train
do
for f in /tmp/defaultPreprocessor/tok/$set/*\.t
do
cat $f | /opt/mosesdecoder/scripts/recaser/truecase.perl --model /tmp/defaultPreprocessor/corpus.tok.t > /tmp/defaultPreprocessor/sc/$set/${f##*/}
done
done

echo "" > /tmp/defaultPreprocessor/corpus.sc.s
for f in /tmp/defaultPreprocessor/sc/train/*\.s
do
cat $f >> /tmp/defaultPreprocessor/corpus.sc.s
done

echo "" > /tmp/defaultPreprocessor/corpus.sc.t
for f in /tmp/defaultPreprocessor/sc/train/*\.t
do
cat $f >> /tmp/defaultPreprocessor/corpus.sc.t
done

##BPE


/opt/subword-nmt/learn_joint_bpe_and_vocab.py --input /tmp/defaultPreprocessor/corpus.sc.s /tmp/defaultPreprocessor/corpus.sc.t -s 40000 -o /data/defaultPreprocessor/model/codec --write-vocabulary /data/defaultPreprocessor/model/voc.s /data/defaultPreprocessor/model/voc.t


for set in dev train
do
for f in /tmp/defaultPreprocessor/tok/$set/*\.s
do
/opt/subword-nmt/apply_bpe.py -c /data/defaultPreprocessor/model/codec --vocabulary /data/defaultPreprocessor/model/voc.s --vocabulary-threshold 50 < $f > /data/defaultPreprocessor/$set/${f##*/}
done

for set in dev train
do
for f in /tmp/defaultPreprocessor/tok/$set/*\.t
do
/opt/subword-nmt/apply_bpe.py -c /data/defaultPreprocessor/model/codec --vocabulary /data/defaultPreprocessor/model/voc.t --vocabulary-threshold 50 < $f > /data/defaultPreprocessor/$set/${f##*/}
done

