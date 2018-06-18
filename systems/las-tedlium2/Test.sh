#!/bin/bash

if (( $# != 1 )); then
  echo "Specify a test set as a parameter to this script (e.g. tst2010)"
  exit
fi

set=$1

export systemName=las-tedlium2

#Download Data - if not there
if [ ! -e /data/orig/eval/$set ]; then
    mkdir -p /data/orig/eval/$set
    cd /data/orig/eval/$set
    wget http://i13pc106.ira.uka.de/~jniehues/IWSLT-SLT/data/eval/en-de/IWSLT-SLT.$set.en-de.tgz
    tar -xzvf IWSLT-SLT.$set.en-de.tgz

fi

cd /opt/SLT.KIT/scripts/xnmt
./make-test-db.sh /data/orig/eval/$set/IWSLT.$set
sed "s|REPLACE_WITH_TEST_DATA_DIR|/data/orig/eval/$set/IWSLT.$set|g" /opt/SLT.KIT/scripts/xnmt/config.las-pyramidal-test.yaml > /data/orig/eval/$set/IWSLT.$set/config.las-pyramidal-test.yaml
/root/anaconda3/bin/python -m xnmt.xnmt_run_experiments --dynet-gpu /data/orig/eval/$set/IWSLT.$set/config.las-pyramidal-test.yaml
mkdir -p /data/las/eval
cat /data/orig/eval/$set/IWSLT.$set/test-db.decoded.txt | sed "s/ //g" | sed "s/__/ /g" > /data/las/eval/$set.s
 



