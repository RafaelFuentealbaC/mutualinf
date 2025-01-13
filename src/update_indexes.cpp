#include "update_indexes.h"

arma::uvec update_indexes(const arma::uvec& original_indices, const arma::uvec& selected_columns) {
  arma::uvec updated_indices(original_indices.n_elem);
  for (size_t i = 0; i < original_indices.n_elem; ++i) {
    arma::uvec found_indices = arma::find(selected_columns == original_indices(i));
    if (found_indices.n_elem > 0) {
      updated_indices(i) = found_indices(0);
    }
  }
  return updated_indices;
}
