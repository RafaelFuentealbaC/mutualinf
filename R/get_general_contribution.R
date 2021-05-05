#' @import data.table
#' @import parallel
get_general_contribution <- function(DT_contribution, contribution, by = NULL, cores = NULL) {
  if (!is.null(by)) {
    if (!is.null(cores)) DT_general_contribution <- DT_contribution[, mclapply(X = .SD, function(i) return(sum(p %*% i)), mc.cores = cores), .SDcols = c(contribution, "interaction"), by = by][, -1:-length(by)]
    else DT_general_contribution <- DT_contribution[, lapply(.SD, function(i) return(sum(p %*% i))), .SDcols = c(contribution, "interaction"), by = by][, -1:-length(by)]
  } else {
    if (!is.null(cores)) DT_general_contribution <- DT_contribution[, mclapply(X = .SD, function(i) return(sum(p %*% i)), mc.cores = cores), .SDcols = c(contribution, "interaction")]
    else DT_general_contribution <- DT_contribution[, lapply(.SD, function(i) return(sum(p %*% i))), .SDcols = c(contribution, "interaction")]
  }
  setnames(x = DT_general_contribution, old = colnames(DT_general_contribution[, -"interaction"]), new = paste0("C_", contribution))
  DT_general_contribution
}
