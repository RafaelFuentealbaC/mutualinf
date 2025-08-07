#' @title Prepares the data to be used by the \code{mutual} function
#'
#' @description
#' Takes a tabular object (micro-data or a frequency table) and returns a
#' \code{data.table} ready for \code{mutual}.
#' The output
#' * stores every analytical variable as a \code{factor};
#' * holds the weight variable under the unified name \code{fw} (numeric);
#' * aggregates identical combinations (summing their weights) and drops rows
#'   where \code{fw == 0}.
#'
#' @param data A tabular object: \code{data.frame}, \code{data.table} or
#'   \code{tibble}.
#' @param vars A vector of column names or indices, or the literal
#'   \code{"all_vars"} to select every column except \code{fw}.
#' @param fw   (optional) Name or index of the frequency-weight column.
#'   Must reference exactly one column. If \code{NULL}, a new variable
#'   \code{fw = 1} is created.
#' @param col.order (optional) Column(s) used to sort the final table;
#'   must be included in \code{vars}. Accepts names or indices.
#'
#' @return A \code{data.table} with classes \code{"mutual.data"},
#'   \code{"data.frame"} and \code{"data.table"}.
#'   The analytical variables are stored in the attribute \code{"vars"};
#'   the key is cleared.
#'
#' @examples
#' \donttest{
#' md <- prepare_data(
#'   DF_Seg_Chile,
#'   vars = c("csep", "ethnicity", "school", "district"),
#'   fw   = "nobs"
#' )
#' md <- prepare_data(DF_Seg_Chile, vars = "all_vars")
#' class(md)
#' }
#'
#' @import data.table
#' @export
prepare_data <- function(data, vars, fw = NULL, col.order = NULL) {

  ## ---------------------------------------------------------------
  ## 1  Basic checks
  ## ---------------------------------------------------------------
  if (!"data.frame" %in% class(data))
    stop("Not a data.frame, data.table, or tibble.")
  if (nrow(data) == 0)
    stop("data.frame is empty.")

  ## Ensure data.table behaviour
  if (!"data.table" %in% class(data))
    data <- as.data.table(data)

  ## ---------------------------------------------------------------
  ## 2  Helper: convert numeric indices to names
  ## ---------------------------------------------------------------
  idx_to_name <- function(x, ref) {
    if (is.null(x))        return(NULL)
    if (is.character(x))   return(x)
    if (is.numeric(x)) {
      if (any(x < 1L | x > length(ref)))
        stop("Column index out of bounds 1 ...", length(ref), ".")
      return(ref[x])
    }
    stop("Arguments 'vars', 'fw', and 'col.order' must be names or indices.")
  }

  ## ---------------------------------------------------------------
  ## 3  Standardise arguments
  ## ---------------------------------------------------------------
  fw  <- idx_to_name(fw, names(data))
  if (length(fw) > 1L)
    stop("'fw' must reference a single column.")

  if (identical(vars, "all_vars"))
    vars <- names(data)

  vars <- idx_to_name(vars, names(data))

  if (!is.null(col.order))
    col.order <- idx_to_name(col.order, vars)

  ## Columns must exist
  miss <- setdiff(c(vars, fw, col.order), names(data))
  if (length(miss))
    stop("Column(s) not found in 'data': ", paste(miss, collapse = ", "))

  ## ---------------------------------------------------------------
  ## 4  Handle the weight column
  ## ---------------------------------------------------------------
  if (is.null(fw)) {                     # no weight supplied
    data[, fw := 1L]                     # create numeric weights
  } else {                               # weight supplied
    setnames(data, fw, "fw")             # normalise name
  }

  ## Always drop 'fw' from analytical vars
  vars <- setdiff(vars, "fw")

  ## Guarantee fw is numeric
  if (is.factor(data$fw))
    data[, fw := as.numeric(as.character(fw))]
  if (!is.numeric(data$fw))
    stop("'fw' must be numeric or coercible to numeric.")

  ## ---------------------------------------------------------------
  ## 5  Convert analytical variables to factor
  ## ---------------------------------------------------------------
  data[, (vars) := lapply(.SD, as.factor), .SDcols = vars]

  ok <- vapply(data[, ..vars], inherits, logical(1L), "factor")
  if (any(!ok))
    stop("After conversion, the following variables are not 'factor': ",
         paste(vars[!ok], collapse = ", "))

  ## ---------------------------------------------------------------
  ## 6  Aggregate and order
  ## ---------------------------------------------------------------
  data <- data[fw > 0, .(fw = sum(fw)), by = vars]

  if (!is.null(col.order))
    setorderv(data, col.order)

  ## ---------------------------------------------------------------
  ## 7  Return result
  ## ---------------------------------------------------------------
  setattr(data, "vars", vars)
  class(data) <- c("mutual.data", class(data))
  setkey(data, NULL)

  data
}
