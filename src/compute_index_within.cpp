#include <vector>
#include <unordered_map>
#include "VectorHash.h"
#include "compute_index_within.h"

arma::mat compute_index_within(const arma::mat& DT_within,
                               const arma::uvec& by_col_indices,
                               const arma::uvec& p_col_indices,
                               const arma::uvec& within_col_indices) {

  arma::uword n_rows = DT_within.n_rows;
  // Mapa para almacenar la suma de p * within por grupo
  std::unordered_map<std::vector<int>, double, VectorHash> group_sums;

  // Construir el mapa de sumas por grupo
  for (arma::uword i = 0; i < n_rows; ++i) {
    // Construir la clave del grupo basada en las columnas 'by'
    std::vector<int> key(by_col_indices.n_elem);
    for (arma::uword j = 0; j < by_col_indices.n_elem; ++j) {
      key[j] = static_cast<int>(DT_within(i, by_col_indices(j)));
    }
    // Calcular el producto elemento a elemento de las columnas 'p' y 'within' para la fila actual
    double product = 0.0;
    for (arma::uword k = 0; k < p_col_indices.n_elem; ++k) {
      product += DT_within(i, p_col_indices(k)) * DT_within(i, within_col_indices(k));
    }
    // Acumular la suma para el grupo correspondiente
    group_sums[key] += product;
  }
  // Preparar la matriz de resultados
  arma::uword n_result_cols = by_col_indices.n_elem + 1; // Columnas 'by' + 'M_W'
  arma::mat result(group_sums.size(), n_result_cols);
  arma::uword result_row = 0;

  // Rellenar la matriz de resultados con las sumas calculadas
  for (const auto& group : group_sums) {
    const std::vector<int>& key = group.first;
    double sum = group.second;
    // Asignar los valores de 'by' al resultado
    for (arma::uword j = 0; j < by_col_indices.n_elem; ++j) {
      result(result_row, j) = key[j];
    }
    // Asignar la suma calculada 'M_W' al resultado
    result(result_row, by_col_indices.n_elem) = sum;
    ++result_row;
  }

  return result;
}
