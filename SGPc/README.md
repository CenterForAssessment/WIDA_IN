# WIDA_IN SGPc Pipeline

This directory houses WIDA_IN-specific SGPc analysis source code and specs. It
is the operational layer for applying the reusable `SGPc` package to WIDA_IN
data.

## Boundary

- Keep reusable analysis functions in the `SGPc` R package.
- Keep WIDA_IN-specific specs, paths, run scripts, and local output conventions
  here.
- Do not commit student-level microdata or generated real assessment outputs.
- Run synthetic/redacted checks before pointing specs at approved WIDA_IN data.

## Starter Layout

- `specs/` — WIDA_IN-local JSON specs.
- `run_wida_in_sgpc.R` — thin runner around `SGPc::run_sgpc_analysis()`.
- `specs/results/` — generated output directory used by the starter template;
  keep real outputs local unless explicitly approved.

## Example

```r
source("SGPc/run_wida_in_sgpc.R")
run_wida_in_sgpc("SGPc/specs/wida-in-2025-sgpc-analysis-spec.template.json")
```
