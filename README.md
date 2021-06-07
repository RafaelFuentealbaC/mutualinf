
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mutualinf

<!-- badges: start -->

[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
<!-- badges: end -->

An R library to calculate and decompose the Mutual Information Index (M)
introduced to social science literature by Theil and Finizza (1971). The
M index is a multigroup segregation measure that is highly decomposable
that satisfies the Strong Unit Decomposability (SUD) and Strong Group
Decomposability (SGD) properties (Frankel and Volij, 2011; Mora and
Ruiz-Castillo, 2011).

The library:

  - Allows calculate the total segregation.
  - Allows descompose the total segregation index into the between term
    and the within term.
  - Allows calculate and know the exclusive segregating effect that
    generate the group variables or the unit variables into the total
    segregation.
  - Allows separate the calculations according to one or more
    characteristics of the system.
  - Deliveries the decompositions information in the general form or in
    detail form. In this last case delivery information about the
    proportions and the local segregation index for all categorical
    combinations of variables when there is a least one dimension for
    the within parameter.
  - Is fast in the compute tasks because uses internally the
    [`data.table`](https://CRAN.R-project.org/package=data.table)
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
?mutual
```

  - This function provides all values related with computation of the
    index and decompositions. For more details consult see the help.

## Usage

The package allow calculate the Mutual Information Index (M) in his
simplest form, i.e., over one group dimension and one unit dimension:

``` r
library(mutualinf)

mutual(data = DT_Seg_Chile, group = "csep", unit = "school")
#>            M
#> 1: 0.1995499
```

Also can be used multiple dimensions in the group and unit analysis:

``` r
# over multiple group dimensions
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = "school")
#>            M
#> 1: 0.2610338

# over multiple unit dimensions
mutual(data = DT_Seg_Chile, group = "csep", unit = c("school", "sch_type"))
#>            M
#> 1: 0.1995741
```

The `by` option allows separate the calculations according to particular
dimension or multiple
dimensions:

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = "school", by = "region")
#>          region         M
#> 1:       BioBio 0.2311937
#> 2: La Araucania 0.2367407
#> 3:     Los Rios 0.2123109
```

The `within` option allows decompose the total segregation into their
between and within
terms:

``` r
# get the segregation that is socio-economic exclusively and then segregation that is ethnic exclusively
# for all socio-economic categories
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = "school", within = "csep")
#>            M  M_B_csep   M_W_csep
#> 1: 0.2610338 0.1995499 0.06148383

# get the segregation that is ethnic exclusively and then segregation that is socio-economic exclusively
# for all ethnic categories
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = "school", within = "ethnicity")
#>            M M_B_ethnicity M_W_ethnicity
#> 1: 0.2610338    0.06213906     0.1988947
```

The `contribution.from` option allows evaluate the exclusive segregating
effect of group variables or unit variables into the total segregation.
It’s an inmediate way of jointly obtaining the relevant results of the
two previous decompositions. The `ìnteraction` term refers to an amount
of segregation that cannot be attributed to the exclusive segregating
effect of characteristics that jointly define the groups (in this
case):

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = "school", contribution.from = "group_vars")
#>            M    C_csep C_ethnicity interaction
#> 1: 0.2610338 0.1988947  0.06148383 0.000655226
```

The `components` option allows know the proportions and the local
segregation index for all categories of variables of the `within`
parameter. The weighted average between `p` and `within` of the
`$W_Decomposition` element is equal to the `M_W_csep` term of the
`$Total`
element:

``` r
mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity"), unit = "school", within = "csep", components = TRUE)
#> $Total
#>            M  M_B_csep   M_W_csep
#> 1: 0.2610338 0.1995499 0.06148383
#> 
#> $W_Decomposition
#>              csep         p     within
#> 1:      preferent 0.2668582 0.04905997
#> 2:       priority 0.5866331 0.07328276
#> 3: non-vulnerable 0.1465087 0.03686939
```

The `cores` option allows use more than one CPU cores in the index
compute. This avoids overloading the current work session by
distributing calculation tasks in child processs. Compare the
differences with the `system.time` function:

``` r
# Sequentially, using one CPU core:
system.time(mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity", "gender"), unit = c("school", "sch_type", "rural"),
                   within = c("ethnicity", "gender"), contribution.from = "unit_vars", components = TRUE))
#>    user  system elapsed 
#>  79.501   0.204  46.804

# In parallel, using two CPU cores:
system.time(mutual(data = DT_Seg_Chile, group = c("csep", "ethnicity", "gender"), unit = c("school", "sch_type", "rural"),
                   within = c("ethnicity", "gender"), contribution.from = "unit_vars", components = TRUE, cores = 2))
#>    user  system elapsed 
#>  29.914   0.791  29.897
```

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
