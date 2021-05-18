#' @title Prepare the data to use
#' @description Function that receive the data that later will be use to computes the index value and the
#' decompositions. Generates a \code{data.table} with the specificate entry variables.
#' @param data A data.frame.
#' @param vars A vector of variable names or vector of variable numbers contained in \code{data}.
#' @param fw Variable name or variable number contained in \code{data} correspondent to frecuency weight in the
#' variable combinations of the dataset. If this variable exists then the function will change his original name
#' to \code{fw}. If this variable no exists then the function will compute the frecuency weight given the
#' variable combinations of \code{vars} and will create a new variable called \code{fw}. By default is NULL.
#' @param col.order A variable name or vector of variables names contained in \code{vars}, or also, a variable
#' number or vector of variables numbers contained in \code{vars}. Defines the columns that will use to order
#' the dataset.
#' @return Returns a data.table.
#' @examples
#' \dontrun{
#' # Considering the variable names of 'data' and that exists a variable to 'fw'.
#' my_data <- prepare_data(data = DF_Seg_Chile, vars = c("csep", "etnia", "school", "comuna"), fw = "nobs")
#'
#' # Considering the variable numbers of 'data' and that exists a variable to 'fw'.
#' my_data <- prepare_data(data = DF_Seg_Chile, vars = c(4, 5, 2, 3), fw = 10)
#'
#' # Considering the variable names of 'data' and that no exists a variable to 'fw'.
#' my_data <- prepare_data(data = DF_Seg_Chile, vars = c("csep", "etnia", "school", "comuna"))
#'
#' # Using the 'col.order' option to order data according to 'csep' column.
#' my_data <- prepare_data(data = DF_Seg_Chile, vars = c("csep", "etnia", "school", "comuna"), fw = "nobs", col.order = "csep")
#'
#' # The class of the resultant object in all cases must be "data.table" "data.frame".
#' class(my_data)
#' }
#' @import data.table
#' @export
prepare_data <- function(data, vars, fw = NULL, col.order = NULL) {
  if ("data.frame" %in% class(data)) {
    if (nrow(data) == 0) stop("data.frame is empty")

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

  setattr(data, "vars", vars)
  setkey(data, NULL)
  data
}
