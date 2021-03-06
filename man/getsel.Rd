% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Selectivity_Functions.R
\name{getsel}
\alias{getsel}
\title{Calculate selectivity curve}
\usage{
getsel(x, lens, lfs, sls, srs)
}
\arguments{
\item{x}{Simulation number}

\item{lens}{Matrix of lengths (nsim by nlengths)}

\item{lfs}{Vector of length at full selection (nsim long)}

\item{sls}{Vector of sigmas of ascending limb (nsim long)}

\item{srs}{Vector of sigmas of descending limb (nsim long)}
}
\description{
Calculate selectivity curve
}
