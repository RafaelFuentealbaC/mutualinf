#ifndef UPDATE_INDEXES_H
#define UPDATE_INDEXES_H

#include <RcppArmadillo.h>

arma::uvec update_indexes(const arma::uvec& original_indices, const arma::uvec& selected_columns);

#endif
