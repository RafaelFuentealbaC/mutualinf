#include <RcppArmadillo.h>
#include <RcppThread.h>
#include <unordered_map>
#include <utility>
#include <vector>

using namespace Rcpp;
using namespace RcppThread;

// [[Rcpp::depends(RcppThread)]]
// [[Rcpp::plugins(cpp23)]]
// [[Rcpp::depends(RcppArmadillo)]]

// Función hash para vector<int>
struct VectorHash {
  size_t operator()(const std::vector<int>& v) const {
    std::hash<int> hasher;
    size_t seed = 0;
    //parallelFor(0, v, [&] (int i) {
    for (int i : v) {
      seed ^= hasher(i) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
    }
    //});
    return seed;
  }
};

// [[Rcpp::export]]
double M_valuerp(arma::mat data, arma::uvec group, arma::uvec unit) {
  // La última columna se asume como "fw"
  arma::vec fw = data.col(data.n_cols - 1);
  double total = arma::sum(fw);

  // Crear vectores para Pg y Pn
  arma::vec Pg(data.n_rows, arma::fill::zeros);
  arma::vec Pn(data.n_rows, arma::fill::zeros);

  // Crear un mapa para almacenar las combinaciones únicas y las sumas de `fw`
  std::unordered_map<std::vector<int>, double, VectorHash> group_sums;
  std::unordered_map<std::vector<int>, double, VectorHash> unit_sums;

  // Calcular las combinaciones únicas y sus sumas de `fw`
  for (unsigned int i = 0; i < data.n_rows; ++i) {
  //parallelFor(0, data.n_rows, [&] (int i) {
    //for (unsigned int i = 0; i < data.n_rows; ++i) {
    std::vector<int> group_key(group.n_elem);
    std::vector<int> unit_key(unit.n_elem);

    for (unsigned int j = 0; j < group.n_elem; ++j) {
      group_key[j] = data(i, group(j));
    }
    for (unsigned int j = 0; j < unit.n_elem; ++j) {
      unit_key[j] = data(i, unit(j));
    }

    group_sums[group_key] += fw(i);
    unit_sums[unit_key] += fw(i);
  };
  //});

  // Asignar valores de Pg y Pn basados en las combinaciones únicas
  parallelFor(0, data.n_rows, [&] (int i) {
  //for (unsigned int i = 0; i < data.n_rows; ++i) {
    std::vector<int> group_key(group.n_elem);
    std::vector<int> unit_key(unit.n_elem);

    for (unsigned int j = 0; j < group.n_elem; ++j) {
      group_key[j] = data(i, group(j));
    }
    for (unsigned int j = 0; j < unit.n_elem; ++j) {
      unit_key[j] = data(i, unit(j));
    }

    Pg(i) = group_sums[group_key] / total;
    Pn(i) = unit_sums[unit_key] / total;
  //}
  },6);

  // Calcular Png
  arma::vec Png = fw / total;

  // Calcular Png_Pn_Pg
  arma::vec Png_Pn_Pg = Png / (Pn % Pg);

  // Calcular log(Png_Pn_Pg)
  arma::vec log_val = arma::log(Png_Pn_Pg);

  // Calcular Png_log
  arma::vec Png_log = Png % log_val;

  // Calcular M
  double M = arma::accu(arma::nonzeros(Png_log));

  return M;
}


