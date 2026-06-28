# acme.toolkit

A minimal, domain-neutral R package that demonstrates a reusable architecture
for analysis tooling: an S7 object model, a config-driven `targets` pipeline,
parameterised Quarto reporting backed by a branded multi-format extension,
and a modular Shiny application.

This is the companion repository for the blog post
[R Package Architecture: Shiny, Quarto, targets, and S7](https://mickael.canouil.fr/posts/2026-07-01-r-package-shiny-quarto/)
on [mickael.canouil.fr](https://mickael.canouil.fr).

## Layout

```
acme.toolkit/
├── R/
│   ├── aaa-generics.R          # S7 generics, search-path fallback
│   ├── aab-classes.R           # Dataset, AnalysisResult, Project classes
│   ├── analyse.R               # analyse() methods
│   ├── pipeline.R              # generate_pipeline(), run_pipeline(), report_pipeline()
│   ├── quarto.R                # .install_acme_extension() helper
│   ├── app_ui.R / app_server.R # Shiny top-level UI and server
│   ├── mod_input.R             # Shiny module: load a dataset
│   ├── mod_analysis.R          # Shiny module: run analyse()
│   ├── mod_report.R            # Shiny module: download the report
│   └── zzz.R                  # S7 + S3 registration at load time
├── inst/
│   ├── _extensions/acme/       # bundled Quarto extension (HTML, Typst, revealjs)
│   │   ├── _extension.yml
│   │   ├── _brand.yml
│   │   ├── acme.scss
│   │   ├── filters/            # Lua filters: copyright-year, prose-divs
│   │   ├── logos/
│   │   └── revealjs/
│   ├── extdata/demo.csv        # toy dataset for quick-start examples
│   └── templates/
│       ├── _targets.R          # Whisker template for the pipeline
│       ├── pipeline-config-schema.yml
│       └── report.qmd          # parameterised report template
└── tests/testthat/
```

## The four pillars

1. **S7 object model** with validators and a search-path fallback for masked verbs (`aaa-generics.R`, `aab-classes.R`, `zzz.R`).
2. **Config-driven `targets` pipeline** rendered from a Whisker/Mustache template (`pipeline.R`, `inst/templates/_targets.R`).
3. **Branded Quarto extension** bundled inside the package, installed into each project at render time (`quarto.R`, `inst/_extensions/acme/`).
4. **Modular Shiny app** with state lifted into the top-level server, reusing the same `analyse()` generic as the batch pipeline (`app_*.R`, `mod_*.R`).

## Quick start

```r
# install.packages("pak")
pak::pak("mcanouil/demo-r-package-shiny-quarto")

library(acme.toolkit)

# S7 objects
d <- Dataset(
  data = read.csv(system.file("extdata", "demo.csv", package = "acme.toolkit")),
  name = "demo"
)
analyse(d)
analyse(d, method = "correlate")
filter(d, height > 170)       # S7 method
filter(mtcars, cyl == 4)      # masked verb still reaches dplyr/base

# targets pipeline from a config list
config <- list(
  data = list(
    file = system.file("extdata", "demo.csv", package = "acme.toolkit"),
    name = "demo"
  ),
  analyses = list(summary = list(method = "describe"))
)
generate_pipeline(config, report = FALSE)
run_pipeline()

# Shiny app
run_app()
```

## What to adapt

Replace the fictional Acme domain with your own:

- Rename the S7 classes and their properties.
- Replace the `analyse()` method bodies with your algorithms.
- Update `_brand.yml`, `acme.scss`, and `revealjs/theme.scss` with your palette and logo.
- Replace the Whisker template targets with your pipeline steps.

## License

MIT © Mickaël Canouil
