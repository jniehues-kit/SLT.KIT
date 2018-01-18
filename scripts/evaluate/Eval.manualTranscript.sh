#!/bin/bash

set=$1
output=$2


source=/data/orig/eval/${set}/IWSLT.${set}/IWSLT.TED.${set}.${sl}-${tl}.${sl}.xml
reference=/data/orig/eval/${set}/IWSLT.${set}/IWSLT.TED.${set}.${sl}-${tl}.${tl}.xml



mkdir -p /tmp/eval.manual
mkdir -p /results/$systemName/$set/


grep "<seg id" $reference | sed -e "s/<[^>]*>//g" > /tmp/eval.manual/$set.reference

sed -e "s/@@ //g" /data/$output/eval/manualTranscript.$set.t | sed -e "s/@@$//g" | sed -e "s/&apos;/'/g" -e 's/&#124;/|/g' -e "s/&amp;/&/g" -e 's/&lt;/>/g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&#91;/[/g' -e 's/&#93;/]/g' | perl -nle 'print ucfirst' > /tmp/eval.manual/$set.hyp

sed -e "s/^\s*$/_EMPTY_/g" /tmp/eval.manual/$set.hyp > /tmp/eval.manual/$set.no-empty.hyp
cat /tmp/eval.manual/$set.hyp | perl /opt/SLT.KIT/scripts/evaluate/wrap-xml.perl de /data/orig/eval/dev2010/IWSLT.dev2010/IWSLT.TED.dev2010.en-de.en.xml $systemName > /tmp/eval.manual/$set.xml



/opt/mosesdecoder/scripts/generic/mteval-v14.pl -c -s $source -r $reference -t /tmp/eval.manual/$set.xml > /results/$systemName/$set/manualTranscript.BLEU.case-sensitive
/opt/mosesdecoder/scripts/generic/mteval-v14.pl  -s $source -r $reference -t /tmp/eval.manual/$set.xml > /results/$systemName/$set/manualTranscript.BLEU.case-insensitive

java -Dfile.encoding=UTF8 -jar /opt/tercom-0.7.25/tercom.7.25.jar -N -s -r $reference -h /tmp/eval.manual/$set.xml > /results/$systemName/$set/manualTranscript.TER.case-sensitive
java -Dfile.encoding=UTF8 -jar /opt/tercom-0.7.25/tercom.7.25.jar -N -r $reference -h /tmp/eval.manual/$set.xml > /results/$systemName/$set/manualTranscript.TER.case-insensitive

/opt/beer_2.0/beer -s /tmp/eval.manual/$set.hyp -r /tmp/eval.manual/$set.reference > /results/$systemName/$set/manualTranscript.BEER.case-sensitive
/opt/CharacTER/CharacTER.py -r /tmp/eval.manual/$set.reference -o /tmp/eval.manual/$set.no-empty.hyp > /results/$systemName/$set/manualTranscript.CharacTER.case-sensitive


BLEU=`grep BLEU /results/$systemName/$set/manualTranscript.BLEU.case-sensitive | head -n 1 | awk '{print $8*100}'`
ciBLEU=`grep BLEU /results/$systemName/$set/manualTranscript.BLEU.case-insensitive | head -n 1 | awk '{print $8*100}'`
TER=`grep TER /results/$systemName/$set/manualTranscript.TER.case-sensitive | awk '{printf("%.2f\n",$3*100)}'`
ciTER=`grep TER /results/$systemName/$set/manualTranscript.TER.case-insensitive | awk '{printf("%.2f\n",$3*100)}'`
beer=`awk '{printf("%.2f\n",$3*100)}' /results/$systemName/$set/manualTranscript.BEER.case-sensitive`
character=`awk '{printf("%.2f\n",$1*100)}' /results/$systemName/$set/manualTranscript.CharacTER.case-sensitive`

echo "| $set (manual Transcript) | $BLEU | $TER | $beer | $character | $ciBLEU | $ciTER |" >> /results/$systemName/$set/Summary.md
