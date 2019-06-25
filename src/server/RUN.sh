#!/bin/bash

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib/:/opt/pv-platform-sample-connector//Linux/lib64/:/opt/lib/cnn/build/lib/:/opt/lib/lamtram/build/lib/
export PYTHONPATH=/opt/lib/NMTGMinor/:/opt/lib/OpenNMT-py/:/opt/subword-nmt/:/usr/local/lib/python


echo $THREADS
if [ -z $THREADS ]; then
export MKL_NUM_THREADS=8
export NUMEXPR_NUM_THREADS=8
export OMP_NUM_THREADS=8
else
export MKL_NUM_THREADS=$THREADS
export NUMEXPR_NUM_THREADS=$THREADS
export OMP_NUM_THREADS=$THREADS
fi

echo $MKL_NUM_THREADS

if [ -z $PORT ]; then
    export PORT=60019
fi

if [ ! -d /logs/ ]; then
    mkdir /logs
fi
sed -e "s/#PORT#/$PORT/g" -e "s/#MEDIATOR#/$MEDIATOR/g" -e "s/#NAME#/$HOSTNAME/g" -e "s/#SL#/$sl/g" -e "s/#TL#/$tl/g" /model/Worker.xml > /tmp/Conf.xml
sl=`grep "source" /tmp/Conf.xml | awk '{print $2}' | head -n 1`
tl=`grep "target" /tmp/Conf.xml | awk '{print $2}' | head -n 1`
name=$sl-$tl-$HOSTNAME
echo $name
TranslationServer /tmp/Conf.xml >& /logs/$name

