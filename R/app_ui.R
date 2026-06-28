# Top-level app UI.
#
# A `bslib::page_navbar` themed with the Acme palette, one `nav_panel` per
# module. Each module owns its own UI under a namespaced id.

#' Application UI
#'
#' @param request Shiny request object (required by `shinyApp`).
#' @returns A `bslib` page definition.
#' @keywords internal
app_ui <- function(request) {
  pal <- acme_palette()
  bslib::page_navbar(
    title = shiny::tags[["span"]](
      shiny::HTML('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" style="vertical-align:middle;margin-right:8px" aria-hidden="true"><rect x="0" y="0" width="24" height="24" rx="4" fill="rgba(255,255,255,0.9)"/><rect x="6" y="6" width="12" height="12" rx="2" fill="#e8662c"/></svg>'),
      "acme.toolkit"
    ),
    theme = bslib::bs_theme(
      version = 5L,
      primary = pal[["primary"]],
      secondary = pal[["accent"]],
      success = pal[["success"]]
    ) |> bslib::bs_add_rules("
      .navbar {
        background-color: #1f3a93 !important;
      }
      .navbar-brand,
      .navbar-brand span,
      .navbar .nav-link {
        color: rgba(255, 255, 255, 0.85) !important;
      }
      .navbar-brand:hover,
      .navbar .nav-link:hover,
      .navbar .nav-link.active {
        color: #ffffff !important;
      }
      .navbar .nav-link.active {
        border-bottom-color: #e8662c !important;
      }
      .bslib-sidebar-layout > .sidebar {
        background-color: #eef2fb !important;
        border-right: 1px solid #c7d4f5 !important;
      }
    "),
    bslib::nav_panel("Input", mod_input_ui("input")),
    bslib::nav_panel("Analysis", mod_analysis_ui("analysis")),
    bslib::nav_panel("Report", mod_report_ui("report"))
  )
}
