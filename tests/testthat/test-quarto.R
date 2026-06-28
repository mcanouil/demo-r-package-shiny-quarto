test_that("the Quarto extension is bundled in the package", {
  ext <- system.file("_extensions", "acme", "_extension.yml", package = "acme.toolkit")
  expect_true(file.exists(ext))
  content <- readLines(ext)
  # The dir name "acme" + format "html" yields the `acme-html` format name.
  expect_true(any(grepl("^\\s*html:", content)))
  expect_true(any(grepl("title: Acme", content)))
})

test_that(".stamp_extension_source records the installing package", {
  dir <- withr::local_tempdir()
  yml <- file.path(dir, "_extension.yml")
  writeLines(c("title: Acme", "version: 0.1.0"), yml)

  acme.toolkit:::.stamp_extension_source(dir, "acme.toolkit@9.9.9")

  out <- readLines(yml)
  expect_true(any(out == "source: acme.toolkit@9.9.9"))
  expect_true(any(out == "source-type: package"))
  # The extension's own version is preserved.
  expect_true(any(grepl("version: 0.1.0", out)))
})
