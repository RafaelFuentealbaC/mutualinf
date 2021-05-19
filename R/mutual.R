#' @include M_within.R
#' @include M.R
NULL
#' @title Calculate and decompose the mutual information index
#' @description Function that delivery the index total value and the decompositions into the between term and the within
#' term, either for all data, a particular variable, or multiple variables. Besides allows know the local segregation
#' and evaluate the exclusive segregating effect that generate the group variables or the unit variables into the total
#' segregation. The decompositions of the within term and contributions can be show in the general form or in detail form.
#' @param data A data.table.
#' @param group A categorical variable name or vector of categorical variables names contained in \code{data}, or also,
#' a categorical variable number or vector of categorical variables numbers contained in \code{data}. Defines the first
#' dimension over which segregation is computed.
#' @param unit A categorical variable name or vector of categorical variables names contained in \code{data}, or also,
#' a categorical variable number or vector of categorical variables numbers contained in \code{data}. Defines the second
#' dimension over which segregation is computed.
#' @param within A categorical variable name or vector of categorical variables names contained in \code{data}, or also,
#' a categorical variable number or vector of categorical variables numbers contained in \code{data}. Defines the
#' dimensions within which segregation is computed. By default is NULL.
#' @param by A categorical variable name or vector of categorical variables names contained in \code{data}, or also, a
#' categorical variable number or vector of categorical variables numbers contained in \code{data}. Defines the
#' dimensions by which calculations are separated. By default is NULL.
#' @param contribution.from A variable of character type that can be 'group_vars' or 'unit_vars', or also, a categorical
#' variable name or vector of categorical variables names contained in the \code{group} parameter or \code{unit}
#' parameter, or also, a categorical variable number or vector of categorical variables numbers contained in the
#' \code{group} parameter or \code{unit} parameter. Defines the dimension over which wants to evaluate it's exclusive
#' segregating effect into the total segregation. By default is NULL.
#' @param components A boolean value. If is TRUE and the \code{within} option is not null and the \code{by} option
#' is null then returns a \code{list} where the first element is a \code{data.table} that contains a summary of the index
#' total value and decompositions while the second element is a \code{data.table} with more detail information of the
#' decomposition of the within term. Besides if the \code{within} and \code{by} options are not null then returns a
#' structure of \code{list of lists} type where each first element is a \code{data.table} that contains the summary of
#' the index total value and decompositions while each second element is a \code{data.table} with more detail information
#' of the decomposition of the within term that displayed in each first element. The detailed information includes the
#' proportions and local segregation. By default is FALSE.
#' @param cores A positive integer. Defines the amount of CPU cores that is use to parallelization task into the
#' index compute. If is NULL then the compute is carried out sequentially in only one core. This option is available
#' to Mac, Linux, Unix, and BSD systems but is not available to Windows sytems. By default is NULL.
#' @return A data.table if the \code{components} option is false; a list if the \code{components} option is true and
#' the \code{within} option is not null and the \code{by} option is null; or a list of lists if the \code{components}
#' option is true and the \code{within} and \code{by} options are not null.
#' @references Frankel, D. and Volij, O. (2011). Measuring school segregation. Journal of Economic Theory. 146(1):1-38. DOI:
#' 10.1016/j.jet.2010.10.008.
#'
#' Mora, R. and Guinea-Martin, D. (2021). Computing decomposable multigroup indexes of segregation. UC3M Working
#' papers. Economics 31803, Universidad Carlos III de Madrid. Departamento de Economía.
#'
#' Mora, R. and Ruiz-Castillo, J. (2003). Additively decomposable segregation indexes. The case of gender segregation by
#' occupations and human capital levels in spain. Journal of Economic Inequality. 1(2):147-179.
#' DOI: 10.1023/A:1026198429377.
#'
#' Mora, R. and Ruiz-Castillo, J. (2011). Entropy-based segregation indices. Sociological Methodology. 41(1):159-194.
#' DOI: 10.1111/j.1467-9531.2011.01237.x.
#'
#' Theil, H. and Finizza, Anthony J. (1971). A note on the measurement of racial integration of schools by means of
#' informational concepts. The Journal of Mathematical Sociology. 1(2):187-193. DOI: 10.1080/0022250X.1971.9989795.

#' @examples
#' \dontrun{
#' # Get the total segregation.
#' mutual(data = DT_Seg_Chile, group = c("csep", "etnia"), unit = "school")
#'
#' # Using the 'by' option to separate the calculations according to particular dimension or
#' # multiple dimensions.
#' mutual(data = DT_Seg_Chile, group = c("csep", "etnia"), unit = "school", by = "region")
#'
#' # Use the 'within' option to decompose the index total value into the between term and the
#' # within term.
#' mutual(data = DT_Seg_Chile, group = c("csep", "etnia"), unit = "school", within = "etnia")
#'
#' # Use the 'components' option to get detail information. The result shows the proportions
#' # and the local segregation index on the 'W_Decomposition' element. The weighted average
#' # between 'p' and 'within' is equal to the within term.
#' mutual(data = DT_Seg_Chile, group = c("csep", "etnia"), unit = "school", within = "etnia",
#' component = TRUE)
#'
#' # Use the 'contribution.from' option to evaluate the exclusive segregating effect of
#' # certain characteristics into the total segregation.
#' ## Contribution from of all variables of 'group' elements:
#' mutual(data = DT_Seg_Chile, group = c("csep", "etnia"), unit = "school", by = "region",
#' contribution.from = "group_vars")
#'
#' ## Contribution only from 'etnia' variable:
#' mutual(data = DT_Seg_Chile, group = c("csep", "etnia"), unit = "school", by = "region",
#' contribution.from = "etnia")
#'
#' # Use the 'cores' option to increase the CPU cores into the index compute.
#' mutual(data = DT_Seg_Chile, group = c("csep", "etnia"), unit = "school", by = "region",
#' cores = 2)
#' }
#' @import data.table
#' @export
mutual <- function(data, group, unit, within = NULL, by = NULL, contribution.from = NULL, components = FALSE, cores = NULL) {
  if (!is.null(cores) & isTRUE(Sys.info()["sysname"] == "windows")) stop("The 'cores' option is not available for windows system. Consider the default option")

  vars <- c(group, unit, within, by)
  contribution_all <- contribution.from[contribution.from %in% c("group_vars", "unit_vars")]
  contribution_from <- contribution.from[!contribution.from %in% c("group_vars", "unit_vars")]

  if (!is.null(contribution.from)) {
    if ((is.numeric(group) | is.numeric(unit) | is.numeric(within) | is.numeric(by)) & is.character(contribution_from)) {
      contribution_exists <- suppressWarnings(as.numeric(contribution_from))
      contribution_exists <- contribution_exists[!contribution_exists %in% NA]
      contribution_no_exists <- contribution_from[!contribution_from %in% as.character(contribution_exists)]
      if (length(contribution_no_exists) > 0) stop("Select variable names or variable numbers in the parameters")
      if (length(contribution_all) > 0 & length(contribution_exists) > 0) stop("Select 'group_vars' or 'unit_vars' or failing that select variables numbers")
      vars <- c(vars, contribution_exists)
    } else {
      vars <- c(vars, contribution_from)
    }
  }

  if (is.numeric(vars)) {
    if (max(vars) > ncol(data) | min(vars) < 1) stop("One or more selected columns are not found in the prepared data")
    vars <- names(data[, ..vars])
  }

  vars_no_exists <- vars[!vars %in% names(data)]
  if (length(vars_no_exists) > 0) {
    vars_no_exists <- paste(vars_no_exists, collapse = ", ")
    stop(paste("Variable(s)", vars_no_exists, "not included in prepared data"))
  }

  if (is.numeric(group)) group <- data[, colnames(.SD), .SDcols = group]
  if (is.numeric(unit)) unit <- data[, colnames(.SD), .SDcols = unit]
  if (is.numeric(within)) within <- data[, colnames(.SD), .SDcols = within]
  if (is.numeric(by)) by <- data[, colnames(.SD), .SDcols = by]
  if (is.numeric(contribution.from)) contribution.from <- data[, colnames(.SD), .SDcols = contribution.from]

  contribution_group <- contribution.from[contribution.from %in% group]
  contribution_unit <- contribution.from[contribution.from %in% unit]
  contribution_no_group_no_unit <- contribution.from[!contribution.from %in% c("group_vars", "unit_vars", contribution_group, contribution_unit)]

  if (("group_vars" %in% contribution.from) & ("unit_vars" %in% contribution.from)) stop("Contribution in groups and units is not possible. Select one of them")
  if ((("group_vars" %in% contribution.from) & (length(contribution_group) > 0)) | (("group_vars" %in% contribution.from) & (length(contribution_unit) > 0))) stop("Consider the vector 'group_vars' or just some dimensions of it")
  if ((("unit_vars" %in% contribution.from) & (length(contribution_unit) > 0)) | (("unit_vars" %in% contribution.from) & (length(contribution_group) > 0))) stop("Consider the vector 'unit_vars' or just some dimensions of it")
  if ((length(contribution_group) > 0) & (length(contribution_unit) > 0)) stop("Contribution in groups and units is not possible. Select variables from groups or variables from units")
  if ((length(contribution_all) > 0) & (length(contribution_from) > 0)) stop(paste("Variable(s)", paste(contribution_from, collapse = ", "), "is required in group or unit elements"))
  if (length(contribution_no_group_no_unit) > 0) stop(paste("Variable(s)", paste(contribution_no_group_no_unit, collapse = ", "), "is required in group or unit elements"))

  if (!is.null(within)) {
    M_within(data = data, group = group, unit = unit, within = within, by = by, contribution.from = contribution.from, components = components, cores = cores)
  } else {
    M(data = data, group = group, unit = unit, by = by, contribution.from = contribution.from, cores = cores)
  }
}
