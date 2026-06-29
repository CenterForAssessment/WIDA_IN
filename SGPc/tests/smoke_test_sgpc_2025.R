################################################################################
###
### Synthetic smoke test for the WIDA_IN 2025 SGPc pipeline.
###
### Exercises the live operational path: a single canonical LONG data set (with
### the canonical VALID_CASE/INVALID_CASE string convention) plus a static
### declarative v0.2 analysis spec, run through SGPc::run_sgpc_analysis(),
### including the merge-back-into-LONG output. Uses only synthetic data; never
### reads or writes real WIDA microdata.
###
################################################################################

load_sgpc_for_smoke_test <- function() {
  sgpc_path <- Sys.getenv(
    "SGPC_PACKAGE_PATH",
    "/Users/conet/GitHub/dataimago/SGPc/SGPc-rpkg/SGPc"
  )

  if (dir.exists(sgpc_path) && requireNamespace("devtools", quietly = TRUE)) {
    devtools::load_all(sgpc_path, quiet = TRUE)
    return(invisible(TRUE))
  }

  if (requireNamespace("SGPc", quietly = TRUE)) {
    return(invisible(TRUE))
  }

  stop(
    "Install SGPc or set SGPC_PACKAGE_PATH to the local SGPc package checkout.",
    call. = FALSE
  )
}

make_synthetic_long <- function() {
  prior <- data.frame(
    ID = sprintf("S%03d", 1:8),
    CONTENT_AREA = "READING",
    YEAR = "2024",
    GRADE = "1",
    SCALE_SCORE = seq(200, 270, length.out = 8),
    ACHIEVEMENT_LEVEL = "WIDA Level 3",
    VALID_CASE = "VALID_CASE",
    stringsAsFactors = FALSE
  )
  current <- data.frame(
    ID = sprintf("S%03d", 1:8),
    CONTENT_AREA = "READING",
    YEAR = "2025",
    GRADE = "2",
    SCALE_SCORE = seq(220, 290, length.out = 8),
    ACHIEVEMENT_LEVEL = "WIDA Level 3",
    VALID_CASE = "VALID_CASE",
    stringsAsFactors = FALSE
  )
  invalid <- data.frame(
    ID = "S999",
    CONTENT_AREA = "READING",
    YEAR = "2025",
    GRADE = "2",
    SCALE_SCORE = NA_real_,
    ACHIEVEMENT_LEVEL = NA_character_,
    VALID_CASE = "INVALID_CASE",
    stringsAsFactors = FALSE
  )
  rbind(prior, current, invalid)
}

write_smoke_spec <- function(spec_dir) {
  spec <- list(
    schema_version = "sgpc.analysis.v0.2",
    analysis_id = "wida-in-smoke-sgpc",
    mode = "norm_referenced_sgpc",
    input = list(
      long_data = "WIDA_IN_Data_LONG_SGPc.Rdata",
      object_name = "WIDA_IN_Data_LONG_SGPc",
      expectations = list(
        schema_version = "sgpc.input.v0.1",
        years = c("2024", "2025"),
        grades = c("1", "2"),
        valid_case_values = c("VALID_CASE", "INVALID_CASE")
      )
    ),
    columns = list(
      id = "ID",
      content_area = "CONTENT_AREA",
      year = "YEAR",
      grade = "GRADE",
      score = "SCALE_SCORE",
      valid_case = "VALID_CASE"
    ),
    design = list(
      content_areas = c("READING"),
      reference_population = "state_valid_cases",
      grade_progression = "typical",
      grades = list(min = 1, max = 2),
      years = list(min = "2024", max = "2025"),
      spans = c(1),
      terminal_years = c("2025"),
      condition_id_template = paste0(
        "{content_area}_{prior_year}_{current_year}_",
        "G{prior_grade}_G{current_grade}"
      )
    ),
    copulas = list(
      empirical = c("raw", "bernstein"),
      parametric = c("gaussian", "t", "frank", "gumbel", "clayton")
    ),
    outputs = list(
      directory = "results",
      manifest = "results/manifest.json",
      student_results = "results/student_sgpc.rds",
      condition_summary = "results/condition_summary.json",
      merged_long = "results/long_with_sgpc.rds"
    )
  )

  spec_path <- file.path(spec_dir, "smoke-spec.json")
  jsonlite::write_json(spec, spec_path, auto_unbox = TRUE, pretty = TRUE)
  spec_path
}

run_smoke_test <- function() {
  load_sgpc_for_smoke_test()

  spec_dir <- tempfile("wida-in-sgpc-smoke-")
  dir.create(spec_dir, recursive = TRUE)

  WIDA_IN_Data_LONG_SGPc <- make_synthetic_long()
  save(
    WIDA_IN_Data_LONG_SGPc,
    file = file.path(spec_dir, "WIDA_IN_Data_LONG_SGPc.Rdata")
  )

  spec_path <- write_smoke_spec(spec_dir)
  run <- SGPc::run_sgpc_analysis(spec_path)
  output_validation <- SGPc::validate_sgpc_results(
    run$result,
    index = run$index
  )

  merged <- readRDS(file.path(spec_dir, "results", "long_with_sgpc.rds"))
  current <- merged[merged$YEAR == "2025" & merged$VALID_CASE == "VALID_CASE", ]
  prior <- merged[merged$YEAR == "2024", ]

  stopifnot(identical(run$spec$schema_version, "sgpc.analysis.v0.2"))
  stopifnot(length(run$spec$analyses) == 1L)
  stopifnot(identical(
    run$spec$analyses[[1]]$condition_id,
    "READING_2024_2025_G1_G2"
  ))
  stopifnot(length(run$spec$copulas$parametric) == 5L)
  stopifnot(run$manifest$row_counts$student_results > 0L)
  stopifnot(identical(
    run$manifest$contracts$analysis$schema_version,
    "sgpc.analysis.v0.2"
  ))
  stopifnot(identical(output_validation$validation$status, "passed"))
  stopifnot(identical(run$index$linked_count, 8L))
  stopifnot("SGPC_GAUSSIAN" %in% names(merged))
  stopifnot(nrow(merged) == nrow(WIDA_IN_Data_LONG_SGPc))
  stopifnot(!anyNA(current$SGPC_GAUSSIAN))
  stopifnot(all(is.na(prior$SGPC_GAUSSIAN)))

  message("Synthetic WIDA_IN SGPc smoke test passed")
  invisible(list(spec = spec_path, run = run, merged = merged))
}

run_smoke_test()
