# File Structure #

## Systems ##

To build, download and use the different [systems](Systems.md) you can find the scripts in /opt/SLT.KIT/systems/${system}.
In general this directory contains three different scripts

  1 Training a model

```bash
    /opt/SLT.KIT/systems/${model}/Train.sh
```

  2 Download a pre-trained model


```bash
    /opt/SLT.KIT/systems/${model}/Download.sh
```



  2 Translate test set

```bash
    /opt/SLT.KIT/systems/${model}/Test.sh $testset
```


## Data ##

All data is stored in the /data directory

* /data/${component}/: Training data after processing of the individual components
* /data/${component}/eval/: Test data after processing of the individual comopents


## Model ##

The different models trained by the individual components are stored in /model/${component}

## Results ##

The results of each system will be reported in /results/${system}
