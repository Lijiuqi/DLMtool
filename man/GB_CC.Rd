% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Output.r
\name{GB_CC}
\alias{GB_CC}
\title{Geromont and Butterworth Constant Catch Harvest Control Rule}
\usage{
GB_CC(x, Data, reps = 100)
}
\arguments{
\item{x}{A position in data-limited methods data object}

\item{Data}{A data-limited methods data object}

\item{reps}{The number of TAC samples}
}
\description{
A simple MP that aims for average historical catches (as a proxy for MSY)
subject to imperfect information.
}
\details{
Note that this is my interpretation of their MP and is now stochastic.
Currently it is generalized and is not 'tuned' to more detailed assessment
data which might explain why in some cases it leads to stock declines.
}
\references{
Geromont, H.F. and Butterworth, D.S. 2014. Complex assessment or
simple management procedures for efficient fisheries management: a
comparative study. ICES J. Mar. Sci. doi:10.1093/icesjms/fsu017
}
\author{
T. Carruthers
}
