\name{mutualinf-package}
\alias{mutualinf-package}
\docType{package}
\title{
An R package to compute and decompose the Mutual Information Index (M).
}
\description{
The Mutual Information Index (M) introduced to the social sciences by Theil and Finizza (1971). The M index is a multigroup segregation measure that is highly decomposable, satisfiying both the Strong Unit Decomposability (SUD) and the Strong Group Decomposability (SGD) properties (Frankel and Volij, 2011; Mora and Ruiz-Castillo, 2011).

The package allows for:
\itemize{
\item The computation of the M index, either overall or over subsamples defined by the user.
\item The decomposition of the M index into a "between" and a "within" term.
\item The identification of the "exclusive contributions" of segregation sources defined either by group or unit characteristics.
\item The computation of all the elements that conform the "within" term in the decomposition.
\item Fast computation employing more than one CPU core in Mac, Linux, Unix, and BSD systems. This option uses the data.table and parallel libraries (which Windows does not permit to run with more than one CPU core).
}
}
\author{ Rafael Fuentealba-Chaura \email{rfuentealba@inf.uct.cl}\cr
Ricardo Mora \email{ricmora@eco.uc3m.es}\cr
Julio Rojas-Mora \email{jrojas@inf.uct.cl}\cr
}
\references{
Frankel, D. and Volij, O. (2011). Measuring school segregation. \emph{Journal of Economic Theory, 146}(1):1-38. \doi{10.1016/j.jet.2010.10.008}.\cr

Guinea-Martin, D., Mora, R., & Ruiz-Castillo, J. (2018). The evolution of gender segregation over the life course. \emph{American Sociological Review, 83}(5), 983-1019. \doi{10.1177/0003122418794503}.\cr

Mora, R. and Guinea-Martin, D. (2021). Computing decomposable multigroup indexes of segregation. \emph{UC3M Working papers, Economics 31803}, Universidad Carlos III de Madrid. Departamento de Economía.\cr

Mora, R. and Ruiz-Castillo, J. (2011). Entropy-based segregation indices. \emph{Sociological Methodology, 41}(1):159-194. \doi{10.1111/j.1467-9531.2011.01237.x}.\cr

Theil, H. and Finizza, A. J. (1971). A note on the measurement of racial integration of schools by means of informational concepts. \emph{The Journal of Mathematical Sociology, 1}(2):187-193. \doi{10.1080/0022250X.1971.9989795}.
}
\keyword{ package }
