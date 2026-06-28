# Module: preview and export the result.
#
# Reads the shared `result` reactiveVal and offers a CSV download. A real app
# would render the Quarto report here via report_pipeline(); this keeps the
# dependency surface small while showing the read-only consumer pattern.

#' Report module UI
#' @param id Module id.
#' @returns A UI definition.
#' @keywords internal
mod_report_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      title = "Export",
      shiny::downloadButton(ns("download"), "Download summary (CSV)")
    ),
    shiny::verbatimTextOutput(ns("status"))
  )
}

#' Report module server
#' @param id Module id.
#' @param result A `reactiveVal` holding the [AnalysisResult].
#' @returns `NULL`, invisibly.
#' @keywords internal
mod_report_server <- function(id, result) {
  shiny::moduleServer(id, function(input, output, session) {
    output[["status"]] <- shiny::renderText({
      res <- result()
      if (is.null(res)) {
        "No analysis yet. Run one on the Analysis tab."
      } else {
        sprintf("Ready: %s analysis with %d rows.", res@method, nrow(res@summary))
      }
    })

    output[["download"]] <- shiny::downloadHandler(
      filename = function() "acme-summary.csv",
      content = function(file) {
        res <- result()
        shiny::req(res)
        utils::write.csv(res@summary, file, row.names = FALSE)
      }
    )
  })

  invisible(NULL)
}
