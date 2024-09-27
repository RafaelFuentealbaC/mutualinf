#' @include get_internal_data.R
#' @include get_proportion.R
#' @include get_contribution.R
#' @include get_general_contribution.R
NULL
#' @import data.table
#' @import parallel
#' @import runner
#' @import stats
M_within_inv <- function(data, group, unit, within, by = NULL, contribution.from = NULL, components = FALSE, cores = NULL) {
  total <- sum(data[, fw])

  if (length(within) > 1) {
    w <- 1
    n <- 1
    list_index_between <- list()
    within_tmp <- NULL
    vec_p_within <- NULL
    comp_within <- NULL
    result <- NULL
      repeat {
        if (w == 1) {
          data_tmp_input <- get_internal_data(data = data, vars = c(group, unit, within[w]))
          data_tmp <- get_internal_data(data = data_tmp_input, vars = c(group, unit))
          index_total <- as.numeric(M_value(data = data_tmp, group =  group, unit = unit))

          if (within[w] %in% group) {
            data_tmp <- get_internal_data(data = data_tmp_input, vars = c(within[w], unit))
            index_between <- as.numeric(M_value(data = data_tmp, group = within[w], unit = unit))
            group <- group[!group %in% within[w]]

          } else if (within[w] %in% unit) {
            data_tmp <- get_internal_data(data = data_tmp_input, vars = c(group, within[w]))
            index_between <- as.numeric(M_value(data = data_tmp, group =  group, unit = within[w]))
            unit <- unit[!unit %in% within[w]]

          } else stop(paste("Computation requires that", within[w], "belongs to either 'group' or 'unit'."))

          DT_p <- get_proportion(data = data_tmp_input, within = within[w], total = total)
          data_tmp <- get_internal_data(data = data_tmp_input, vars = c(group, unit, within[w]))
          by <- within[w]

          data_by <- split(data_tmp, by = by)
          M_list <- lapply(data_by, function(d) {
            data_tmp <- get_internal_data(data = d, vars = c(group, unit))
            cbind(unique(d[, ..by]), M = M_value(data = data_tmp, group = group, unit = unit))
          })

          DT_general <- do.call(rbind, M_list)
          DT_general <- na.omit(object = DT_general, cols = colnames(DT_general))

          comp_within <- DT_general$M

          DT_within <- cbind(DT_p, within = comp_within)
          index_within <- sum(DT_within$p %*% DT_within$within)
          DT_general <- data.table(M = index_total, M_B = index_between)
          setnames(x = DT_general, old = "M_B", new = paste0("M_B_", within[w]))

          DT_general <- cbind(DT_general, M_W = index_within)
          setnames(x = DT_general, old = "M_W", new = paste0("M_W_", within[w]))

          list_index_between[[w]] <- DT_general$M_B
          vec_p_within <- get_proportion(data = data, within = within[w], total = total)$p

        } else {
          data_tmp_input <- get_internal_data(data = data, vars = c(group, unit, within[w], within_tmp))
          by <- within_tmp
          data_tmp <- get_internal_data(data = data_tmp_input, vars = c(group, unit, by))
          data_by <- split(data_tmp, by = by)

          M_list <- lapply(data_by, function(d) {
            data_tmp <- get_internal_data(data = d, vars = c(group, unit))
            cbind(unique(d[, ..by]), M = M_value(data = data_tmp, group = group, unit = unit))
          })

          DT_general <- do.call(rbind, M_list)
          index_total <- na.omit(object = DT_general, cols = colnames(DT_general))

          if (within[w] %in% group) {
            data_tmp <- get_internal_data(data = data_tmp_input, vars = c(within[w], unit, by))
            data_by <- split(data_tmp, by = by)

            M_list <- lapply(data_by, function(d) {
              data_tmp <- get_internal_data(data = d, vars = c(within[w], unit))
              cbind(unique(d[, ..by]), M = M_value(data = data_tmp, group = within[w], unit = unit))
            })

            DT_general <- do.call(rbind, M_list)
            index_between <- na.omit(object = DT_general, cols = colnames(DT_general))
            group <- group[!group %in% within[w]]

          } else if (within[w] %in% unit) {
            data_tmp <- get_internal_data(data = data, vars = c(group, within[w], by))
            data_by <- split(data_tmp, by = by)

            M_list <- lapply(data_by, function(d) {
              data_tmp <- get_internal_data(data = d, vars = c(group, within[w]))
              cbind(unique(d[, ..by]), M = M_value(data = data_tmp, group = group, unit = within[w]))
            })

            DT_general <- do.call(rbind, M_list)
            index_between <- na.omit(object = DT_general, cols = colnames(DT_general))
            unit <- unit[!unit %in% within[w]]

          } else stop(paste("Computation requires that", within[w], "belongs to either 'group' or 'unit'."))

          DT_p <- get_proportion(data = data_tmp_input, within = within[w], by = by)
          data_tmp <- get_internal_data(data = data_tmp_input, vars = c(group, unit, by, within))
          by <- c(by, within[w])
          data_by <- split(data_tmp, by = by)

          M_list <- lapply(data_by, function(d) {
            data_tmp <- get_internal_data(data = d, vars = c(group, unit))
            cbind(unique(d[, ..by]), M = M_value(data = data_tmp, group = group, unit = unit))
          })

          DT_general <- do.call(rbind, M_list)
          DT_general <- na.omit(object = DT_general, cols = colnames(DT_general))

          comp_within <- DT_general$M
          by <- within_tmp

          DT_within <- cbind(DT_p, within = comp_within)
          index_within <- DT_within[, list(M_W = sum(p %*% within)), by = by]
          DT_general <- merge(x = index_total, y = index_between, by = by, sort = FALSE)
          setnames(x = DT_general, old = c("M.x", "M.y"), new = c("M", paste0("M_B_", within[w])))

          DT_general <- merge(x = DT_general, y = index_within, by = by, sort = FALSE)
          setnames(x = DT_general, old = "M_W", new = paste0("M_W_", within[w]))

          index_between <- DT_general$M_B

          list_index_between[[w]] <- sum(vec_p_within %*% index_between)
          vec_p_within <- get_proportion(data = data, within = c(within_tmp, within[w]), total = total)$p

          if (w == length(within)) {
            data_tmp <- get_internal_data(data = data, vars = c(group, unit, within))
            by <- within

            data_by <- split(data_tmp, by = by)
            M_list <- lapply(data_by, function(d) {
              data_tmp <- get_internal_data(data = d, vars = c(group, unit))
              cbind(unique(d[, ..by]), M = M_value(data = data_tmp, group = group, unit = unit))
            })

            DT_general <- do.call(rbind, M_list)
            DT_general <- na.omit(object = DT_general, cols = colnames(DT_general))

            comp_within <- DT_general$M

          }
        }

        if (within[w] %in% group) group <- group[!group %in% within[w]]
        if (within[w] %in% unit) unit <- unit[!unit %in% within[w]]
        within_tmp <- c(within_tmp, within[w])

        if (w == length(within)) break
        w <- w + 1
      }

      list_between_names <- c(paste0("M_B_", within[1]), rep("M_W_", length(within)-1))
      list_between_end_names <- runner::runner(within[-length(within)], f = paste, collapse = "_")
      list_between_names[2:length(list_between_names)] <- paste0(list_between_names[2:length(list_between_names)], list_between_end_names)
      index_between_sum <- sum(unlist(list_index_between, use.names = FALSE))
      list_index_between <- setNames(object = list_index_between, nm = list_between_names)

      DT_p <- get_proportion(data = data, within = within, total = total)
      DT_within <- cbind(DT_p, within = comp_within)
      index_within <- sum(DT_within$p %*% DT_within$within)

      index_total <- index_between_sum + index_within
      DT_general <- data.table(M = index_total, rbind(list_index_between))

      DT_general <- cbind(DT_general, M_W = index_within)
      setnames(x = DT_general, old = "M_W", new = paste0("M_W_", paste0(within, collapse = "_")))

      result <- DT_general
      result

  } else {
      data_tmp <- get_internal_data(data = data, vars = c(group, unit))
      index_total <- as.numeric(M_value(data = data_tmp, group =  group, unit = unit))

      if (within %in% group) {
        data_tmp <- get_internal_data(data = data, vars = c(within, unit))
        index_between <- as.numeric(M_value(data = data_tmp, group = within, unit = unit))
        group <- group[!group %in% within]

      } else if (within %in% unit) {
        data_tmp <- get_internal_data(data = data, vars = c(group, within))
        index_between <- as.numeric(M_value(data = data_tmp, group = group, unit = within))
        unit <- unit[!unit %in% within]

      } else stop(paste("Computation requires that", within, "belongs to either 'group' or 'unit'."))

      DT_p <- get_proportion(data = data, within = within, total = total)
      data_tmp <- get_internal_data(data = data, vars = c(group, unit, within))
      by = within
      data_by <- split(data_tmp, by = by)

      M_list <- lapply(data_by, function(d) {
        data_tmp <- get_internal_data(data = d, vars = c(group, unit))
        cbind(unique(d[, ..by]), M = M_value(data = data_tmp, group = group, unit = unit
        ))
      })

      DT_general <- do.call(rbind, M_list)
      DT_general <- na.omit(object = DT_general, cols = colnames(DT_general))

      comp_within <- DT_general$M

      DT_within <- cbind(DT_p, within = comp_within)
      index_within <- sum(DT_within$p %*% DT_within$within)
      DT_general <- data.table(M = index_total, M_B = index_between)
      setnames(x = DT_general, old = "M_B", new = paste0("M_B_", within))

      DT_general <- cbind(DT_general, M_W = index_within)
      setnames(x = DT_general, old = "M_W", new = paste0("M_W_", within))

      result <- DT_general
      result

  }
}
