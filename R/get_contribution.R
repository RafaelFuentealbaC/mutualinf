#' @include get_internal_data.R
NULL
#' @import data.table
#' @import parallel
#' @import future.apply
get_contribution <- function(data, group, unit, within = NULL, by = NULL, component = NULL, contribution, cores = NULL, iterm = NULL) {
  data_contribution <- split(data, by = c(by, within))
  id_data_contribution <- names(data_contribution)
  DT_id_data_contribution <- data.table(do.call(rbind, strsplit(x = id_data_contribution, split = "\\.")))
  setnames(x = DT_id_data_contribution, old = colnames(DT_id_data_contribution), new = c(by, within))

  if (!is.null(cores)) {
    if ((tolower(Sys.info()["sysname"]) == "windows") || (cores <= 6)) {
      plan(multisession, workers = cores)
      comp_d <- future_lapply(data_contribution, function(d) {
        M_contribution <- lapply(contribution, function(c) {
          if (c %in% group) c_tmp <- group[!group %in% c]
          else c_tmp <- unit[!unit %in% c]
          data_tmp <- get_internal_data(data = d, vars = c(group, unit, c_tmp))
          DT_res <- rev(M_within_inv(data = data_tmp, group = group, unit = unit, within = c_tmp))
          DT_res[, 1]
        })
        unlist(M_contribution, use.names = FALSE)

      }, future.seed = NULL)
      plan(sequential)
    } else {
      comp_d <- mclapply(X = data_contribution, function(d) {
        M_contribution <- mclapply(X = contribution, function(c) {
          if (c %in% group) c_tmp <- group[!group %in% c]
          else c_tmp <- unit[!unit %in% c]
          data_tmp <- get_internal_data(data = d, vars = c(group, unit, c_tmp))
          DT_res <- rev(M_within_inv(data = data_tmp, group = group, unit = unit, within = c_tmp))
          DT_res[, 1]
        }, mc.cores = cores)
        unlist(M_contribution, use.names = FALSE)
      }, mc.cores = cores)
    }
  } else {
    comp_d <- lapply(data_contribution, function(d) {
      M_contribution <- lapply(contribution, function(c) {
        if (c %in% group) c_tmp <- group[!group %in% c]
        else c_tmp <- unit[!unit %in% c]
        data_tmp <- get_internal_data(data = d, vars = c(group, unit, c_tmp))
        DT_res <- rev(M_within_inv(data = data_tmp, group = group, unit = unit, within = c_tmp))
        DT_res[, 1]
      })
      unlist(M_contribution, use.names = FALSE)
    })
  }
  DT_comp_d <- transpose(as.data.table(comp_d), keep.names = NULL)
  names(DT_comp_d) <- contribution
  DT_comp_d <- cbind(DT_id_data_contribution, DT_comp_d)
  DT_general <- merge(x = component, y = DT_comp_d, by = c(by, within), sort = FALSE)

  if (is.null(within)) {
    DT_contribution <- data.table(M = DT_general$M, DT_general[, ..contribution])
    if (isTRUE(iterm)) {
      DT_int <- DT_contribution[, list(sum_d = rowSums(.SD)), .SDcols = contribution]
      DT_int <- cbind(M = DT_contribution$M, DT_int)
      DT_int <- DT_int[, list(interaction = M - sum_d), by = list(row.names(DT_int))][, -1]
      DT_contribution <- cbind(DT_contribution[, -"M"], DT_int)
    } else {
      DT_contribution[, -"M"]
    }
  } else {
    DT_contribution <- DT_general
    if (isTRUE(iterm)) {
      DT_int <- DT_contribution[, list(sum_d = rowSums(.SD)), .SDcols = contribution]
      DT_int <- cbind(M = DT_contribution$within, DT_int)
      DT_int <- DT_int[, list(interaction = M - sum_d), by = list(row.names(DT_int))][, -1]
      DT_contribution <- cbind(DT_contribution, DT_int)
    }
    DT_contribution
  }
}
