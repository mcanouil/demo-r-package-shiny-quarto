# S7 generics.
#
# This file is named with the `aaa-` prefix so that R sources it before the
# class definitions in `aab-classes.R`. Generics must exist before methods are
# attached to them.

#' Analyse a dataset
#'
#' @description
#' `analyse()` is an S7 generic that computes an [AnalysisResult] from a
#' [Dataset] or each dataset held by a [Project]. Methods are available for the
#' following classes:
#'
#' - [Dataset]: compute summary statistics or a correlation matrix.
#' - [Project]: run [analyse()] on the project's data and store the result.
#'
#' @param object A [Dataset] or [Project] object.
#' @param method Analysis method. One of `"describe"` or `"correlate"`.
#'   Default is `"describe"`.
#' @param ... Additional arguments passed to methods.
#'
#' @returns An [AnalysisResult] object, or for [Project] the modified project
#'   with the result appended and its `modified` timestamp updated.
#'
#' @examples
#' d <- Dataset(data = mtcars, name = "mtcars")
#' analyse(d)
#' analyse(d, method = "correlate")
#'
#' @export
analyse <- S7::new_generic("analyse", "object", function(object, method = "describe", ...) {
  S7::S7_dispatch()
})

#' Filter rows of a dataset
#'
#' @description
#' `filter()` is an S7 generic that keeps rows of a [Dataset] (or the data of a
#' [Project]) matching a predicate. The generic intentionally shares its name
#' with [dplyr::filter()] and [stats::filter()]; for any object that is not an
#' acme.toolkit class, the call is forwarded to the next `filter()` on the
#' search path. This is the "masked verb" pattern: the package can offer an
#' ergonomic verb without breaking existing code that relies on the base or
#' tidyverse function of the same name.
#'
#' @param object A [Dataset] or [Project] object, or any object supported by a
#'   masked `filter()` elsewhere on the search path.
#' @param ... For acme.toolkit classes: an unquoted predicate evaluated in the
#'   data (e.g. `mpg > 20`). For other objects: forwarded to the masked
#'   function.
#'
#' @returns A filtered [Dataset] or [Project], or the result of the masked
#'   function.
#'
#' @examples
#' d <- Dataset(data = mtcars, name = "mtcars")
#' filter(d, cyl == 4)
#'
#' @export
filter <- S7::new_generic("filter", "object", function(object, ...) {
  S7::S7_dispatch()
})

#' Forward a masked generic to the search path
#'
#' Walks the attached search path (skipping this package) for a plain function
#' of the same name and delegates to it. This lets [filter()] keep working as
#' [dplyr::filter()] / [stats::filter()] for non-acme.toolkit objects.
#'
#' @param generic_name Character. Name of the function to find.
#' @param object The first argument to forward.
#' @param ... Additional arguments to forward.
#' @returns The result of calling the masked function.
#' @noRd
.s3_fallback <- function(generic_name, object, ...) {
  for (env_name in search()) {
    if (env_name == "package:acme.toolkit") {
      next
    }
    env <- as.environment(env_name)
    if (exists(generic_name, envir = env, inherits = FALSE)) {
      fn <- get(generic_name, envir = env, inherits = FALSE)
      if (is.function(fn) && !inherits(fn, "S7_generic")) {
        return(fn(object, ...))
      }
    }
  }
  cli::cli_abort(
    "No method found for {.fn {generic_name}} with object of class {.cls {class(object)[[1]]}}."
  )
}

#' @noRd
filter.default <- S7::method(filter, S7::class_any) <- function(object, ...) {
  .s3_fallback("filter", object, ...)
}
