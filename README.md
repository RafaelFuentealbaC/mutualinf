
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mutualinf

<!-- badges: start -->

[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
<!-- badges: end -->

An R library to calculate and decompose the Mutual Information Index (M)
introduced to the social sciences by Theil and Finizza (1971). The M
index is a multigroup segregation measure that is highly decomposable,
satisfiying both the Strong Unit Decomposability (SUD) and the Strong
Group Decomposability (SGD) properties (Frankel and Volij, 2011; Mora
and Ruiz-Castillo, 2011).

The library allows for:

  - The computation of the M index, either overall or over subsamples
    defined by the user.
  - The descomposition of the M index into a “between” and a “within”
    term.
  - The identification of the “exclusive contributions” of segregation
    sources defined either by group or unit characteristics.
  - The computation of all the elements that conform the “within” term
    in the decomposition.
  - Fast computation employing more than one CPU core in Mac, Linux,
    Unix, and BSD systems. This option uses the
    [`data.table`](https://CRAN.R-project.org/package=data.table) and
    [`parallel`](https://stat.ethz.ch/R-manual/R-devel/library/parallel/doc/parallel.pdf)
    libraries (which Windows does not permit to run with more than one
    CPU core).

## Installation

You can install the stable version of \[`mutualinf`\] from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("mutualinf")
```

and the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("RafaelFuentealbaC/mutualinf")
```

## Functions

The package provides two functions:

``` r
?prepare_data 
```

  - Which prepares the data to be used by the `mutual`function. For more
    details see `help(prepare_data)`.

<!-- end list -->

``` r
?mutual
```

  - Which computes the M index and its decompositions. For more details
    see `help(mutual)`.

## Usage

The library computes the M Index. Suponga que tiene datos chilenos para
el período 2016-2018 de frecuencias de estudiantes (`nobs`) por
combinaciones de, entre otras variables, escuela (`school`), distrito
(`commune`), etnia (`ethnicity`), y nivel socio económico (`csep`) en un
objeto de formato tabular (data.frame, data.table, tibble). El primer
paso es cargar el paquete y usar la función prepare\_data para declarar
la columna que incluye las frecuencias y para formatear los datos para
la función `mutual`:

``` r
library(mutualinf)

DT_Seg_Chile_1 <- prepare_data(data = DF_Seg_Chile, vars = "all_vars", fw = "nobs")
```

Si se elige `vars = "all_vars"`, entonces `prepare_data` utiliza todas
las columnas de la tabla. Es útil usar la opción `vars` con tablas que
tienen gran cantidad de columnas que no son necesarias en el análisis.
Por
ejemplo:

``` r
DT_Seg_Chile_1 <- prepare_data(data = DF_Seg_Chile, vars = c("school","csep"), fw = "nobs")
```

prepara los datos para poder hacer, como veremos más adelante, un
análisis de segregación socioeconómica por escuela. Si se desea hacer
adicionalmente un análisis de segregación por etnia en las escuelas, la
preparación de los datos puede recoger todas las columnas
relevantes:

``` r
DT_Seg_Chile_1 <- prepare_data(data = DF_Seg_Chile, vars = c("school","csep","ethnicity"), fw = "nobs")
```

Si los datos vienen completamente desagregados, `prepare_data` calculará
las frecuencias para todas las celdas de combinación de las variables
especificadas:

``` r
DT_Seg_Chile_2 <- prepare_data(data = DF_Seg_Chile, vars = "all_vars")
```

La función `mutual`permite calcular el índice M en su forma más simple,
es decir, sobre una dimensión grupal de segregación con respecto a una
unidad de análisis. Para calcular la segregración socioeconómica por
escuelas:

``` r
mutual(data = DT_Seg_Chile, group = "csep", unit = "school")
#>            M
#> 1: 0.1995499
```

Para calcular la segregación étnica por escuelas:

``` r
mutual(data = DT_Seg_Chile, group = "ethnicity", unit = "school")
#>             M
#> 1: 0.06213906
```

La función `mutual`también permite utilizar múltiples dimensiones
grupales sobre las que se calcula la segregación, usando las
combinaciones de las mismas sobre las unidades de análisis. Por
ejemplo:

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = "school")
#>            M
#> 1: 0.2610338
```

calcula la segregación socioeconómica y étnica en las escuelas. Los
grupos sobre los que se calcula la segregación automáticamente se
definen por todas las combinaciones de nivel socioeconómico y de
pertenencia étnica de los estudiantes que se producen en la base de
datos. Como podemos ver, la segregación obtenida considerando
simultáneamente el nivel socioeconómico y la etnia es mayor que las
obtenidas por separado.

De igual manera, se puede realizar el análisis de la segregación
utilizando múltiples dimensiones unitarias y/o grupales. Por
ejemplo:

``` r
mutual(data = DT_Seg_Chile, group = c("csep","ethnicity"), unit = c("school", "commune"))
#>            M
#> 1: 0.2610338
```

calcula la segregación socioeconómica y étnica en las combinaciones de
escuelas y distritos. Claramente, el resultado es un nivel de
segregación idéntico al obtenido en el caso anterior, pues cada escuela
sólo pertenece a un distrito (los distritos son una partición de las
escuelas).

Las variables que definen las unidades pueden no tener una relación
jerárquica entre ellas. Por ejemplo, si cambiamos los distritos por la
dependencia administrativa de las escuelas (`sch_type`, que puede ser
privada, pública y
subvencionada):

``` r
 mutual(data = DT_Seg_Chile, group = c("csep","ethnicity"), unit = c("school", "sch_type"))
#>            M
#> 1: 0.2610865
```

calcula la segregación en unidades definidas por las combinaciones de
escuelas y tipos de escuelas, de grupos definidos por las combinaciones
de nivel socioeconómico y étnia. En las unidades no existe una
estructura jerárquica pues hay escuelas que cambián su dependencia
administrativa en el período muestral.

La opción `by`de la función `mutual`permite generar submuestras sobre
las que se calcula el nivel de segregación. Los datos utilizados como
ilustración incluyen las escuelas de formación primaria de las regiones
chilenas del Biobio, La Araucania, y Los Rios. La opción `by`permite
obtener el nivel de segregación para cada una de las tres regiones en un
solo
comando:

``` r
 mutual(data = DT_Seg_Chile, group = c("csep","ethnicity"), unit = c("school", "sch_type"), by = "region")
#>          region         M
#> 1:       Biobio 0.2312423
#> 2: La Araucania 0.2367493
#> 3:     Los Rios 0.2125013
```

### REVISAR ESTO DE ACUERDO AL OUTPUT\!\!\!

En este caso, la función reporta el nombre de cada región acompañado de
su respectivo índice. Podemos ver que la segregación es mayor en la
región del Biobio que en las regiones de La Araucania y Los Rios, y a
su vez, es mayor que la segregación socioeconómica en las escuelas de
las tres regiones conjuntas.

La opción `within`de la función `mutual`permite descomponer el índice de
segregación total en sus términos “between” y
“within”.

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = c("school", "sch_type"),
        by = "region", within = "csep")
#>          region         M  M_B_csep   M_W_csep
#> 1:       Biobio 0.2312423 0.2030819 0.02816039
#> 2: La Araucania 0.2367493 0.1906641 0.04608521
#> 3:     Los Rios 0.2125013 0.1774420 0.03505928
```

Obtenemos tres términos para cada región. El primero, `M` coincide con
los valores totales sin la opción `within` El segundo, `M\_B\_csep`
conocido como término “between”, es la segregación socioeconómica en las
combinaciones de escuelas y tipos de escuelas. El tercero, `M\_W\_csep`
conocido como término “within”, es la combinacion lineal de los niveles
de segregacion étnica obtenidos dentro de cada nivel socioeconomico (con
pesos iguales a la importancia demográfica de cada nivel). Este termino
“within” se puede interpretar como la parte de la segregacion total
derivada exclusivamente de diferencias etnicas. A partir de este punto
nos referiremos a esta última segregación como “la contribución”, en
este caso, de etnia.

También es posible obtener la descomposición del índice en un término
“between” etnia y un término “within”
etnia"

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = c("school","sch_type"), by = "region", within = "ethnicity")
#>          region         M M_B_ethnicity M_W_ethnicity
#> 1:       Biobio 0.2312423    0.02582674     0.2054156
#> 2: La Araucania 0.2367493    0.04840892     0.1883404
#> 3:     Los Rios 0.2125013    0.03324738     0.1792539
```

De nuevo tenemos tres términos para cada región. El primero, `M` vuelve
a coincidir con los valores totales sin la opción `within` El segundo,
`M\_B\_ethnicity` es la segregación étnica en las combinaciones de
escuelas y tipos de escuelas. El tercero, `M\_W\_csep` es la
contribución socioeconómica.

La opción `contribution.from`permite computar de forma simultánea las
dos
contribuciones:

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = c("school","sch_type"),
        by = "region", contribution.from = "group_vars")
#>          region         M    C_csep C_ethnicity  interaction
#> 1:       Biobio 0.2312423 0.2054156  0.02816039 -0.002333648
#> 2: La Araucania 0.2367493 0.1883404  0.04608521  0.002323710
#> 3:     Los Rios 0.2125013 0.1792539  0.03505928 -0.001811897
```

Obtenemos cuatro términos para cada región: `M` `C\_csep` `C\_ethnicity`
`interaction` El término `M`es la segregación total, como ya hemos
visto. El término `C\_csep`es la contribución socioeconómica, y coincide
con el término “within” etnia, `M\_W\_ethnicity` El término
`C\_ethnicity`es la contribución étnica, y coincide con el término
“within” socioeconómico, `M\_W\_csep` Por último, el término
`interaction`es igual a `M`menos la suma de `C\_csep`y `C\_ethnicity` Es
la parte de la segregación total que no se puede atribuir al efecto
segregador exclusivo de `etnicity` o de `csep`. \#\#\# COMPROBAR CON EL
OUTPUT Podemos ver que la segregación exclusivamente socioeconómica es
mayor en la región del Biobio, mientras que la segregación
exclusivamente étnica es mayor en la región de La Araucania.

La opción `contribution.from`permite obtener las contribuciones de un
subconjunto de variables. Por
ejemplo:

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = c("school","sch_type"),
        by = "region", contribution.from = "csep")
#>          region         M    C_csep interaction
#> 1:       Biobio 0.2312423 0.2054156  0.02582674
#> 2: La Araucania 0.2367493 0.1883404  0.04840892
#> 3:     Los Rios 0.2125013 0.1792539  0.03324738
```

devuelve únicamente `M` `C\_csep` e `interaction` y omite la
contribución de étnia.

El análisis de contribuciones también se puede hacer para unidades
organizativas. Por
ejemplo:

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = c("school","sch_type"),
        by = "region", contribution.from = "unit_vars")
#>          region         M  C_school   C_sch_type interaction
#> 1:       Biobio 0.2312423 0.1293566 4.860549e-05  0.10183706
#> 2: La Araucania 0.2367493 0.1709480 8.563946e-06  0.06579272
#> 3:     Los Rios 0.2125013 0.1351602 1.903942e-04  0.07715072
```

El primero de los cuatro términos es la segregación total por región. El
segundo término, `C\_school` recoge la contribución de la segregación
socioeconómica y étnica por escuelas. El tercer término,
`C\_sch_type`captura la contribución de la segregación socioeconómica y
étnica por dependencia administrativa. El cuarto término es la parte de
la segregación que no puede ser atribuída exclusivamente ni a la
segregación por escuelas ni a la segregación por dependencia
administrativa.

En el caso de particiones, el análisis de contribuciones se simplifica.
Por
ejemplo:

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = c("school","commune"),
        by = "region", contribution.from = "unit_vars")
#>          region         M  C_school C_commune interaction
#> 1:       Biobio 0.2311937 0.1558457         0  0.07534802
#> 2: La Araucania 0.2367407 0.1635589         0  0.07318187
#> 3:     Los Rios 0.2123109 0.1605696         0  0.05174127
```

La contribución comunal (`C\_commune`es cero pues no hay segregación por
distritos dentro de cada escuela. Intuitivamente toda segregación por
distritos deviene en segregación por escuelas.

El análisis de las contribuciones se generaliza a situaciones en las que
hay más de dos fuentes de segregación por grupos o unidades. Por
ejemplo, si consideramos tres fuentes de segregación en grupos
(`ethnicity`, `csep`, y
`gender`):

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity", "gender"), unit = c("school","commune"),
        by = "region", contribution.from = "group_vars")
#>          region         M    C_csep C_ethnicity   C_gender interaction
#> 1:       Biobio 0.2731123 0.2143102  0.03438802 0.04191863 -0.01750455
#> 2: La Araucania 0.2718037 0.2017662  0.05742349 0.03506293 -0.02244892
#> 3:     Los Rios 0.2836338 0.1941962  0.04642725 0.07132289 -0.02831253
```

presenta cinco términos, la segregación total, las contribuciones de las
tres fuentes de segregación por grupos, y el término de interacción. La
única restricción de la opción `contribution.from`es que no se pueden
calcular simultáneamente contribuciones de variables que definen los
grupos y variables que definen las unidades, pues no existe una única
forma de hacer esta descomposición. No obstante, la opción
`components`permite recuperar todos los elementos de la combinación
lineal del término “within” para computar la descomposición deseada por
el usuario avanzado.

## Citation

If you use this library for your research, please cite:

Fuentealba-Chaura, R., Mora, R., Rojas-Mora, J. (2021). mutualinf: a
library to calculate and decompose the Mutual Information Index.
<https://www.github.com/RafaelFuentealbaC/mutualinf>

## References

Elbers, B. (2021). A Method for Studying Differences in Segregation
Across Time and Space. Sociological Methods & Research.
<https://doi.org/10.1177/0049124121986204>.

Frankel, D. and Volij, O. (2011). Measuring school segregation. Journal
of EconomicTheory. 146(1):1-38.
<https://doi.org/10.1016/j.jet.2010.10.008>.

Kullback, S. (1959).Information Theory and Statistics. Wiley Publication
in Mathematical Statistics.

Mora, R. and Guinea-Martin, D. (2021). Computing decomposable multigroup
indexesof segregation. UC3M Working papers. Economics 31803, Universidad
Carlos III de Madrid. Departamento de Economía.

Mora, R. and Ruiz-Castillo, J. (2003). Additively decomposable
segregation indexes. The case of gender segregation by occupations and
human capital levels in Spain. Journal of Economic Inequality.
1(2):147-179. <https://doi.org/10.1023/A:1026198429377>.

Mora, R. and Ruiz-Castillo, J. (2011). Entropy-based segregation
indices. Sociological Methodology. 41(1):159-194.
<https://doi.org/10.1111/j.1467-9531.2011.01237.x>.

Theil, H. and Finizza, Anthony J. (1971). A note on the measurement of
racial integration of schools by means of informational concepts. The
Journal of Mathematical Sociology. 1(2):187-193.
<https://doi.org/10.1080/0022250X.1971.9989795>.
