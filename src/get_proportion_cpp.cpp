#include <vector>
#include <unordered_map>
#include "VectorHash.h"
#include "get_proportion_cpp.h"

arma::mat get_proportion_cpp(const arma::mat& data, const arma::uvec& within, const arma::uvec& by, double total) {
  // La última columna se asume como "fw" (frecuencia)
  arma::vec fw = data.col(data.n_cols - 1);
  // Si no se ha proporcionado un valor total, lo calculamos
  if (total < 0) {
    total = arma::sum(fw);
  }
  // Mapas hash para acumular sumas de `fw` en diferentes combinaciones
  std::unordered_map<std::vector<int>, double, VectorHash> sum_within;
  std::unordered_map<std::vector<int>, double, VectorHash> sum_by_within;

  // Verificar si el parámetro `by` está vacío
  if (!by.is_empty()) {
    // Primera parte: Calcular las sumas de `fw` por las combinaciones de `by` y `within`
    for (unsigned int i = 0; i < data.n_rows; ++i) {
      std::vector<int> key_by_within(by.n_elem + within.n_elem);
      // Obtener las claves de `by`
      for (unsigned int j = 0; j < by.n_elem; ++j) {
        key_by_within[j] = data(i, by(j));
      }
      // Obtener las claves de `within`
      for (unsigned int j = 0; j < within.n_elem; ++j) {
        key_by_within[by.n_elem + j] = data(i, within(j));
      }
      // Acumular las sumas
      sum_by_within[key_by_within] += fw(i);
    }

    // Segunda parte: Calcular las sumas de `fw` solo para las combinaciones de `by`
    std::unordered_map<std::vector<int>, double, VectorHash> sum_by;
    for (unsigned int i = 0; i < data.n_rows; ++i) {
      std::vector<int> key_by(by.n_elem);
      // Obtener las claves de `by`
      for (unsigned int j = 0; j < by.n_elem; ++j) {
        key_by[j] = data(i, by(j));
      }
      // Acumular las sumas
      sum_by[key_by] += fw(i);
    }
    // Crear la matriz de salida para almacenar las proporciones
    arma::mat result(sum_by_within.size(), by.n_elem + within.n_elem + 1);

    // Calcular las proporciones dividiendo las sumas
    unsigned int row = 0;
    for (const auto& kv : sum_by_within) {
      std::vector<int> key_by(by.n_elem);
      // Obtener la clave para `by` y buscar su suma
      for (unsigned int j = 0; j < by.n_elem; ++j) {
        key_by[j] = kv.first[j];
        result(row, j) = kv.first[j];
      }
      // Añadir las claves para `within`
      for (unsigned int j = 0; j < within.n_elem; ++j) {
        result(row, by.n_elem + j) = kv.first[by.n_elem + j];
      }
      // Dividir la suma de `by_within` entre la suma de `by`
      result(row, by.n_elem + within.n_elem) = kv.second / sum_by[key_by];
      ++row;
    }
    return result;

  } else {
    // Si `by` está vacío, calcular las sumas de `fw` solo para `within`
    for (unsigned int i = 0; i < data.n_rows; ++i) {
      std::vector<int> key_within(within.n_elem);
      // Obtener las claves de `within`
      for (unsigned int j = 0; j < within.n_elem; ++j) {
        key_within[j] = data(i, within(j));
      }
      // Acumular las sumas
      sum_within[key_within] += fw(i);
    }
    // Crear la matriz de salida para almacenar las proporciones
    arma::mat result(sum_within.size(), within.n_elem + 1);

    // Calcular las proporciones dividiendo entre el total
    unsigned int row = 0;
    for (const auto& kv : sum_within) {
      for (unsigned int j = 0; j < within.n_elem; ++j) {
        result(row, j) = kv.first[j];
      }
      result(row, within.n_elem) = kv.second / total;
      ++row;
    }
    return result;
  }
}
