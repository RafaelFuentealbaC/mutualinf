
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mutualinf

<!-- badges: start -->

<!-- badges: end -->

An R package to calculate the Mutual Information Index (M) introduced to
social science literature by Theil and Finizza (2011). The M index is a
multigroup segregation measure that is highly decomposable that
satisfies the Strong Unit Decomposability (SUD) and Strong Group
Decomposability (SGD) properties (Frankel and Volij, 2011; Mora and
Ruiz-Castillo, 2011).

The package:

  - Allows calculate the total segregation.
  - Allows descompose the total segregation index into the between term
    and the within term.
  - Allows calculate the value of the before terms for all data, a
    particular variable or multiple variables.
  - Allows calculate and know the contribution that generate the group
    variables or the unit variables into the total segregation.
  - Deliveries the decompositions information in the general form or in
    detail form. In this last case delivery information about the
    proportions and the local segregation index for all categorical
    combinations of variables.
  - Is fast in the compute tasks because uses internally the
    [`data.table`](https://cran.r-project.org/web/packages/data.table/index.html)
    package.
  - Uses parallelization methods of the
    [`parallel`](https://stat.ethz.ch/R-manual/R-devel/library/parallel/doc/parallel.pdf)
    library to help calculate the index and decompositions. This option
    allows use more than one CPU cores of the computer to efficiently
    advantage the resources in the calculation. However this option is
    available only to Mac, Linux, Unix, and BSD systems but is not
    available to Windows sytems because the package uses internally the
    function
    [`mclapply`](https://www.rdocumentation.org/packages/parallel/versions/3.4.1/topics/mclapply)
    that is based on the bifurcation. In the Windows case, the
    calculation is carried out sequentially through
    [`lapply`](https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/lapply)
    function.

## Installation

You can install the released version of mutualinf from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("mutualinf")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("RafaelFuentealbaC/mutualinf")
```

## Functions

The package provides two principal functions:

``` r
?prepare_data 
```

  - This function allows prepare the dataset that later will be use to
    computation index and generate the decompositions. For more details
    see the help.

<!-- end list -->

``` r
?M_total
```

  - This function provides all values related with computation of the
    index and decompositions. For more details consult see the help.

## Usage

The package allow calculate the Mutual Information Index (M) in a simple
way through the `mutual` function:

``` r
library(mutualinf)

mutual(data = DT_Seg_Ar, group = "etnia", unit = "school2")
#>             M
#> 1: 0.03607692
```

The `by` option allows calculate the segregation index for a particular
variable or multiple variables:

``` r
mutual(data = DT_Seg_Ar, group = "etnia", unit = "school2", by = "year")
#>    year          M
#> 1: 2016 0.04257812
#> 2: 2017 0.03682014
#> 3: 2018 0.03761050
```

The `within` option allows decompose the total segregation into their
between and within
terms:

``` r
mutual(data = DT_Seg_Ar, group = c("csep2", "etnia"), unit = c("school2", "comuna"), within = "etnia")
#>            M  M_B_etnia M_W_etnia
#> 1: 0.2110833 0.03607692 0.1750063
```

The `components` option allows know the proportions and the local
segregation index for all categories. The weighted average between `p`
and `within` in the `$W_Decomposition` element is equal to the within
term in the `$Total`
element:

``` r
mutual(data = DT_Seg_Ar, group = c("csep2", "etnia"), unit = c("school2", "comuna"), within = "etnia",
       components = TRUE)
#> $Total
#>            M  M_B_etnia M_W_etnia
#> 1: 0.2110833 0.03607692 0.1750063
#> 
#> $W_Decomposition
#>    etnia         p    within
#> 1:     0 0.7735436 0.1907459
#> 2:     1 0.2264564 0.1212421
```

The `components.from` option allows calculate the contribution of the
group variables or unit variables in the total segregation. The weighted
average between `p` and each contributor variable of the
`$W_Decomposition` element is equal to their corresponding variable in
the `$Total`
element:

``` r
mutual(data = DT_Seg_Ar, group = c("csep2", "etnia"), unit = c("school2", "comuna"), within = "etnia",
       contribution.from = "unit_vars", components = TRUE)
#> $Total
#>            M  M_B_etnia C_school2 C_comuna interaction
#> 1: 0.2110833 0.03607692 0.1194126        0  0.05559372
#> 
#> $W_Decomposition
#>    etnia         p    within    school2 comuna interaction
#> 1:     0 0.7735436 0.1907459 0.12995140      0  0.06079454
#> 2:     1 0.2264564 0.1212421 0.08341366      0  0.03782843
```

The `cores` option allows use more than one CPU cores in the index
compute. This avoids overloading the current work session by
distributing calculation tasks in child processs. Compare the
differences with the `system.time` function:

``` r
# Sequentially, using one CPU core:
system.time(mutual(data = DT_Seg_Ar, group = c("csep2", "etnia"), unit = c("school2", "comuna"), within = "etnia",
       contribution.from = "unit_vars", components = TRUE))
#>    user  system elapsed 
#>  13.358   0.019   6.858

# In parallel, using two CPU cores:
system.time(mutual(data = DT_Seg_Ar, group = c("csep2", "etnia"), unit = c("school2", "comuna"), within = "etnia",
       contribution.from = "unit_vars", components = TRUE, cores = 2))
#>    user  system elapsed 
#>   0.584   0.149   4.236
```

## References

Elbers, B. (2021). A Method for Studying Differences in Segregation
Across Time and Space. Sociological Methods & Research.
<https://doi.org/10.1177/0049124121986204>.

Frankel, D. & Volij, O. (2011). Measuring school segregation. Journal of
EconomicTheory. 146(1):1-38.
<https://doi.org/10.1016/j.jet.2010.10.008>.

Kullback, S. (1959).Information Theory and Statistics. Wiley Publication
in Mathematical Statistics.

Mora, R. & Guinea-Martin, D. (2021). Computing decomposable multigroup
indexesof segregation. UC3M Working papers. Economics 31803, Universidad
Carlos III de Madrid. Departamento de Economía.

Mora, R. & Ruiz-Castillo, J. (2003). Additively decomposable segregation
indexes. The case of gender segregation by occupations and human capital
levels in Spain. Journal of Economic Inequality. 1(2):147-179.
<https://doi.org/10.1023/A:1026198429377>.

Mora, R. & Ruiz-Castillo, J. (2011). Entropy-based segregation indices.
Sociological Methodology. 41(1):159-194.
<https://doi.org/10.1111/j.1467-9531.2011.01237.x>.

Theil, H. & Finizza, Anthony J. (1971). A note on the measurement of
racial integration of schools by means of informational concepts. The
Journal of Mathematical Sociology. 1(2):187-193.
<https://doi.org/10.1080/0022250X.1971.9989795>.
