## code to prepare `DATASET` dataset goes here

DF_Seg_Chile <- read.csv("data-raw/DF_Seg_Chile.csv", header = TRUE, sep = ",")
usethis::use_data(DF_Seg_Chile, overwrite = TRUE)

DT_Seg_Chile <- prepare_data(data = DF_Seg_Chile, vars = "all_vars", fw = "nobs", col.order = "region")
usethis::use_data(DT_Seg_Chile, overwrite = TRUE)

DT_test <- prepare_data(data = DF_Seg_Chile, vars = c("school", "csep", "ethnicity", "region", "year", "grade"), fw = "nobs",
                        col.order = "region")
DT_test <- DT_test[year == 2018 & grade == 4, ]
DT_test <- DT_test[, -c("year", "grade")]
usethis::use_data(DT_test, overwrite = TRUE)
