# Package hooks.

#' @keywords internal
.onLoad <- function(libname, pkgname) {
  # Register the S7 methods defined in this package.
  S7::methods_register()

  # Set package options (only if the user has not already set them).
  op <- options()
  op_acme <- list(acme.toolkit.verbose = TRUE)
  toset <- !(names(op_acme) %in% names(op))
  if (any(toset)) {
    options(op_acme[toset])
  }

  # Register S3 methods for the S7 classes. S7 uses namespaced class names
  # (e.g. "acme.toolkit::Dataset") which S3 dispatch cannot find via the usual
  # `print.Dataset` lookup, so the methods are registered explicitly.
  .s3_register("base::print", "acme.toolkit::Dataset")
  .s3_register("base::print", "acme.toolkit::AnalysisResult")
  .s3_register("base::print", "acme.toolkit::Project")

  # Register the filter method for dplyr so `dplyr::filter()` dispatches to the
  # S7 method when given a Dataset or Project. S7 class names are namespaced, so
  # the methods must be registered under the namespaced names to be found by S3
  # dispatch (the class of an S7 object is c("acme.toolkit::Dataset", ...)).
  if (requireNamespace("dplyr", quietly = TRUE)) {
    registerS3method(
      "filter",
      "acme.toolkit::Dataset",
      function(.data, ...) filter(.data, ...),
      envir = asNamespace("dplyr")
    )
    registerS3method(
      "filter",
      "acme.toolkit::Project",
      function(.data, ...) filter(.data, ...),
      envir = asNamespace("dplyr")
    )
  }

  invisible()
}

# Adapted from vctrs::s3_register. Registers an S3 method for a class so that
# S3 dispatch works with S7's namespaced class names. Uses a load hook so the
# registration also happens if the target package is attached later.
#' @noRd
.s3_register <- function(generic, class, method = NULL) {
  stopifnot(
    is.character(generic),
    length(generic) == 1L,
    is.character(class),
    length(class) == 1L
  )

  pieces <- strsplit(generic, "::", fixed = TRUE)[[1L]]
  stopifnot(length(pieces) == 2L)
  package <- pieces[[1L]]
  generic_name <- pieces[[2L]]

  if (is.null(method)) {
    simple_class <- sub("^.*::", "", class)
    method <- get(paste0(generic_name, ".", simple_class), envir = parent.frame())
  }

  if (package %in% loadedNamespaces()) {
    registerS3method(generic_name, class, method, envir = asNamespace(package))
  }

  setHook(
    packageEvent(package, "onLoad"),
    function(...) {
      registerS3method(generic_name, class, method, envir = asNamespace(package))
    }
  )
}
