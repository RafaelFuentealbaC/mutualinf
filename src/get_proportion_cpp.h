#ifndef GET_PROPORTION_CPP_H
#define GET_PROPORTION_CPP_H

#include <RcppArmadillo.h>

arma::mat get_proportion_cpp(const arma::mat& data, const arma::uvec& within, const arma::uvec& by = arma::uvec(), double total = -1);

#endif
