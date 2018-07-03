#!/bin/bash

if (( $# != 3 )); then
  echo "Not enough parameters: $0 testset hypothesis result_dir"
  exit
fi

testset=$1
hypothesis=$2
result_dir=$3

mkdir -p /tmp

# hacky way of scoring, just write the whole text in a line and give it the same utt-id
grep "<seg id" /data/orig/eval/${testset}/*/*${testset}.en-de.en.xml | sed -e "s/<[^>]*>//g" -e "s/[\.?,:\!]//g" -e 's/"//g' -e "s/-//g" | tr '\n' ' ' | awk '{print $0 "(uttID-"NR")"}' > /tmp/${testset}.ref.trn
cat ${hypothesis} | tr '\n' ' ' | awk '{print $0 "(uttID-"NR")"}' > /tmp/${testset}.hyp.trn
/opt/sctk-2.4.10/bin/sclite -r /tmp/${testset}.ref.trn trn -h /tmp/${testset}.hyp.trn trn -i rm -o all -O $3

