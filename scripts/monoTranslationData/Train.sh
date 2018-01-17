#!/bin/bash


input=$1
name=$2

mkdir -p /data/${name}
mkdir -p /model/${name}

for set in train valid
do
    
mkdir -p /data/${name}/${set}
for sub in pc randCut np
do
    
mkdir -p /tmp/${name}/${sub}/${set}
done
done


for set in train valid
do
    
for f in /data/${input}/${set}/*\.s
do
    #remove BPE and xml escape
    # remove double punctuation
    cat $f | sed -e "s/@@ //g" | sed -e "s/&apos;/'/g" -e 's/&#124;/|/g' -e "s/&amp;/&/g" -e 's/&lt;/>/g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&#91;/[/g' -e 's/&#93;/]/g' | sed -e 's/\.\.\././g' | sed -e 's/ \.\s*/. /g' | sed -e 's/ \.\s*/ /g' | sed -e 's/ \,\s*\,/ , /g' | sed -e 's/ \,\s*/, /g' | sed -e 's/ ! ! / ! /g' | sed -e 's/ ! ! / ! /g' | sed -e 's/ ! ! / ! /g' | sed -e 's/\s*!\s*/! /g' | sed -e 's/\s*?/?/g' | sed -e 's/\"\s*\"/""/g' | sed -e 's/ "/"/g' > /tmp/${name}/pc/${set}/${f##*/}
    #randomly split data
    perl /opt/SLT.KIT/scripts/monoTranslationData/RandCat_long.pl /tmp/${name}/pc/${set}/${f##*/} | sed -e 's/\s*"/"/g' > /tmp/${name}/randCut/${set}/${f##*/}
    #genereate Target Labels
    filename=${f##*/}
    perl /opt/SLT.KIT/scripts/monoTranslationData/generateUL.pl /tmp/${name}/randCut/${set}/${f##*/} > /data/${name}/${set}/${filename%.*}.t
    #remove punctuation and lowercase
    cat /tmp/${name}/randCut/${set}/${f##*/} |  perl -nle 'print lc' | sed -e 's/\,//g' | sed -e 's/\.//g' | sed -e 's/?//g' | sed -e 's/\!//g' | sed -e 's/\"//g' | sed -e 's/^\s*//g' | sed -e 's/\s\s*/ /g' > /tmp/${name}/np/${set}/${f##*/}
done
done

echo -n "" > /tmp/${name}/corpus

set=train

for f in /data/${input}/${set}/*\.s
do
    cat /tmp/${name}/np/${set}/${f##*/} | perl -nle 'print lc' >> /tmp/${name}/corpus
    
done



#train BPE

/opt/subword-nmt/learn_bpe.py -s 40000 -o /model/${name}/codec < /tmp/${name}/corpus
/opt/subword-nmt/apply_bpe.py -c /model/${name}/codec  < /tmp/${name}/corpus | /opt/subword-nmt/get_vocab.py > /model/${name}/voc

#apply BPE
for set in valid train
do
    
for f in /data/${input}/${set}/*\.s
do

    cat /tmp/${name}/np/${set}/${f##*/} | /opt/subword-nmt/apply_bpe.py -c /model/${name}/codec --vocabulary /model/${name}/voc --vocabulary-threshold 50 > /data/${name}/${set}/${f##*/}

done

done

rm -r /tmp/${name}/
