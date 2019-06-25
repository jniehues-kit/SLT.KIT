#!/bin/bash


set=$1
name=$2

if [ -z "$BASEDIR" ]; then
    BASEDIR=/
fi

if [ -z "$MOSESDIR" ]; then
    MOSESDIR=/opt/mosesdecoder/
fi

if [ -z "$BPEDIR" ]; then
    BPEDIR=/opt/subword-nmt/
fi



mkdir -p $BASEDIR/data/${name}/eval
mkdir -p $BASEDIR/data/${name}/valid

##TOKENIZE
##SMARTCASE
##BPE

xml=0
if [ -f $BASEDIR/data/orig/eval/$set/IWSLT.$set/IWSLT.TED.$set.$sl-$tl.$sl.xml ]; then
    inFile=$BASEDIR/data/orig/eval/$set/IWSLT.$set/IWSLT.TED.$set.$sl-$tl.$sl.xml
    xml=1
elif [ -f $BASEDIR/data/orig/eval/$set/$set.$sl ]; then
    inFile=$BASEDIR/data/orig/eval/$set/$set.$sl
    xml=0
fi

xmlcommand=""
if [ $xml -eq 1 ]; then

 cat $inFile | grep "<seg id" | sed -e "s/<[^>]*>//g" | \
    perl $MOSESDIR/scripts/tokenizer/tokenizer.perl -l ${sl} | \
    $MOSESDIR/scripts/recaser/truecase.perl --model $BASEDIR/model/${name}/truecase-model.s | \
    $BPEDIR/apply_bpe.py -c $BASEDIR/model/${name}/codec --vocabulary $BASEDIR/model/${name}/voc.s --vocabulary-threshold 50 \
				  > $BASEDIR/data/${name}/eval/manualTranscript.$set.s
else
cat $inFile | \
    perl $MOSESDIR/scripts/tokenizer/tokenizer.perl -l ${sl} | \
    $MOSESDIR/scripts/recaser/truecase.perl --model $BASEDIR/model/${name}/truecase-model.s | \
    $BPEDIR/apply_bpe.py -c $BASEDIR/model/${name}/codec --vocabulary $BASEDIR/model/${name}/voc.s --vocabulary-threshold 50 \
				  > $BASEDIR/data/${name}/eval/manualTranscript.$set.s

fi
