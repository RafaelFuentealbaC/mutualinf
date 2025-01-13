#ifndef COMPUTE_INDEX_WITHIN_H
#define COMPUTE_INDEX_WITHIN_H

#include <RcppArmadillo.h>

arma::mat compute_index_within(const arma::mat& DT_within,
                               const arma::uvec& by_col_indices,
                               const arma::uvec& p_col_indices,
                               const arma::uvec& within_col_indices);

#endif
