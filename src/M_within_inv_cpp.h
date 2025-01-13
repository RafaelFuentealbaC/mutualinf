#ifndef M_WITHIN_INV_CPP_H
#define M_WITHIN_INV_CPP_H

#include <RcppArmadillo.h>

arma::mat M_within_inv_cpp(const arma::mat& data, arma::uvec group, arma::uvec unit, arma::uvec within);

#endif
