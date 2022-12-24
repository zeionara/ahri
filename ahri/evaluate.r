#!/usr/bin/env Rscript

library(dplyr)

library(tidytext)
library(optparse)
library(tidyverse)
# library(stopwords)
library(SnowballC)
library(caTools)

# library(e1071)

library(caret)
library(doParallel)
library(MLmetrics)

cl <- makePSOCKcluster(8)
registerDoParallel(cl)

options <- list(
    make_option(
        c("-i", "--input"), type = "character", default = "assets/data/comments.csv"
    ),
    make_option(
        c("-v", "--vectors"), type = "character", default = "assets/data/pmi-word-vectors.csv"
    ),
    # make_option(
    #     c("-o", "--output"), type = "character", default = "assets/data/pmi-word-vectors.csv"
    # ),
    # make_option(
    #     c("-s", "--embedding_size"), type = "integer", default = 10L
    # ),
    # make_option(
    #     c("-e", "--n_epochs"), type = "integer", default = 1000L
    # ),
    # make_option(
    #     c("-w", "--window_size"), type = "integer", default = 4L
    # ),
    make_option(
        c("-f", "--min_token_frequency"), type = "integer", default = 50L
    )
    # make_option(
    #     c("-v", "--verbose"), action = "store_true"
    # )
) %>% (\(option_list) OptionParser(option_list = option_list)) %>% parse_args

comments <- read.csv(file = options$input)
vectors <- read.csv(file = options$vectors)

stopwords <- get_stopwords() %>%
    rename(token = word)

tidy_comments <- comments %>%
    select(Comment, Sentiment) %>%
    rename(sentiment = Sentiment) %>%
    mutate(comment = row_number()) %>%  # Column 'comment' contains comment id
    unnest_tokens(token, Comment) %>%
    anti_join(stopwords, by = "token") %>%
    filter(!str_detect(token, "[0-9]+|\\s+")) %>%  # Drop all numeric tokens
    filter(nchar(token) > 0) %>%  # Drop all numeric tokens
    mutate(stem = wordStem(token)) %>%
    filter(str_detect(stem, ".+")) %>%  # Drop empty tokens
    select(-token) %>%
    add_count(stem) %>%
    filter(n >= options$min_token_frequency) %>%
    select(-n)

comment_vectors <- tidy_comments %>%
    merge(vectors %>% rename(stem = token), by = "stem", all.x = TRUE) %>%
    group_by(comment, sentiment) %>%
    summarise(across(starts_with("X"), mean), .groups = "drop")

set.seed(17)

split <- sample.split(comment_vectors$sentiment, SplitRatio = 0.75)

train_subset <- subset(comment_vectors, split == TRUE)
test_subset <- subset(comment_vectors, split == FALSE)

# print(nrow(tidy_comments))
# print(comment_vectors)
print(train_subset)
print(test_subset)

# classifier <- svm(  # https://www.rdocumentation.org/packages/e1071/versions/1.7-12/topics/svm
#     formula = sentiment ~ . - comment,
#     data = train_subset,
#     type = "C-classification",
#     kernel = "linear"
# )

# train_control <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
# classifier <- train(sentiment ~ . - comment, data = head(train_subset, 1000), method = "svmLinear", trControl = train_control, preProcess = c("center", "scale"), verbose = TRUE)

train_subset$sentiment <- as.factor(train_subset$sentiment)
levels(train_subset$sentiment) <- c("negative", "neutral", "positive")
train_control <- trainControl(method = "repeatedcv", number = 10, repeats = 3, classProbs = TRUE, summaryFunction = multiClassSummary, verboseIter = TRUE)
metric <- "logLoss"
formula <- paste("sentiment ~", paste(colnames(train_subset)[3:ncol(train_subset)], collapse = " + "))
# print(formula)
classifier <- train(as.formula(formula), data = head(train_subset, 5000), method = "mlp", trControl = train_control, preProcess = c("center", "scale"), verbose = TRUE, metric = metric,
    tuneGrid = data.frame(size = c(1, 5, 7, 9)))

print(classifier)

# y_pred <- predict(classifier, newdata = (test_subset[, 3:ncol(test_subset)] %>% as.matrix))
# test_data_as_matrix <- test_subset[, 3:ncol(test_subset)] %>% as.matrix
# print(test_data_as_matrix)
# y_pred <- predict(classifier, newdata = test_data_as_matrix)
y_pred <- predict(classifier, newdata = test_subset)

# print(y_pred)

ConfusionMatrix(y_pred = y_pred, test_subset$sentiment)

# print(nchar(comment_vectors[1, "stem"]))

# head(tidy_comments)
