test_that("generate_pipeline writes a valid _targets.R from a list config", {
  skip_if_not_installed("whisker")

  config <- list(
    data = list(file = "demo.csv", name = "demo"),
    analyses = list(
      summary = list(method = "describe"),
      pairs = list(method = "correlate")
    )
  )
  path <- withr::local_tempfile(fileext = ".R")

  generate_pipeline(config, path = path, report = FALSE, overwrite = TRUE, verbose = FALSE)

  expect_true(file.exists(path))
  content <- paste(readLines(path), collapse = "\n")
  expect_match(content, "config-hash:")
  expect_match(content, 'name = "demo"', fixed = TRUE)
  expect_match(content, 'method = "describe"', fixed = TRUE)
  expect_match(content, 'method = "correlate"', fixed = TRUE)

  # The generated file must parse as R (no stray trailing commas).
  expect_silent(parse(text = content))
})

test_that("generate_pipeline reads a YAML config file", {
  skip_if_not_installed("whisker")
  skip_if_not_installed("yaml")

  yml <- withr::local_tempfile(fileext = ".yml")
  writeLines(
    c(
      "data:",
      "  file: demo.csv",
      "  name: fromyaml",
      "analyses:",
      "  s:",
      "    method: describe"
    ),
    yml
  )
  path <- withr::local_tempfile(fileext = ".R")

  generate_pipeline(yml, path = path, report = FALSE, overwrite = TRUE, verbose = FALSE)
  content <- paste(readLines(path), collapse = "\n")
  expect_match(content, "fromyaml", fixed = TRUE)
})

test_that("generate_pipeline rejects a config without data.file", {
  expect_error(
    generate_pipeline(list(analyses = list()), report = FALSE),
    "data.file"
  )
})

test_that("generate_pipeline rejects an invalid analysis method", {
  config <- list(
    data = list(file = "demo.csv"),
    analyses = list(bad = list(method = "nope"))
  )
  expect_error(generate_pipeline(config, report = FALSE), "invalid")
})

test_that("the same config yields a stable hash", {
  skip_if_not_installed("whisker")
  config <- list(data = list(file = "demo.csv", name = "demo"))
  p1 <- withr::local_tempfile(fileext = ".R")
  p2 <- withr::local_tempfile(fileext = ".R")
  generate_pipeline(config, path = p1, report = FALSE, overwrite = TRUE, verbose = FALSE)
  generate_pipeline(config, path = p2, report = FALSE, overwrite = TRUE, verbose = FALSE)
  hash1 <- grep("config-hash:", readLines(p1), value = TRUE)
  hash2 <- grep("config-hash:", readLines(p2), value = TRUE)
  expect_identical(hash1, hash2)
})
