library(tokenizers)
library(dplyr)

comments <- read.csv(file = "assets/data/comments.csv")

stop_words <- c("the", "on", "that")

# print(c(sentiments[1], c("foo", "bar")))

# tokens <-
#     comments[, "Comment"] %>%
#         head(2) %>%
#         tokenize_words()

# comment <- tokens[[1]]

# comment_without_stop_words <- comment[!sapply(comment, function(x) x %in% stop_words)]

filtered_tokens <- comments[, "Comment"] %>%
    tokenize_words() %>%
    lapply(function(text) text[!sapply(text, function(x) x %in% stop_words)])

sentiments <- comments[, "Sentiment"]

dir.create("assets/ingested", recursive = TRUE)

save(filtered_tokens, file = "assets/ingested/tokens.rda")
save(sentiments, file = "assets/ingested/labels.rda")

print("Data was ingested and saved successfully")

# print(head(filtered_tokens, 3))

# print(comment)
# print(comment_without_stop_words)
