#' @title Segregation data in southern Chile
#' @description The data set included in this package was build using two data sets. The first one is the student
#' enrollment reported by the Ministry of Education (MINEDUC, \url{https://datosabiertos.mineduc.cl/}) for students of primary
#' education (first eight years of formal education) who attended establishments officially recognized by the State.
#' The second one is the Quality and Context of Education Questionnaire for Parents and Guardians, and the Student
#' Questionnaire, both applied by the Education Quality Agency (\url{https://www.agenciaeducacion.cl/}) to all students in
#' grades 4 and 8 of primary education. Both sources are limited to the period 2016-2018. Contains information related
#' to students and educational system characteristics in southern Chile (Biobio, La Araucania and Los Rios regions).
#' @format A \code{data.frame} with 191495 observations and 11 variables:
#' \describe{
#' \item{year}{Student enrollment year. From 2016 to 2018.}
#' \item{school}{School ID (RBD, Rol de Base de Datos).}
#' \item{district}{Administrative district where the school is located.}
#' \item{csep}{Preferential Scholar Subsidy Category (from the SpanishCategoría de Sub-vención Escolar Preferencial).
#'  Students belong to either the non-subsidized, the partially-subsidized, or the subsidized group acording to the
#'  Act 20.248 of Preferencial Scholar Subsidy (SEP).}
#' \item{ethnicity}{Self-reported Mapuche ethnicity. Students belong to Mapuche ethnicity or not.}
#' \item{rural}{School with multiage classrooms. The school is located in a urban zone or not.}
#' \item{region}{Administrative region where the school is located. Schools can belong either Biobio region,
#' La Araucania region or Los Rios region.}
#' \item{sch_type}{Whether the school is public, charter, or private.}
#' \item{gender}{Student gender code. Students can either be female or male.}
#' \item{grade}{Student grade. Students can either belong to the 4th (4) or 8th (8) grade of basic school.}
#' \item{nobs}{Number of students in a cell or combination of variables.}
#' }
#' @source Ministry of Education (MINEDUC): \url{https://datosabiertos.mineduc.cl/}
#'
#' Education Quality Agency: \url{https://www.agenciaeducacion.cl/}
"DF_Seg_Chile"


#' @title Segregation data in southern Chile
#' @description The data set included in this package was build using two data sets. The first one is the student
#' enrollment reported by the Ministry of Education (MINEDUC, \url{https://datosabiertos.mineduc.cl/}) for students of primary
#' education (first eight years of formal education) who attended establishments officially recognized by the State.
#' The second one is the Quality and Context of Education Questionnaire for Parents and Guardians, and the Student
#' Questionnaire, both applied by the Education Quality Agency (\url{https://www.agenciaeducacion.cl/}) to all students in
#' grades 4 and 8 of primary education. Both sources are limited to the period 2016-2018. Contains information related
#' to students and educational system characteristics in southern Chile (Biobio, La Araucania and Los Rios regions).
#' @format A \code{data.table} with 55960 observations and 11 variables:
#' \describe{
#' \item{year}{Student enrollment year. From 2016 to 2018.}
#' \item{school}{School ID (RBD, Rol de Base de Datos).}
#' \item{district}{Administrative district where the school is located.}
#' \item{csep}{Preferential Scholar Subsidy Category (from the SpanishCategoría de Sub-vención Escolar Preferencial).
#'  Students belong to either the non-subsidized, the partially-subsidized, or the subsidized group acording to the
#'  Act 20.248 of Preferencial Scholar Subsidy (SEP).}
#' \item{ethnicity}{Self-reported Mapuche ethnicity. Students belong to Mapuche ethnicity or not.}
#' \item{rural}{School with multiage classrooms. The school is located in a urban zone or not.}
#' \item{region}{Administrative region where the school is located. Schools can belong either Biobio region,
#' La Araucania region or Los Rios region.}
#' \item{sch_type}{Whether the school is public, charter, or private.}
#' \item{gender}{Student gender code. Students can either be female or male.}
#' \item{grade}{Student grade. Students can either belong to the 4th (4) or 8th (8) grade of basic school.}
#' \item{nobs}{Number of students in a cell or combination of variables.}
#' }
#' @source Ministry of Education (MINEDUC): \url{https://datosabiertos.mineduc.cl/}
#'
#' Education Quality Agency: \url{https://www.agenciaeducacion.cl/}
"DT_Seg_Chile"

#' @title Segregation data in southern Chile
#' @description The data set included in this package was build using two data sets. The first one is the student
#' enrollment reported by the Ministry of Education (MINEDUC, \url{https://datosabiertos.mineduc.cl/}) for students of primary
#' education (first eight years of formal education) who attended establishments officially recognized by the State.
#' The second one is the Quality and Context of Education Questionnaire for Parents and Guardians, and the Student
#' Questionnaire, both applied by the Education Quality Agency (\url{https://www.agenciaeducacion.cl/}) to all students in
#' grades 4 and 8 of primary education. Both sources are limited to 2018. Contains information related
#' to students and educational system characteristics in southern Chile (Biobio, La Araucania and Los Rios regions).
#' @format A \code{data.table} with 6703 observations and 5 variables, only for testing pourposes:
#' \describe{
#' \item{school}{School ID (RBD, Rol de Base de Datos).}
#' \item{csep}{Preferential Scholar Subsidy Category (from the SpanishCategoría de Sub-vención Escolar Preferencial).
#'  Students belong to either the non-subsidized, the partially-subsidized, or the subsidized group acording to the
#'  Act 20.248 of Preferencial Scholar Subsidy (SEP).}
#' \item{ethnicity}{Self-reported Mapuche ethnicity. Students belong to Mapuche ethnicity or not.}
#' \item{region}{Administrative region where the school is located. Schools can belong either Biobio region,
#' La Araucania region or Los Rios region.}
#' \item{fw}{Number of students in a cell or combination of variables.}
#' }
#' @source Ministry of Education (MINEDUC): \url{https://datosabiertos.mineduc.cl/}
#'
#' Education Quality Agency: \url{https://www.agenciaeducacion.cl/}
"DT_test"
