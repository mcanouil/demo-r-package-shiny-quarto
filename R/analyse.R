# Methods for the `analyse()` and `filter()` generics.
#
# One file per generic keeps method implementations next to the internal
# helpers they delegate to (the pattern used across the source packages).

#' Numeric columns of a data.frame
#' @noRd
.numeric_columns <- function(data) {
  is_num <- vapply(data, is.numeric, logical(1L))
  data[, is_num, drop = FALSE]
}

#' Compute per-column summary statistics
#' @noRd
.describe <- function(data) {
  num <- .numeric_columns(data)
  if (ncol(num) == 0L) {
    cli::cli_abort(c(
      "{.arg data} has no numeric columns to describe.",
      i = "Provide a data.frame with at least one numeric column."
    ))
  }
  data.frame(
    variable = names(num),
    n = colSums(!is.na(num)),
    mean = colMeans(num, na.rm = TRUE),
    sd = apply(num, 2L, stats::sd, na.rm = TRUE),
    min = apply(num, 2L, min, na.rm = TRUE),
    max = apply(num, 2L, max, na.rm = TRUE),
    row.names = NULL,
    stringsAsFactors = FALSE
  )
}

#' Compute a long-format correlation table
#' @noRd
.correlate <- function(data) {
  num <- .numeric_columns(data)
  if (ncol(num) < 2L) {
    cli::cli_abort(c(
      "{.arg data} needs at least two numeric columns to correlate.",
      i = "Found {ncol(num)} numeric column{?s}."
    ))
  }
  corr_mat <- stats::cor(num, use = "pairwise.complete.obs")
  pairs <- which(upper.tri(corr_mat), arr.ind = TRUE)
  data.frame(
    x = rownames(corr_mat)[pairs[, "row"]],
    y = colnames(corr_mat)[pairs[, "col"]],
    correlation = corr_mat[upper.tri(corr_mat)],
    row.names = NULL,
    stringsAsFactors = FALSE
  )
}

#' @noRd
S7::method(analyse, Dataset) <- function(object, method = "describe", ...) {
  if (is.null(object@data)) {
    cli::cli_abort("Cannot analyse a {.cls Dataset} with no data.")
  }
  summary <- switch(
    method,
    describe = .describe(object@data),
    correlate = .correlate(object@data),
    cli::cli_abort("Unknown {.arg method}: {.val {method}}. Use {.val describe} or {.val correlate}.")
  )
  AnalysisResult(
    summary = summary,
    method = method,
    params = list(...),
    source = object
  )
}

#' @noRd
S7::method(analyse, Project) <- function(object, method = "describe", ...) {
  if (is.null(object@data)) {
    cli::cli_abort(c(
      "Project {.val {object@name}} has no data to analyse.",
      i = "Set the project's data before calling {.fn analyse}."
    ))
  }
  result <- analyse(object@data, method = method, ...)
  object@results <- c(object@results, list(result))
  object@modified <- Sys.time()
  object
}

#' @noRd
S7::method(filter, Dataset) <- function(object, ...) {
  if (is.null(object@data)) {
    cli::cli_abort("Cannot filter a {.cls Dataset} with no data.")
  }
  quos <- rlang::enquos(...)
  keep <- rep(TRUE, nrow(object@data))
  for (q in quos) {
    keep <- keep & rlang::eval_tidy(q, data = object@data)
  }
  # Match dplyr::filter(): a predicate that is NA drops the row.
  keep[is.na(keep)] <- FALSE
  object@data <- object@data[keep, , drop = FALSE]
  object
}

#' @noRd
S7::method(filter, Project) <- function(object, ...) {
  if (is.null(object@data)) {
    cli::cli_abort(c(
      "Project {.val {object@name}} has no data to filter.",
      i = "Set the project's data before calling {.fn filter}."
    ))
  }
  object@data <- filter(object@data, ...)
  object@modified <- Sys.time()
  object
}
