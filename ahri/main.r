#!/usr/bin/env Rscript

# library(tokenizers)
library(dplyr)
library(tidytext)
library(stopwords)
library(SnowballC)
library(tidyverse)
library(widyr)
library(slider)
library(furrr)

library(optparse)
# library(quanteda)

source("ahri/skipgram.r")


options <- list(
    make_option(
        c("-i", "--input"), type = "character", default = "assets/data/comments.csv"
    ),
    make_option(
        c("-o", "--output"), type = "character", default = "assets/data/pmi-word-vectors.csv"
    ),
    make_option(
        c("-s", "--embedding_size"), type = "integer", default = 10L
    ),
    make_option(
        c("-e", "--n_epochs"), type = "integer", default = 1000L
    ),
    make_option(
        c("-w", "--window_size"), type = "integer", default = 4L
    ),
    make_option(
        c("-f", "--min_token_frequency"), type = "integer", default = 50L
    ),
    make_option(
        c("-v", "--verbose"), action = "store_true"
    )
) %>% (\(option_list) OptionParser(option_list = option_list)) %>% parse_args

# opt_parser = OptionParser(option_list = option_list)
# opt = parse_args(
# print(options$embedding_size)

comments <- read.csv(file = options$input)

# Prepare reference labels for each comment

# labels <- comments %>%
#     select(Sentiment) %>%
#     rename(sentiment = Sentiment) %>%
#     mutate(comment = row_number())

# Perpare comment embeddings

stopwords <- get_stopwords() %>%
    rename(token = word)

tidy_comments <- comments %>%
    select(Comment) %>%
    mutate(comment = row_number()) %>%  # Column 'comment' contains comment id
    unnest_tokens(token, Comment) %>%
    anti_join(stopwords, by = "token") %>%
    filter(!str_detect(token, "[0-9]+")) %>%  # Drop all numeric tokens
    mutate(stem = wordStem(token)) %>%
    select(-token) %>%
    add_count(stem) %>%
    filter(n >= options$min_token_frequency) %>%
    select(-n) # %>%
    # nrow

nested_comments <- tidy_comments %>%
    nest(stems = c(stem)) # %>%
    # head(100)
    # head(3) %>%
    # print

tidy_pmi <- nested_comments %>%
    mutate(stems = future_map(stems, slide_windows, options$window_size, .progress = options$verbose)) %>%  # install.packages('furrr')
    unnest(stems) %>%
    unite(window, comment, window) %>%
    pairwise_pmi(stem, window)

vectors <- tidy_pmi %>%
    widely_svd(item1, item2, pmi, nv = options$embedding_size, maxit = options$n_epochs) %>%  # install.packages('irlba')
    rename(token = item1) %>%
    spread(dimension, value) %>%
    mutate_at(1:options$embedding_size %>% as.character, ~(scale(.) %>% as.vector)) %>%
    write_csv(options$output)

print(vectors)

# Prepare term-document-matrix

# comments %>%
#     select(Comment) %>%
#     mutate(comment = row_number()) %>%  # Column 'comment' contains comment id
#     unnest_tokens(token, Comment) %>%
#     anti_join(stopwords, by = "token") %>%
#     mutate(stem = wordStem(token)) %>%
#     count(comment, stem) %>%
#     bind_tf_idf(stem, comment, n) %>%
#     cast_dfm(comment, stem, tf_idf) %>%
#     # head(3) %>%
#     print
