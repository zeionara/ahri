library(optparse)

library(tidyverse)
library(tidytext)

source("processing.r")

stopwords <- get_stopwords() %>% rename(token = word)

options <- list(
    make_option(
        c("-m", "--model"), type = "character", default = "assets/models/weights.rds"
    ),
    make_option(
        c("-v", "--vectors"), type = "character", default = "assets/data/pmi-word-vectors.csv"
    ),
    make_option(
        c("-f", "--min_token_frequency"), type = "integer", default = 1L
    )
) %>% (\(option_list) OptionParser(option_list = option_list)) %>% parse_args

classifier <- readRDS(paste("..", options$model, sep = "/"))
stopwords <- get_stopwords() %>% rename(token = word)
vectors <- read.csv(file = paste("..", options$vectors, sep = "/")) %>% rename(stem = token)

#' @post /predict
function(req) {
    body <- jsonlite::fromJSON(req$postBody)

    comments <- body$comments

    # print(comments)
    # print(stopwords)

    df <- data.frame(Comment = comments, Sentiment = NA) %>% preprocess(stopwords, options$min_token_frequency) %>% vectorize(vectors)

    y_pred <- predict(classifier, newdata = df)

    return(data.frame(predictions = y_pred))
}

