% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DataObj.r
\name{Cant}
\alias{Cant}
\title{What methods can't be applied to this DLM data object}
\usage{
Cant(Data, timelimit = 1)
}
\arguments{
\item{Data}{A data-limited methods data object (class Data)}

\item{timelimit}{The maximum time (seconds) taken for a method to undertake
10 reps (this filters out methods that are too slow)}
}
\description{
The methods that don't have sufficient data, lead to errors or don't run in
time along with a list of their data requirments.
}
