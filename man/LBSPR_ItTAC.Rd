% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/LBSPR_MPs.r
\name{LBSPR_ItTAC}
\alias{LBSPR_ItTAC}
\title{Length-based SPR model with HCR that iteratively adjusts TAC}
\usage{
LBSPR_ItTAC(x, Data, yrsmth=1,reps=5, ...)
}
\arguments{
\item{x}{Simulation number}

\item{Data}{Data object}

\item{yrsmth}{Number of years to smooth length data - not currently used}

\item{reps}{Number of repetitions}

\item{...}{ignored}
}
\description{
Iteratively adjusts TAC based on distance between estimated and target SPR
(40\%), and slope of recent SPR estimates.
}
\author{
A. Hordyk
}
