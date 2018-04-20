#!/bin/bash

/root/anaconda3/bin/python -m xnmt.xnmt_run_experiments --dynet-gpu /opt/SLT.KIT/scripts/xnmt/config.las-pyramidal-preproc.yaml

/root/anaconda3/bin/python -m xnmt.xnmt_run_experiments --dynet-gpu /opt/SLT.KIT/scripts/xnmt/config.las-pyramidal-train.yaml

