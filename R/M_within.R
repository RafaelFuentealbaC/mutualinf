#' @include get_internal_data.R
#' @include mutual.R
#' @include get_proportion.R
#' @include get_contribution.R
#' @include get_general_contribution.R
NULL
#' @import data.table
#' @import parallel
#' @import stats
M_within <- function(data, group, unit, within, by = NULL, contribution.from = NULL, components = FALSE, cores = NULL) {
  total <- sum(data[, fw])
  contribution <- NULL

  if (length(within) > 1) {
    w <- 1
    list_index_between <- list()
    within_tmp <- NULL
    vec_p_within <- NULL
    comp_within <- NULL
    result <- NULL

    if (!is.null(by)) {
      id_by <- unique(data[, .SD, .SDcols = by])
      formated_id_by <- as.data.table(sapply(id_by, function(i) return(gsub(" ", "_", i))))

      repeat {
        if (w == 1) {
          data_tmp <- get_internal_data(data = data, vars = c(group, unit, within[w], by))
          index_between <- mutual(data = data_tmp, group = group, unit = unit, within = within[w], by = by)$M_B
          list_index_between[[w]] <- index_between
          vec_p_within <- get_proportion(data = data, within = within[w], by = by)$p
        } else {
          data_tmp <- get_internal_data(data = data, vars = c(group, unit, within[w], by, within_tmp))
          index_between <- mutual(data = data_tmp, group = group, unit = unit, within = within[w], by = c(by, within_tmp))$M_B
          DT_index_between <- data.table(unique(data[, .SD, .SDcols = c(by, within_tmp)]), p = vec_p_within, M = index_between)
          list_index_between[[w]] <- DT_index_between[, list(M_B = sum(p %*% M)), by = by]$M_B
          vec_p_within <- get_proportion(data = data, within = c(within_tmp, within[w]), by = by)$p

          if (w == length(within)) {
            data_tmp <- get_internal_data(data = data, vars = c(group, unit, by, within))
            comp_within <- mutual(data = data_tmp, group = group, unit = unit, by = c(by, within))$M
          }
        }

        if (within[w] %in% group) group <- group[!group %in% within[w]]
        if (within[w] %in% unit) unit <- unit[!unit %in% within[w]]
        within_tmp <- c(within_tmp, within[w])

        if (w == length(within)) break
        w <- w + 1
      }

      list_index_between <- setNames(object = list_index_between, nm = c(paste0("M_B_", within[1]), paste0("M_W_", within[-1])))
      index_between <- as.data.table(do.call(cbind, list_index_between))

      DT_p <- get_proportion(data = data, within = within, by = by)
      DT_within <- cbind(DT_p, within = comp_within)
      index_within <- DT_within[, list(M_W = sum(p %*% within)), by = by]$M_W

      DT_index_total <- cbind(index_between, index_within)
      index_total <- DT_index_total[, list(M = rowSums(.SD)), .SDcols = names(DT_index_total)]
      DT_general <- cbind(id_by, index_total, index_between)

      if ("group_vars" %in% contribution.from) contribution <- group
      else if ("unit_vars" %in% contribution.from) contribution <- unit
      else contribution <- contribution.from

      if (!is.null(contribution)) {
        if (((isTRUE(contribution %in% group)) & (length(group) < 2)) | (isTRUE(contribution %in% unit)) & (length(unit) < 2)) stop("The length of the group/unit vector must be greater than one when the within vector includes some variables of him")
        DT_within <- get_contribution(data = data, group = group, unit = unit, within = within, by = by, component = DT_within, contribution = contribution, cores = cores)
        DT_general_comp <- get_general_contribution(DT_contribution = DT_within, contribution = contribution, by = by, cores = cores)
        DT_general <- cbind(DT_general, DT_general_comp)
      } else {
        DT_general <- cbind(DT_general, M_W = index_within)
        setnames(x = DT_general, old = "M_W", new = paste0("M_W_", paste0(within, collapse = "_")))
      }

      if (isTRUE(components)) {
        DT_general <- split(DT_general, by = by)
        DT_within <- split(DT_within, by = by)

        element <- 1
        repeat {
          res <- list()
          DT_general[[element]] <- DT_general[[element]][, -1:-length(by)]
          DT_within[[element]] <- DT_within[[element]][, -1:-length(by)]
          res[['Total']] <- DT_general[[element]]
          res[['W_Decomposition']] <- DT_within[[element]]
          result[[element]] <- res
          if (element == length(DT_general)) break
          element <- element + 1
        }
        names_result <- as.data.table(do.call(cbind, Map(paste, names(formated_id_by), formated_id_by, sep = ".")))
        names_result <- names_result[, list(list_name = do.call(paste, c(.SD, sep = ".")))]
        result <- setNames(object = result, nm = names_result$list_name)
      } else {
        result <- DT_general
      }
      result
    } else {
      repeat {
        if (w == 1) {
          data_tmp <- get_internal_data(data = data, vars = c(group, unit, within[w]))
          list_index_between[[w]] <- mutual(data = data_tmp, group = group, unit = unit, within = within[w])$M_B
          vec_p_within <- get_proportion(data = data, within = within[w], total = total)$p
        } else {
          data_tmp <- get_internal_data(data = data, vars = c(group, unit, within[w], within_tmp))
          index_between <- mutual(data = data_tmp, group = group, unit = unit, within = within[w], by = within_tmp)$M_B
          list_index_between[[w]] <- sum(vec_p_within %*% index_between)
          vec_p_within <- get_proportion(data = data, within = c(within_tmp, within[w]), total = total)$p

          if (w == length(within)) {
            data_tmp <- get_internal_data(data = data, vars = c(group, unit, within))
            comp_within <- mutual(data = data_tmp, group = group, unit = unit, by = within)$M
          }
        }

        if (within[w] %in% group) group <- group[!group %in% within[w]]
        if (within[w] %in% unit) unit <- unit[!unit %in% within[w]]
        within_tmp <- c(within_tmp, within[w])

        if (w == length(within)) break
        w <- w + 1
      }

      list_index_between <- setNames(object = list_index_between, nm = c(paste0("M_B_", within[1]), paste0("M_W_", within[-1])))
      index_between <- sum(unlist(list_index_between, use.names = FALSE))

      DT_p <- get_proportion(data = data, within = within, total = total)
      DT_within <- cbind(DT_p, within = comp_within)
      index_within <- sum(DT_within$p %*% DT_within$within)

      index_total <- index_between + index_within
      DT_general <- data.table(M = index_total, rbind(list_index_between))

      if ("group_vars" %in% contribution.from) contribution <- group
      else if ("unit_vars" %in% contribution.from) contribution <- unit
      else contribution <- contribution.from

      if (!is.null(contribution)) {
        if (((isTRUE(contribution %in% group)) & (length(group) < 2)) | (isTRUE(contribution %in% unit)) & (length(unit) < 2)) stop("The length of the group/unit vector must be greater than one when the within vector includes some variables of him")
        DT_within <- get_contribution(data = data, group = group, unit = unit, within = within, component = DT_within, contribution = contribution, cores = cores)
        DT_general_comp <- get_general_contribution(DT_contribution = DT_within, contribution = contribution, cores = cores)
        DT_general <- cbind(DT_general, DT_general_comp)
      } else {
        DT_general <- cbind(DT_general, M_W = index_within)
        setnames(x = DT_general, old = "M_W", new = paste0("M_W_", paste0(within, collapse = "_")))
      }

      if (isTRUE(components)) {
        result <- list(Total = DT_general, W_Decomposition = DT_within)
      } else {
        result <- DT_general
      }
      result
    }
  } else {
    if (!is.null(by)) {
      result <- NULL

      data_tmp <- get_internal_data(data = data, vars = c(group, unit, by))
      index_total <- mutual(data = data_tmp, group = group, unit = unit, by = by)

      if (within %in% group) {
        data_tmp <- get_internal_data(data = data, vars = c(within, unit, by))
        index_between <- mutual(data = data_tmp, group = within, unit = unit, by = by)
        group <- group[!group %in% within]
      } else if (within %in% unit) {
        data_tmp <- get_internal_data(data = data, vars = c(group, within, by))
        index_between <- mutual(data = data_tmp, group = group, unit = within, by = by)
        unit <- unit[!unit %in% within]
      } else stop(paste("Variable(s)", within, "is required in group or unit elements"))

      DT_p <- get_proportion(data = data, within = within, by = by)
      data_tmp <- get_internal_data(data = data, vars = c(group, unit, by, within))
      comp_within <- mutual(data = data_tmp, group = group, unit = unit, by = c(by, within))$M
      DT_within <- cbind(DT_p, within = comp_within)
      index_within <- DT_within[, list(M_W = sum(p %*% within)), by = by]
      DT_general <- merge(x = index_total, y = index_between, by = by, sort = FALSE)
      setnames(x = DT_general, old = c("M.x", "M.y"), new = c("M", paste0("M_B_", within)))

      if ("group_vars" %in% contribution.from) contribution <- group
      else if ("unit_vars" %in% contribution.from) contribution <- unit
      else contribution <- contribution.from

      if (!is.null(contribution)) {
        if (((isTRUE(contribution %in% group)) & (length(group) < 2)) | (isTRUE(contribution %in% unit)) & (length(unit) < 2)) stop("The length of the group/unit vector must be greater than one when the within vector includes some variables of him")
        DT_within <- get_contribution(data = data, group = group, unit = unit, within = within, by = by, component = DT_within, contribution = contribution, cores = cores)
        DT_general_comp <- get_general_contribution(DT_contribution = DT_within, contribution = contribution, by = by, cores = cores)
        DT_general <- cbind(DT_general, DT_general_comp)
      } else {
        DT_general <- merge(x = DT_general, y = index_within, by = by, sort = FALSE)
        setnames(x = DT_general, old = "M_W", new = paste0("M_W_", within))
      }

      if (isTRUE(components)) {
        DT_general <- split(DT_general, by = by)
        DT_within <- split(DT_within, by = by)

        element <- 1
        repeat {
          res <- list()
          DT_general[[element]] <- DT_general[[element]][, -1:-length(by)]
          DT_within[[element]] <- DT_within[[element]][, -1:-length(by)]
          res[['Total']] <- DT_general[[element]]
          res[['W_Decomposition']] <- DT_within[[element]]
          result[[element]] <- res
          if (element == length(DT_general)) break
          element <- element + 1
        }
        id_value <- unique(data[, .SD, .SDcols = by])
        formated_id_value <- as.data.table(sapply(id_value, function(i) return(gsub(" ", "_", i))))
        names_result <- as.data.table(do.call(cbind, Map(paste, names(formated_id_value), formated_id_value, sep = ".")))
        names_result <- names_result[, list(list_name = do.call(paste, c(.SD, sep = ".")))]
        result <- setNames(object = result, nm = names_result$list_name)
      } else {
        result <- DT_general
      }
      result
    } else {
      data_tmp <- get_internal_data(data = data, vars = c(group, unit))
      index_total <- as.numeric(mutual(data = data_tmp, group = group, unit = unit))

      if (within %in% group) {
        data_tmp <- get_internal_data(data = data, vars = c(within, unit))
        index_between <- as.numeric(mutual(data = data_tmp, group = within, unit = unit))
        group <- group[!group %in% within]
      } else if (within %in% unit) {
        data_tmp <- get_internal_data(data = data, vars = c(group, within))
        index_between <- as.numeric(mutual(data = data_tmp, group = group, unit = within))
        unit <- unit[!unit %in% within]
      } else stop(paste("Variable(s)", within, "is required in group or unit elements"))

      DT_p <- get_proportion(data = data, within = within, total = total)
      data_tmp <- get_internal_data(data = data, vars = c(group, unit, within))
      comp_within <- mutual(data = data_tmp, group = group, unit = unit, by = within)$M
      DT_within <- cbind(DT_p, within = comp_within)
      index_within <- sum(DT_within$p %*% DT_within$within)
      DT_general <- data.table(M = index_total, M_B = index_between)
      setnames(x = DT_general, old = "M_B", new = paste0("M_B_", within))

      if ("group_vars" %in% contribution.from) contribution <- group
      else if ("unit_vars" %in% contribution.from) contribution <- unit
      else contribution <- contribution.from

      if (!is.null(contribution)) {
        if (((isTRUE(contribution %in% group)) & (length(group) < 2)) | (isTRUE(contribution %in% unit)) & (length(unit) < 2)) stop("The length of the group/unit vector must be greater than one when the within vector includes some variables of him")
        DT_within <- get_contribution(data = data, group = group, unit = unit, within = within, component = DT_within, contribution = contribution, cores = cores)
        DT_general_comp <- get_general_contribution(DT_contribution = DT_within, contribution = contribution, cores = cores)
        DT_general <- cbind(DT_general, DT_general_comp)
      } else {
        DT_general <- cbind(DT_general, M_W = index_within)
        setnames(x = DT_general, old = "M_W", new = paste0("M_W_", within))
      }

      if (isTRUE(components)) {
        result <- list(Total = DT_general, W_Decomposition = DT_within)
      } else {
        result <- DT_general
      }
      result
    }
  }
}
