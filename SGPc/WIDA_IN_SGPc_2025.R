################################################################################
###
### Script for calculating SGPc percentiles for 2024-2025 WIDA/ACCESS Indiana
###
### Prerequisite: a single canonical LONG data set produced by the existing
### WIDA_IN data-prep scripts, saved as
### Data/WIDA_IN_Data_LONG_SGPc.Rdata (object WIDA_IN_Data_LONG_SGPc) with
### columns VALID_CASE, CONTENT_AREA, YEAR, GRADE, SCALE_SCORE,
### ACHIEVEMENT_LEVEL, ID and covering the analysis years (e.g. 2024 and 2025).
###
### This runner reads the committed static spec and calls SGPc. It does NOT
### build panels or generate specs; that prep/config automation is set aside in
### build_wida_in_sgpc_panel.R and generate_wida_in_sgpc_spec.R for later.
###
################################################################################

if (!exists("find_wida_in_root", mode = "function")) {
  find_wida_in_root <- function(start = getwd()) {
    current <- normalizePath(start, mustWork = TRUE)

    repeat {
      if (
        file.exists(file.path(current, "WIDA_IN_Data_LONG_2025.R")) &&
          dir.exists(file.path(current, "Data"))
      ) {
        return(current)
      }

      parent <- dirname(current)
      if (identical(parent, current)) {
        stop(
          "Could not find WIDA_IN master directory from ",
          start,
          call. = FALSE
        )
      }
      current <- parent
    }
  }
}
source(
  file.path(find_wida_in_root(), "SGPc", "run_wida_in_sgpc.R"),
  local = FALSE
)

run_wida_in_sgpc_2025 <- function(
  spec_path = file.path(
    "SGPc",
    "specs",
    "wida-in-2025-sgpc-analysis-spec.json"
  ),
  steps = NULL,
  root_dir = find_wida_in_root(),
  parallel = NULL
) {
  load_wida_in_sgpc_package(
    required = c("read_sgpc_spec", "run_sgpc_analysis", "merge_sgpc_into_long")
  )

  spec_file <- file.path(root_dir, spec_path)
  run <- run_wida_in_sgpc(
    spec_path = spec_file,
    steps = steps,
    parallel = parallel
  )
  manifest <- run$manifest

  message("WIDA_IN SGPc 2025 complete")
  message("  Spec: ", spec_file)
  message("  Manifest: ", run$paths$manifest)
  message("  Merged LONG: ", run$paths$merged_long %||% "<none>")
  message("  Conditions: ", length(manifest$conditions))
  message("  Student result rows: ", manifest$row_counts$student_results)
  message(
    "  Parallel: ",
    manifest$parallel$engine,
    " (workers: ",
    manifest$parallel$workers %||% 1L,
    ")"
  )

  invisible(run)
}

`%||%` <- function(x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}

WIDA_IN_SGPc_2025 <- run_wida_in_sgpc_2025()
