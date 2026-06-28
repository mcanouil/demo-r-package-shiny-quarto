# Small fixture generators shared across tests. Keep these tiny: tests should
# run on minimal synthetic data, not large bundled files.

new_test_data <- function(n = 6L) {
  data.frame(
    group = rep(c("a", "b"), length.out = n),
    x = seq_len(n) + 0.5,
    y = rev(seq_len(n)) * 1.5,
    stringsAsFactors = FALSE
  )
}

new_test_dataset <- function(n = 6L, name = "fixture") {
  Dataset(data = new_test_data(n), name = name)
}
