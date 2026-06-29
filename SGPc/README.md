# WIDA_IN SGPc Pipeline

This directory houses WIDA_IN-specific SGPc analysis source code and specs. It
is the operational layer for applying the reusable `SGPc` package to WIDA_IN
data.

## Boundary

- Keep reusable analysis functions in the `SGPc` R package.
- Keep WIDA_IN-specific analysis specs, paths, run scripts, and local output
  conventions here.
- Keep raw-to-LONG preparation in the existing `WIDA_IN_Data_LONG_<year>.R`
  pipeline scripts before SGPc runs.
- Do not commit student-level microdata or generated real assessment outputs.
- Run synthetic/redacted checks before pointing specs at approved WIDA_IN data.

## Three Stages

SGPc work is organized into three stages, developed in this order:

1. **Data analysis** — calculate copulas and SGPc from canonical LONG data.
2. **Output** — a manifest-indexed bundle of language-neutral artifacts (plus
   optional SGPc merged back into the LONG data). See "Output Bundle" below.
3. **Data preparation** — raw-to-LONG. Deferred; keep using the existing
   `WIDA_IN_Data_LONG_<year>.R` scripts for now.

## Layout

- `specs/wida-in-2025-sgpc-analysis-spec.json` — committed declarative
  `sgpc.analysis.v0.2` analysis spec; the run target for 2025.
- `specs/wida-in-2025-sgpc-analysis-spec.template.json` — annotated template /
  documentation.
- `contexts/wida-access-in.json` — metadata-only context registry for WIDA
  ACCESS in Indiana; searchable context for specs and manifests.
- `run_wida_in_sgpc.R` — helper around `SGPc::run_sgpc_analysis()` that loads the
  SGPc package and runs a spec.
- `WIDA_IN_SGPc_2025.R` — sourceable 2025 workflow script (runs the static spec).
- `build_wida_in_sgpc_panel.R`, `generate_wida_in_sgpc_spec.R` — **set aside /
  deferred** prep + config automation; not used by the default 2025 workflow.
- `specs/results/` — generated output directory; keep real outputs local.

## Prerequisite: a single canonical LONG data set

The 2025 workflow starts from one canonical LONG data set you produce with the
existing WIDA_IN data-prep scripts. Save it as:

- `Data/WIDA_IN_Data_LONG_SGPc.Rdata` with object `WIDA_IN_Data_LONG_SGPc`

containing columns `VALID_CASE`, `CONTENT_AREA`, `YEAR`, `GRADE`, `SCALE_SCORE`,
`ACHIEVEMENT_LEVEL`, `ID`, and covering the analysis years (e.g. 2024 and 2025).
SGPc reads the canonical `VALID_CASE`/`INVALID_CASE` string convention natively;
no derived flag is required. Domain expectations for `CONTENT_AREA`, `YEAR`, and
`GRADE` are applied to valid cases by default; excluded invalid rows may contain
missing analysis fields such as `GRADE = NA`.

## 2025 Workflow

From the WIDA_IN root, after the LONG data set exists:

```r
source("SGPc/WIDA_IN_SGPc_2025.R")
```

From this `SGPc/` directory:

```r
source("WIDA_IN_SGPc_2025.R")
```

For a helper-only run against an explicit spec:

```r
source("SGPc/run_wida_in_sgpc.R")
run_wida_in_sgpc("SGPc/specs/wida-in-2025-sgpc-analysis-spec.json")
```

The default run is serial. To benchmark condition-level mirai parallelism, keep
the sourceable script loaded and call the helper explicitly:

```r
source("SGPc/WIDA_IN_SGPc_2025.R")
WIDA_IN_SGPc_2025_parallel <- run_wida_in_sgpc_2025(
  parallel = list(engine = "mirai", workers = 6, min_tasks = 1)
)
```

SGPc creates one scoped mirai daemon pool for eligible stages and reuses it for
copula fitting and percentile computation. Daemon startup has a fixed cost, so
small 12-condition runs may only improve modestly; larger all-year/span specs
should amortize setup better. Compare `manifest$timings`,
`manifest$parallel`, row counts, and condition summaries between serial and
parallel runs before treating the timing as representative.

The committed spec uses a declarative `design` block rather than hand-written
R-style grade-sequence lists. The current 2025 spec expands to the same
2024->2025 span-1 conditions as the previous explicit JSON:

- `READING_2024_2025_G0_G1`
- ...
- `READING_2024_2025_G11_G12`

To run all one-year spans in the 2017-2025 panel, set
`design.terminal_years` to `"all"` and keep `design.spans` as `[1]`. To add
two-, three-, and four-year lagged analyses, set `design.spans` to
`[1, 2, 3, 4]`. These are still bivariate SGPc analyses: span means the lag
between the prior and current assessment, not a multivariate copula dimension.

A condition with no linked students will stop the run with a clear error so you
know which condition to remove or narrow.

The committed spec also references `contexts/wida-access-in.json` through its
`context` block. That registry is where searchable meaning lives: jurisdiction
(`IN`), assessment system (`wida-access`), assessment family (`WIDA-ACCESS`),
administration (`wida-access-in-2025`), grades, and content areas. Keep
`analysis_id` and `condition_id` as slugs; do not rely on parsing those names
for cross-state or cross-assessment search.

## Smoke Check

Run the synthetic smoke check before pointing specs at real data:

```sh
Rscript SGPc/tests/smoke_test_sgpc_2025.R
```

The smoke test creates a temporary synthetic LONG data set (using the canonical
`VALID_CASE`/`INVALID_CASE` strings) plus a declarative v0.2 spec, runs
`SGPc::run_sgpc_analysis()`, validates the result contract, and checks the
merge-back output. It does not read or write real WIDA microdata.

During local package development the WIDA helpers prefer the SGPc checkout at
`/Users/conet/GitHub/dataimago/SGPc/SGPc-rpkg/SGPc` when `devtools` is
available. Set `SGPC_PACKAGE_PATH` if your SGPc checkout lives elsewhere.

## Output Bundle

A completed run writes a manifest-indexed output bundle into
`SGPc/specs/results/2025/`. `manifest.json` is the canonical index: it lists
every artifact with its `format`, `classification`, row count, content hash, and
intended `consumers`, plus a `disclosure` block grouping artifacts by
classification. Validate a bundle with
`SGPc::validate_sgpc_output_bundle(manifest, base_dir)`.

Artifacts are classified for downstream use:

- **restricted** — contain student identifiers; keep behind access control and
  never expose through APIs/MCP or visualizations. These are `student_sgpc.rds`,
  its `student_sgpc.csv` sidecar, and the merged LONG file.
- **aggregate** — de-identified summaries safe for charts, reports, APIs, and
  MCP. These are `condition_summary.json`/`.csv` and
  `visualization_extract.csv`/`.json` (per-condition/family percentile
  distributions with no IDs).
- **metadata** — `manifest.json` (provenance and the bundle index).

CSV sidecars are written during the transition so non-R consumers do not need an
R session. Set `outputs.sidecars` to `false` in the spec to suppress the CSV
sidecars; the manifest, JSON condition summary, and visualization extract are
always written.

The R-object artifacts (`student_results`, `merged_long`) default to the `qs2`
format (`.qs2`), which is faster and smaller than `.rds` while remaining
losslessly convertible to RDS (`qs2::qs_to_rds()`). Read them in R with
`qs2::qs_read(path)`. To use base `.rds` instead, give the artifact an `.rds`
path or set its `format` to `"rds"`.

## Expected Local Artifacts

- `Data/WIDA_IN_Data_LONG_SGPc.Rdata` (you create this)
- `SGPc/specs/results/2025/manifest.json` (metadata)
- `SGPc/specs/results/2025/student_sgpc.qs2` (restricted; read with `qs2::qs_read()`)
- `SGPc/specs/results/2025/student_sgpc.csv` (restricted sidecar)
- `SGPc/specs/results/2025/condition_summary.json` (aggregate)
- `SGPc/specs/results/2025/condition_summary.csv` (aggregate sidecar)
- `SGPc/specs/results/2025/visualization_extract.csv` (aggregate)
- `SGPc/specs/results/2025/visualization_extract.json` (aggregate)
- `SGPc/specs/results/2025/WIDA_IN_Data_LONG_SGPc_2025.qs2` (restricted; LONG + `SGPC_<FAMILY>`)

The committed static spec is safe to commit (paths and condition metadata only).
The LONG data set and all `restricted` result artifacts contain student-level
data and must remain local/gitignored. Only `aggregate` and `metadata` artifacts
are appropriate for downstream visualizations, reports, APIs, and MCP.
