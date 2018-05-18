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

cat /data/$input/eval/$set.s | sed -e 's/\,//g' | sed -e 's/\.//g' | sed -e 's/?//g' | sed -e 's/\!//g' | sed -e 's/\"//g' | sed -e 's/^\s*//g' | sed -e 's/\s\s*/ /g' |  perl /opt/mosesdecoder/scripts/tokenizer/tokenizer.perl -l ${sl} | perl -nle 'print lc' > /tmp/$name/$set.$i.np
/opt/SLT.KIT/scripts/monoTranslationData/ConCat10.pl /tmp/$name/$set.$i.np 10 > /tmp/$name/$set.$i.np.concat
cat /tmp/$name/$set.$i.np.concat | /opt/subword-nmt/apply_bpe.py -c /model/${name}/codec --vocabulary /model/${name}/voc --vocabulary-threshold 50 > /data/${name}/eval/input.$input.$set.s
/opt/SLT.KIT/scripts/openNMT-py/Translate.sh input.$input.$set $name $translator $model
python /opt/SLT.KIT/scripts/monoTranslationData/AddPunctuation.py /tmp/$name/$set.$i.np.concat /data/$translator/eval/input.$input.$set.t 10 >> /data/${name}/eval/$input.$set.s
