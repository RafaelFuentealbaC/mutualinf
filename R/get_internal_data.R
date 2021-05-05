#' @import data.table
get_internal_data <- function(data, vars) {
  data <- data[, list(fw = sum(fw)), by = vars]
  data
}
