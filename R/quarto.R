# Quarto extension installation.
#
# The branded multi-format extension is bundled in `inst/_extensions/acme/`.
# Reports need it present in their own project directory, so this installs a
# copy into the target project and stamps it with the package version. Adapted
# from the source packages' install-extension helper.

#' Install the bundled Acme Quarto extension
#'
#' @param target_dir Directory where `_extensions/acme/` will be created.
#' @param overwrite Force reinstallation even if the extension already exists?
#'   Default is `FALSE`.
#' @param quiet Suppress Quarto output? Default is `TRUE`.
#' @returns Invisibly, the path to the installed extension directory.
#' @noRd
.install_acme_extension <- function(target_dir, overwrite = FALSE, quiet = TRUE) {
  if (!requireNamespace("quarto", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg quarto} is required to install the extension.")
  }
  ext_source <- system.file("_extensions", package = "acme.toolkit", mustWork = TRUE)
  ext_dest <- file.path(target_dir, "_extensions", "acme")

  pkg_version <- as.character(utils::packageVersion("acme.toolkit"))
  source_tag <- paste0("acme.toolkit@", pkg_version)

  if (dir.exists(ext_dest) && !overwrite) {
    return(invisible(ext_dest))
  }
  if (dir.exists(ext_dest)) {
    unlink(ext_dest, recursive = TRUE)
  }

  withr_dir(target_dir, {
    quarto::quarto_add_extension(extension = ext_source, no_prompt = TRUE, quiet = quiet)
  })

  .stamp_extension_source(ext_dest, source_tag)
  invisible(ext_dest)
}

#' Record which package installed the extension, preserving its own version
#' @noRd
.stamp_extension_source <- function(ext_dir, source_tag) {
  yml_path <- file.path(ext_dir, "_extension.yml")
  if (!file.exists(yml_path)) {
    return(invisible(NULL))
  }
  lines <- readLines(yml_path, warn = FALSE)
  lines <- lines[!grepl("^source:\\s*|^source-type:\\s*", lines)]
  block <- c(paste0("source: ", source_tag), "source-type: package")
  version_idx <- grep("^version:\\s*", lines)
  if (length(version_idx) > 0L) {
    lines <- append(lines, block, after = version_idx[[1L]])
  } else {
    lines <- c(lines, block)
  }
  writeLines(lines, yml_path)
  invisible(NULL)
}

#' Minimal `withr::with_dir()` to avoid a hard dependency
#' @noRd
withr_dir <- function(dir, code) {
  old <- getwd()
  on.exit(setwd(old), add = TRUE)
  setwd(dir)
  force(code)
}
