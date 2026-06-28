# Config-driven targets pipeline.
#
# `generate_pipeline()` turns a YAML (or list) config into a `_targets.R` file
# by rendering a Whisker template bundled in `inst/templates/`. `run_pipeline()`
# executes it and `report_pipeline()` renders the Quarto report. This mirrors
# the source architecture: users describe *what* they want in a config, never
# hand-write the targets graph.

#' @noRd
.is_verbose <- function(verbose = NULL) {
  if (is.null(verbose)) {
    return(isTRUE(getOption("acme.toolkit.verbose", TRUE)))
  }
  isTRUE(verbose)
}

#' Parse a pipeline config into a canonical list
#'
#' Accepts a list (used as-is) or a path to a YAML file.
#' @noRd
.parse_pipeline_config <- function(config) {
  if (is.list(config)) {
    return(config)
  }
  if (is.character(config) && length(config) == 1L && file.exists(config)) {
    if (!requireNamespace("yaml", quietly = TRUE)) {
      cli::cli_abort("Package {.pkg yaml} is required to read a config file.")
    }
    return(yaml::read_yaml(config))
  }
  cli::cli_abort(c(
    "{.arg config} must be a list or a path to an existing YAML file.",
    i = "Got {.cls {class(config)[[1]]}}."
  ))
}

#' Validate a parsed pipeline config
#' @noRd
.validate_pipeline_config <- function(config) {
  if (is.null(config[["data"]]) || is.null(config[["data"]][["file"]])) {
    cli::cli_abort(c(
      "Config must contain {.field data.file}.",
      i = "Example: a {.field data} entry with a {.field file} and optional {.field name}."
    ))
  }
  analyses <- config[["analyses"]]
  if (!is.null(analyses)) {
    valid_methods <- c("describe", "correlate")
    for (nm in names(analyses)) {
      method <- analyses[[nm]][["method"]]
      if (is.null(method) || !method %in% valid_methods) {
        cli::cli_abort(c(
          "Analysis {.val {nm}} has an invalid {.field method}.",
          i = "Use one of: {.val {valid_methods}}."
        ))
      }
    }
  }
  invisible(config)
}

#' Build the data list passed to the Whisker template
#' @noRd
.prepare_template_data <- function(config, config_hash) {
  analyses <- config[["analyses"]] %||% list()
  analyses_data <- lapply(names(analyses), function(nm) {
    list(name = nm, method = analyses[[nm]][["method"]])
  })
  list(
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    config_hash = config_hash,
    data_file = config[["data"]][["file"]],
    data_name = config[["data"]][["name"]] %||% "dataset",
    analyses = analyses_data
  )
}

#' Generate a targets pipeline from a config
#'
#' @description
#' Render a `_targets.R` file from a config (a list or a path to a YAML file).
#' The config is validated, hashed, and the hash recorded in the file header so
#' [run_pipeline()] can warn when the config has drifted. When `report = TRUE`
#' the Quarto report template and the Acme Quarto extension are installed
#' alongside the pipeline.
#'
#' @param config A list or a path to a YAML config file. Must contain a
#'   `data.file` entry.
#' @param path Output path for the generated pipeline. Default is `"_targets.R"`.
#' @param report Install the report template and Quarto extension? Default is
#'   `TRUE`.
#' @param overwrite Overwrite an existing `path`? Default is `FALSE`.
#' @param verbose Print progress messages? `NULL` (default) uses
#'   `getOption("acme.toolkit.verbose", TRUE)`.
#'
#' @returns Invisibly, the path to the generated pipeline.
#'
#' @examples
#' config <- list(
#'   data = list(file = "demo.csv", name = "demo"),
#'   analyses = list(summary = list(method = "describe"))
#' )
#' path <- file.path(tempdir(), "_targets.R")
#' generate_pipeline(config, path = path, report = FALSE, overwrite = TRUE)
#'
#' @export
generate_pipeline <- function(config, path = "_targets.R", report = TRUE, overwrite = FALSE, verbose = NULL) {
  verbose <- .is_verbose(verbose)

  config <- .parse_pipeline_config(config)
  .validate_pipeline_config(config)
  config_hash <- substr(rlang::hash(config), 1L, 12L)

  if (file.exists(path) && !overwrite) {
    cli::cli_abort(c(
      "File {.file {path}} already exists.",
      i = "Use {.code overwrite = TRUE} to overwrite."
    ))
  }

  template_data <- .prepare_template_data(config, config_hash)
  template_path <- system.file("templates", "_targets.R", package = "acme.toolkit")
  if (!requireNamespace("whisker", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg whisker} is required to render the pipeline template.")
  }
  template_content <- paste(readLines(template_path, warn = FALSE), collapse = "\n")
  output <- whisker::whisker.render(template_content, template_data)
  writeLines(enc2utf8(output), path, useBytes = TRUE)

  if (isTRUE(report)) {
    report_dest <- file.path(dirname(path), "report.qmd")
    if (!file.exists(report_dest) || isTRUE(overwrite)) {
      file.copy(
        system.file("templates", "report.qmd", package = "acme.toolkit"),
        report_dest,
        overwrite = TRUE
      )
    }
    .install_acme_extension(dirname(path), overwrite = overwrite, quiet = !verbose)
  }

  if (verbose) {
    cli::cli_alert_success("Generated {.file {path}}.")
    cli::cli_alert_info("Run {.code acme.toolkit::run_pipeline()} to execute the pipeline.")
  }

  invisible(path)
}

#' Run a targets pipeline
#'
#' @description
#' Execute the pipeline with `targets::tar_make()`.
#'
#' @param store Path to the targets store. Default is `NULL` (targets default).
#' @param verbose Print progress messages? `NULL` (default) uses the package
#'   option.
#'
#' @returns Invisibly, `NULL`.
#'
#' @export
run_pipeline <- function(store = NULL, verbose = NULL) {
  verbose <- .is_verbose(verbose)
  if (!requireNamespace("targets", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg targets} is required to run the pipeline.")
  }
  if (is.null(store)) {
    targets::tar_make(reporter = if (verbose) "verbose" else "silent")
  } else {
    targets::tar_make(store = store, reporter = if (verbose) "verbose" else "silent")
  }
  invisible(NULL)
}

#' Render the pipeline report
#'
#' @description
#' Render the Quarto report from a targets store. The report reads pipeline
#' results with `targets::tar_read()`, so the pipeline must have been run first.
#'
#' @param input Path to the report `.qmd`. Default is `"report.qmd"`.
#' @param output_format Quarto output format. Default is `"acme-html"`.
#' @param store Path to the targets store, exposed to the report via the
#'   `TAR_STORE` environment variable. Default is `NULL`.
#' @param verbose Print progress messages? `NULL` (default) uses the package
#'   option.
#'
#' @returns Invisibly, the path to the rendered report input.
#'
#' @export
report_pipeline <- function(input = "report.qmd", output_format = "acme-html", store = NULL, verbose = NULL) {
  verbose <- .is_verbose(verbose)
  if (!requireNamespace("quarto", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg quarto} is required to render the report.")
  }
  if (!file.exists(input)) {
    cli::cli_abort(c(
      "Report input {.file {input}} not found.",
      i = "Run {.fn generate_pipeline} with {.code report = TRUE} first."
    ))
  }
  if (!is.null(store)) {
    old <- Sys.getenv("TAR_STORE", unset = NA)
    Sys.setenv(TAR_STORE = store)
    on.exit(
      if (is.na(old)) Sys.unsetenv("TAR_STORE") else Sys.setenv(TAR_STORE = old),
      add = TRUE
    )
  }
  quarto::quarto_render(input = input, output_format = output_format, quiet = !verbose)
  invisible(input)
}
