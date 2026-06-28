# S7 class definitions.
#
# Each class is an immutable container with a validator and an explicit
# constructor that stamps a creation time. `Project` aggregates the others and
# enforces element types with `S7::S7_inherits()`.

#' Dataset class
#'
#' @description
#' A thin wrapper around a `data.frame` with workflow metadata.
#'
#' @param data A `data.frame` holding the observations, or `NULL`.
#' @param name A short label for the dataset. Default is `""`.
#'
#' @details
#' A Dataset contains:
#' - `data`: the wrapped `data.frame`.
#' - `name`: a human-readable label.
#' - `created`: creation timestamp, set by the constructor.
#'
#' @returns A Dataset object.
#'
#' @examples
#' Dataset(data = mtcars, name = "mtcars")
#'
#' @export
Dataset <- S7::new_class(
  name = "Dataset",
  properties = list(
    data = S7::class_any,
    name = S7::new_property(class = S7::class_character, default = ""),
    created = S7::new_property(class = S7::class_any, default = NULL)
  ),
  validator = function(self) {
    if (!is.null(self@data) && !is.data.frame(self@data)) {
      return("@data must be a data.frame or NULL")
    }
    if (length(self@name) != 1L) {
      return("@name must be a single string")
    }
    NULL
  },
  constructor = function(data = NULL, name = "") {
    S7::new_object(
      S7::S7_object(),
      data = data,
      name = name,
      created = Sys.time()
    )
  }
)

#' AnalysisResult class
#'
#' @description
#' Container for the output of [analyse()].
#'
#' @param summary A `data.frame` of computed statistics.
#' @param method Analysis method. One of `"describe"` or `"correlate"`.
#'   Default is `"describe"`.
#' @param params A list of analysis parameters. Default is `list()`.
#' @param source Optional reference to the source [Dataset]. Default is `NULL`.
#'
#' @returns An AnalysisResult object.
#'
#' @export
AnalysisResult <- S7::new_class(
  name = "AnalysisResult",
  properties = list(
    summary = S7::class_any,
    method = S7::new_property(class = S7::class_character, default = "describe"),
    params = S7::new_property(class = S7::class_list, default = list()),
    source = S7::class_any,
    created = S7::new_property(class = S7::class_any, default = NULL)
  ),
  validator = function(self) {
    valid_methods <- c("describe", "correlate")
    if (!self@method %in% valid_methods) {
      return(sprintf("@method must be one of: %s", toString(valid_methods)))
    }
    if (!is.null(self@summary) && !is.data.frame(self@summary)) {
      return("@summary must be a data.frame or NULL")
    }
    NULL
  },
  constructor = function(summary = NULL, method = "describe", params = list(), source = NULL) {
    S7::new_object(
      S7::S7_object(),
      summary = summary,
      method = method,
      params = params,
      source = source,
      created = Sys.time()
    )
  }
)

#' Project class
#'
#' @description
#' A container for a complete analysis: an input [Dataset] plus a list of
#' [AnalysisResult] objects.
#'
#' @param data A [Dataset] object, or `NULL`.
#' @param results A list of [AnalysisResult] objects. Default is `list()`.
#' @param name Project name. Default is `""`.
#' @param description Project description. Default is `""`.
#'
#' @returns A Project object.
#'
#' @export
Project <- S7::new_class(
  name = "Project",
  properties = list(
    data = S7::class_any,
    results = S7::new_property(class = S7::class_list, default = list()),
    name = S7::new_property(class = S7::class_character, default = ""),
    description = S7::new_property(class = S7::class_character, default = ""),
    created = S7::new_property(class = S7::class_any, default = NULL),
    modified = S7::new_property(class = S7::class_any, default = NULL)
  ),
  validator = function(self) {
    if (!is.null(self@data) && !S7::S7_inherits(self@data, Dataset)) {
      return("@data must be a Dataset object or NULL")
    }
    for (i in seq_along(self@results)) {
      if (!S7::S7_inherits(self@results[[i]], AnalysisResult)) {
        return(sprintf("@results[[%d]] must be an AnalysisResult object", i))
      }
    }
    NULL
  },
  constructor = function(data = NULL, results = list(), name = "", description = "") {
    now <- Sys.time()
    S7::new_object(
      S7::S7_object(),
      data = data,
      results = results,
      name = name,
      description = description,
      created = now,
      modified = now
    )
  }
)

#' Print a Dataset object
#'
#' @param x A Dataset object.
#' @param ... Additional arguments (unused).
#' @returns Invisibly returns `x`.
#' @keywords internal
print.Dataset <- function(x, ...) {
  n_rows <- if (is.null(x@data)) 0L else nrow(x@data)
  n_cols <- if (is.null(x@data)) 0L else ncol(x@data)
  cli::cli_h1("Dataset")
  cli::cli_bullets(c(
    "*" = "Name: {x@name}",
    "*" = "Rows: {format(n_rows, big.mark = ',')}",
    "*" = "Columns: {n_cols}",
    "*" = "Created: {format(x@created, '%Y-%m-%d %H:%M:%S')}"
  ))
  invisible(x)
}

#' Print an AnalysisResult object
#'
#' @param x An AnalysisResult object.
#' @param ... Additional arguments (unused).
#' @returns Invisibly returns `x`.
#' @keywords internal
print.AnalysisResult <- function(x, ...) {
  n_rows <- if (is.null(x@summary)) 0L else nrow(x@summary)
  cli::cli_h1("AnalysisResult")
  cli::cli_bullets(c(
    "*" = "Method: {x@method}",
    "*" = "Rows: {n_rows}",
    "*" = "Created: {format(x@created, '%Y-%m-%d %H:%M:%S')}"
  ))
  invisible(x)
}

#' Print a Project object
#'
#' @param x A Project object.
#' @param ... Additional arguments (unused).
#' @returns Invisibly returns `x`.
#' @keywords internal
print.Project <- function(x, ...) {
  cli::cli_h1("Project")
  cli::cli_bullets(c(
    "*" = "Name: {x@name}",
    "*" = "Data: {if (is.null(x@data)) 'none' else x@data@name}",
    "*" = "Results: {length(x@results)}",
    "*" = "Modified: {format(x@modified, '%Y-%m-%d %H:%M:%S')}"
  ))
  invisible(x)
}
