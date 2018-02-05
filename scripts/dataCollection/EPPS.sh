#!/bin/bash

mkdir -p /tmp/corpus
cd /tmp/corpus

mkdir -p /data/orig/parallel/

if [ $sl == "en" ]; then
    wget http://statmt.org/europarl/v7/$tl-$sl.tgz
    tar -xzvf ${tl}-${sl}.tgz
    cp /tmp/corpus/europarl-v7.$tl-$sl.$sl /data/orig/parallel/EPPS.s
    cp /tmp/corpus/europarl-v7.$tl-$sl.$tl /data/orig/parallel/EPPS.t
else
    wget http://statmt.org/europarl/v7/$sl-$tl.tgz
    tar -xzvf ${sl}-${tl}.tgz
    cp /tmp/corpus/europarl-v7.$sl-$tl.$sl /data/orig/parallel/EPPS.s
    cp /tmp/corpus/europarl-v7.$sl-$tl.$tl /data/orig/parallel/EPPS.t
fi




rm -r /tmp/corpus/
