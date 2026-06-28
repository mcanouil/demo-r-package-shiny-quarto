test_that("analyse() describes numeric columns", {
  d <- new_test_dataset()
  res <- analyse(d, method = "describe")
  expect_s7_class(res, AnalysisResult)
  expect_identical(res@method, "describe")
  expect_setequal(res@summary$variable, c("x", "y"))
  expect_true(all(c("mean", "sd", "min", "max") %in% names(res@summary)))
})

test_that("analyse() correlates numeric columns", {
  d <- new_test_dataset()
  res <- analyse(d, method = "correlate")
  expect_identical(res@method, "correlate")
  expect_true("correlation" %in% names(res@summary))
})

test_that("analyse() errors on an unknown method", {
  expect_error(analyse(new_test_dataset(), method = "nope"), "Unknown")
})

test_that("analyse() on a Project appends a result and bumps modified", {
  p <- Project(data = new_test_dataset(), name = "p")
  before <- p@modified
  Sys.sleep(0.01)
  p2 <- analyse(p, method = "describe")
  expect_length(p2@results, 1L)
  expect_true(p2@modified > before)
})

test_that("filter() subsets a Dataset by a predicate", {
  d <- new_test_dataset(n = 6L)
  out <- filter(d, group == "a")
  expect_true(all(out@data$group == "a"))
  expect_lt(nrow(out@data), nrow(d@data))
})

test_that("filter() drops rows whose predicate is NA, like dplyr", {
  d <- Dataset(data = data.frame(x = c(1, NA, 3)), name = "na")
  out <- filter(d, x > 1)
  expect_identical(out@data$x, 3)
})

test_that("filter() on a Project with no data errors clearly", {
  p <- Project(name = "empty")
  expect_error(filter(p, x > 1), "no data to filter")
})

test_that("dplyr::filter() dispatches to the S7 method for a Dataset", {
  skip_if_not_installed("dplyr")
  d <- new_test_dataset()
  out <- dplyr::filter(d, group == "a")
  expect_s7_class(out, Dataset)
  expect_true(all(out@data$group == "a"))
})

test_that("filter() falls back to stats::filter for non-Dataset objects", {
  # The masked verb must keep working for everything that is not an
  # acme.toolkit class. stats::filter is on the default search path, so a
  # numeric vector delegates straight to it.
  expect_identical(
    filter(1:4, rep(1, 1)),
    stats::filter(1:4, rep(1, 1))
  )
})
