# ahri

Exploratory project for applying github actions to implement ml pipelines.

The project uses a [corpus with youtube comments](https://www.kaggle.com/datasets/advaypatil/youtube-statistics) from kaggle.

# Prerequisites

The project requires the following version of R to be installed:

```sh
R version 4.2.2 Patched (2022-11-10 r83330)
```

To install necessary software components locally run the following command in ubuntu:

```sh
sudo apt-get install libblas-dev liblapack-dev gfortran
```

Also see separate scripts for libraries which need to be installed.

# Usage

Currently there are multiple steps of the data processing pipeline:

1. Generate word vectors

```
./ahri/main.r -s 10
```
