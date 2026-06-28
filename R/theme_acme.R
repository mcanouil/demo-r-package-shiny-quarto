# Branding utilities shared by plots, tables, and the Shiny app.
#
# Colours live in one place so the whole package (and the Quarto extension's
# `_brand.yml`) can be re-skinned by editing a single palette.

#' Acme brand palette
#'
#' @description
#' Named character vector of the Acme Inc brand colours. Re-skin the package by
#' editing these hex values (and the matching values in the Quarto extension's
#' `_brand.yml` and `acme.scss`).
#'
#' @returns A named character vector of hex colours.
#' @keywords internal
acme_palette <- function() {
  c(
    primary = "#1f3a93",
    accent = "#e8662c",
    neutral = "#4a4a4a",
    light = "#eef2fb",
    success = "#2e9e5b"
  )
}

#' Acme ggplot2 theme
#'
#' @description
#' A minimal ggplot2 theme using the Acme brand colours. Requires the optional
#' `ggplot2` package.
#'
#' @param base_size Base font size. Default is `12`.
#' @returns A ggplot2 theme object.
#'
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   library(ggplot2)
#'   ggplot(mtcars) +
#'     aes(x = wt, y = mpg) +
#'     geom_point() +
#'     theme_acme()
#' }
#'
#' @export
theme_acme <- function(base_size = 12) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg ggplot2} is required for {.fn theme_acme}.")
  }
  pal <- acme_palette()
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(colour = pal[["primary"]], face = "bold"),
      panel.grid.major = ggplot2::element_line(colour = pal[["light"]]),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "bottom",
      text = ggplot2::element_text(colour = pal[["neutral"]])
    )
}
