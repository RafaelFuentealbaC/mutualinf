#include <vector>
#include <unordered_map>
#include "VectorHash.h"
#include "get_internal_data_cpp.h"

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
