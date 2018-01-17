#!/bin/bash

set=$1
input=$2
name=$3
translator=$4

echo "SET:"$set
echo "INPUT:"$input
echo "NAME:"$name
echo "T:"$translator

mkdir -p /tmp/$name
mkdir -p /data/${name}/eval/

cd /data/$input/eval/$set/IWSLT.$set/
echo -n "" > /tmp/$name/$set.np
i=0
while read -r line
do
    sed -e "s/([0-9]*)//g" $line | sed -e '/\$(.*)/d' | awk '{if($1 != "#") {printf("%s ",$5)}}END{print ""}' | sed -e 's/\,//g' | sed -e 's/\.//g' | sed -e 's/?//g' | sed -e 's/\!//g' | sed -e 's/\"//g' | sed -e 's/^\s*//g' | sed -e 's/\s\s*/ /g' | perl -nle 'print lc' >> /tmp/$name/$set.$i.np
    /opt/SLT.KIT/scripts/monoTranslationData/ConCat10.pl /tmp/$name/$set.$i.np 10 > /tmp/$name/$set.$i.np.concat
    cat /tmp/$name/$set.$i.np.concat | /opt/subword-nmt/apply_bpe.py -c /model/${name}/codec --vocabulary /model/${name}/voc --vocabulary-threshold 50 > /data/${name}/eval/$set.$i.s
    /opt/SLT.KIT/scripts/openNMT-py/Translate.sh $set.$i $name $translator 
    ((i++))
done < /data/$input/eval/$set/IWSLT.$set/CTM_LIST


