load_wida_in_sgpc_package <- function(
  required = c("run_sgpc_analysis")
) {
  sgpc_path <- Sys.getenv(
    "SGPC_PACKAGE_PATH",
    "/Users/conet/GitHub/dataimago/SGPc/SGPc-rpkg/SGPc"
  )

  if (dir.exists(sgpc_path) && requireNamespace("devtools", quietly = TRUE)) {
    devtools::load_all(sgpc_path, quiet = TRUE)
  }

  if (!requireNamespace("SGPc", quietly = TRUE)) {
    stop(
      "The SGPc package must be installed before running WIDA_IN SGPc analyses.",
      call. = FALSE
    )
  }

  missing <- setdiff(required, getNamespaceExports("SGPc"))
  if (length(missing) > 0L) {
    stop(
      "The available SGPc package is missing required export(s): ",
      paste(missing, collapse = ", "),
      ". Install the current SGPc package or set SGPC_PACKAGE_PATH to the ",
      "local checkout.",
      call. = FALSE
    )
  }

  invisible(TRUE)
}

run_wida_in_sgpc <- function(
  spec_path = "SGPc/specs/wida-in-2025-sgpc-analysis-spec.json",
  steps = NULL,
  parallel = NULL
) {
  load_wida_in_sgpc_package()

  SGPc::run_sgpc_analysis(
    spec_path = spec_path,
    steps = steps,
    parallel = parallel
  )
}

if (interactive()) {
  message(
    "Loaded run_wida_in_sgpc(). To run the 2025 workflow, use ",
    "source('SGPc/WIDA_IN_SGPc_2025.R') from the WIDA_IN root or ",
    "source('WIDA_IN_SGPc_2025.R') from SGPc/."
  )
}
