# acme.toolkit 0.1.0

- First release of the reference architecture skeleton.
- S7 object model: `Dataset`, `AnalysisResult`, `Project`, with the `analyse()`
  and `filter()` generics (the latter demonstrating search-path fallback).
- Config-driven `targets` pipeline rendered from a Whisker template.
- Parameterised Quarto reporting backed by a bundled multi-format extension.
- Modular Shiny app (`run_app()`).
