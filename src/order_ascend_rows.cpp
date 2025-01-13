#include "order_ascend_rows.h"

arma::mat order_ascend_rows(const arma::mat& M, int n) {
  // Validar que n esté dentro del rango de columnas de la matriz
  // Inicialmente, todos los índices en orden natural
  arma::uvec order_indexes = arma::regspace<arma::uvec>(0, M.n_rows - 1);

  // Ordenar sucesivamente por cada columna, empezando desde la última
  for (int col = n - 1; col >= 0; --col) {
    // Obtener la columna completa
    arma::vec column = M.col(col);
    // Seleccionar los elementos de la columna según los índices actuales
    arma::vec select_column = column.elem(order_indexes);
    // Obtener los nuevos índices basados en la columna actual
    arma::uvec new_indexes = arma::stable_sort_index(select_column);
    // Actualizar los índices totales
    order_indexes = order_indexes.elem(new_indexes);
  }
  // Reordenar la matriz basada en los índices ordenados
  arma::mat M_order = M.rows(order_indexes);

  return M_order;
}
