#include <vector>
#include <unordered_map>
#include "VectorHash.h"
#include "get_internal_data_cpp.h"
#include "M_value_cpp.h"
#include "lapply_M_value.h"

arma::mat lapply_M_value(const arma::mat& data_tmp,
                         const arma::uvec& by_col_indices,
                         const arma::uvec& group_col_indices,
                         const arma::uvec& unit_col_indices) {

  arma::uword n_rows = data_tmp.n_rows;

  // Mapa para agrupar índices de filas por combinaciones únicas de 'by'
  std::unordered_map<std::vector<int>, std::vector<arma::uword>, VectorHash> group_map;

  // Construir el mapa de grupos
  for (arma::uword i = 0; i < n_rows; ++i) {
    std::vector<int> by_key(by_col_indices.n_elem);
    for (arma::uword j = 0; j < by_col_indices.n_elem; ++j) {
      by_key[j] = static_cast<int>(data_tmp(i, by_col_indices(j)));
    }
    group_map[by_key].push_back(i);
  }

  // Preparar la matriz de resultados
  arma::mat result(group_map.size(), by_col_indices.n_elem + 1); // Columnas 'by' + columna para 'M'
  arma::uword result_row = 0;

  for (const auto& group : group_map) {
    // Obtener índices para el grupo actual
    const std::vector<arma::uword>& indices = group.second;
    arma::uvec idx = arma::conv_to<arma::uvec>::from(indices);

    // Extraer submatriz 'd' para el grupo actual
    arma::mat d = data_tmp.rows(idx);

    // Combinar group_col_indices y unit_col_indices en 'vars'
    arma::uvec vars = arma::join_vert(group_col_indices, unit_col_indices);

    // Llamar a get_internal_data en 'd' con 'vars'
    arma::mat data_tmp_internal = get_internal_data_cpp(d, vars);

    // Calcular M_value en 'data_tmp_internal' con 'group_col_indices' y 'unit_col_indices'
    double M = M_value_cpp(data_tmp_internal, group_col_indices, unit_col_indices);

    // Extraer valores 'by' (son los mismos para todo el grupo)
    const std::vector<int>& by_value = group.first;

    // Almacenar 'by_value' y 'M' en el resultado
    for (arma::uword j = 0; j < by_col_indices.n_elem; ++j) {
      result(result_row, j) = by_value[j];
    }
    result(result_row, by_col_indices.n_elem) = M;

    ++result_row;
  }

  return result;
}
