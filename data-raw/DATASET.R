## code to prepare `DATASET` dataset goes here

DF_Seg_Ar <- read.csv("data-raw/DF_Seg_Ar.csv", header = TRUE, sep = ",")
usethis::use_data(DF_Seg_Ar, overwrite = TRUE)

DT_Seg_Ar <- prepare_data(data = DF_Seg_Ar, vars = c("year", "school", "comuna", "csep", "etnia", "rural", "region", "sch_type", "gender"), fw = "nobs")
usethis::use_data(DT_Seg_Ar, overwrite = TRUE)
