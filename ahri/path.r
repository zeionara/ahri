library(dplyr)
library(stringr)

insert_suffix <- function(path, suffix) {
    splitted_path <- str_split(path, "\\.")[[1]]

    splitted_path[1:length(splitted_path) - 1] %>%
        c(suffix, splitted_path[-1]) %>%
        paste0(collapse = ".")
}
