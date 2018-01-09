#!/bin/bash


input=$1
name=$2

mkdir -p /tmp/${name}/tok/train
mkdir -p /tmp/${name}/tok/valid
mkdir -p /tmp/${name}/sc/train
mkdir -p /tmp/${name}/sc/valid
mkdir -p /model/${name}
mkdir -p /data/${name}/train
mkdir -p /data/${name}/valid

##TOKENIZE

echo "" > /tmp/${name}/corpus.tok.s
for f in /data/${input}/parallel/*\.s
do
cat $f | perl /opt/mosesdecoder/scripts/tokenizer/tokenizer.perl -l ${sl} > /tmp/${name}/tok/train/${f##*/}
cat /tmp/${name}/tok/train/${f##*/} >> /tmp/${name}/corpus.tok.s
done
for f in /data/${input}/valid/*\.s
do
cat $f | perl /opt/mosesdecoder/scripts/tokenizer/tokenizer.perl -l ${sl} > /tmp/${name}/tok/valid/${f##*/}
done



echo "" > /tmp/${name}/corpus.tok.t
for f in /data/${input}/parallel/*\.t
do
cat $f | perl /opt/mosesdecoder/scripts/tokenizer/tokenizer.perl -l ${tl} > /tmp/${name}/tok/train/${f##*/}
cat /tmp/${name}/tok/train/${f##*/} >> /tmp/${name}/corpus.tok.t
done
for f in /data/${input}/valid/*\.t
do
cat $f | perl /opt/mosesdecoder/scripts/tokenizer/tokenizer.perl -l ${tl} > /tmp/${name}/tok/valid/${f##*/}
done



##SMARTCASE


/opt/mosesdecoder/scripts/recaser/train-truecaser.perl --model /model/${name}/truecase-model.s --corpus /tmp/${name}/corpus.tok.s
/opt/mosesdecoder/scripts/recaser/train-truecaser.perl --model /model/${name}/truecase-model.t --corpus /tmp/${name}/corpus.tok.t

for set in valid train
do
for f in /tmp/${name}/tok/$set/*\.s
do
cat $f | /opt/mosesdecoder/scripts/recaser/truecase.perl --model /model/${name}/truecase-model.s > /tmp/${name}/sc/$set/${f##*/}
done
done

for set in valid train
do
for f in /tmp/${name}/tok/$set/*\.t
do
cat $f | /opt/mosesdecoder/scripts/recaser/truecase.perl --model /model/${name}/truecase-model.t > /tmp/${name}/sc/$set/${f##*/}
done
done

echo "" > /tmp/${name}/corpus.sc.s
for f in /tmp/${name}/sc/train/*\.s
do
cat $f >> /tmp/${name}/corpus.sc.s
done

echo "" > /tmp/${name}/corpus.sc.t
for f in /tmp/${name}/sc/train/*\.t
do
cat $f >> /tmp/${name}/corpus.sc.t
done

##BPE


/opt/subword-nmt/learn_joint_bpe_and_vocab.py --input /tmp/${name}/corpus.sc.s /tmp/${name}/corpus.sc.t -s 40000 -o /model/${name}/codec --write-vocabulary /model/${name}/voc.s /model/${name}/voc.t


for set in valid train
do
for f in /tmp/${name}/tok/$set/*\.s
do
echo $f
/opt/subword-nmt/apply_bpe.py -c /model/${name}/codec --vocabulary /model/${name}/voc.s --vocabulary-threshold 50 < $f > /data/${name}/$set/${f##*/}
done
done

for set in valid train
do
for f in /tmp/${name}/tok/$set/*\.t
do
echo $f
/opt/subword-nmt/apply_bpe.py -c /model/${name}/codec --vocabulary /model/${name}/voc.t --vocabulary-threshold 50 < $f > /data/${name}/$set/${f##*/}
done
done


rm -r /tmp/${name}/
