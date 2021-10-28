#' @include get_internal_data.R
#' @include M_value.R
#' @include get_contribution.R
NULL
#' @import data.table
#' @import parallel
#' @import stats
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
      if (((isTRUE(contribution %in% group)) & (length(group) < 2)) | (isTRUE(contribution %in% unit)) & (length(unit) < 2))
        stop("When using option 'contribution.from' vectors 'group' or 'unit' should have length larger than one. Compute without option 'contribution.from'.")
      if ((length(intersect(contribution, group)) == length(group)) | length(intersect(contribution, unit)) == length(unit)) {
        DT_contribution <- get_contribution(data = data, group = group, unit = unit, by = by, contribution = contribution, component = DT_general, cores = cores, iterm = TRUE)
        setnames(x = DT_contribution, old = colnames(DT_contribution[, -"interaction"]), new = paste0("C_", contribution))
      } else {
        DT_contribution <- get_contribution(data = data, group = group, unit = unit, by = by, contribution = contribution, component = DT_general, cores = cores, iterm = FALSE)
        setnames(x = DT_contribution, old = colnames(DT_contribution), new = paste0("C_", contribution))
      }
      result <- cbind(DT_general, DT_contribution)
    } else {
      result <- DT_general
    }
    result
  } else {
    if (!is.null(contribution)) {
      if (((isTRUE(contribution %in% group)) & (length(group) < 2)) | (isTRUE(contribution %in% unit)) & (length(unit) < 2))
        stop("When using option 'contribution.from' vectors 'group' or 'unit' should have length larger than one. Compute without option 'contribution.from'.")
      data_tmp <- get_internal_data(data = data, vars = c(group, unit))
      index_total <- mutual(data = data_tmp, group = group, unit = unit)

      if (!is.null(cores)) {
        M_contribution <- mclapply(X = contribution, function(c) {
          if (c %in% group) c_tmp <- group[!group %in% c]
          else c_tmp <- unit[!unit %in% c]
          data_tmp <- get_internal_data(data = data, vars = c(group, unit, c_tmp))
          DT_res <- rev(mutual(data = data_tmp, group = group, unit = unit, within = c_tmp))
          DT_res[, 1]
        }, mc.cores = cores)
      } else {
        M_contribution <- lapply(X = contribution, function(c) {
          if (c %in% group) c_tmp <- group[!group %in% c]
          else c_tmp <- unit[!unit %in% c]
          data_tmp <- get_internal_data(data = data, vars = c(group, unit, c_tmp))
          DT_res <- rev(mutual(data = data_tmp, group = group, unit = unit, within = c_tmp))
          DT_res[, 1]
        })
      }
      DT_contribution <- do.call(cbind, M_contribution)
      names(DT_contribution) <- paste0("C_", contribution)
      if ((length(intersect(contribution, group)) == length(group)) | length(intersect(contribution, unit)) == length(unit)) {
        DT_contribution <- cbind(index_total, DT_contribution, interaction = (index_total - sum(DT_contribution)))
        setnames(x = DT_contribution, old = "interaction.M", "interaction")
      } else {
        DT_contribution <- cbind(index_total, DT_contribution)
      }
      result <- DT_contribution
    } else {
      data_tmp <- get_internal_data(data = data, vars = c(group, unit))
      result <- data.table(M = M_value(data = data_tmp, group =  group, unit = unit))
    }
    result
  }
}
