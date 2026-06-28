# Shiny application entry point.
#
# The app is intentionally small but demonstrates the modular pattern used in
# the source packages: a top-level UI/server pair (`app_ui()`/`app_server()`)
# that lifts shared state into `reactiveVal`s and wires one module per feature.

#' @noRd
.require_shiny <- function() {
  for (pkg in c("shiny", "bslib")) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      cli::cli_abort("Package {.pkg {pkg}} is required to run the app.")
    }
  }
}

#' Run the Acme Shiny application
#'
#' @description
#' Launch the modular demo app: load a dataset, run an analysis, and preview the
#' result. Requires the optional `shiny` and `bslib` packages.
#'
#' @param ... Passed to [shiny::shinyApp()].
#' @returns A Shiny app object.
#'
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
#'
#' @export
run_app <- function(...) {
  .require_shiny()
  shiny::shinyApp(ui = app_ui, server = app_server, ...)
}
