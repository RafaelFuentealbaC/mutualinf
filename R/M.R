#' @include M_value.R
NULL
#' @import data.table
#' @import parallel
M <- function(data, group, unit, by = NULL, contribution.from = NULL, cores = NULL) {
  if ("group_vars" %in% contribution.from) contribution <- group
  else if ("unit_vars" %in% contribution.from) contribution <- unit
  else contribution <- contribution.from

  if (!is.null(by))  {
    data_by <- split(data, by = by)

    if (!is.null(cores)) {
      M_list <- mclapply(X = data_by, function(d) {
        data_tmp <- get_internal_data(data = d, vars = c(group, unit))
        cbind(unique(d[, ..by]), M = M_value(data = data_tmp, group = group, unit = unit))
      }, mc.cores = cores)
    } else {
      M_list <- lapply(X = data_by, function(d) {
        data_tmp <- get_internal_data(data = d, vars = c(group, unit))
        cbind(unique(d[, ..by]), M = M_value(data = data_tmp, group = group, unit = unit))
      })
    }

    DT_general <- do.call(rbind, M_list)
    DT_general <- na.omit(object = DT_general, cols = colnames(DT_general))

    if (!is.null(contribution)) {
      comp_total <- do.call(rbind, M_list)$M
      DT_contribution <- get_contribution(data = data, group = group, unit = unit, by = by, contribution = contribution, component = comp_total, cores = cores)
      setnames(x = DT_contribution, old = colnames(DT_contribution[, -"interaction"]), new = paste0("C_", contribution))
      result <- cbind(DT_general, DT_contribution)
    } else {
      result <- DT_general
    }
    result
  } else {
    if (!is.null(contribution)) {
      data_tmp <- get_internal_data(data = data, vars = c(group, unit))
      index_total <- mutual(data = data_tmp, group = group, unit = unit)

      if (!is.null(cores)) {
        M_contribution <- mclapply(X = contribution, function(c) {
          data_tmp <- get_internal_data(data = data, vars = c(group, unit, c))
          mutual(data = data_tmp, group = group, unit = unit, within = c)$M_W
        }, mc.cores = cores)
      } else {
        M_contribution <- lapply(X = contribution, function(c) {
          data_tmp <- get_internal_data(data = data, vars = c(group, unit, c))
          mutual(data = data_tmp, group = group, unit = unit, within = c)$M_W
        })
      }
      DT_contribution <- as.data.table(rev(M_contribution))
      names(DT_contribution) <- paste0("C_", contribution)
      DT_contribution <- cbind(index_total, DT_contribution, interaction = (index_total - sum(DT_contribution)))
      setnames(x = DT_contribution, old = "interaction.M", "interaction")
      result <- DT_contribution
    } else {
      data_tmp <- get_internal_data(data = data, vars = c(group, unit))
      result <- data.table(M = M_value(data = data_tmp, group =  group, unit = unit))
    }
    result
  }
}
