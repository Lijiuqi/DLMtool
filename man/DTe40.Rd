% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Input.r
\name{DTe40}
\alias{DTe40}
\title{Effort searching MP aiming for 40 per cent stock depletion}
\usage{
DTe40(x, Data, reps = 100, alpha=0.4, LB=0.9, UB=1.1)
}
\arguments{
\item{x}{A position in a data-limited methods data object}

\item{Data}{A data-limited methods data object}

\item{reps}{The number of stochastic samples of the TAC recommendation}

\item{alpha}{The target level of depletion}

\item{LB}{The lowest permitted factor of previous fishing effort}

\item{UB}{The highest permitted factor of previous fishing effort}
}
\description{
A very simple MP that modifies effort to reach 40 percent stock depletion
}
\author{
T. Carruthers
}
