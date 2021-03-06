% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Output.r
\name{Lratio_BHI}
\alias{Lratio_BHI}
\title{Mean length-based indicator MP of Jardim et al. 2015 using Beverton-Holt invariant 
M/K ratio = 1.5 and assumes FMSY = M.}
\usage{
Lratio_BHI(x, Data, reps, yrsmth = 3)
}
\arguments{
\item{x}{A position in data-limited methods data object}

\item{Data}{A data-limited methods data object}

\item{reps}{The number of TAC samples}

\item{yrsmth}{The most recent years of data to smooth the calculation of the mean length}
}
\description{
The TAC is adjusted by the ratio alpha, where the numerator 
is the mean length of the catch (of lengths larger than Lc) and 
the denominator is the mean length expected when FMSY = M and M/K = 1.5. 
Natural mortality M and von Bertalanffy K are not used in this MP 
(see Appendix A of Jardim et al. 2015). Here, Lc is the length at 
full selection (LFS).
}
\details{
Argument yrsmth currently takes the mean length of the most recent 3 years of data 
as a smoother.
}
\references{
Ernesto Jardim, Manuela Azevedo, Nuno M. Brites, Harvest control rules for 
data limited stocks using length-based reference points and survey biomass indices, 
Fisheries Research, Volume 171, November 2015, Pages 12-19, ISSN 0165-7836, 
https://doi.org/10.1016/j.fishres.2014.11.013
}
\author{
Coded by Q. Huynh. Developed by Jardim et al. (2015)
}
