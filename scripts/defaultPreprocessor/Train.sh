#!/bin/bash

if [ -z "$BASEDIR" ]; then
    BASEDIR=/
fi

if [ -z "$MOSESDIR" ]; then
    MOSESDIR=/opt/mosesdecoder/
fi

if [ -z "$BPEDIR" ]; then
    BPEDIR=/opt/subword-nmt/
fi

input=$1
name=$2

mkdir -p $BASEDIR/tmp/${name}/tok/train
mkdir -p $BASEDIR/tmp/${name}/tok/valid
mkdir -p $BASEDIR/tmp/${name}/sc/train
mkdir -p $BASEDIR/tmp/${name}/sc/valid
mkdir -p $BASEDIR/model/${name}
mkdir -p $BASEDIR/data/${name}/train
mkdir -p $BASEDIR/data/${name}/valid

##TOKENIZE

echo "" > $BASEDIR/tmp/${name}/corpus.tok.s
for f in $BASEDIR/data/${input}/parallel/*\.s
do
cat $f | perl $MOSESDIR/scripts/tokenizer/tokenizer.perl -l ${sl} > $BASEDIR/tmp/${name}/tok/train/${f##*/}
cat $BASEDIR/tmp/${name}/tok/train/${f##*/} >> $BASEDIR/tmp/${name}/corpus.tok.s
done
for f in $BASEDIR/data/${input}/valid/*\.s
do
cat $f | perl $MOSESDIR/scripts/tokenizer/tokenizer.perl -l ${sl} > $BASEDIR/tmp/${name}/tok/valid/${f##*/}
done



echo "" > $BASEDIR/tmp/${name}/corpus.tok.t
for f in $BASEDIR/data/${input}/parallel/*\.t
do
cat $f | perl $MOSESDIR/scripts/tokenizer/tokenizer.perl -l ${tl} > $BASEDIR/tmp/${name}/tok/train/${f##*/}
cat $BASEDIR/tmp/${name}/tok/train/${f##*/} >> $BASEDIR/tmp/${name}/corpus.tok.t
done
for f in $BASEDIR/data/${input}/valid/*\.t
do
cat $f | perl $MOSES/opt/mosesdecoder/scripts/tokenizer/tokenizer.perl -l ${tl} > $BASEDIR/tmp/${name}/tok/valid/${f##*/}
done



##SMARTCASE


$MOSESDIR/scripts/recaser/train-truecaser.perl --model $BASEDIR/model/${name}/truecase-model.s --corpus $BASEDIR/tmp/${name}/corpus.tok.s
$MOSESDIR/scripts/recaser/train-truecaser.perl --model $BASEDIR/model/${name}/truecase-model.t --corpus $BASEDIR/tmp/${name}/corpus.tok.t

for set in valid train
do
for f in $BASEDIR/tmp/${name}/tok/$set/*\.s
do
cat $f | $MOSESDIR/scripts/recaser/truecase.perl --model $BASEDIR/model/${name}/truecase-model.s > $BASEDIR/tmp/${name}/sc/$set/${f##*/}
done
done

for set in valid train
do
for f in $BASEDIR/tmp/${name}/tok/$set/*\.t
do
cat $f | $MOSESDIR/scripts/recaser/truecase.perl --model $BASEDIR/model/${name}/truecase-model.t > $BASEDIR/tmp/${name}/sc/$set/${f##*/}
done
done

echo "" > $BASEDIR/tmp/${name}/corpus.sc.s
for f in $BASEDIR/tmp/${name}/sc/train/*\.s
do
cat $f >> $BASEDIR/tmp/${name}/corpus.sc.s
done

echo "" > $BASEDIR/tmp/${name}/corpus.sc.t
for f in $BASEDIR/tmp/${name}/sc/train/*\.t
do
cat $f >> $BASEDIR/tmp/${name}/corpus.sc.t
done

##BPE


$BPEDIR/subword_nmt/learn_joint_bpe_and_vocab.py --input $BASEDIR/tmp/${name}/corpus.sc.s $BASEDIR/tmp/${name}/corpus.sc.t -s 40000 -o $BASEDIR/model/${name}/codec --write-vocabulary $BASEDIR/model/${name}/voc.s $BASEDIR/model/${name}/voc.t


for set in valid train
do
for f in $BASEDIR/tmp/${name}/sc/$set/*\.s
do
echo $f
$BPEDIR/subword_nmt/apply_bpe.py -c $BASEDIR/model/${name}/codec --vocabulary $BASEDIR/model/${name}/voc.s --vocabulary-threshold 50 < $f > $BASEDIR/data/${name}/$set/${f##*/}
done
done

for set in valid train
do
for f in $BASEDIR/tmp/${name}/sc/$set/*\.t
do
echo $f
$BPEDIR/subword_nmt/apply_bpe.py -c $BASEDIR/model/${name}/codec --vocabulary $BASEDIR/model/${name}/voc.t --vocabulary-threshold 50 < $f > $BASEDIR/data/${name}/$set/${f##*/}
done
done


rm -r $BASEDIR/tmp/${name}/
