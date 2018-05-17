# SLT.KIT

This repository contains a Spoken Language Translation System. It can be used to translate the output of an Automatic Speech Recognition (ASR) system. The system contains an monolingual translation system that adds punctuation marks to the output of the ASR system. Furthermore, it recases the output. Then the output is translated by an machine translation system system. The system can be used to train such systems as well as pre-trained systems are available. The systems can be trained and used by installing the docker container.

The system uses the following software:
* [OpenNMT-py](https://github.com/OpenNMT/OpenNMT-py)
* [Moses](http://www.statmt.org/moses/)
* [XNMT](https://github.com/neulab/xnmt)
* [Subword NMT](https://github.com/rsennrich/subword-nmt)
* [Translation error rate](http://www.cs.umd.edu/%7Esnover/tercom/)
* [BEER](https://github.com/stanojevic/beer)
* [CharacTER](https://github.com/rwth-i6/CharacTER)
* [mwerSegmenter](https://www-i6.informatik.rwth-aachen.de/web/Software/mwerSegmenter.tar.gz)
* [NLTK](http://www.nltk.org/)
* [LIUM Speaker Diarization](http://lium3.univ-lemans.fr/diarization/doku.php)
* [CTC.ISL](https://github.com/markus-m-u-e-l-l-e-r/CTC.ISL)


Requirements:
* [Docker](https://www.docker.com/)

## Installation ##

```bash
	git clone https://github.com/jniehues-kit/SLT.KIT.git
	cd SLT.KIT
	docker build --build-arg CUDA=$CUDAVERSION -t slt.kit -f Dockerfile.ST-Baseline .
	with CUDAVERSION = 8.0 or 9.0 or 9.1
```

## Run ##


* Starting the docker container (e.g. source language English (en) and target language German (de))


```bash
	docker run -ti --rm --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=$gpuid slt.kit
	export sl=en
	export tl=de
```

* Within a docker container

  1 Training a model or download pre-trained model
    * Training a model

```bash
	/opt/SLT.KIT/systems/${model}/Train.sh
```

    * Download a pre-trained model


```bash
	/opt/SLT.KIT/systems/${model}/Download.sh
```



  2 Translate test set

```bash
	/opt/SLT.KIT/systems/${model}/Translate.sh $testset
```




where $model can be:
* smallTED

and $testset can be:
* English to {German | French}
** dev2010
** tst2010
** tst2013 (only German)
** tst2014
** tst2015
* German to English
** dev2012
** tst2013
** tst2014


## Models ##


### small TED ###

SLT model trained only on the [TED corpus] (https://wit3.fbk.eu/)

Performance:

#### English to German ####
| SET | BLEU | TER | BEER | CharacTER | BLEU(ci) | TER(ci) |
| --- | ---- | --- | ---- | --------- | -------- | ------- |
| dev2010 | 14.46 | 70.98 | 46.61 | 83.77 | 15.42 | 69.00 |
| dev2010 (manual Transcript) | 23.45 | 56.74 | 54.44 | 56.77 | 25.03 | 55.17 |
| tst2010 | 10.41 | 76.53 | 36.15 | 318.59 | 11.04 | 74.96 |
| tst2010 (manual Transcript) | 24.81 | 55.66 | 53.34 | 55.85 | 26.41 | 54.04 |
| tst2013 | 13.91 | 71.71 | 44.54 | 80.07 | 14.81 | 69.60 |
| tst2013 (manual Transcript) | 26.05 | 54.27 | 54.34 | 54.22 | 27.49 | 52.98 |
| tst2014 | 13.24 | 72.34 | 43.78 | 83.44 | 14.03 | 70.57 |
| tst2014 (manual Transcript) | 22.31 | 58.36 | 51.85 | 57.66 | 23.18 | 57.44 |
| tst2015 | 13.03 | 83.20 | 43.66 | 74.03 | 13.75 | 81.30 |
| tst2015 (manual Transcript) | 25.07 | 57.76 | 53.10 | 54.77 | 26.06 | 56.81 |


#### English to French ####

| SET | BLEU | TER | BEER | CharacTER | BLEU(ci) | TER(ci) |
| --- | ---- | --- | ---- | --------- | -------- | ------- |
| dev2010 | 13.6 | 78.37 | 45.80 | 74.62 | 14.37 | 76.65 |
| dev2010 (manual Transcript) | 22.85 | 64.49 | 53.09 | 56.77 | 24.04 | 63.22 |
| tst2014 | 16.99 | 69.48 | 47.42 | 77.37 | 17.88 | 67.77 |
| tst2014 (manual Transcript) | 28.64 | 54.90 | 56.15 | 52.08 | 29.36 | 54.16 |
| tst2015 | 17.17 | 71.06 | 47.30 | 70.50 | 18.15 | 69.18 |
| tst2015 (manual Transcript) | 28.46 | 56.21 | 56.21 | 50.68 | 29.26 | 55.28 |


#### German to English ####

| SET | BLEU | TER | BEER | CharacTER | BLEU(ci) | TER(ci) |
| --- | ---- | --- | ---- | --------- | -------- | ------- |
| dev2012 | 10.66 | 79.40 | 42.97 | 82.97 | 11.49 | 77.57 |
| dev2012 (manual Transcript) | 19.58 | 66.13 | 52.20 | 66.61 | 20.12 | 65.28 |
| tst2013 | 10.76 | 76.36 | 40.52 | 138.57 | 11.53 | 74.67 |
| tst2013 (manual Transcript) | 22.68 | 59.64 | 56.15 | 57.47 | 23.45 | 58.63 |
| tst2014 | 10.05 | 79.03 | 41.04 | 93.92 | 10.69 | 77.46 |
| tst2014 (manual Transcript) | 17.86 | 65.73 | 51.52 | 64.09 | 18.3 | 64.99 |
