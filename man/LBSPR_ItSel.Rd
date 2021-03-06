% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/LBSPR_MPs.r
\name{LBSPR_ItSel}
\alias{LBSPR_ItSel}
\title{Length-based SPR model with HCR that iteratively adjusts Selectivity}
\usage{
LBSPR_ItSel(x, Data, yrsmth=1,reps=5, ...)
}
\arguments{
\item{x}{Simulation number}

\item{Data}{Data object}

\item{yrsmth}{Number of years to smooth length data - not currently used}

\item{reps}{Number of repetitions. Not currently used}

\item{...}{ignored}
}
\description{
Management Procedure which adjusts size-at-selection based on estimated SPR.
Entirely untested, and included at to demonstrate MPs of this type.
}
\author{
A. Hordyk
}
