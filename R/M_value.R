#' @import data.table
M_value <- function(data, group, unit) {
  total <- sum(data[, fw])
  data[, Pg := sum(fw) / total, by = group]
  data[, Pn := sum(fw) / total, by = unit]
  data[, Png := fw / total]
  data[Pn > 0 & Pg > 0, Png_Pn_Pg := Png / (Pn * Pg)]
  data[Png_Pn_Pg > 0, log := log(Png_Pn_Pg, base = exp(1))]
  data[, Png_log := Png * log]
  M <- data[Png > 0, sum(Png_log)]
  M
}
