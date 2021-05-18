## code to prepare `DATASET` dataset goes here

DF_Seg_Chile <- read.csv("data-raw/DF_Seg_Chile.csv", header = TRUE, sep = ",")
usethis::use_data(DF_Seg_Chile, overwrite = TRUE)

DT_Seg_Chile <- prepare_data(data = DF_Seg_Chile, vars = c("year", "school", "comuna", "csep", "etnia", "rural", "region",
                                                           "sch_type", "gender"), fw = "nobs", col.order = "region")
usethis::use_data(DT_Seg_Chile, overwrite = TRUE)
