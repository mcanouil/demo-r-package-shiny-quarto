test_that("Dataset stores data and stamps a creation time", {
  d <- new_test_dataset()
  expect_s7_class(d, Dataset)
  expect_true(is.data.frame(d@data))
  expect_identical(d@name, "fixture")
  expect_s3_class(d@created, "POSIXct")
})

test_that("Dataset validator rejects non-data.frame data", {
  expect_error(Dataset(data = 1:10), "@data must be a data.frame")
})

test_that("AnalysisResult validator enforces the method vocabulary", {
  expect_error(
    AnalysisResult(summary = data.frame(), method = "bogus"),
    "@method must be one of"
  )
})

test_that("Project validator enforces element types", {
  expect_error(Project(data = 1L), "@data must be a Dataset")
  expect_error(
    Project(results = list("not a result")),
    "must be an AnalysisResult"
  )
})

test_that("Project aggregates a Dataset and results", {
  p <- Project(data = new_test_dataset(), name = "p")
  expect_s7_class(p, Project)
  expect_length(p@results, 0L)
  expect_s3_class(p@modified, "POSIXct")
})
