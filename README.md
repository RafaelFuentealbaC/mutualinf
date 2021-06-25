
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

  - Which prepares the data to be used by the  function. For more
    details see `help(prepare_data)`.

<!-- end list -->

``` r
?mutual
```

  - Which computes the M index and its decompositions. For more details
    see `help(mutual)`.

## Usage

The library computes the M Index. Suponga que tiene datos de frecuencias
de estudiantes (`nobs`) por combinaciones de escuela (`school`), etnia
(`ethnicity`), nivel socio económico (`csep`) y sexo (`gender`) en un
objeto de formato tabular (data.frame, data.table, tibble), que puede
contener más columnas. El primer paso es cargar la librería y usar la
función prepare\_data para declarar la columna que incluye las
frecuencias y para formatear los datos para la función `mutual`:

``` r
library(mutualinf)

DT_Seg_Chile_1 <- prepare_data(data = DF_Seg_Chile, vars = "all_vars", fw = "nobs")
```

Si el parámetro de la opción `vars = "all_vars"`, entonces
`prepare_data` utiliza todas las columnas de la tabla. Es útil usar la
opción `vars` con tablas que tienen gran cantidad de columnas que no son
necesarias en el análisis.

Si los datos vienen completamente desagregados, `prepare_data` calculará
las frecuencias para todas las celdas de combinación de las variables
especificadas:

``` r
DT_Seg_Chile_2 <- prepare_data(data = DF_Seg_Chile, vars = "all_vars")
```

La función  permite calcular el índice M en su forma más simple, es
decir, sobre una dimensión grupal de segregación con respecto a una
unidad de análisis:

``` r
mutual(data = DT_Seg_Chile, group = "csep", unit = "school")
#>            M
#> 1: 0.1995499
```

En este caso, utilizamos los datos disponibles de 2016 a 2018 de las
escuelas básicas de las regiones del Biobio, La Araucania, y Los Rios.
El valor del índice reportado es exclusivamente socioeconómico y no
considera diferencias por ninguna variable de unidad. El índice de
información mutua es estrictamente mayor que cero y, por lo tanto, no
puede analizarse sino en relación a otro resultado.

La función  también permite utilizar múltiples dimensiones grupales
sobre las que se calcula la segregación, usando las combinaciones de las
mismas sobre las unidades de
análisis:

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = "school")
#>            M
#> 1: 0.2610338
```

En este caso, la segregación se calcula en base a combinaciones de nivel
socioeconómico y de pertenencia étnica de los estudiantes. Como podemos
ver, la segregación que considera estas dos dimensiones grupales es
mayor que la segregación exclusivamente socioeconómica.

De igual manera, se puede realizar el análisis de la segregación
utilizando múltiples dimensiones unitarias con una o más dimensiones
grupales:

``` r
mutual(data = DT_Seg_Chile, group = "csep", unit = c("school", "commune"))
#>            M
#> 1: 0.1995499
```

En esta ocasión, el resultado es una segregación idéntica a la expuesta
en el primer caso, pues cada escuela sólo pertenece a una comuna. En
otras palabras, las dos dimensiones unitarias poseen una relación
jerárquica en donde las escuelas corresponden a las unidades
organizativas más pequeñas, y las comunas a las unidades organizativas
más amplias. Sin embargo, si cambiamos las comunas por la dependencia
administrativa de las escuelas, entonces observamos una variación en el
índice:

``` r
 mutual(data = DT_Seg_Chile, group = "csep", unit = c("school", "sch_type"))
#>            M
#> 1: 0.1995741
```

A pesar de que podría pensarse que una escuela tendría un sólo tipo de
dependencia a lo largo del período estudiado, el cambio en el valor del
índice de información mutua señala que ha habido escuelas que cambiaron
de entidad administrativa. Además, estamos en un caso donde las escuelas
y su dependencia administrativa no conforman una partición (no poseen
una relación jerárquica), por lo que el resultado proporciona mayor
información que la comuna donde pertenece la escuela.

La opción  de la función  permite generar submuestras sobre las que se
calcula el índice de información mutua. Esta opción será de utilidad
para estudiar la segregación en cada una de las regiones que existe en
los datos, tal como se presenta a
continuación:

``` r
 mutual(data = DT_Seg_Chile, group = "csep", unit = "school", by = "region")
#>          region         M
#> 1:       Biobio 0.2030510
#> 2: La Araucania 0.1906555
#> 3:     Los Rios 0.1774124
```

En este caso, la función nos reporta el nombre de cada región acompañado
de su respectivo índice, el cual corresponde a la segregación
socioeconómica en las escuelas. Podemos ver que la segregación es mayor
en la región del Biobio que en las regiones de La Araucania y Los Rios,
y a su vez, es mayor que la segregación socioeconómica en las escuelas
de las tres regiones conjuntas.

En el siguiente caso se incorpora la pertenencia étnica de los
estudiantes:

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = "school", by = "region")
#>          region         M
#> 1:       Biobio 0.2311937
#> 2: La Araucania 0.2367407
#> 3:     Los Rios 0.2123109
```

El resultado corresponde a la segregación socioeconómica y étnica en las
escuelas de cada una de las regiones. Podemos ver que la segregación es
mayor en la región de La Araucania que en las regiones del Biobio y Los
Rios. Por otro lado, la segregación de cada región se mantiene por
debajo de la segregación socioeconómica y étnica que resulta en el
conjunto de las tres regiones.

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
