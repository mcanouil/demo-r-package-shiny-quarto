# Contributing to acme.toolkit

Thanks for your interest. This package is a reference skeleton, so contributions
that clarify the architecture are especially welcome.

## Development

```r
devtools::load_all()
devtools::test()
```

## Before opening a pull request

1. Format: `air format .`.
2. Lint: `Rscript -e 'lintr::lint_package()'` (zero issues).
3. Test: `Rscript -e 'devtools::test()'` (zero failures).
4. Document: `Rscript -e 'devtools::document()'` if you changed roxygen blocks.
5. Check: `Rscript -e 'devtools::check()'` (zero errors, zero warnings).

## Conventions

- Use `<-` for assignment and `[[` for element access.
- Prefix package functions with `::` inside function bodies.
- Define S7 generics in `R/aaa-generics.R` and classes in `R/aab-classes.R`.
- One file per generic for method implementations.
