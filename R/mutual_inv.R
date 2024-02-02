#' @include M_within.R
#' @include M.R
#' @include get_internal_data.R
#' @include mutual.R
NULL
#' @import data.table
mutual_inv <- function(data, group, unit, within = NULL, by = NULL, contribution.from = NULL, components = FALSE, cores = NULL) {

  if (is.numeric(group)) group <- data[, colnames(.SD), .SDcols = group]
  if (is.numeric(unit)) unit <- data[, colnames(.SD), .SDcols = unit]
  if (is.numeric(within)) within <- data[, colnames(.SD), .SDcols = within]
  if (is.numeric(by)) by <- data[, colnames(.SD), .SDcols = by]
  if (is.numeric(contribution.from)) contribution.from <- data[, colnames(.SD), .SDcols = contribution.from]

  if (!is.null(within)) {
    M_within(data = data, group = group, unit = unit, within = within, by = by, contribution.from = contribution.from, components = components, cores = cores)
  } else {
    M(data = data, group = group, unit = unit, by = by, contribution.from = contribution.from, cores = cores)
  }

}


