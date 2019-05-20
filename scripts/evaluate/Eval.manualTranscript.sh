#!/bin/bash

set=$1
output=$2


if [ -z "$BASEDIR" ]; then
    BASEDIR=/
fi

if [ -z "$MOSESDIR" ]; then
    MOSESDIR=/opt/mosesdecoder/
fi

if [ -z "$SLTKITDIR" ]; then
    SLTKIT=/opt/SLT.KIT
fi

if [ -z "$TERDIR" ]; then
    TERDIR=/opt/tercom-0.7.25/
fi

if [ -z "$BEERDIR" ]; then
    BEERDIR=/opt/beer_2.0/
fi

if [ -z "$CHARACTERDIR" ]; then
    CHARACTERDIR=/opt/CharacTER/
fi


source=$BASEDIR/data/orig/eval/${set}/IWSLT.${set}/IWSLT.TED.${set}.${sl}-${tl}.${sl}.xml
reference=$BASEDIR/data/orig/eval/${set}/IWSLT.${set}/IWSLT.TED.${set}.${sl}-${tl}.${tl}.xml



mkdir -p $BASEDIR/tmp/eval.manual
mkdir -p $BASEDIR/results/$systemName/$set/


grep "<seg id" $reference | sed -e "s/<[^>]*>//g" > $BASEDIR/tmp/eval.manual/$set.reference

sed -e "s/@@ //g" $BASEDIR/data/$output/eval/manualTranscript.$set.t | sed -e "s/@@$//g" | sed -e "s/&apos;/'/g" -e 's/&#124;/|/g' -e "s/&amp;/&/g" -e 's/&lt;/>/g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&#91;/[/g' -e 's/&#93;/]/g' | perl -nle 'print ucfirst' > $BASEDIR/tmp/eval.manual/$set.hyp

sed -e "s/^\s*$/_EMPTY_/g" $BASEDIR/tmp/eval.manual/$set.hyp > $BASEDIR/tmp/eval.manual/$set.no-empty.hyp
cat $BASEDIR/tmp/eval.manual/$set.hyp | perl $SLTKIT/scripts/evaluate/wrap-xml.perl $tl $BASEDIR/data/orig/eval/$set/IWSLT.$set/IWSLT.TED.$set.$sl-$tl.$sl.xml $systemName > $BASEDIR/tmp/eval.manual/$set.xml



$MOSESDIR/scripts/generic/mteval-v14.pl -c -s $source -r $reference -t $BASEDIR/tmp/eval.manual/$set.xml > $BASEDIR/results/$systemName/$set/manualTranscript.BLEU.case-sensitive
$MOSESDIR/scripts/generic/mteval-v14.pl  -s $source -r $reference -t $BASEDIR/tmp/eval.manual/$set.xml > $BASEDIR/results/$systemName/$set/manualTranscript.BLEU.case-insensitive

java -Dfile.encoding=UTF8 -jar $TERDIR/tercom.7.25.jar -N -s -r $reference -h $BASEDIR/tmp/eval.manual/$set.xml > $BASEDIR/results/$systemName/$set/manualTranscript.TER.case-sensitive
java -Dfile.encoding=UTF8 -jar $TERDIR/tercom.7.25.jar -N -r $reference -h $BASEDIR/tmp/eval.manual/$set.xml > $BASEDIR/results/$systemName/$set/manualTranscript.TER.case-insensitive

$BEERDIR/beer -s $BASEDIR/tmp/eval.manual/$set.hyp -r $BASEDIR/tmp/eval.manual/$set.reference > $BASEDIR/results/$systemName/$set/manualTranscript.BEER.case-sensitive
$CHARACTERDIR/CharacTER.py -r $BASEDIR/tmp/eval.manual/$set.reference -o $BASEDIR/tmp/eval.manual/$set.no-empty.hyp > $BASEDIR/results/$systemName/$set/manualTranscript.CharacTER.case-sensitive


BLEU=`grep BLEU $BASEDIR/results/$systemName/$set/manualTranscript.BLEU.case-sensitive | head -n 1 | awk '{print $8*100}'`
ciBLEU=`grep BLEU $BASEDIR/results/$systemName/$set/manualTranscript.BLEU.case-insensitive | head -n 1 | awk '{print $8*100}'`
TER=`grep TER $BASEDIR/results/$systemName/$set/manualTranscript.TER.case-sensitive | awk '{printf("%.2f\n",$3*100)}'`
ciTER=`grep TER $BASEDIR/results/$systemName/$set/manualTranscript.TER.case-insensitive | awk '{printf("%.2f\n",$3*100)}'`
beer=`awk '{printf("%.2f\n",$3*100)}' $BASEDIR/results/$systemName/$set/manualTranscript.BEER.case-sensitive`
character=`awk '{printf("%.2f\n",$1*100)}' $BASEDIR/results/$systemName/$set/manualTranscript.CharacTER.case-sensitive`

echo "| $set (manual Transcript) | $BLEU | $TER | $beer | $character | $ciBLEU | $ciTER |" >> $BASEDIR/results/$systemName/$set/Summary.md
