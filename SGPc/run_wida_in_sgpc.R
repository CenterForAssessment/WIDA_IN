run_wida_in_sgpc <- function(
  spec_path = "SGPc/specs/wida-in-2025-sgpc-analysis-spec.template.json",
  steps = NULL
) {
  if (!requireNamespace("SGPc", quietly = TRUE)) {
    stop(
      "The SGPc package must be installed before running WIDA_IN SGPc analyses.",
      call. = FALSE
    )
  }

  SGPc::run_sgpc_analysis(spec_path = spec_path, steps = steps)
}
