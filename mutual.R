#' @include M_within.R
#' @include M.R
NULL
#' @title Computes and decomposes the Mutual Information index
#' @description Computes and decomposes the Mutual Information index into "between" and "within" terms. The
#' "within" terms can also be decomposed into "exclusive contributions" of segregation sources defined either by group
#' or unit characteristics. The mathematical components required to compute each "within" term can also be displayed at
#' the user's request. The results can be computed over subsamples defined by the user.
#' @param data An object from the "data.table" and "mutual.data" classes.
#' @param group A categorical variable name or vector of categorical variables names contained in \code{data}, or also,
#' a column number or vector of column numbers of \code{data}. Defines the first dimension over which segregation is
#' computed.
#' @param unit A categorical variable name or vector of categorical variables names contained in \code{data}, or also,
#' a column number or vector of column numbers of \code{data}. Defines the second dimension over which segregation is
#' computed.
#' @param within A categorical variable name or vector of categorical variables names contained in \code{data}, or also,
#' a column number or vector of column numbers of \code{data}. Defines the partitions to compute the between and within
#' decompositions. By default is \code{NULL}.
#' @param by A categorical variable name or vector of categorical variables names contained in \code{data}, or also,
#' a column number or vector of column numbers of \code{data}. Defines the subsamples over which indexes are computed.
#' By default is \code{NULL}.
#' @param contribution.from A variable of character type that can be 'group_vars' or 'unit_vars', or also, a categorical
#' variable name or vector of categorical variables names contained in the \code{group} parameter or \code{unit}
#' parameter, or also, a column number or vector of column numbers in the \code{group} parameter or the \code{unit}
#' parameter. Defines the segregation sources whose exclusive contributions to the "within" terms and the overall index
#' are computed. By default is \code{NULL}.
#' @param components A boolean value. If TRUE and the \code{within} option is not \code{NULL} and the \code{by} option is \code{NULL},
#' then it returns a list where the first element is a \code{data.table} that contains a summary of the index total value and
#' its decompositions, while the second element is a \code{data.table} with more detailed information of the decomposition of the
#' "within" term (the mathematical components required to compute the within terms). If the \code{within} and \code{by}
#' options are not \code{NULL}, then the function returns a list of lists where each first element is a \code{data.table} that contains
#' the summary of the index total value and decompositions in a given subsample, while each second element is a \code{data.table}
#' with more detailed information of the decomposition of the within term displayed in each first element in the same
#' subsample. By default is FALSE.
#' @param cores A positive integer. Defines the amount of CPU cores to use in parallelization tasks. If \code{NULL}, then the
#' computation is carried out in only one core. This option is available to Mac, Linux, Unix, and BSD systems
#' but is not available to Windows sytems. By default is \code{NULL}.
#' @details Mixing \code{group} variables with \code{unit} variables in \code{contribution.from} will produce an error.
#' @return A \code{data.table} if the \code{components} option is \code{FALSE}; a list if the \code{components} option is \code{TRUE},
#' the \code{within} option is not \code{NULL} and the \code{by} option is \code{NULL}; or a list of lists if the \code{components}
#' option is \code{TRUE}, and both \code{within} and \code{by} options are not \code{NULL}.
#' @references Frankel, D. and Volij, O. (2011). Measuring school segregation. \emph{Journal of Economic Theory, 146}(1):1-38.
#' \doi{10.1016/j.jet.2010.10.008}.
#'
#' Guinea-Martin, D., Mora, R., & Ruiz-Castillo, J. (2018). The evolution of gender segregation over the life course.
#' \emph{American Sociological Review, 83}(5), 983-1019. \doi{10.1177/0003122418794503}.
#'
#' Mora, R. and Guinea-Martin, D. (2021). Computing decomposable multigroup indexes of segregation. \emph{UC3M Working
#' papers, Economics 31803}. Universidad Carlos III de Madrid. Departamento de Economía.
#'
#' Mora, R. and Ruiz-Castillo, J. (2011). Entropy-based segregation indices. \emph{Sociological Methodology, 41}(1):159-194.
#' \doi{10.1111/j.1467-9531.2011.01237.x}.
#'
#' Theil, H. and Finizza, A. J. (1971). A note on the measurement of racial integration of schools by means of
#' informational concepts. \emph{The Journal of Mathematical Sociology, 1}(2):187-193. \doi{10.1080/0022250X.1971.9989795}.
#'
#' @examples
#' # To compute the overall measure of school segregation by socioeconomic and ethnic status.
#' mutual(data = DT_test, group = c("csep", "ethnicity"), unit = "school")
#'
#' # Computation of the exclusive effect of specific segregation sources on the overall measure, e.g.,
#' # socioeconomic and ethnic contributions, and the contribution that cannot be attributed to any of
#' # them (the "interaction" term).
#' mutual(data = DT_test, group = c("csep", "ethnicity"), unit = "school", by = "region",
#' contribution.from = "group_vars")
#'
#' # For more information on the package, refer to the manual and the README file.
#'
#' @import data.table
#' @export
mutual <- function(data, group, unit, within = NULL, by = NULL, contribution.from = NULL, components = FALSE, cores = NULL) {
  if (!is.null(cores) & isTRUE(Sys.info()["sysname"] == "windows")) stop("The 'cores' option is not available for Windows systems. Use the default option.")
  if ((!"data.table" %in% class(data)) & (!"mutual.data" %in% class(data))) stop("The 'data' object must belong to classes 'data.table' and 'mutual.data'.")

  vars <- c(group, unit, within, by)
  contribution_all <- contribution.from[contribution.from %in% c("group_vars", "unit_vars")]
  contribution_from <- contribution.from[!contribution.from %in% c("group_vars", "unit_vars")]

  if (!is.null(contribution.from)) {
    if ((is.numeric(group) | is.numeric(unit) | is.numeric(within) | is.numeric(by)) & is.character(contribution_from)) {
      contribution_exists <- suppressWarnings(as.numeric(contribution_from))
      contribution_exists <- contribution_exists[!contribution_exists %in% NA]
      contribution_no_exists <- contribution_from[!contribution_from %in% as.character(contribution_exists)]
      if (length(contribution_no_exists) > 0) stop("Select valid variable names or columns numbers of the dataset in option 'contribution.from'.")
      if (length(contribution_all) > 0 & length(contribution_exists) > 0) stop("Use either 'group_vars' or 'unit_vars' or a vector of valid column names or numbers.")
      vars <- c(vars, contribution_exists)
    } else {
      vars <- c(vars, contribution_from)
    }
  }

  if (is.numeric(vars)) {
    if (max(vars) > ncol(data) | min(vars) < 1) stop("Column not found in the dataset.")
    vars <- names(data[, ..vars])
  }

  vars_no_exists <- vars[!vars %in% names(data)]
  if (length(vars_no_exists) > 0) {
    vars_no_exists <- paste(vars_no_exists, collapse = ", ")
    stop(paste("Variable(s)", vars_no_exists, "not found in the dataset."))
  }

  if (is.numeric(group)) group <- data[, colnames(.SD), .SDcols = group]
  if (is.numeric(unit)) unit <- data[, colnames(.SD), .SDcols = unit]
  if (is.numeric(within)) within <- data[, colnames(.SD), .SDcols = within]
  if (is.numeric(by)) by <- data[, colnames(.SD), .SDcols = by]
  if (is.numeric(contribution.from)) contribution.from <- data[, colnames(.SD), .SDcols = contribution.from]

  contribution_group <- contribution.from[contribution.from %in% group]
  contribution_unit <- contribution.from[contribution.from %in% unit]
  contribution_no_group_no_unit <- contribution.from[!contribution.from %in% c("group_vars", "unit_vars", contribution_group, contribution_unit)]

  if (("group_vars" %in% contribution.from) & ("unit_vars" %in% contribution.from)) stop("Simultaneous contributions from 'group' and 'unit' variables is not possible. Select one of them.")
  if ((("group_vars" %in% contribution.from) & (length(contribution_group) > 0)) | (("group_vars" %in% contribution.from) & (length(contribution_unit) > 0))) stop("Do not mix 'group_vars' with 'group' variables in option 'contribution.from'.")
  if ((("unit_vars" %in% contribution.from) & (length(contribution_unit) > 0)) | (("unit_vars" %in% contribution.from) & (length(contribution_group) > 0))) stop("Do not mix 'unit_vars' with 'unit' variables in option 'contribution.from'.")
  if ((length(contribution_group) > 0) & (length(contribution_unit) > 0)) stop("Simultaneous contributions from 'group' and 'unit' variables is not possible. Select one of them.")
  if ((length(contribution_all) > 0) & (length(contribution_from) > 0)) stop("Do not mix 'group_vars' or 'unit_vars' with 'group' or 'unit' variables in option 'contribution.from'.")
  if (length(contribution_no_group_no_unit) > 0) stop(paste("Variable(s)", paste(contribution_no_group_no_unit, collapse = ", "), "should be (a) 'group' or 'unit' variable(s)."))

  if (!is.null(within)) {
    M_within(data = data, group = group, unit = unit, within = within, by = by, contribution.from = contribution.from, components = components, cores = cores)
  } else {
    M(data = data, group = group, unit = unit, by = by, contribution.from = contribution.from, cores = cores)
  }
}
