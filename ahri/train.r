#!/usr/bin/env Rscript

library(dplyr)

# library(tidytext)
library(optparse)
# library(tidyverse)
# library(stopwords)
library(SnowballC)
library(caTools)

# library(e1071)

library(caret)
library(doParallel)
library(MLmetrics)

source("ahri/processing.r")
source("ahri/path.r")

options <- list(
    make_option(
        c("-t", "--train"), type = "character", default = "assets/data/comments.train.csv"
    ),
    make_option(
        c("-e", "--valid"), type = "character", default = "assets/data/comments.valid.csv"
    ),
    make_option(
        c("-v", "--vectors"), type = "character", default = "assets/data/pmi-word-vectors.csv"
    ),
    make_option(
        c("-m", "--method"), type = "character", default = "svmLinear"
    ),
    make_option(
        c("-o", "--output"), type = "character", default = "assets/models/weights.rds"
    ),
    make_option(
        c("-f", "--min_token_frequency"), type = "integer", default = 50L
    ),
    make_option(
        c("--seed"), type = "integer", default = 17L
    ),
    make_option(
        c("-n", "--n_workers"), type = "integer", default = 1L
    )
) %>% (\(option_list) OptionParser(option_list = option_list)) %>% parse_args

makePSOCKcluster(options$n_workers) %>%
    registerDoParallel

stopwords <- get_stopwords() %>% rename(token = word)
vectors <- read.csv(file = options$vectors) %>% rename(stem = token)

train_subset <- read.csv(file = options$train) %>% preprocess(stopwords, options$min_token_frequency) %>% vectorize(vectors) %>% na.omit
train_subset$sentiment <- as.factor(train_subset$sentiment)
levels(train_subset$sentiment) <- c("negative", "neutral", "positive")

# test_subset <- read.csv(file = options$valid) %>% preprocess(stopwords) %>% vectorize(vectors) %>% na.omit

set.seed(options$seed)

# classifier <- train(sentiment ~ . - comment, data = head(train_subset, 1000), method = options$method, trControl = train_control, preProcess = c("center", "scale"), verbose = TRUE)

train_control <- trainControl(method = "repeatedcv", number = 10, repeats = 3, classProbs = TRUE, summaryFunction = multiClassSummary, verboseIter = TRUE)
classifier <- paste("sentiment ~", paste(colnames(train_subset)[3:ncol(train_subset)], collapse = " + ")) %>%
    as.formula %>%
    train(data = head(train_subset, 5000), method = options$method, trControl = train_control, preProcess = c("center", "scale"), verbose = TRUE, metric = "logLoss")

options$output %>%
    dirname %>%
    dir.create(recursive = TRUE)

classifier %>%
    saveRDS(insert_suffix(options$output, options$method))

# y_pred <- predict(classifier, newdata = test_subset)

# ConfusionMatrix(y_pred = y_pred, test_subset$sentiment)
