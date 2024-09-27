#include <RcppArmadillo.h>
#include <unordered_map>
#include <vector>
#include <RcppThread.h>

using namespace Rcpp;
using namespace RcppThread;

// [[Rcpp::depends(RcppArmadillo, RcppThread)]]
// [[Rcpp::plugins(cpp23)]]

// Estructura hash para combinar claves de grupos
struct VectorHash {
  size_t operator()(const std::vector<int>& v) const {
    std::hash<int> hasher;
    size_t seed = 0;
    for (int i : v) {
      seed ^= hasher(i) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
    }
    return seed;
  }
};

// Función para replicar el comportamiento de get_internal_data en C++
// [[Rcpp::export]]
arma::mat get_internal_data_cpp(const arma::mat& data, const arma::uvec& vars) {
  // La última columna se asume como "fw" (frecuencia)
  arma::vec fw = data.col(data.n_cols - 1);

  // Usar un mapa hash para agrupar las combinaciones únicas y acumular la suma de `fw`
  std::unordered_map<std::vector<int>, double, VectorHash> group_sums;

  // Recorrer todas las filas y agrupar por las columnas indicadas en `vars`
  for (unsigned int i = 0; i < data.n_rows; ++i) {
    std::vector<int> key(vars.n_elem);
    for (unsigned int j = 0; j < vars.n_elem; ++j) {
      key[j] = data(i, vars(j));  // Obtener el valor de cada columna de `vars` en la fila i
    }
    group_sums[key] += fw(i);  // Acumular el valor de `fw` para esta combinación de grupos
  }

  // Crear una matriz para almacenar el resultado (combinaciones únicas y la suma de `fw`)
  arma::mat result(group_sums.size(), vars.n_elem + 1);

  // Rellenar la matriz de resultados con las combinaciones únicas y las sumas
  unsigned int row = 0;
  for (const auto& kv : group_sums) {
    for (unsigned int j = 0; j < kv.first.size(); ++j) {
      result(row, j) = kv.first[j];  // Asignar las combinaciones únicas de los grupos
    }
    result(row, kv.first.size()) = kv.second;  // Asignar la suma de `fw`
    ++row;
  }

  return result;  // Devolver la matriz resultante
}
