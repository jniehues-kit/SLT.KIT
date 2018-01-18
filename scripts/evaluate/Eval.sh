#!/bin/bash

set=$1
output=$2


source=/data/orig/eval/${set}/IWSLT.${set}/IWSLT.TED.${set}.${sl}-${tl}.${sl}.xml
reference=/data/orig/eval/${set}/IWSLT.${set}/IWSLT.TED.${set}.${sl}-${tl}.${tl}.xml



mkdir -p /tmp/eval
mkdir -p /results/$systemName/$set/


grep "<seg id" $reference | sed -e "s/<[^>]*>//g" > /tmp/eval/$set.reference

sed -e "s/@@ //g" /data/$output/eval/$set.t | sed -e "s/@@$//g" | sed -e "s/&apos;/'/g" -e 's/&#124;/|/g' -e "s/&amp;/&/g" -e 's/&lt;/>/g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&#91;/[/g' -e 's/&#93;/]/g' | perl -nle 'print ucfirst' > /tmp/eval/$set.clean.t



/opt/mwerSegmenter/segmentBasedOnMWER.sh $source $reference /tmp/eval/$set.clean.t $systemName $tl /tmp/eval/$set.sgm normalize 1
/opt/mwerSegmenter/segmentBasedOnMWER.sh $source $reference /tmp/eval/$set.clean.t $systemName $tl /tmp/eval/$set.no-case.sgm normalize 0
sed -e "/<[^>]*>/d" /tmp/eval/$set.sgm > /tmp/eval/$set.hyp
sed -e "/<[^>]*>/d" /tmp/eval/$set.no-case.sgm > /tmp/eval/$set.no-case.hyp
sed -e "s/^\s*$/_EMPTY_/g" /tmp/eval/$set.hyp > /tmp/eval/$set.no-empty.hyp
cat /tmp/eval/$set.hyp | perl /opt/SLT.KIT/scripts/evaluate/wrap-xml.perl de /data/orig/eval/dev2010/IWSLT.dev2010/IWSLT.TED.dev2010.en-de.en.xml $systemName > /tmp/eval/$set.xml
cat /tmp/eval/$set.no-case.hyp | perl /opt/SLT.KIT/scripts/evaluate/wrap-xml.perl de /data/orig/eval/dev2010/IWSLT.dev2010/IWSLT.TED.dev2010.en-de.en.xml $systemName > /tmp/eval/$set.no-case.xml


/opt/mosesdecoder/scripts/generic/mteval-v14.pl -c -s $source -r $reference -t /tmp/eval/$set.xml > /results/$systemName/$set/BLEU.case-sensitive
/opt/mosesdecoder/scripts/generic/mteval-v14.pl  -s $source -r $reference -t /tmp/eval/$set.no-case.xml > /results/$systemName/$set/BLEU.case-insensitive

java -Dfile.encoding=UTF8 -jar /opt/tercom-0.7.25/tercom.7.25.jar -N -s -r $reference -h /tmp/eval/$set.xml > /results/$systemName/$set/TER.case-sensitive
java -Dfile.encoding=UTF8 -jar /opt/tercom-0.7.25/tercom.7.25.jar -N -r $reference -h /tmp/eval/$set.no-case.xml > /results/$systemName/$set/TER.case-insensitive

/opt/beer_2.0/beer -s /tmp/eval/$set.hyp -r /tmp/eval/$set.reference > /results/$systemName/$set/BEER.case-sensitive
/opt/CharacTER/CharacTER.py -r /tmp/eval/$set.reference -o /tmp/eval/$set.no-empty.hyp > /results/$systemName/$set/CharacTER.case-senstive


BLEU=`grep BLEU /results/$systemName/$set/BLEU.case-sensitive | head -n 1 | awk '{print $8*100}'`
ciBLEU=`grep BLEU /results/$systemName/$set/BLEU.case-insensitive | head -n 1 | awk '{print $8*100}'`
TER=`grep TER /results/$systemName/$set/TER.case-sensitive | awk '{printf("%.2f\n",$3*100)}'`
ciTER=`grep TER /results/$systemName/$set/TER.case-insensitive | awk '{printf("%.2f\n",$3*100)}'`
beer=`awk '{printf("%.2f\n",$3*100)}' /results/$systemName/$set/BEER.case-sensitive`
character=`awk '{printf("%.1f\n",$3*100)}' /results/$systemName/$set/BEER.case-sensitive`

echo "Results for $systemName" > /results/$systemName/$set/Summary.md
echo "=======================" >> /results/$systemName/$set/Summary.md
echo "| SET | BLEU | TER | BEER | CharacTER | BLEU(ci) | TER(ci) |" >> /results/$systemName/$set/Summary.md
echo "| --- | ---- | --- | ---- | --------- | -------- | ------- |" >> /results/$systemName/$set/Summary.md
echo "| $set | $BLEU | $TER | $beer | $character | $ciBLEU | $ciTER |" >> /results/$systemName/$set/Summary.md
