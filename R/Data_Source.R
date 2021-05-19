#' @title Segregation data in southern Chile
#' @description The data set included in this package was build using two data sets. The first one is the student enrollment reported by the Ministry of Education (MINEDUC) for students of primary education (first eight years of formal education) who attended establishments officially recognized by the State. The second one is the Quality and Context of Education Questionnaire for Parents and Guardians, and the Student Questionnaire, both applied by the Education Quality Agency to all students in grades 4 and 8 of primary education. Both sources are limited to the period 2016-2018.Contains information related to students and educational system characteristics in southern Chile (Bio-Bio, La Araucanía and Los Ríos Regions).
#' @format A data.frame with 682172 observations and 10 variables:
#' \describe{
#' \item{year}{Academic year. From 2016 to 2018.}
#' \item{school}{School ID (RBD, Rol de Base de Datos).}
#' \item{comuna}{Official commune code of the school location.}
#' \item{csep}{Socio-economic criterion. Students belong to either the non-vulnerable (1), the preferent (2), or the priority (3) group acording to the Act 20.248 of Preferencial Scholar Subsidy (SEP).}
#' \item{etnia}{Ethnicity criterion. Students belong to mapuche ethnicity (1) or not (0).}
#' \item{rural}{Rurality criterion. The school is located in a urban zone (0) or not (1).}
#' \item{region}{Official region code of the school location. Schools can belong either Bio-Bío region (8), Araucanía region (9) or
#' Los Ríos region (14).}
#' \item{sch_type}{Dependency code. School dependancy as municipal (1), private subsidized (2) or private paid (3).}
#' \item{gender}{Binary student gender. Students can either be female (1) or male (2).}
#' \item{grade}{Student grade. Students can either belong to the 4th (4) or 8th (8) grade of basic school.}
#' \item{nobs}{Number of students in a cell or combination of variables.}
#' }
#' @source <https://github.com/RafaelFuentealbaC/mutualinf>
#'
#' <http://datosabiertos.mineduc.cl/>
#'
#' <http://www.agenciaeducacion.cl/>
"DF_Seg_Chile"


#' @title Segregation data of the south zone of Chile
#' @description Contains information related to students and educational system characteristics of the south zone of Chile
#' between year 2016 and 2018. The data was be obtain from the DatosAbiertos platform of the Study Center of the Ministry of
#' Education <http://datosabiertos.mineduc.cl/> and SIMCE data of the Education Quality Agency
#' <http://www.agenciaeducacion.cl/>.
#' @format A data.table with 53202 observations and 10 variables:
#' \describe{
#' \item{year}{school year. Can be 2016, 2017 or 2018.}
#' \item{school}{establishment database role.}
#' \item{comuna}{official code of commune in which the establishment is located.}
#' \item{csep}{socio-economic criterion. Organizated students in Non-Vulnerables (1), Preferents (2), Prioritaries (3).}
#' \item{etnia}{ethnicity criterion. Students does not belongs to indigenous people (0) or students does belong to
#' indigenous people (1).}
#' \item{rural}{rurality criterion. The establishment is located in urban zone (0) or is located in rural zone (1).}
#' \item{region}{Region code where the establishment is located. Can be either in the Bio-Bío region (8), the Araucanía region (9) or
#' the Los Ríos region (14).}
#' \item{sch_type}{dependency code. Dependency of the establishment can be municipal (1), subsidized private (2) or paid
#' private (3).}
#' \item{gender}{sex of student. Students can be female (1) or male (2).}
#' \item{fw}{number of students.}
#' }
#' @source <https://github.com/RafaelFuentealbaC/mutualinf>
#'
#' <http://datosabiertos.mineduc.cl/>
#'
#' <http://www.agenciaeducacion.cl/>
"DT_Seg_Chile"
