library(dplyr)
library(furrr)

slide_windows <- function(data, window_size) {
    skipgrams <- slider::slide(
        data,
        ~.x,
        .after = window_size - 1,
        .step = 1,
        .complete = TRUE
    )

    safe_mutate = safely(mutate)

    out <- map2(
        skipgrams,
        1:length(skipgrams),
        ~ safe_mutate(.x, window = .y)
    )

    out %>%
        transpose() %>%
        pluck("result") %>%
        compact() %>%
        bind_rows()
}
