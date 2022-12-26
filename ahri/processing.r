library(dplyr)
library(tidytext)
library(SnowballC)
library(tidyverse)

preprocess <- function(comments, stopwords) {
    comments %>%
        select(Comment, Sentiment) %>%
        rename(sentiment = Sentiment) %>%
        mutate(comment = row_number()) %>%  # Column 'comment' contains comment id
        unnest_tokens(token, Comment) %>%
        anti_join(stopwords, by = "token") %>%
        mutate(stem = wordStem(token)) %>%
        filter(!str_detect(stem, "[0-9]+|\\s+")) %>%  # Drop all numeric tokens
        filter(nchar(stem) > 0) %>%  # Drop all numeric tokens
        select(-token) %>%
        add_count(stem) %>%
        filter(n >= options$min_token_frequency) %>%
        select(-n)
}

vectorize <- function(comments, vectors) {
    comments %>%
        merge(vectors, by = "stem", all.x = TRUE) %>%
        group_by(comment, sentiment) %>%
        summarise(across(starts_with("X"), mean), .groups = "drop")
}
