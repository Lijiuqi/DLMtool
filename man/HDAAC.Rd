% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Output.r
\name{HDAAC}
\alias{HDAAC}
\title{Hybrid Depletion Adjusted Average Catch}
\usage{
HDAAC(x, Data, reps = 100)
}
\arguments{
\item{x}{A position in a data-limited methods data object}

\item{Data}{A data-limited methods data object}

\item{reps}{The number of stochastic samples of the TAC recommendation}
}
\description{
Essentially DCAC multiplied by 2*depletion and divided by BMSY/B0 (Bpeak)
when below BMSY, and DCAC above BMSY
}
\references{
MacCall, A.D., 2009. Depletion-corrected average catch: a simple
formula for estimating sustainable yields in data-poor situations. ICES J.
Mar. Sci. 66, 2267-2271. Harford W. and Carruthers, T. 2016. Testing novel
catch-based fisheries management procedures.
}
\author{
W. Harford and T. Carruthers
}
