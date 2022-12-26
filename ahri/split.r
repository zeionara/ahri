#!/usr/bin/env Rscript

# library(dplyr)
library(optparse)
# library(stringr)

library(caTools)

source("ahri/path.r")

path <- "assets/data/comments.csv"

options <- list(
    make_option(
        c("-i", "--input"), type = "character", default = path
    ),
    make_option(
        c("-o", "--output"), type = "character", default = path
    ),
    make_option(
        c("-t", "--train_fraction"), type = "double", default = 0.8
    ),
    make_option(
        c("-v", "--valid_fraction"), type = "double", default = 0.1
    ),
    make_option(
        c("-s", "--seed"), type = "integer", default = 17L
    )
) %>% (\(option_list) OptionParser(option_list = option_list)) %>% parse_args

if (options$train_fraction + options$valid_fraction > 1) {
    stop("train portion and valid purtion must sum up at most to 1")
}

# splitted_path <- str_split(path, "\\.")[[1]]
#
# splitted_path[1:length(splitted_path) - 1] %>%
#     # paste0(".") %>%
#     c("train", splitted_path[-1]) %>%
#     paste0(collapse = ".") %>%
#     # c(splitted_path[-1]) %>%
#     # paste0(".") %>%
#     print
# print(splitted_path[-1])

# train_path <- insert_suffix(options$output, "train") %>%
#     print

set.seed(options$seed)

data <- read.csv(file = options$input)

options$output %>%
    dirname %>%
    dir.create(recursive = TRUE)

# Make train subset

train_split <- sample.split(data$Sentiment, SplitRatio = options$train_fraction)

subset(data, train_split) %>%
    write.csv(insert_suffix(options$output, "train"))


# Make valid and test subsets

valid_and_test_subset <- subset(data, train_split == FALSE)

valid_fraction <- options$valid_fraction / (1 - options$train_fraction)
valid_split <- sample.split(valid_and_test_subset$Sentiment, SplitRatio = valid_fraction)

subset(valid_and_test_subset, valid_split) %>%
    write.csv(insert_suffix(options$output, "valid"))

subset(valid_and_test_subset, valid_split == FALSE) %>%
    write.csv(insert_suffix(options$output, "test"))

# print(path)

# print(nrow(train_subset))
# print(nrow(test_subset))
# print(nrow(valid_subset))
