# Module: dataset input.
#
# Loads the bundled demo CSV or a user upload and writes a Dataset into the
# shared `dataset` reactiveVal. UI and server live in one file (the source
# packages' convention).

#' Input module UI
#' @param id Module id.
#' @returns A UI definition.
#' @keywords internal
mod_input_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      title = "Data source",
      shiny::radioButtons(
        ns("source"),
        "Source",
        choices = c("Demo dataset" = "demo", "Upload CSV" = "upload"),
        selected = "demo"
      ),
      shiny::conditionalPanel(
        condition = "input.source == 'upload'",
        ns = ns,
        shiny::fileInput(ns("file"), "CSV file", accept = ".csv")
      ),
      shiny::textInput(ns("name"), "Dataset name", value = "demo")
    ),
    shiny::tableOutput(ns("preview"))
  )
}

#' Input module server
#' @param id Module id.
#' @param dataset A `reactiveVal` to write the loaded [Dataset] into.
#' @returns `NULL`, invisibly.
#' @keywords internal
mod_input_server <- function(id, dataset) {
  shiny::moduleServer(id, function(input, output, session) {
    raw <- shiny::reactive({
      if (identical(input[["source"]], "upload")) {
        shiny::req(input[["file"]])
        utils::read.csv(input[["file"]][["datapath"]])
      } else {
        utils::read.csv(system.file("extdata", "demo.csv", package = "acme.toolkit"))
      }
    })

    shiny::observe({
      dataset(Dataset(data = raw(), name = input[["name"]]))
    })

    output[["preview"]] <- shiny::renderTable(utils::head(raw(), 5L))
  })

  invisible(NULL)
}
