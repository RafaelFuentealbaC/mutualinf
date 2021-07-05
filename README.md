
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mutualinf

<!-- badges: start -->

[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
<!-- badges: end -->

An R package to calculate and decompose the Mutual Information Index (M)
introduced to the social sciences by Theil and Finizza (1971). The M
index is a multigroup segregation measure that is highly decomposable,
satisfiying both the Strong Unit Decomposability (SUD) and the Strong
Group Decomposability (SGD) properties (Frankel and Volij, 2011; Mora
and Ruiz-Castillo, 2011).

The package allows for:

  - The computation of the M index, either overall or over subsamples
    defined by the user.
  - The decomposition of the M index into a “between” and a “within”
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

  - Which prepares the data to be used by the `mutual` function. For
    more details see `help(prepare_data)`.

<!-- end list -->

``` r
?mutual
```

  - Which computes the M index and its decompositions. For more details
    see `help(mutual)`.

## Usage

The library computes the M Index. Suppose you have 2016-2018 primary
school enrollment Chile data. Each observation is a combination of,
among other variables, school (`school`), school district (`commune`),
ethnicity (`ethnicity`), and socio-economic level (`csep`) in a tabular
format object (data.frame, data.table, tibble). Variable `nobs`
represents students frequencies in each of these combinations. In the
first step, we load the package and use the `prepare_data` function (i)
to declare the variable that includes the frequencies and (ii) to format
the data for the `mutual` function:

``` r
library(mutualinf)

DT_Seg_Chile_1 <- prepare_data(data = DF_Seg_Chile,
                               vars = "all_vars",
                               fw = "nobs")
class(DT_Seg_Chile_1)
#> [1] "data.table"  "data.frame"  "mutual.data"
```

If `vars =" all_vars "`, `prepare_data` uses all columns in the table.
You may, nonetheless, use the `vars` option with tables that have a
large number of columns that are not needed in the analysis. For
example:

``` r
DT_Seg_Chile_1 <- prepare_data(data = DF_Seg_Chile, 
                               vars = c("school", "csep"),
                               fw = "nobs")
```

prepares the data to conduct, as we see below, an analysis of
socioeconomic segregation by school. If you want to additionally study
segregation by ethnicity in the schools, the data preparation should
collect all the relevant variables:

``` r
DT_Seg_Chile_1 <- prepare_data(data = DF_Seg_Chile, 
                               vars = c("school", "csep", "ethnicity"),
                               fw = "nobs")
```

If the data is originally fully disaggregated (i.e., one record
represents one student), `prepare_data` computes the cell frequencies of
the specified variables:

``` r
DT_Seg_Chile_2 <- prepare_data(data = DF_Seg_Chile, 
                               vars = "all_vars")
```

The `mutual` function can calculate the index M in its simplest form,
i.e., on a group dimension for a unit of analysis. For example, to
compute socioeconomic segregation by schools:

``` r
mutual(data = DT_Seg_Chile,
       group = "csep", 
       unit = "school")
#>            M
#> 1: 0.1995499
```

and to compute ethnic segregation by schools:

``` r
mutual(data = DT_Seg_Chile, 
       group = "ethnicity", 
       unit = "school")
#>             M
#> 1: 0.06213906
```

The `mutual` function also allows the use of multiple group dimensions
on which segregation is computed. For example:

``` r
mutual(data = DT_Seg_Chile, 
       group = c("csep", "ethnicity"), 
       unit = "school")
#>            M
#> 1: 0.2610338
```

computes socioeconomic and ethnic segregation in schools, effectively
defining the groups as the combinations of socioeconomic and ethnic
categories. As we can see, the segregation obtained considering,
simultaneously, socioeconomic level and ethnicity (`0.2610338`) is
larger than those obtained separately (`0.1995499` and `0.06213906`,
respectively).

More generally, segregation analysis can be computed using multiple unit
and/or group dimensions. For example:

``` r
mutual(data = DT_Seg_Chile, 
       group = c("csep", "ethnicity"), 
       unit = c("school", "commune"))
#>            M
#> 1: 0.2610338
```

computes socioeconomic and ethnic segregation in combinations of schools
and districts. Note that the result is identical to that obtained in the
previous case, `0.2610338`. The reason is that each school only belongs
to one district so that the combinations of schools and districts
coincide with the set of schools. We can say that the districts are a
partition of the schools and districts do not add a new source for
socioeconomic and ethnic segregation.

Yet the variables that define the units may not have a hierarchical
relationship between them. For example, if instead of district
(`commune`) we use type of school (`sch_type`, either private, charter,
or public):

``` r
 mutual(data = DT_Seg_Chile, 
        group = c("csep", "ethnicity"), 
        unit = c("school", "sch_type"))
#>            M
#> 1: 0.2610865
```

computes segregation in units defined by combinations of schools and
types of schools. There is no hierarchical structure in the units as
some schools change their type in the sample period. Consequently, the
level of segregation is higher (`0.2610865` vs. `0.2610338`).

Option `by` computes the index for subsamples. The data used as an
illustration include primary schools in the Chilean regions of Biobio,
La Araucania, and Los Rios. The `by` option allows obtaining the level
of segregation for each of the three regions in a single command:

``` r
 mutual(data = DT_Seg_Chile, 
        group = c("csep", "ethnicity"), 
        unit = c("school", "sch_type"), 
        by = "region")
#>          region         M
#> 1:       Biobio 0.2312423
#> 2: La Araucania 0.2367493
#> 3:     Los Rios 0.2125013
```

In this case, the function displays the index for each region. We see
that socioeconomic and ethnic segregation is greater in La Araucania
(`0.2367493`) than in Biobio (`0.2312423`) and Los Rios (`0.2125013`).

Option `within` additively decomposes the total segregation index into a
“between” and a “within” term:

``` r
mutual(data = DT_Seg_Chile, 
       group = c("csep", "ethnicity"), 
       unit = c("school", "sch_type"), 
       by = "region", 
       within = "csep")
#>          region         M  M_B_csep   M_W_csep
#> 1:       Biobio 0.2312423 0.2030819 0.02816039
#> 2: La Araucania 0.2367493 0.1906641 0.04608521
#> 3:     Los Rios 0.2125013 0.1774420 0.03505928
```

We get three terms for each region. The first, `M`, contains the total
segregation and matches the values without the `within` option. The
second, `M_B_csep`, referred to as the “between” term, measures
socioeconomic segregation in the combinations of schools and types of
schools. The third, `M_W_csep`, referred to as the “within” term, is the
weighted average of ethnic segregation (in the combinations of schools
and types of schools) computed for each socioeconomic level (with
weights equal to the demographic importance of each socioeconomic
level). This “within” term can be interpreted as the part of total
segregation, `M`, derived exclusively from ethnic differences. From this
point on, we will refer to this term as “the contribution of” ethnicity.

It is also possible to obtain the decomposition of the index into a
“between” ethnicity term and a “within” ethnicity term:

``` r
mutual(data = DT_Seg_Chile, 
       group = c("csep", "ethnicity"), 
       unit = c("school", "sch_type"), 
       by = "region", 
       within = "ethnicity")
#>          region         M M_B_ethnicity M_W_ethnicity
#> 1:       Biobio 0.2312423    0.02582674     0.2054156
#> 2: La Araucania 0.2367493    0.04840892     0.1883404
#> 3:     Los Rios 0.2125013    0.03324738     0.1792539
```

We get, again, three terms for each region. The first, `M`, captures
total segregation as before. The second, `M_B_ethnicity`, is ethnic
segregation in the schools and types of schools combinations. The third,
`M_W_ethnicity`, is the socioeconomic contribution.

Option `contribution.from` displays the two contributions
simultaneously:

``` r
mutual(data = DT_Seg_Chile, 
       group = c("csep", "ethnicity"), 
       unit = c("school", "sch_type"), 
       by = "region", 
       contribution.from = "group_vars")
#>          region         M    C_csep C_ethnicity  interaction
#> 1:       Biobio 0.2312423 0.2054156  0.02816039 -0.002333648
#> 2: La Araucania 0.2367493 0.1883404  0.04608521  0.002323710
#> 3:     Los Rios 0.2125013 0.1792539  0.03505928 -0.001811897
```

We get four terms for each region: `M`, `C_csep`, `C_ethnicity`, and
`interaction`. `M` is total segregation, as we have already seen.
`C_csep` is the socioeconomic contribution and matches the “within”
ethnicity term,`M_W_ethnicity`. `C_ethnicity` is the ethnic contribution
and matches the “within” socioeconomic term,`M_W_csep`. Finally,
`interaction` is equal to `M` minus the sum of `C_csep` and
`C_ethnicity`. It is the part of the total segregation in the
combinations of schools and school types that cannot be exclusively
attributed to the segregation effect of either `ethnicity` or `csep`. We
can see that the socioeconomic contribution is largest in Biobio
(`0.2054156`), while the ethnicity contribution is largest in La
Araucania (`0.04608521`).

Option `contribution.from` may also display the contributions of a
subset of variables. For example:

``` r
mutual(data = DT_Seg_Chile, 
       group = c("csep", "ethnicity"), 
       unit = c("school", "sch_type"), 
       by = "region", 
       contribution.from = "csep")
#>          region         M    C_csep interaction
#> 1:       Biobio 0.2312423 0.2054156  0.02582674
#> 2: La Araucania 0.2367493 0.1883404  0.04840892
#> 3:     Los Rios 0.2125013 0.1792539  0.03324738
```

returns `M`, `C_csep`, and `interaction`, omitting `C_ethnicity`.

The display of contributions can also be performed for organizational
units. For example:

``` r
mutual(data = DT_Seg_Chile, 
       group = c("csep", "ethnicity"), 
       unit = c("school", "sch_type"), 
       by = "region", 
       contribution.from = "unit_vars")
#>          region         M  C_school   C_sch_type interaction
#> 1:       Biobio 0.2312423 0.1293566 4.860549e-05  0.10183706
#> 2: La Araucania 0.2367493 0.1709480 8.563946e-06  0.06579272
#> 3:     Los Rios 0.2125013 0.1351602 1.903942e-04  0.07715072
```

The first of the four terms is total segregation, `M`, as before. The
second term, `C_school`, contains the contribution of schools, while the
third term, `C_sch_type`, captures the contribution of school types. The
fourth term, `interaction`, is the part of socioeconomic and ethnic
segregation that cannot be exclusively attributed to segregation by
schools or by school type. Most schools types do not vary in the sample,
so `sch_type` is almost a partition of schools. Hence, the type of
school is a minor source of information compared to the school, and its
contribution is minimal.

In the presence of a true partition, the analysis of contributions is
simpler:

``` r
mutual(data = DT_Seg_Chile, 
       group = c("csep", "ethnicity"), 
       unit = c("school", "commune"), 
       by = "region", 
       contribution.from = "unit_vars")
#>          region         M  C_school C_commune interaction
#> 1:       Biobio 0.2311937 0.1558457         0  0.07534802
#> 2: La Araucania 0.2367407 0.1635589         0  0.07318187
#> 3:     Los Rios 0.2123109 0.1605696         0  0.05174127
```

The contribution of districts, `C_commune`, is zero since there is no
segregation by districts within each school. Intuitively, all
segregation by districts becomes segregation by schools.

The analysis of contributions is generalized to situations in which
there are more than two sources of segregation by groups or units. For
example, if we consider three sources of group segregation
(`csep`,`ethnicity` and `gender`):

``` r
mutual(data = DT_Seg_Chile, 
       group = c("csep", "ethnicity", "gender"), 
       unit = c("school", "commune"), 
       by = "region", 
       contribution.from = "group_vars")
#>          region         M    C_csep C_ethnicity   C_gender interaction
#> 1:       Biobio 0.2731123 0.2143102  0.03438802 0.04191863 -0.01750455
#> 2: La Araucania 0.2718037 0.2017662  0.05742349 0.03506293 -0.02244892
#> 3:     Los Rios 0.2836338 0.1941962  0.04642725 0.07132289 -0.02831253
```

displays five terms: total segregation, the contributions of the three
sources of segregation by groups, and the interaction term.

The only restriction of option `contribution.from` is that contributions
of variables that define groups and variables that define units cannot
be simultaneously computed since there is no single way to do this
decomposition. However, option `components` allows retrieving all the
elements of the linear combination of the “within” terms to compute the
decomposition desired by an advanced user.

## References

Frankel, D. and Volij, O. (2011). Measuring school segregation.
<em>Journal of Economic Theory, 146</em>(1):1-38.
<https://doi.org/10.1016/j.jet.2010.10.008>.

Guinea-Martin, D., Mora, R., & Ruiz-Castillo, J. (2018). The evolution
of gender segregation over the life course. <em>American Sociological
Review, 83</em>(5), 983-1019.
<https://doi.org/10.1177/0003122418794503>.

Mora, R. and Guinea-Martin, D. (2021). Computing decomposable multigroup
indexes of segregation. <em>UC3M Working papers, Economics 31803</em>,
Universidad Carlos III de Madrid. Departamento de Economía.

Mora, R. and Ruiz-Castillo, J. (2011). Entropy-based segregation
indices. <em>Sociological Methodology, 41</em>(1):159-194.
<https://doi.org/10.1111/j.1467-9531.2011.01237.x>.

Theil, H. and Finizza, A. J. (1971). A note on the measurement of racial
integration of schools by means of informational concepts. <em>The
Journal of Mathematical Sociology, 1</em>(2):187-193.
<https://doi.org/10.1080/0022250X.1971.9989795>.
