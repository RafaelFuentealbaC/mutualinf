#' @title Prepare the data to be used by \code{mutual} function
#' @description Function that receives the data that later will be used to computes the index value and the
#' decompositions. Generates a \code{data.table} with the entry variables.
#' @param data An object of class "data.frame". The data expected is microdata or frequency weight data
#' for each combination of variables. The variables must be of "factor" class.
#' @param vars A vector of variable names or vector of variable numbers contained in \code{data}.
#' @param fw Variable name or variable number contained in \code{data} that contains frecuency weight for
#' each combination of variables of the dataset. If this variable exists then the function will change its
#' original name to \code{fw}. If this variable does not exist or is NULL, then the function will compute the
#' frecuency weight given the combination of variables of \code{vars} and will create a new variable called
#' \code{fw}. By default is NULL.
#' @param col.order A variable name or vector of variables names contained in \code{vars}, or also, a variable
#' number or vector of variables numbers contained in \code{vars}. Defines the columns that will use to sort
#' the dataset.
#' @return Returns a \code{data.table} of class "data.table" "data.frame" "mutual.data".
#' @examples
#' \dontrun{
#' # Using some variable names in 'data' with explicit 'fw'.
#' my_data <- prepare_data(data = DF_Seg_Chile, vars = c("csep", "ethnicity", "school", "commune"),
#' fw = "nobs")
#'
#' # Using some column numbers in 'data' and explicit 'fw' as another column number.
#' my_data <- prepare_data(data = DF_Seg_Chile, vars = c(4, 5, 2, 3), fw = 11)
#'
#' # Using some variable names in 'data' and 'fw' does not exist (in this case, the new 'fw' will
#' # be equal to 1 for all variable combinations as 'data' already has a frequency weights variable)
#' my_data <- prepare_data(data = DF_Seg_Chile, vars = c("csep", "ethnicity", "school", "commune"))
#'
#' # Using the 'col.order' option to sort data according to the 'csep' column.
#' my_data <- prepare_data(data = DF_Seg_Chile, vars = c("csep", "ethnicity", "school", "commune"),
#' fw = "nobs", col.order = "csep")
#'
#' # The class of the resultant object in all cases must be "data.table", "data.frame" and
#' # "mutual.data".
#' class(my_data)
#' }
#' @import data.table
#' @export
prepare_data <- function(data, vars, fw = NULL, col.order = NULL) {
  if ("data.frame" %in% class(data)) {
    if (nrow(data) == 0) stop("data.frame is empty")

    data[, vars] <- lapply(data[, vars], as.factor)
    vars_exists <- c(vars, fw)

    if (is.numeric(vars_exists)) {
      if (!is.null(col.order)) {
        col_order_no_exists <- col.order[!col.order %in% vars_exists]
        if (length(col_order_no_exists) > 0) stop(paste("Variable(s)", col_order_no_exists, "not in data.frame"))
      }

      if (max(vars_exists) > ncol(data) | min(vars_exists) < 1) stop("One or more selected columns are outside of the data.frame")
      vars_exists <- names(data[, vars_exists])
    }

    vars_no_exists <- vars_exists[!vars_exists %in% names(data)]
    if (length(vars_no_exists) > 0) {
      vars_no_exists <- paste(vars_no_exists, collapse = ", ")
      stop(paste("Variable(s)", vars_no_exists, "not in data.frame"))
    }
  } else {
    stop("Not a data.frame")
  }

  data <- as.data.table(data)

  if (is.numeric(vars)) vars <- names(data[, ..vars])

  if (!is.null(fw)) {
    fw <- names(data[, ..fw])
    setnames(x = data, old = fw, new = "fw")
  } else {
    data[, fw := 1]
  }

  data <- data[fw > 0, list(fw = sum(fw)), by = vars]
  if (!is.null(col.order)) {
    if (is.numeric(col.order)) col.order <- data[, colnames(.SD), .SDcols = col.order]
    setorderv(x = data, cols = col.order)
  }

  class(data) <- c(class(data), "mutual.data")
  setattr(data, "vars", vars)
  setkey(data, NULL)
  data
}
