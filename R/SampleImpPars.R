#' Sample Implementation Error Parameters
#'
#' @param Imp An object of class 'Imp' or class 'OM'
#' @param nsim Number of simulations. Ignored if 'Stock' is class 'OM'
#'
#' @return A named list of sampled Implementation Error parameters
#' @export
#'
SampleImpPars <- function(Imp, nsim=NULL) {
  if (class(Imp) != "Imp" & class(Imp) != "OM") 
    stop("First argument must be class 'Imp' or 'OM'")
  if (class(Imp) == "OM") nsim <- Imp@nsim
  
  ImpOut <- list() 
  # === Sample implementation error parameters ====
  ImpOut$TACSD <- runif(nsim, Imp@TACSD[1], Imp@TACSD[2])  # Sampled TAC error (lognormal sd)
  ImpOut$TACFrac <- runif(nsim, Imp@TACFrac[1], Imp@TACFrac[2])  # Sampled TAC fraction (log normal sd)
  
  ImpOut$TAESD <- runif(nsim, Imp@TAESD[1], Imp@TAESD[2])  # Sampled Effort error (lognormal sd)
  ImpOut$TAEFrac <- runif(nsim, Imp@TAEFrac[1], Imp@TAEFrac[2])  # Sampled Effort fraction (log normal sd)
  
  ImpOut$SizeLimSD<-runif(nsim,Imp@SizeLimSD[1],Imp@SizeLimSD[2])
  ImpOut$SizeLimFrac<-runif(nsim,Imp@SizeLimFrac[1],Imp@SizeLimFrac[2])
  
  ImpOut
}