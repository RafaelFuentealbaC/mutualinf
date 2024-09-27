// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <RcppThread.h>
#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// M_valuerp
double M_valuerp(arma::mat data, arma::uvec group, arma::uvec unit);
RcppExport SEXP _mutualinf_M_valuerp(SEXP dataSEXP, SEXP groupSEXP, SEXP unitSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< arma::mat >::type data(dataSEXP);
    Rcpp::traits::input_parameter< arma::uvec >::type group(groupSEXP);
    Rcpp::traits::input_parameter< arma::uvec >::type unit(unitSEXP);
    rcpp_result_gen = Rcpp::wrap(M_valuerp(data, group, unit));
    return rcpp_result_gen;
END_RCPP
}
// get_internal_data_cpp
arma::mat get_internal_data_cpp(const arma::mat& data, const arma::uvec& vars);
RcppExport SEXP _mutualinf_get_internal_data_cpp(SEXP dataSEXP, SEXP varsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const arma::mat& >::type data(dataSEXP);
    Rcpp::traits::input_parameter< const arma::uvec& >::type vars(varsSEXP);
    rcpp_result_gen = Rcpp::wrap(get_internal_data_cpp(data, vars));
    return rcpp_result_gen;
END_RCPP
}
// get_proportion_cpp
arma::mat get_proportion_cpp(const arma::mat& data, const arma::uvec& within, const arma::uvec& by, double total);
RcppExport SEXP _mutualinf_get_proportion_cpp(SEXP dataSEXP, SEXP withinSEXP, SEXP bySEXP, SEXP totalSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const arma::mat& >::type data(dataSEXP);
    Rcpp::traits::input_parameter< const arma::uvec& >::type within(withinSEXP);
    Rcpp::traits::input_parameter< const arma::uvec& >::type by(bySEXP);
    Rcpp::traits::input_parameter< double >::type total(totalSEXP);
    rcpp_result_gen = Rcpp::wrap(get_proportion_cpp(data, within, by, total));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_mutualinf_M_valuerp", (DL_FUNC) &_mutualinf_M_valuerp, 3},
    {"_mutualinf_get_internal_data_cpp", (DL_FUNC) &_mutualinf_get_internal_data_cpp, 2},
    {"_mutualinf_get_proportion_cpp", (DL_FUNC) &_mutualinf_get_proportion_cpp, 4},
    {NULL, NULL, 0}
};

RcppExport void R_init_mutualinf(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
