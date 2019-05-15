#!/bin/bash

if [ -z "$BASEDIR" ]; then
    BASEDIR=/
fi

mkdir -p $BASEDIR/tmp/corpus
cd $BASEDIR/tmp/corpus
wget https://wit3.fbk.eu/archive/2017-01-trnted//texts/${sl}/${tl}/${sl}-${tl}.tgz
tar -xzvf ${sl}-${tl}.tgz

mkdir -p $BASEDIR/data/orig/parallel/

#KEEP only lines, where there is no xml in source or target
paste ${sl}-${tl}/train.tags.${sl}-${tl}.${sl} ${sl}-${tl}/train.tags.${sl}-${tl}.${tl} | awk '{if($1 ~ /^</ && $NF ~ />\s*$/) {print "REMOVE"}else{print "KEEP";}}' > ${sl}-${tl}/train.tags.lines
paste ${sl}-${tl}/train.tags.lines ${sl}-${tl}/train.tags.${sl}-${tl}.${sl} | awk '{if($1 == "KEEP"){$1="";print $0}}' | sed -e "s/^\s*//g"  > $BASEDIR/data/orig/parallel/TED.s
paste ${sl}-${tl}/train.tags.lines ${sl}-${tl}/train.tags.${sl}-${tl}.${tl} | awk '{if($1 == "KEEP"){$1="";print $0}}' | sed -e "s/^\s*//g"  > $BASEDIR/data/orig/parallel/TED.t

mkdir -p $BASEDIR/data/orig/valid/


 
grep "<seg" ${sl}-${tl}/IWSLT17.TED.tst2014.${sl}-${tl}.${sl}.xml | sed -e "s/<[^>]*>//g" | sed -e "s/^\s*//g" > $BASEDIR/data/orig/valid/TED.tst2014.s
grep "<seg" ${sl}-${tl}/IWSLT17.TED.tst2014.${sl}-${tl}.${tl}.xml | sed -e "s/<[^>]*>//g" | sed -e "s/^\s*//g" > $BASEDIR/data/orig/valid/TED.tst2014.t


cd $BASEDIR
rm -r $BASEDIR/tmp/corpus/
