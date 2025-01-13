#ifndef LAPPLY_M_VALUE_H
#define LAPPLY_M_VALUE_H

#include <RcppArmadillo.h>

arma::mat lapply_M_value(const arma::mat& data_tmp,
                         const arma::uvec& by_col_indices,
                         const arma::uvec& group_col_indices,
                         const arma::uvec& unit_col_indices);

#endif
