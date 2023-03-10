# ahri

<!--
logo source: https://www.reddit.com/r/leagueoflegends/comments/660rsj/ahri_orb_logo/
!-->

[![evaluate](https://github.com/zeionara/ahri/actions/workflows/evaluate.yml/badge.svg)](https://github.com/zeionara/ahri/actions/workflows/evaluate.yml)

<img src="assets/images/logo.png" width="400px" align="right"/>

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

Also see separate scripts for libraries which need to be installed, but additional libraries must be present to be able to run the provided scripts:

```r
install.packages("furrr")
install.packages('kernlab')
install.packages('kknn')  # raises exception on ubuntu, but necessary to apply kknn classifier
install.packages('MLmetrics')
```

# Usage

Currently there are multiple steps of the data processing pipeline:

1. Split source corpus

```sh
./ahri/split.r
```

2. Generate word vectors

```sh
./ahri/embed.r -n 8
```

3. Run model training
```sh
./ahri/train.r
```

4. Deploy model (coming soon)
```sh
./ahri/deploy.r
```
