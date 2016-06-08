\name{runMSErobust}
\alias{runMSErobust}
\title{
Run a Management Strategy Evaluation
}
\description{
Run a Management Strategy Evaluation and save out the results to a Rdata file.  To increase speed and efficiency, particulary for runs with a large number simulations (\code{nsim}), the simulations are split into a number of packets.  The functions loops over the packets and combines the output into a single MSE object. If the MSE model crashes during a run, the MSE is run again until it is successfully completed. The MSE is stopped if the number of consecutive crashes exceeds \code{maxCrash}.  There is an ption to save the packets as Rdata files to the current working directory (default is FALSE). By default, the functions saves the completed MSE object as a Rdata file (to the current working directory). 
}
\usage{
runMSErobust(OM = "1", MPs = NA, nsim = 200, proyears = 28, interval = 4, pstar = 0.5, 
  maxF = 0.8, timelimit = 1, reps = 1, custompars = 0, CheckMPs = TRUE, maxsims = 64, 
  name = NULL, maxCrash = 10, saveMSE = TRUE, savePack = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{OM}{
An operating model object (class OM)
}
  \item{MPs}{
A vector of methods (character string) of class DLM_output or DLM_input. If NA all available MPs are run.
}
  \item{nsim}{
Number of simulations
}
  \item{proyears}{
Number of projected years
}
  \item{interval}{
The assessment interval - how often would you like to update the management system?
}
  \item{pstar}{
The percentile of the sample of the management recommendation for each method
}
  \item{maxF}{
Maximum instantaneous fishing mortality rate that may be simulated for any given age class
}
  \item{timelimit}{
Maximum time taken for a method to carry out 10 reps (methods are ignored that take longer)
}
  \item{reps}{
Number of samples of the management recommendation for each method. Note that when this is set to 1, the mean value of the data inputs is used. 
}
  \item{custompars}{
A data.table with nsim rows and nparameter columns. The column names must respond to variables of the operating model or observation model see the OM and Obs slots of the MSE class for correct names and interpretation. This allows users to prescribe correlated parameters or estimates from stock assessments. 
}
  \item{CheckMPs}{
Logical to indicate if Can function should be used to check if MPs can be run 
}
  \item{maxsims}{
Maximum number of simulations per packet
}
  \item{name}{
Character string for name of saved MSE packets (if \code{savePack=TRUE}) and final MSE object. If none provided, it uses the first four letters from the \code{OM} name
}
  \item{maxCrash}{
Maximum number of consecutive crashes before the MSE stops
}
  \item{saveMSE}{
Logical to indiciate if final MSEobject should be saved to current working directory (this is probably a good idea)
}
  \item{savePack}{
Logical to indicate if packets should be save to current working directory 
}
}
\value{
An object of class MSE
}

\author{
A. Hordyk and T. Carruthers
}
