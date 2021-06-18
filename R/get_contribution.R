#' @include get_internal_data.R
#' @include mutual.R
NULL
#' @import data.table
#' @import parallel
get_contribution <- function(data, group, unit, within = NULL, by = NULL, p = NULL, component = NULL, contribution, cores = NULL) {
  data_contribution <- split(data, by = c(by, within))

  if (!is.null(cores)) {
    comp_d <- mclapply(X = data_contribution, function(d) {
      M_contribution <- mclapply(X = contribution, function(c) {
        if (c %in% group) c_tmp <- group[!group %in% c]
        else c_tmp <- unit[!unit %in% c]
        data_tmp <- get_internal_data(data = d, vars = c(group, unit, c_tmp))
        DT_res <- rev(mutual(data = data_tmp, group = group, unit = unit, within = c_tmp))
        DT_res[, 1]
      }, mc.cores = cores)
      unlist(M_contribution, use.names = FALSE)
    }, mc.cores = cores)
  } else {
    comp_d <- lapply(X = data_contribution, function(d) {
      M_contribution <- lapply(X = contribution, function(c) {
        if (c %in% group) c_tmp <- group[!group %in% c]
        else c_tmp <- unit[!unit %in% c]
        data_tmp <- get_internal_data(data = d, vars = c(group, unit, c_tmp))
        DT_res <- rev(mutual(data = data_tmp, group = group, unit = unit, within = c_tmp))
        DT_res[, 1]
      })
      unlist(M_contribution, use.names = FALSE)
    })
  }
  DT_comp_d <- transpose(as.data.table(comp_d), keep.names = NULL)
  names(DT_comp_d) <- contribution

  if (is.null(within)) {
    DT_contribution <- cbind(M = component, DT_comp_d)
    DT_int <- DT_comp_d[, list(sum_d = rowSums(.SD)), .SDcols = names(DT_comp_d)]
    DT_int <- cbind(M = DT_contribution$M, DT_int)
    DT_int <- DT_int[, list(interaction = M - sum_d), by = list(row.names(DT_int))][, -1]
    DT_contribution <- cbind(DT_contribution[, -"M"], DT_int)
    DT_contribution
  } else {
    DT_contribution <- cbind(p, within = component, DT_comp_d)
    DT_int <- DT_comp_d[, list(sum_d = rowSums(.SD)), .SDcols = names(DT_comp_d)]
    DT_int <- cbind(M = DT_contribution$within, DT_int)
    DT_int <- DT_int[, list(interaction = M - sum_d), by = list(row.names(DT_int))][, -1]
    DT_contribution <- cbind(DT_contribution, DT_int)
    DT_contribution
  }
}
