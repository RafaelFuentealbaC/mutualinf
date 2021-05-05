#' @import data.table
get_proportion <- function(data, within, by = NULL, total = NULL) {
  if (!is.null(by)) {
    p_by_within <- data[, list(p = sum(fw)), by = c(by, within)]
    p_by <- data[, list(p = sum(fw)), by = by]
    DT_p <- merge(p_by_within, p_by, by.x = by, by.y = by, sort = FALSE)
    DT_p <- DT_p[, list(p = p.x / p.y), by = c(by, within)]
    DT_p
  } else {
    p_within <- data[, list(p = sum(fw) / total), by = within]
    p_within
  }
}
