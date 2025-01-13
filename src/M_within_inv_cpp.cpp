#include <vector>
#include "get_internal_data_cpp.h"
#include "update_indexes.h"
#include "get_proportion_cpp.h"
#include "M_value_cpp.h"
#include "lapply_M_value.h"
#include "compute_index_within.h"
#include "order_ascend_rows.h"
#include "M_within_inv_cpp.h"

arma::mat M_within_inv_cpp(const arma::mat& data, arma::uvec group, arma::uvec unit, arma::uvec within) {
  double total = arma::sum(data.col(data.n_cols - 1));
  arma::uvec within_tmp;
  if (within.n_elem > 1) {
    arma::mat result;
    std::vector<double> list_index_between;

    arma::vec vec_p_within;
    arma::vec comp_within;

    for (size_t w = 0; w < within.n_elem; ++w) {
      if (w == 0) {
        arma::uvec combined_vars = arma::join_cols(arma::join_cols(group, unit), arma::uvec{within(w)});
        arma::mat data_tmp_input = get_internal_data_cpp(data, combined_vars);

        arma::uvec new_group = update_indexes(group, combined_vars);
        arma::uvec new_unit= update_indexes(unit, combined_vars);
        arma::uvec new_within = arma::uvec{static_cast<arma::uword>(combined_vars.n_elem - 1)};

        arma::mat data_tmp = get_internal_data_cpp(data_tmp_input, arma::join_cols(new_group, new_unit));

        double index_between = 0.0;
        if (arma::any(group == within(w))) {
          data_tmp = get_internal_data_cpp(data_tmp_input, arma::join_cols(new_within, new_unit));
          new_within = update_indexes(new_within, arma::join_cols(new_within, new_unit));
          new_unit = update_indexes(new_unit, arma::join_cols(new_within, new_unit));

          index_between = M_value_cpp(data_tmp, new_within, new_unit);
          arma::uvec indices_to_keep = arma::find(group != within(w));
          group = group.elem(indices_to_keep);

        } else if (arma::any(unit == within(w))) {
          data_tmp = get_internal_data_cpp(data_tmp_input, arma::join_cols(new_group, new_within));
          new_group = update_indexes(new_group, arma::join_cols(new_group, new_within));
          new_within = update_indexes(new_within, arma::join_cols(new_group, new_within));

          index_between = M_value_cpp(data_tmp, new_group, new_within);
          arma::uvec indices_to_keep = arma::find(unit != within(w));
          unit = unit.elem(indices_to_keep);
        } else {Rcpp::stop("Computation requires that %d belongs to either 'group' or 'unit'.", within(w));}

        arma::mat DT_p = get_proportion_cpp(data_tmp_input, new_within, arma::uvec(), total);

        DT_p = order_ascend_rows(DT_p, new_within.n_elem);

        new_group = update_indexes(group, combined_vars);
        new_unit = update_indexes(unit, combined_vars);
        new_within = arma::uvec{static_cast<arma::uword>(combined_vars.n_elem - 1)};

        data_tmp = get_internal_data_cpp(data_tmp_input, arma::join_cols(new_group, new_unit, new_within));

        combined_vars = arma::join_cols(arma::join_cols(new_group, new_unit), arma::uvec{new_within});
        new_group = update_indexes(new_group, combined_vars);
        new_unit= update_indexes(new_unit, combined_vars);
        new_within = arma::uvec{static_cast<arma::uword>(combined_vars.n_elem - 1)};

        arma::mat M_list = lapply_M_value(data_tmp, new_within, new_group, new_unit);
        M_list = order_ascend_rows(M_list, new_within.n_elem);

        comp_within = M_list.col(M_list.n_cols - 1);

        list_index_between.push_back(index_between);

        arma::mat vec_p_within_mat = get_proportion_cpp(data, arma::uvec{within[w]}, arma::uvec(), total);
        vec_p_within_mat = order_ascend_rows(vec_p_within_mat, arma::uvec{within[w]}.n_elem);

        vec_p_within = vec_p_within_mat.col(vec_p_within_mat.n_cols - 1);

      } else {
        arma::uvec combined_vars = arma::join_cols(arma::join_cols(group, unit), arma::join_cols(arma::uvec{within(w)}, within_tmp));
        arma::mat data_tmp_input = get_internal_data_cpp(data, combined_vars);

        arma::uvec new_group_input = update_indexes(group, combined_vars);
        arma::uvec new_unit_input = update_indexes(unit, combined_vars);
        arma::uvec new_within_input = update_indexes(arma::uvec{within(w)}, combined_vars);
        arma::uvec new_by_input = update_indexes(within_tmp, combined_vars);

        arma::mat data_tmp = get_internal_data_cpp(data_tmp_input, arma::join_cols(new_group_input, new_unit_input, new_by_input));

        arma::uvec combined_vars2 = arma::join_cols(new_group_input, new_unit_input, new_by_input);
        arma::uvec new_group = update_indexes(new_group_input, combined_vars2);
        arma::uvec new_unit= update_indexes(new_unit_input, combined_vars2);
        arma::uvec new_by = update_indexes(new_by_input, combined_vars2);;

        arma::mat index_total = lapply_M_value(data_tmp, new_by, new_group, new_unit);
        index_total = order_ascend_rows(index_total, new_by.n_elem);

        arma::mat index_between;
        if (arma::any(group == within(w))) {
          combined_vars2 = arma::join_cols(new_within_input, new_unit_input, new_by_input);
          data_tmp = get_internal_data_cpp(data_tmp_input, combined_vars2);
          arma::uvec new_within = update_indexes(new_within_input, combined_vars2);
          new_unit = update_indexes(new_unit_input, combined_vars2);
          new_by = update_indexes(new_by_input, combined_vars2);

          index_between = lapply_M_value(data_tmp, new_by, new_within, new_unit);
          index_between = order_ascend_rows(index_between, new_by.n_elem);

          arma::uvec indices_to_keep = arma::find(group != within(w));
          group = group.elem(indices_to_keep);

        } else if (arma::any(unit == within(w))) {
          combined_vars2 = arma::join_cols(new_group_input, new_within_input, new_by_input);
          data_tmp = get_internal_data_cpp(data_tmp_input, combined_vars2);
          new_group = update_indexes(new_group_input, combined_vars2);
          arma::uvec new_within = update_indexes(new_within_input, combined_vars2);
          new_by = update_indexes(new_by_input, combined_vars2);

          index_between = lapply_M_value(data_tmp, new_by, new_group, new_within);
          index_between = order_ascend_rows(index_between, new_by.n_elem);

          arma::uvec indices_to_keep = arma::find(unit != within(w));
          unit = unit.elem(indices_to_keep);
        } else {Rcpp::stop("Computation requires that %d belongs to either 'group' or 'unit'.", within(w));}

        arma::mat DT_p = get_proportion_cpp(data_tmp_input, new_within_input, new_by_input);
        DT_p = order_ascend_rows(DT_p, DT_p.n_cols - 1);

        arma::uvec within_p = new_within_input;
        arma::uvec by_p = new_by_input;

        new_group = update_indexes(group, combined_vars);
        new_unit = update_indexes(unit, combined_vars);
        new_by = update_indexes(within_tmp, combined_vars);
        new_within_input = update_indexes(arma::uvec{within(w)}, combined_vars);
        arma::uvec new_within_general = update_indexes(within, combined_vars);

        data_tmp = get_internal_data_cpp(data_tmp_input, arma::join_cols(new_group, new_unit, new_by, new_within_general));

        combined_vars = arma::join_cols(new_group, new_unit, new_by, new_within_general);
        new_group = update_indexes(new_group, combined_vars);
        new_unit = update_indexes(new_unit, combined_vars);
        new_by = update_indexes(arma::join_cols(new_by, new_within_input), combined_vars);

        arma::mat M_list_final = lapply_M_value(data_tmp, new_by, new_group, new_unit);
        M_list_final = order_ascend_rows(M_list_final, new_by.n_elem);

        comp_within = M_list_final.col(M_list_final.n_cols - 1);

        arma::mat DT_within = arma::join_horiz(DT_p, comp_within);

        new_within_input = update_indexes(within, arma::join_cols(within_p, by_p));
        arma::uvec new_p = {DT_within.n_cols-1};
        new_by = update_indexes(within_tmp, arma::join_cols(within_p, by_p));

        arma::mat index_within = compute_index_within(DT_within, new_by, new_p, new_within_input);
        index_within = order_ascend_rows(index_within, new_by.n_elem);


        list_index_between.push_back(arma::sum(vec_p_within % index_between.col(index_between.n_cols - 1)));

        arma::uvec within_tmp_w = arma::join_cols(within_tmp, arma::uvec{within[w]});

        arma::mat vec_p_within_mat = get_proportion_cpp(data, arma::join_cols(within_tmp, arma::uvec{within[w]}), arma::uvec(), total);

        arma::uvec vars_vec_p = arma::join_cols(within_tmp, arma::uvec{within[w]});

        vec_p_within_mat = order_ascend_rows(vec_p_within_mat, vars_vec_p.n_elem);

        vec_p_within = vec_p_within_mat.col(vec_p_within_mat.n_cols - 1);

        if (w == within.n_elem - 1) {
          data_tmp = get_internal_data_cpp(data, arma::join_cols(group, unit, within));

          arma::uvec final_group = update_indexes(group, arma::join_cols(group, unit, within));
          arma::uvec final_unit = update_indexes(unit, arma::join_cols(group, unit, within));
          arma::uvec final_within = update_indexes(within, arma::join_cols(group, unit, within));

          arma::mat M_list = lapply_M_value(data_tmp, final_within, final_group, final_unit);
          M_list = order_ascend_rows(M_list, final_within.n_elem);

          comp_within = M_list.col(M_list.n_cols - 1);
        }
      }

      if (arma::any(group == within(w))) {
        arma::uvec filtered_group_indices = arma::find(group != within(w));
        group = arma::conv_to<arma::uvec>::from(group.elem(filtered_group_indices));
      }
      if (arma::any(unit == within(w))) {
        arma::uvec filtered_unit_indices = arma::find(unit != within(w));
        unit = arma::conv_to<arma::uvec>::from(unit.elem(filtered_unit_indices));
      }

      within_tmp.insert_rows(within_tmp.n_elem, 1);
      within_tmp(within_tmp.n_elem - 1) = within[w];
    }

    double index_between_sum = std::accumulate(list_index_between.begin(), list_index_between.end(), 0.0);

    arma::mat DT_p = get_proportion_cpp(data, within, arma::uvec(), total);
    DT_p = order_ascend_rows(DT_p, within.n_elem);

    double index_within = arma::sum(DT_p.col(DT_p.n_cols - 1) % comp_within);

    double index_total = index_between_sum + index_within;

    arma::rowvec list_index_between_arma = arma::conv_to<arma::rowvec>::from(list_index_between);
    arma::rowvec fila_completa = arma::join_horiz(arma::rowvec(1).fill(index_total), list_index_between_arma);
    fila_completa = arma::join_horiz(fila_completa, arma::rowvec(1).fill(index_within));

    result = arma::join_vert(result, fila_completa);

    return result;

  } else {
    arma::uvec combined_vars = arma::join_cols(group, unit);
    arma::mat data_tmp = get_internal_data_cpp(data, combined_vars);

    arma::uvec new_group = update_indexes(group, combined_vars);
    arma::uvec new_unit = update_indexes(unit, combined_vars);
    arma::uvec new_within = update_indexes(within, combined_vars);

    double index_total = M_value_cpp(data_tmp, new_group, new_unit);

    double index_between = 0.0;
    if (arma::any(group == within(0))) {
      data_tmp = get_internal_data_cpp(data_tmp, arma::join_cols(new_within, new_unit));

      new_within = update_indexes(new_within, arma::join_cols(new_within, new_unit));
      new_unit = update_indexes(new_unit, arma::join_cols(new_within, new_unit));

      index_between = M_value_cpp(data_tmp, new_within, new_unit);

      arma::uvec indices_to_keep = arma::find(group != within(0));
      group = group.elem(indices_to_keep);

    } else if (arma::any(unit == within(0))) {
      data_tmp = get_internal_data_cpp(data_tmp, arma::join_cols(new_group, new_within));

      new_group = update_indexes(new_group, arma::join_cols(new_group, new_within));
      new_within = update_indexes(new_within, arma::join_cols(new_group, new_within));

      index_between = M_value_cpp(data_tmp, new_group, new_within);

      arma::uvec indices_to_keep = arma::find(unit != within(0));
      unit = unit.elem(indices_to_keep);

    } else {Rcpp::stop("Computation requires that %d belongs to either 'group' or 'unit'.", within(0));}

    arma::mat DT_p = get_proportion_cpp(data, within, arma::uvec(), total);
    DT_p = order_ascend_rows(DT_p, DT_p.n_cols - 1);

    data_tmp = get_internal_data_cpp(data, arma::join_cols(group, unit, within));

    new_group = update_indexes(group, arma::join_cols(group, unit, within));
    new_unit = update_indexes(unit, arma::join_cols(group, unit, within));
    arma::uvec by = update_indexes(within, arma::join_cols(group, unit, within));

    arma::mat M_list = lapply_M_value(data_tmp, by, new_group, new_unit);
    M_list = order_ascend_rows(M_list, by.n_elem);

    arma::vec comp_within = M_list.col(M_list.n_cols - 1);

    double index_within = arma::sum(DT_p.col(DT_p.n_cols - 1) % comp_within);

    arma::mat result(1, 3);
    result(0, 0) = index_total;
    result(0, 1) = index_between;
    result(0, 2) = index_within;

    return result;
  }
}
