################################################################################
###
### SET ASIDE / DEFERRED: automatic SGPc spec generation from a panel.
###
### This prep/config automation is not part of the default 2025 SGPc workflow.
### The 2025 runner (WIDA_IN_SGPc_2025.R) consumes the committed static spec at
### SGPc/specs/wida-in-2025-sgpc-analysis-spec.json. Keep this here for when
### spec-driven generation becomes useful, after a few SGPc runs are in place.
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

source_wida_in_sgpc_builder <- function(root_dir = find_wida_in_root()) {
  builder_path <- file.path(root_dir, "SGPc", "build_wida_in_sgpc_panel.R")
  if (!exists("validate_wida_in_canonical_long", mode = "function")) {
    source(builder_path)
  }
  invisible(TRUE)
}

load_wida_in_sgpc_panel <- function(
  root_dir = find_wida_in_root(),
  panel_path = file.path("Data", "WIDA_IN_Data_LONG_PANEL_2025.Rdata"),
  object_name = "WIDA_IN_Data_LONG_PANEL_2025"
) {
  source_wida_in_sgpc_builder(root_dir)
  path <- file.path(root_dir, panel_path)

  if (!file.exists(path)) {
    stop(
      "SGPc panel file is missing: ",
      path,
      ". Run build_wida_in_sgpc_panel() first.",
      call. = FALSE
    )
  }

  env <- new.env(parent = emptyenv())
  load(path, envir = env)

  if (!exists(object_name, envir = env, inherits = FALSE)) {
    stop(
      "Expected panel object not found in ",
      path,
      ": ",
      object_name,
      call. = FALSE
    )
  }

  panel <- get(object_name, envir = env)
  validate_wida_in_canonical_long(panel, label = object_name)
  if (
    !"SGPC_VALID_CASE" %in% names(panel) ||
      !is.logical(panel$SGPC_VALID_CASE)
  ) {
    panel <- add_sgpc_valid_case(panel)
    assign(object_name, panel, envir = env)
    save(list = object_name, file = path, envir = env)
  }
  as.data.frame(panel, stringsAsFactors = FALSE)
}

valid_wida_in_sgpc_rows <- function(panel, content_area = "READING") {
  keep <- as.character(panel$VALID_CASE) == "VALID_CASE" &
    as.character(panel$CONTENT_AREA) == content_area &
    !is.na(panel$ID) &
    nzchar(as.character(panel$ID)) &
    !is.na(panel$SCALE_SCORE) &
    !is.na(panel$YEAR) &
    !is.na(panel$GRADE)

  panel[keep, , drop = FALSE]
}

linked_count_for_condition <- function(
  data,
  prior_year,
  current_year,
  prior_grade,
  current_grade
) {
  prior_ids <- unique(as.character(data$ID[
    as.character(data$YEAR) == prior_year &
      as.character(data$GRADE) == prior_grade
  ]))
  current_ids <- unique(as.character(data$ID[
    as.character(data$YEAR) == current_year &
      as.character(data$GRADE) == current_grade
  ]))

  length(intersect(prior_ids, current_ids))
}

build_wida_in_sgpc_conditions <- function(
  panel,
  terminal_year = "2025",
  content_area = "READING",
  spans = c(1L),
  min_linked = 1L
) {
  data <- valid_wida_in_sgpc_rows(panel, content_area = content_area)
  terminal_year <- as.character(terminal_year)
  terminal_year_num <- as.integer(terminal_year)
  spans <- as.integer(spans)

  if (any(is.na(spans)) || any(spans < 1L)) {
    stop("spans must be positive integers", call. = FALSE)
  }

  current_grades <- sort(unique(as.integer(
    data$GRADE[as.character(data$YEAR) == terminal_year]
  )))
  current_grades <- current_grades[!is.na(current_grades)]

  conditions <- list()
  for (span in spans) {
    prior_year <- as.character(terminal_year_num - span)
    for (current_grade_num in current_grades) {
      prior_grade_num <- current_grade_num - span
      if (prior_grade_num < 0L) {
        next
      }

      prior_grade <- as.character(prior_grade_num)
      current_grade <- as.character(current_grade_num)
      linked_count <- linked_count_for_condition(
        data,
        prior_year = prior_year,
        current_year = terminal_year,
        prior_grade = prior_grade,
        current_grade = current_grade
      )

      if (linked_count < min_linked) {
        next
      }

      condition_id <- paste0(
        content_area,
        "_",
        prior_year,
        "_",
        terminal_year,
        "_G",
        prior_grade,
        "_G",
        current_grade
      )

      conditions[[condition_id]] <- list(
        condition_id = condition_id,
        content_area = content_area,
        panel_years = c(prior_year, terminal_year),
        grade_sequence = c(prior_grade, current_grade),
        span = span,
        reference_population = "state_valid_cases"
      )
    }
  }

  if (length(conditions) == 0L) {
    stop(
      "No SGPc conditions were generated for terminal year ",
      terminal_year,
      ". Check panel years, grades, and linked IDs.",
      call. = FALSE
    )
  }

  unname(conditions)
}

build_wida_in_sgpc_spec <- function(
  panel,
  analysis_id = "wida-in-2025-sgpc-percentiles",
  terminal_year = "2025",
  content_area = "READING",
  spans = c(1L),
  long_data = "../../Data/WIDA_IN_Data_LONG_PANEL_2025.Rdata",
  object_name = "WIDA_IN_Data_LONG_PANEL_2025"
) {
  list(
    schema_version = "sgpc.analysis.v0.1",
    analysis_id = analysis_id,
    mode = "norm_referenced_sgpc",
    input = list(
      long_data = long_data,
      object_name = object_name
    ),
    columns = list(
      id = "ID",
      content_area = "CONTENT_AREA",
      year = "YEAR",
      grade = "GRADE",
      score = "SCALE_SCORE",
      valid_case = "SGPC_VALID_CASE"
    ),
    analyses = build_wida_in_sgpc_conditions(
      panel,
      terminal_year = terminal_year,
      content_area = content_area,
      spans = spans
    ),
    copulas = list(
      empirical = c("raw", "bernstein"),
      parametric = c("gaussian", "t", "frank", "gumbel", "clayton")
    ),
    outputs = list(
      directory = file.path("results", terminal_year),
      manifest = file.path("results", terminal_year, "manifest.json"),
      student_results = file.path("results", terminal_year, "student_sgpc.rds"),
      condition_summary = file.path(
        "results",
        terminal_year,
        "condition_summary.json"
      )
    )
  )
}

write_wida_in_sgpc_spec <- function(
  spec,
  root_dir = find_wida_in_root(),
  spec_path = file.path(
    "SGPc",
    "specs",
    "wida-in-2025-sgpc-analysis-spec.json"
  ),
  validate = TRUE
) {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("The jsonlite package is required to write SGPc specs.", call. = FALSE)
  }

  path <- file.path(root_dir, spec_path)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(spec, path, auto_unbox = TRUE, pretty = TRUE)

  if (isTRUE(validate)) {
    if (!requireNamespace("SGPc", quietly = TRUE)) {
      stop(
        "The SGPc package is required to validate generated specs.",
        call. = FALSE
      )
    }
    if (!"read_sgpc_spec" %in% getNamespaceExports("SGPc")) {
      stop(
        "The available SGPc package does not export read_sgpc_spec(). ",
        "Install the current SGPc package or set SGPC_PACKAGE_PATH before ",
        "running the 2025 workflow.",
        call. = FALSE
      )
    }
    SGPc::read_sgpc_spec(path)
  }

  path
}

generate_wida_in_sgpc_spec <- function(
  root_dir = find_wida_in_root(),
  panel_path = file.path("Data", "WIDA_IN_Data_LONG_PANEL_2025.Rdata"),
  panel_object = "WIDA_IN_Data_LONG_PANEL_2025",
  spec_path = file.path(
    "SGPc",
    "specs",
    "wida-in-2025-sgpc-analysis-spec.json"
  ),
  terminal_year = "2025",
  content_area = "READING",
  spans = c(1L),
  validate = TRUE
) {
  source_wida_in_sgpc_builder(root_dir)
  panel <- load_wida_in_sgpc_panel(
    root_dir = root_dir,
    panel_path = panel_path,
    object_name = panel_object
  )
  spec <- build_wida_in_sgpc_spec(
    panel,
    terminal_year = terminal_year,
    content_area = content_area,
    spans = spans,
    long_data = file.path("..", "..", panel_path),
    object_name = panel_object
  )
  path <- write_wida_in_sgpc_spec(
    spec,
    root_dir = root_dir,
    spec_path = spec_path,
    validate = validate
  )

  list(
    path = path,
    analysis_id = spec$analysis_id,
    condition_count = length(spec$analyses),
    spans = spans,
    terminal_year = terminal_year
  )
}
