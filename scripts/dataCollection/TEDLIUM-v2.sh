#!/bin/bash

mkdir -p /data/orig/
if [ ! -f /data/orig/TEDLIUM_release2/README ]; then
  echo Carry out these steps manually:
  echo - download TEDLIUM from http://www-lium.univ-lemans.fr/en/content/ted-lium-corpus
  echo - extract to /data/orig/TEDLIUM_release2
  echo then re-run this script
  exit
fi

# need absolute paths here:
tedliumdir=/data/orig/TEDLIUM_release2
datadir=/data/tedlium2-xnmt
mkdir -p $datadir

##### convert to .wav #######

for spl in dev test train
do
  for f in `ls $tedliumdir/$spl/sph/*.sph`
  do
    mkdir -p $datadir/wav/$spl
    filename=$(basename "$f" .sph) 
    sox -t sph -b 16 -e signed -r 16000 -c 1 $f $datadir/wav/$spl/$filename.wav
  done
done

#### prepare database and transcripts #####
mkdir $datadir/db/
mkdir $datadir/transcript/

python extract_db.py "$tedliumdir" "$datadir"
cat $datadir/transcript/dev.char | sed "s/ //g" | sed "s/__/ /g" > $datadir/transcript/dev.words
cat $datadir/transcript/test.char | sed "s/ //g" | sed "s/__/ /g" > $datadir/transcript/test.words
cat $datadir/transcript/train.char | sed "s/ //g" | sed "s/__/ /g" > $datadir/transcript/train.words


