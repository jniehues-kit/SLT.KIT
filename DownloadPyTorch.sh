#!/bin/bash

cuda=`echo $1 | sed -e "s/\.//g"`
pip install http://download.pytorch.org/whl/cu${cuda}/torch-0.3.1-cp36-cp36m-linux_x86_64.whl
