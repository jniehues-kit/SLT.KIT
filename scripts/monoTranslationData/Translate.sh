#!/bin/bash

set=$1
input=$2
name=$3
translator=$4

model=model.pt
if [ $# -ne 4 ]; then
    model=$5
fi


echo "SET:"$set
echo "INPUT:"$input
echo "NAME:"$name
echo "T:"$translator

mkdir -p /tmp/$name
mkdir -p /data/${name}/eval/

cd /data/$input/eval/$set/IWSLT.$set/
i=0
echo -n "" > /data/${name}/eval/$set.s
while read -r line
do
    #clean ctm; sort by time; extract words; remove puncutation; lower-case
    sed -e "s/([0-9]*)//g" $line | sed -e '/\$(.*)/d' | sort -g -k 3,3 | awk '{if($1 != "#") {printf("%s ",$5)}}END{print ""}' | sed -e 's/\,//g' | sed -e 's/\.//g' | sed -e 's/?//g' | sed -e 's/\!//g' | sed -e 's/\"//g' | sed -e 's/^\s*//g' | sed -e 's/\s\s*/ /g' | perl -nle 'print lc' > /tmp/$name/$set.$i.np
    /opt/SLT.KIT/scripts/monoTranslationData/ConCat10.pl /tmp/$name/$set.$i.np 10 > /tmp/$name/$set.$i.np.concat
    cat /tmp/$name/$set.$i.np.concat | /opt/subword-nmt/apply_bpe.py -c /model/${name}/codec --vocabulary /model/${name}/voc --vocabulary-threshold 50 > /data/${name}/eval/$set.$i.s
    /opt/SLT.KIT/scripts/openNMT-py/Translate.sh $set.$i $name $translator $model
    python /opt/SLT.KIT/scripts/monoTranslationData/AddPunctuation.py /tmp/$name/$set.$i.np.concat /data/$translator/eval/$set.$i.t 10 >> /data/${name}/eval/$set.s
    ((i++))
done < /data/$input/eval/$set/IWSLT.$set/CTM_LIST

rm -r /tmp/$name


