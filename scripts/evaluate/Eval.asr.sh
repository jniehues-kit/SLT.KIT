#!/bin/bash

if (( $# != 3 )); then
  echo "Not enough parameters: $0 testset hypothesis result_dir"
  exit
fi

testset=$1
hypothesis=$2
result_dir=$3

if [ -z "$BASEDIR" ]; then
    BASEDIR=/
fi

if [ -z "$SCTKDIR" ]; then
    SCTKDIR=/opt/sctk-2.4.10/
fi

mkdir -p $BASEDIR/tmp

# hacky way of scoring, just write the whole text in a line and give it the same utt-id
grep "<seg id" $BASEDIR/data/orig/eval/${testset}/*/*${testset}.en-de.en.xml | sed -e "s/<[^>]*>//g" -e "s/[\.?,:\!]//g" -e 's/"//g' -e "s/-//g" | tr '\n' ' ' | awk '{print $0 "(uttID-"NR")"}' > $BASEDIR/tmp/${testset}.ref.trn
cat ${hypothesis} | tr '\n' ' ' | awk '{print $0 "(uttID-"NR")"}' > $BASEDIR/tmp/${testset}.hyp.trn
$SCTKDIR/bin/sclite -r $BASEDIR/tmp/${testset}.ref.trn trn -h $BASEDIR/tmp/${testset}.hyp.trn trn -i rm -o sum rsum sgml lur dtl pra prf -O $3

