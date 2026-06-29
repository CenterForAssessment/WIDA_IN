################################################################################
###
### SET ASIDE / DEFERRED: multi-year canonical LONG panel builder.
###
### This prep/config automation is not part of the default 2025 SGPc workflow.
### The 2025 runner (WIDA_IN_SGPc_2025.R) consumes a single canonical LONG data
### set plus the committed static spec. Keep this here for when spec-driven prep
### becomes useful, after a few SGPc runs are in place.
###
################################################################################

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

load_wida_in_long_year <- function(year, root_dir = find_wida_in_root()) {
  object_name <- paste0("WIDA_IN_Data_LONG_", year)
  path <- file.path(root_dir, "Data", paste0(object_name, ".Rdata"))

  if (!file.exists(path)) {
    stop(
      "Canonical LONG file is missing for ",
      year,
      ": ",
      path,
      ". Run WIDA_IN_Data_LONG_",
      year,
      ".R first.",
      call. = FALSE
    )
  }

  env <- new.env(parent = emptyenv())
  load(path, envir = env)

  if (!exists(object_name, envir = env, inherits = FALSE)) {
    stop(
      "Expected object not found in ",
      path,
      ": ",
      object_name,
      call. = FALSE
    )
  }

  data <- get(object_name, envir = env)
  validate_wida_in_canonical_long(data, label = object_name)
  as.data.frame(data, stringsAsFactors = FALSE)
}

validate_wida_in_canonical_long <- function(
  data,
  label = "canonical LONG data"
) {
  required <- c(
    "VALID_CASE",
    "CONTENT_AREA",
    "YEAR",
    "GRADE",
    "ID",
    "SCALE_SCORE"
  )
  missing <- setdiff(required, names(data))

  if (length(missing) > 0L) {
    stop(
      label,
      " is missing required column(s): ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }

  invisible(data)
}

add_sgpc_valid_case <- function(data) {
  data$SGPC_VALID_CASE <- as.character(data$VALID_CASE) == "VALID_CASE"
  data
}

build_wida_in_sgpc_panel <- function(
  years = 2023:2025,
  root_dir = find_wida_in_root(),
  output_path = file.path("Data", "WIDA_IN_Data_LONG_PANEL_2025.Rdata"),
  output_object = "WIDA_IN_Data_LONG_PANEL_2025",
  overwrite = TRUE
) {
  if (!is.numeric(years) && !is.character(years)) {
    stop("years must be a numeric or character vector", call. = FALSE)
  }

  years <- as.character(years)
  output_file <- file.path(root_dir, output_path)

  if (file.exists(output_file) && !isTRUE(overwrite)) {
    stop("Panel output already exists: ", output_file, call. = FALSE)
  }

  panel <- do.call(
    rbind,
    lapply(years, load_wida_in_long_year, root_dir = root_dir)
  )
  row.names(panel) <- NULL
  panel <- add_sgpc_valid_case(panel)
  validate_wida_in_canonical_long(panel, label = output_object)

  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
  assign(output_object, panel)
  save(list = output_object, file = output_file)

  list(
    path = output_file,
    object_name = output_object,
    years = years,
    row_count = nrow(panel),
    valid_count = sum(
      as.character(panel$VALID_CASE) == "VALID_CASE",
      na.rm = TRUE
    )
  )
}
