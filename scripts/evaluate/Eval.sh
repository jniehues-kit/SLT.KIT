#!/bin/bash

name=$1
output=$2

if [ $# -ne 2 ]; then
    set=$3
else
set=$name
fi


source=/data/orig/eval/${set}/IWSLT.${set}/IWSLT.TED.${set}.${sl}-${tl}.${sl}.xml
reference=/data/orig/eval/${set}/IWSLT.${set}/IWSLT.TED.${set}.${sl}-${tl}.${tl}.xml



mkdir -p /tmp/eval
mkdir -p /results/$systemName/$name/


grep "<seg id" $reference | sed -e "s/<[^>]*>//g" > /tmp/eval/$set.reference

sed -e "s/@@ //g" /data/$output/eval/$name.t | sed -e "s/@@$//g" | sed -e "s/&apos;/'/g" -e 's/&#124;/|/g' -e "s/&amp;/&/g" -e 's/&lt;/>/g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&#91;/[/g' -e 's/&#93;/]/g' | perl -nle 'print ucfirst' > /tmp/eval/$name.clean.t



/opt/mwerSegmenter/segmentBasedOnMWER.sh $source $reference /tmp/eval/$name.clean.t $systemName $tl /tmp/eval/$name.sgm normalize 1
/opt/mwerSegmenter/segmentBasedOnMWER.sh $source $reference /tmp/eval/$name.clean.t $systemName $tl /tmp/eval/$name.no-case.sgm normalize 0
sed -e "/<[^>]*>/d" /tmp/eval/$name.sgm > /tmp/eval/$name.hyp
sed -e "/<[^>]*>/d" /tmp/eval/$name.no-case.sgm > /tmp/eval/$name.no-case.hyp
sed -e "s/^\s*$/_EMPTY_/g" /tmp/eval/$name.hyp > /tmp/eval/$name.no-empty.hyp
cat /tmp/eval/$name.hyp | sed -e "s/&/&amp;/g" | perl /opt/SLT.KIT/scripts/evaluate/wrap-xml.perl $tl /data/orig/eval/$set/IWSLT.$set/IWSLT.TED.$set.$sl-$tl.$sl.xml $systemName > /tmp/eval/$name.xml
cat /tmp/eval/$name.no-case.hyp | sed -e "s/&/&amp;/g" | perl /opt/SLT.KIT/scripts/evaluate/wrap-xml.perl $tl /data/orig/eval/$set/IWSLT.$set/IWSLT.TED.$set.$sl-$tl.$sl.xml $systemName > /tmp/eval/$name.no-case.xml


/opt/mosesdecoder/scripts/generic/mteval-v14.pl -c -s $source -r $reference -t /tmp/eval/$name.xml > /results/$systemName/$name/BLEU.case-sensitive
/opt/mosesdecoder/scripts/generic/mteval-v14.pl  -s $source -r $reference -t /tmp/eval/$name.no-case.xml > /results/$systemName/$name/BLEU.case-insensitive

java -Dfile.encoding=UTF8 -jar /opt/tercom-0.7.25/tercom.7.25.jar -N -s -r $reference -h /tmp/eval/$name.xml > /results/$systemName/$name/TER.case-sensitive
java -Dfile.encoding=UTF8 -jar /opt/tercom-0.7.25/tercom.7.25.jar -N -r $reference -h /tmp/eval/$name.no-case.xml > /results/$systemName/$name/TER.case-insensitive

/opt/beer_2.0/beer -s /tmp/eval/$name.hyp -r /tmp/eval/$set.reference > /results/$systemName/$name/BEER.case-sensitive
/opt/CharacTER/CharacTER.py -r /tmp/eval/$set.reference -o /tmp/eval/$name.no-empty.hyp > /results/$systemName/$name/CharacTER.case-sensitive


BLEU=`grep BLEU /results/$systemName/$name/BLEU.case-sensitive | head -n 1 | awk '{print $8*100}'`
ciBLEU=`grep BLEU /results/$systemName/$name/BLEU.case-insensitive | head -n 1 | awk '{print $8*100}'`
TER=`grep TER /results/$systemName/$name/TER.case-sensitive | awk '{printf("%.2f\n",$3*100)}'`
ciTER=`grep TER /results/$systemName/$name/TER.case-insensitive | awk '{printf("%.2f\n",$3*100)}'`
beer=`awk '{printf("%.2f\n",$3*100)}' /results/$systemName/$name/BEER.case-sensitive`
character=`awk '{printf("%.2f\n",$1*100)}' /results/$systemName/$name/CharacTER.case-sensitive`

echo "Results for $systemName" > /results/$systemName/$name/Summary.md
echo "=======================" >> /results/$systemName/$name/Summary.md
echo "| SET | BLEU | TER | BEER | CharacTER | BLEU(ci) | TER(ci) |" >> /results/$systemName/$name/Summary.md
echo "| --- | ---- | --- | ---- | --------- | -------- | ------- |" >> /results/$systemName/$name/Summary.md
echo "| $name | $BLEU | $TER | $beer | $character | $ciBLEU | $ciTER |" >> /results/$systemName/$name/Summary.md
