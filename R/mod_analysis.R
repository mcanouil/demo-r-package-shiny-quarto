# Module: run an analysis.
#
# Reads the shared `dataset`, runs `analyse()` when the button is clicked, and
# writes the result into the shared `result` reactiveVal. The work runs behind
# a `bslib::input_task_button` so the UI stays responsive (the source packages
# pair this with an async backend; here the work is fast enough to run inline).

#' Analysis module UI
#' @param id Module id.
#' @returns A UI definition.
#' @keywords internal
mod_analysis_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      title = "Analysis settings",
      shiny::selectInput(
        ns("method"),
        "Method",
        choices = c("Describe" = "describe", "Correlate" = "correlate")
      ),
      bslib::input_task_button(ns("run"), "Run analysis")
    ),
    shiny::tableOutput(ns("summary"))
  )
}

#' Analysis module server
#' @param id Module id.
#' @param dataset A `reactiveVal` holding the input [Dataset].
#' @param result A `reactiveVal` to write the [AnalysisResult] into.
#' @returns `NULL`, invisibly.
#' @keywords internal
mod_analysis_server <- function(id, dataset, result) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::observeEvent(input[["run"]], {
      ds <- dataset()
      if (is.null(ds)) {
        shiny::showNotification("Load a dataset first.", type = "warning")
        return()
      }
      result(analyse(ds, method = input[["method"]]))
    })

    output[["summary"]] <- shiny::renderTable({
      res <- result()
      shiny::req(res)
      res@summary
    })
  })

  invisible(NULL)
}
