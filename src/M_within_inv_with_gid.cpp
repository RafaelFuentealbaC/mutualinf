#include <RcppArmadillo.h>
#include "get_internal_data_cpp.h"
#include "update_indexes.h"
#include "M_within_inv_cpp.h"

// [[Rcpp::depends(RcppArmadillo)]]

// [[Rcpp::export]]
arma::mat M_within_inv_with_gid(const arma::mat& data, const arma::uvec& vars, arma::uvec group, arma::uvec unit, arma::uvec within) {
  arma::mat data_tmp = get_internal_data_cpp(data, vars);
  group = update_indexes(group, vars);
  unit = update_indexes(unit, vars);
  within = update_indexes(within, vars);

  arma::mat result = M_within_inv_cpp(data_tmp, group, unit, within);
  return result;
}
