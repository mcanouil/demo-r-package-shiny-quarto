# Top-level app server.
#
# Shared state is "lifted" here into reactiveVal containers and passed down to
# the module servers. Modules communicate only through these reactives: the
# input module writes the dataset, the analysis module reads it and writes a
# result, and the report module reads the result. No module reaches into
# another's namespace.

#' Application server
#'
#' @param input,output,session Shiny server parameters.
#' @returns `NULL`, invisibly.
#' @keywords internal
app_server <- function(input, output, session) {
  dataset <- shiny::reactiveVal(NULL)
  result <- shiny::reactiveVal(NULL)

  mod_input_server("input", dataset = dataset)
  mod_analysis_server("analysis", dataset = dataset, result = result)
  mod_report_server("report", result = result)

  invisible(NULL)
}
